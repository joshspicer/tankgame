//
//  GameViewControllerSceneSetup.swift
//  tankgame iOS
//
//  Scene setup logic extracted from GameViewController
//

import UIKit
import SpriteKit

/// Handles SpriteKit scene setup for GameViewController
extension GameViewController {

    func setupSKViewIfNeeded() {
        if skView == nil {
            let newSKView = SKView(frame: view.bounds)
            newSKView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(newSKView, at: 0)
            skView = newSKView
        }
    }

    func presentGameScene(with gameState: GameState) {
        let scene = GameScene.newGameScene()
        scene.startGame(with: gameState)
        scene.onGameMessage = { [weak self] message in
            self?.handleGameMessage(message)
        }

        gameScene = scene

        skView?.presentScene(scene)
        skView?.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
    }
}
