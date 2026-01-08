//
//  TankGameApp.swift
//  tankgame iOS
//
//  Complete rewrite - SwiftUI App entry
//

import SwiftUI

@main
struct TankGameApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView(coordinator: coordinator)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        switch coordinator.state {
        case .lobby:
            LobbyView(viewModel: coordinator.makeLobbyViewModel())

        case .game(let gameState):
            GameView(viewModel: coordinator.makeGameViewModel(gameState: gameState))
        }
    }
}
