//
//  GameViewModel.swift
//  tankgame iOS
//
//  Complete rewrite - Game state management
//

import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var isGameOver = false
    @Published var winner: String?

    private let networkRepo: NetworkRepository
    private let engine: GameEngine
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    var onGameEnd: (() -> Void)?

    init(gameState: GameState, networkRepo: NetworkRepository) {
        self.gameState = gameState
        self.networkRepo = networkRepo
        self.engine = GameEngine(state: gameState)
        networkRepo.delegate = self

        startGameLoop()
    }

    private func startGameLoop() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    private func update() {
        engine.update()
        gameState = engine.state

        if engine.isRoundOver() && !isGameOver {
            isGameOver = true
            winner = engine.winnerId()

            if networkRepo.isHost {
                networkRepo.send(message: .roundEnd(winnerId: winner))
            }

            // End game after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.endGame()
            }
        }
    }

    func moveTank(direction: Direction) {
        let playerId = gameState.localPlayerId
        if engine.moveTank(playerId: playerId, direction: direction) {
            gameState = engine.state
            let tank = engine.state.tanks.first { String($0.id) == playerId }!
            networkRepo.send(message: .move(playerId: playerId, position: tank.position, direction: tank.direction))
        }
    }

    func shootBullet() {
        let playerId = gameState.localPlayerId
        if let bullet = engine.shootBullet(playerId: playerId) {
            gameState = engine.state
            networkRepo.send(message: .shoot(playerId: playerId, bullet: bullet))
        }
    }

    func endGame() {
        updateTimer?.invalidate()
        updateTimer = nil
        onGameEnd?()
    }

    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - NetworkRepositoryDelegate

extension GameViewModel: NetworkRepositoryDelegate {
    nonisolated func networkRepository(_ repo: NetworkRepository, didFindPeer peer: Player) {}
    nonisolated func networkRepository(_ repo: NetworkRepository, didLosePeer peer: Player) {}
    nonisolated func networkRepository(_ repo: NetworkRepository, didConnectPeer peer: Player) {}

    nonisolated func networkRepository(_ repo: NetworkRepository, didDisconnectPeer peer: Player) {
        // Could handle peer disconnection during game
    }

    nonisolated func networkRepository(_ repo: NetworkRepository, didReceiveMessage message: GameMessage) {
        Task { @MainActor in
            switch message {
            case .move(let playerId, let position, let direction):
                if let index = engine.state.tanks.firstIndex(where: { String($0.id) == playerId }) {
                    engine.state.tanks[index].position = position
                    engine.state.tanks[index].direction = direction
                    gameState = engine.state
                }

            case .shoot(let playerId, let bullet):
                engine.state.bullets.append(bullet)
                gameState = engine.state

            case .hit(let playerId):
                if let index = engine.state.tanks.firstIndex(where: { String($0.id) == playerId }) {
                    engine.state.tanks[index].isAlive = false
                    gameState = engine.state
                }

            case .roundEnd(let winnerId):
                isGameOver = true
                winner = winnerId

            default:
                break
            }
        }
    }
}
