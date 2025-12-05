//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene - Classic retro style
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    
    init() {}
    
    /// Setup UI elements with classic retro styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label - classic monospace font
        let newStatusLabel = SKLabelNode(fontNamed: "Courier-Bold")
        newStatusLabel.fontSize = 18
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 40)
        newStatusLabel.text = "WAITING..."
        newStatusLabel.fontColor = .white
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score label - classic monospace font
        let newScoreLabel = SKLabelNode(fontNamed: "Courier")
        newScoreLabel.fontSize = 14
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 25)
        newScoreLabel.text = "P1: 0  P2: 0"
        newScoreLabel.fontColor = SKColor(white: 0.8, alpha: 1.0)
        scene.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Update status text
    func updateStatus(_ text: String) {
        statusLabel?.text = text.uppercased()
    }
    
    /// Update score display
    func updateScore(wins: [Int]) {
        if wins.count == 2 {
            scoreLabel?.text = "P1: \(wins[0])  P2: \(wins[1])"
        } else {
            // For 3-4 players, show all scores
            let scoreText = wins.enumerated().map { "P\($0.offset+1):\($0.element)" }.joined(separator: " ")
            scoreLabel?.text = scoreText
        }
    }
    
    /// Show round end message
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        if let winner = winner {
            if winner == localPlayerIndex {
                statusLabel?.text = "YOU WIN!"
            } else {
                statusLabel?.text = "P\(winner + 1) WINS!"
            }
        } else {
            statusLabel?.text = "DRAW!"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "NEXT ROUND..."
        }
    }
}
