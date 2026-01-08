//
//  AppCoordinator.swift
//  tankgame iOS
//
//  Complete rewrite - Navigation coordinator
//

import SwiftUI

enum AppState {
    case lobby
    case game(GameState)
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var state: AppState = .lobby

    private let networkRepo: NetworkRepository
    private var lobbyViewModel: LobbyViewModel?
    private var gameViewModel: GameViewModel?

    init() {
        self.networkRepo = NetworkRepository()
    }

    func makeLobbyViewModel() -> LobbyViewModel {
        let vm = LobbyViewModel(networkRepo: networkRepo)
        vm.onStartGame = { [weak self] gameState in
            self?.startGame(with: gameState)
        }
        lobbyViewModel = vm
        return vm
    }

    func makeGameViewModel(gameState: GameState) -> GameViewModel {
        let vm = GameViewModel(gameState: gameState, networkRepo: networkRepo)
        vm.onGameEnd = { [weak self] in
            self?.endGame()
        }
        gameViewModel = vm
        return vm
    }

    private func startGame(with gameState: GameState) {
        state = .game(gameState)
    }

    private func endGame() {
        networkRepo.disconnect()
        state = .lobby
        lobbyViewModel = nil
        gameViewModel = nil
    }
}
