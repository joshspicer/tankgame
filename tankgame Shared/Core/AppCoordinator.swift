//
//  AppCoordinator.swift
//  tankgame Shared
//
//  Main application coordinator using Coordinator pattern

import Foundation
import Combine

/// Coordinates app-wide navigation and flow
final class AppCoordinator {

    enum State {
        case lobby
        case waitingForPlayers
        case playing
        case roundEnd
    }

    @Published private(set) var state: State = .lobby
    private var cancellables = Set<AnyCancellable>()

    let networkService: NetworkService
    let gameEngine: GameEngine

    init() {
        self.networkService = NetworkService()
        self.gameEngine = GameEngine()
        setupBindings()
    }

    private func setupBindings() {
        // Transition to playing when game starts
        networkService.gameDidStart
            .sink { [weak self] _ in
                self?.state = .playing
            }
            .store(in: &cancellables)

        // Transition to round end when game ends
        gameEngine.roundDidEnd
            .sink { [weak self] _ in
                self?.state = .roundEnd
            }
            .store(in: &cancellables)
    }

    func startHosting() {
        networkService.startHosting()
        state = .waitingForPlayers
    }

    func joinGame() {
        networkService.startBrowsing()
        state = .waitingForPlayers
    }

    func startGame() {
        networkService.startGame()
        state = .playing
    }

    func returnToLobby() {
        networkService.disconnect()
        gameEngine.reset()
        state = .lobby
    }
}
