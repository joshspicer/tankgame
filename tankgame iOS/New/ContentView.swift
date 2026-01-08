//
//  ContentView.swift
//  tankgame iOS
//
//  Main SwiftUI view coordinator

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            switch viewModel.gamePhase {
            case .lobby:
                LobbyView(viewModel: viewModel)
                
            case .playing:
                GameView(viewModel: viewModel)
                
            case .roundEnd:
                GameView(viewModel: viewModel)
                    .overlay {
                        VStack {
                            if let winner = viewModel.gameState?.winner {
                                Text("Player \(winner + 1) Wins!")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(12)
                            } else {
                                Text("Draw!")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: { Task { await viewModel.startGame() } }) {
                                Text("Next Round")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 20)
                        }
                    }
            }
        }
        .preferredColorScheme(.dark)
    }
}
