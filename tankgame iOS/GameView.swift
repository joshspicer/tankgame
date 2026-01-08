//
//  GameView.swift
//  tankgame iOS
//
//  Complete rewrite - SwiftUI wrapper for SpriteKit
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var scene: GameSceneMinimal?

    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            }

            if viewModel.isGameOver {
                VStack {
                    Text("Game Over!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    if let winner = viewModel.winner {
                        Text("Winner: \(winner)")
                            .font(.title2)
                            .foregroundColor(.white)
                    } else {
                        Text("Draw!")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
            }
        }
        .onAppear {
            setupScene()
        }
        .onChange(of: viewModel.gameState) { oldValue, newValue in
            scene?.render(newValue)
        }
    }

    private func setupScene() {
        let newScene = GameSceneMinimal(size: CGSize(width: 600, height: 800))
        newScene.scaleMode = .aspectFit

        newScene.onMove = { direction in
            viewModel.moveTank(direction: direction)
        }

        newScene.onShoot = {
            viewModel.shootBullet()
        }

        newScene.render(viewModel.gameState)
        scene = newScene
    }
}
