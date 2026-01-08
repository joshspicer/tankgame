//
//  LobbyViewModel.swift
//  tankgame iOS
//
//  Complete rewrite - Lobby state management
//

import Foundation
import Combine

@MainActor
final class LobbyViewModel: ObservableObject {
    @Published var isHosting = false
    @Published var isBrowsing = false
    @Published var availablePeers: [Player] = []
    @Published var connectedPeers: [Player] = []
    @Published var canStartGame = false

    private let networkRepo: NetworkRepository
    private var cancellables = Set<AnyCancellable>()

    var onStartGame: ((GameState) -> Void)?

    init(networkRepo: NetworkRepository) {
        self.networkRepo = networkRepo
        networkRepo.delegate = self

        // Update canStartGame when connected peers change
        $connectedPeers
            .map { $0.count >= 1 && $0.count <= 5 } // 2-6 players total (including host)
            .assign(to: &$canStartGame)
    }

    func hostGame() {
        isHosting = true
        networkRepo.startHosting()
    }

    func joinGame() {
        isBrowsing = true
        networkRepo.startBrowsing()
    }

    func invitePeer(_ peer: Player) {
        networkRepo.invitePeer(peer)
    }

    func cancel() {
        isHosting = false
        isBrowsing = false
        availablePeers = []
        connectedPeers = []
        networkRepo.disconnect()
    }

    func startGame() {
        guard networkRepo.isHost, canStartGame else { return }

        // Generate game state
        let seed = UInt32.random(in: 0...UInt32.max)
        let allPlayers = [networkRepo.localPlayer] + connectedPeers
        let playerIds = allPlayers.map { $0.id }

        // Create tanks for all players
        var tanks: [Tank] = []
        for (index, playerId) in playerIds.enumerated() {
            let spawn = GameState.spawnPositions[index]
            tanks.append(Tank(
                id: index,
                position: Position(row: spawn.row, col: spawn.col),
                direction: spawn.direction
            ))
        }

        let gameState = GameState(
            grid: GameState.generateGrid(seed: seed),
            tanks: tanks,
            localPlayerId: networkRepo.localPlayer.id
        )

        // Notify clients
        networkRepo.send(message: .startGame(seed: seed, players: playerIds))

        // Start local game
        onStartGame?(gameState)
    }
}

// MARK: - NetworkRepositoryDelegate

extension LobbyViewModel: NetworkRepositoryDelegate {
    nonisolated func networkRepository(_ repo: NetworkRepository, didFindPeer peer: Player) {
        Task { @MainActor in
            if !availablePeers.contains(where: { $0.id == peer.id }) {
                availablePeers.append(peer)
            }
        }
    }

    nonisolated func networkRepository(_ repo: NetworkRepository, didLosePeer peer: Player) {
        Task { @MainActor in
            availablePeers.removeAll { $0.id == peer.id }
        }
    }

    nonisolated func networkRepository(_ repo: NetworkRepository, didConnectPeer peer: Player) {
        Task { @MainActor in
            if !connectedPeers.contains(where: { $0.id == peer.id }) {
                connectedPeers.append(peer)
            }
            availablePeers.removeAll { $0.id == peer.id }
        }
    }

    nonisolated func networkRepository(_ repo: NetworkRepository, didDisconnectPeer peer: Player) {
        Task { @MainActor in
            connectedPeers.removeAll { $0.id == peer.id }
        }
    }

    nonisolated func networkRepository(_ repo: NetworkRepository, didReceiveMessage message: GameMessage) {
        Task { @MainActor in
            switch message {
            case .startGame(let seed, let players):
                // Client received game start
                guard let localIndex = players.firstIndex(of: networkRepo.localPlayer.id) else { return }

                var tanks: [Tank] = []
                for (index, _) in players.enumerated() {
                    let spawn = GameState.spawnPositions[index]
                    tanks.append(Tank(
                        id: index,
                        position: Position(row: spawn.row, col: spawn.col),
                        direction: spawn.direction
                    ))
                }

                let gameState = GameState(
                    grid: GameState.generateGrid(seed: seed),
                    tanks: tanks,
                    localPlayerId: networkRepo.localPlayer.id
                )

                onStartGame?(gameState)

            default:
                break
            }
        }
    }
}
