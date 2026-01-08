//
//  GameView.swift
//  tankgame iOS
//
//  SwiftUI + SpriteKit game view

import SwiftUI
import SpriteKit

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var scene: MinimalGameScene?
    
    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            }
            
            VStack {
                HStack {
                    if let state = viewModel.gameState {
                        Text("Score: \(state.scores.map(String.init).joined(separator: " - "))")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.disconnect() }) {
                        Text("Quit")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            setupScene()
        }
        .onChange(of: viewModel.gameState) { _, newState in
            if let state = newState {
                scene?.render(state: state)
            }
        }
    }
    
    private func setupScene() {
        let newScene = MinimalGameScene(size: CGSize(width: 600, height: 800))
        newScene.scaleMode = .aspectFill
        newScene.onMove = { direction in
            viewModel.move(direction)
        }
        newScene.onShoot = {
            viewModel.shoot()
        }
        scene = newScene
    }
}
