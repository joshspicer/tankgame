//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene with classic retro styling
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    
    init() {}
    
    /// Setup UI elements with retro fonts
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label with retro font
        let newStatusLabel = SKLabelNode(fontNamed: RetroFonts.title)
        newStatusLabel.fontSize = 18
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 50)
        newStatusLabel.text = "WAITING FOR GAME..."
        newStatusLabel.fontColor = .white
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score label with retro font
        let newScoreLabel = SKLabelNode(fontNamed: RetroFonts.label)
        newScoreLabel.fontSize = 14
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 30)
        newScoreLabel.text = "SCORE: 0 - 0"
        newScoreLabel.fontColor = .white
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
