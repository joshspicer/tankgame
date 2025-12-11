//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene (status and score labels)
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    
    init() {}
    
    /// Setup UI elements
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label
        let newStatusLabel = SKLabelNode(fontNamed: "Arial")
        newStatusLabel.fontSize = 16
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 40)
        newStatusLabel.text = "Waiting..."
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score label
        let newScoreLabel = SKLabelNode(fontNamed: "Arial")
        newScoreLabel.fontSize = 14
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 25)
        newScoreLabel.text = "0 - 0"
        scene.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Update status text
    func updateStatus(_ text: String) {
        statusLabel?.text = text
    }
    
    /// Update score display
    func updateScore(wins: [Int]) {
        if wins.count == 2 {
            scoreLabel?.text = "\(wins[0]) - \(wins[1])"
        } else {
            // For 3-4 players, show all scores
            let scoreText = wins.enumerated().map { "\($0.offset+1): \($0.element)" }.joined(separator: " ")
            scoreLabel?.text = scoreText
        }
    }
    
    /// Show round end message
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        if let winner = winner {
            if winner == localPlayerIndex {
                statusLabel?.text = "You Win!"
            } else {
                statusLabel?.text = "P\(winner + 1) Wins!"
            }
        } else {
            statusLabel?.text = "Draw!"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "Next round..."
        }
    }
}
