//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene - clean retro style
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    
    init() {}
    
    /// Setup UI elements with retro styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label with retro font
        let newStatusLabel = SKLabelNode(fontNamed: RetroTheme.Fonts.primary)
        newStatusLabel.fontSize = RetroTheme.Fonts.titleSize
        newStatusLabel.fontColor = RetroTheme.Colors.text
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 45)
        newStatusLabel.text = "WAITING..."
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score label with retro font
        let newScoreLabel = SKLabelNode(fontNamed: RetroTheme.Fonts.secondary)
        newScoreLabel.fontSize = RetroTheme.Fonts.bodySize
        newScoreLabel.fontColor = RetroTheme.Colors.textSecondary
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 25)
        newScoreLabel.text = "SCORE: 0 - 0"
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
            scoreLabel?.text = "SCORE: \(wins[0]) - \(wins[1])"
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
                statusLabel?.text = "PLAYER \(winner + 1) WINS!"
            }
        } else {
            statusLabel?.text = "DRAW!"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "NEXT ROUND..."
        }
    }
}
