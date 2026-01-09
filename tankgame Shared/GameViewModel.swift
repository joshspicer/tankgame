//
//  GameViewModel.swift
//  tankgame Shared
//
//  MVVM coordinator for game logic and networking

import Foundation
import Combine
import MultipeerConnectivity

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState?
    @Published var availablePeers: [MCPeerID] = []
    @Published var isHost = false
    @Published var gamePhase: GamePhase = .lobby
    
    private let network = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    
    enum GamePhase {
        case lobby
        case playing
        case roundEnd
    }
    
    init() {
        setupNetworkObservers()
    }
    
    private func setupNetworkObservers() {
        // Observe network messages
        Task { @MainActor in
            let stream = await network.messagePublisher
            for await (message, peer) in stream.values {
                self.handleMessage(message, from: peer)
            }
        }
        
        // Observe peer changes  
        Task { @MainActor in
            let stream = await network.peerPublisher
            for await peers in stream.values {
                if !peers.isEmpty {
                    self.availablePeers = peers
                }
            }
        }
    }
    
    func hostGame() {
        isHost = true
        Task { await network.startHosting() }
    }
    
    func joinGame() {
        isHost = false
        Task { await network.startBrowsing() }
    }
    
    func invitePeer(_ peer: MCPeerID) {
        Task { await network.invite(peer) }
    }
    
    func startGame() async {
        guard isHost else { return }
        
        let allPlayers = await network.allPlayers
        let seed = UInt32.random(in: 0...UInt32.max)
        let assignments = Dictionary(uniqueKeysWithValues: allPlayers.enumerated().map { ($1, $0) })
        
        // Send start message
        await network.send(.start(seed: seed, playerCount: allPlayers.count, assignments: assignments))
        
        // Start local game
        gameState = GameState.generate(seed: seed, playerCount: allPlayers.count, localIndex: 0)
        gamePhase = .playing
        startGameLoop()
    }
    
    func move(_ direction: Direction) {
        guard var state = gameState,
              state.tanks[state.localPlayerIndex].isAlive else { return }
        
        if state.tanks[state.localPlayerIndex].move(direction, in: state.grid) {
            let tank = state.tanks[state.localPlayerIndex]
            Task {
                await network.send(.move(
                    playerIndex: state.localPlayerIndex,
                    row: tank.position.row,
                    col: tank.position.col,
                    direction: tank.direction
                ))
            }
            gameState = state
        }
    }
    
    func shoot() {
        guard var state = gameState,
              state.tanks[state.localPlayerIndex].isAlive else { return }
        
        let projectile = state.tanks[state.localPlayerIndex].shoot()
        state.projectiles.append(projectile)
        
        Task {
            await network.send(.shoot(playerIndex: state.localPlayerIndex, projectile: projectile))
        }
        
        gameState = state
    }
    
    private func startGameLoop() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }
    
    private func updateGame() {
        guard var state = gameState else { return }
        
        state.update()
        gameState = state
        
        if state.isRoundOver {
            updateTimer?.invalidate()
            gamePhase = .roundEnd
            
            if let winner = state.winner {
                gameState?.scores[winner] += 1
            }
        }
    }
    
    private func handleMessage(_ message: GameMessage, from peer: MCPeerID) {
        Task { @MainActor in
            switch message {
            case .start(let seed, let playerCount, let assignments):
                let deviceName = self.getDeviceName()
                let localIndex = assignments[deviceName] ?? 1
                gameState = GameState.generate(seed: seed, playerCount: playerCount, localIndex: localIndex)
                gamePhase = .playing
                startGameLoop()
                
            case .move(let playerIndex, let row, let col, let direction):
                gameState?.tanks[playerIndex].position = Tank.Position(row: row, col: col)
                gameState?.tanks[playerIndex].direction = direction
                
            case .shoot(let playerIndex, let projectile):
                gameState?.projectiles.append(projectile)
                
            case .ready:
                break // Handle ready state
            }
        }
    }
    
    private func getDeviceName() -> String {
        #if os(iOS) || os(tvOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return "Unknown"
        #endif
    }
    
    func disconnect() {
        Task { await network.disconnect() }
        updateTimer?.invalidate()
        gameState = nil
        gamePhase = .lobby
    }
}
