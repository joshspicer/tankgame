//
//  GameViewModel.swift
//  tankgame iOS
//
//  MVVM pattern - connects UI to game logic

import Foundation
import Combine

/// View model using MVVM and Observer patterns
final class GameViewModel: ObservableObject {

    // MARK: - Published State
    @Published var gameState: GameState = .lobby
    @Published var discoveredPeers: [String] = []
    @Published var connectedPeers: [String] = []
    @Published var scores: [Int] = []
    @Published var message: String = ""

    // MARK: - Dependencies
    private let network: NetworkManagerProtocol
    private(set) var engine: GameEngine?

    // MARK: - State
    private var isHost = false
    private var localPlayerIndex = 0
    private var playerAssignments: [String: Int] = [:]

    enum GameState {
        case lobby
        case waiting
        case playing
        case roundEnd(winner: Int?)
    }

    init(network: NetworkManagerProtocol = BluetoothNetworkManager()) {
        self.network = network
        self.network.delegate = self
    }

    // MARK: - Actions
    func hostGame() {
        isHost = true
        localPlayerIndex = 0
        network.startHosting()
        gameState = .waiting
        message = "Waiting for players..."
    }

    func joinGame() {
        isHost = false
        network.startBrowsing()
        gameState = .waiting
        message = "Looking for games..."
    }

    func invitePeer(_ peer: String) {
        network.invite(peer)
    }

    func startGame() {
        guard isHost else { return }

        // Assign player indices
        let allPeers = [UIDevice.current.name] + network.connectedPeers
        playerAssignments = Dictionary(uniqueKeysWithValues: allPeers.enumerated().map { ($1, $0) })

        // Create engine
        engine = GameEngine(playerCount: allPeers.count, localPlayerIndex: 0)

        // Start round
        let seed = UInt32.random(in: 0...UInt32.max)
        engine?.startRound(seed: seed)

        // Notify peers
        network.send(.startRound(seed: seed, playerAssignments: playerAssignments))

        gameState = .playing
        message = "Fight!"
        scores = engine?.scores ?? []
    }

    func moveLocalTank() {
        guard let engine = engine, engine.moveTank(localPlayerIndex) else { return }
        let tank = engine.tanks[localPlayerIndex]
        network.send(.move(playerIndex: localPlayerIndex, position: tank.position, direction: tank.direction))
    }

    func rotateLocalTank(clockwise: Bool) {
        engine?.rotateTank(localPlayerIndex, clockwise: clockwise)
    }

    func shootLocalTank() {
        guard let engine = engine else { return }
        let tank = engine.tanks[localPlayerIndex]
        engine.shootProjectile(from: localPlayerIndex)
        network.send(.shoot(playerIndex: localPlayerIndex, position: tank.position, direction: tank.direction))
    }

    func update() {
        engine?.update()

        // Check round end
        if let engine = engine, engine.isRoundOver(), case .playing = gameState {
            let winner = engine.winner()
            if let winner = winner {
                engine.recordWin(for: winner)
                scores = engine.scores
            }
            gameState = .roundEnd(winner: winner)
            network.send(.roundEnd(winner: winner))
        }
    }

    func disconnect() {
        network.disconnect()
        engine = nil
        gameState = .lobby
        message = ""
    }
}

// MARK: - NetworkManagerDelegate
extension GameViewModel: NetworkManagerDelegate {
    func networkManager(_ manager: NetworkManagerProtocol, didDiscover peer: String) {
        if !discoveredPeers.contains(peer) {
            discoveredPeers.append(peer)
        }
    }

    func networkManager(_ manager: NetworkManagerProtocol, didConnect peer: String) {
        if !connectedPeers.contains(peer) {
            connectedPeers.append(peer)
        }
        message = "\(peer) connected"
    }

    func networkManager(_ manager: NetworkManagerProtocol, didDisconnect peer: String) {
        connectedPeers.removeAll { $0 == peer }
        message = "\(peer) disconnected"
    }

    func networkManager(_ manager: NetworkManagerProtocol, didReceive message: NetworkMessage, from peer: String) {
        handleMessage(message, from: peer)
    }

    private func handleMessage(_ message: NetworkMessage, from peer: String) {
        switch message {
        case .startRound(let seed, let assignments):
            playerAssignments = assignments
            localPlayerIndex = assignments[UIDevice.current.name] ?? 0
            engine = GameEngine(playerCount: assignments.count, localPlayerIndex: localPlayerIndex)
            engine?.startRound(seed: seed)
            gameState = .playing
            self.message = "Fight!"
            scores = engine?.scores ?? []

        case .move(let playerIndex, let position, let direction):
            engine?.tanks[playerIndex].position = position
            engine?.tanks[playerIndex].direction = direction

        case .shoot(let playerIndex, let position, let direction):
            engine?.shootProjectile(from: playerIndex)

        case .hit(let playerIndex):
            engine?.tanks[playerIndex].isAlive = false

        case .roundEnd(let winner):
            if let winner = winner {
                engine?.recordWin(for: winner)
                scores = engine?.scores ?? []
            }
            gameState = .roundEnd(winner: winner)
        }
    }
}
