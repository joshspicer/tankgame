//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene (status and score labels) with modern styling
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var statusBackground: SKShapeNode?
    private var scoreContainer: SKNode?
    private var scoreLabels: [SKLabelNode] = []
    
    init() {}
    
    /// Setup UI elements with modern styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Status bar background
        let statusBg = SKShapeNode(rectOf: CGSize(width: 240, height: 36), cornerRadius: 18)
        statusBg.fillColor = UXTheme.gameBackground.withAlphaComponent(0.85)
        statusBg.strokeColor = SKColor.white.withAlphaComponent(0.1)
        statusBg.lineWidth = 1
        statusBg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 45)
        statusBg.zPosition = 90
        scene.addChild(statusBg)
        statusBackground = statusBg
        
        // Create status label
        let newStatusLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        newStatusLabel.fontSize = 16
        newStatusLabel.fontColor = .white
        newStatusLabel.position = CGPoint(x: 0, y: -6)
        newStatusLabel.text = "Waiting..."
        newStatusLabel.zPosition = 91
        statusBg.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Score container at bottom
        let scoreNode = SKNode()
        scoreNode.position = CGPoint(x: sceneSize.width / 2, y: 32)
        scoreNode.zPosition = 90
        scene.addChild(scoreNode)
        scoreContainer = scoreNode
        
        // Score background
        let scoreBg = SKShapeNode(rectOf: CGSize(width: 200, height: 28), cornerRadius: 14)
        scoreBg.fillColor = UXTheme.gameBackground.withAlphaComponent(0.8)
        scoreBg.strokeColor = SKColor.white.withAlphaComponent(0.1)
        scoreBg.lineWidth = 1
        scoreNode.addChild(scoreBg)
        
        // Initial score label
        let newScoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        newScoreLabel.fontSize = 14
        newScoreLabel.fontColor = SKColor.white.withAlphaComponent(0.9)
        newScoreLabel.position = CGPoint(x: 0, y: -5)
        newScoreLabel.text = "Score: 0 - 0"
        newScoreLabel.zPosition = 91
        scoreNode.addChild(newScoreLabel)
        scoreLabels.append(newScoreLabel)
    }
    
    /// Update status text with animation
    func updateStatus(_ text: String) {
        guard let label = statusLabel else { return }
        
        // Fade out, update, fade in
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let updateText = SKAction.run { [weak label] in
            label?.text = text
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        
        label.run(SKAction.sequence([fadeOut, updateText, fadeIn]))
    }
    
    /// Update score display with player colors
    func updateScore(wins: [Int]) {
        guard let scoreLabel = scoreLabels.first else { return }
        
        if wins.count == 2 {
            scoreLabel.text = "🔵 \(wins[0])  vs  \(wins[1]) 🔴"
        } else {
            // For 3-4 players, show all scores with colors
            let emojis = ["🔵", "🔴", "🟢", "🟠"]
            let scoreText = wins.enumerated().map { "\(emojis[$0.offset])\($0.element)" }.joined(separator: "  ")
            scoreLabel.text = scoreText
        }
    }
    
    /// Show round end message with dramatic effect
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        guard let statusBg = statusBackground, let label = statusLabel else { return }
        
        // Expand status background
        let expandBg = SKAction.resize(toWidth: 280, height: 50, duration: 0.2)
        statusBg.run(expandBg)
        
        // Update message with color
        if let winner = winner {
            if winner == localPlayerIndex {
                label.text = "🏆 YOU WIN!"
                label.fontColor = UXTheme.successColor
                
                // Victory pulse animation
                let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
                let pulse = SKAction.sequence([scaleUp, scaleDown])
                label.run(SKAction.repeat(pulse, count: 3))
            } else {
                label.text = "💀 Player \(winner + 1) Wins"
                label.fontColor = UXTheme.accentColor
            }
        } else {
            label.text = "🤝 DRAW!"
            label.fontColor = UXTheme.textSecondary
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self, weak statusBg, weak label] in
            // Shrink background back
            let shrinkBg = SKAction.resize(toWidth: 240, height: 36, duration: 0.2)
            statusBg?.run(shrinkBg)
            
            label?.fontColor = .white
            self?.updateStatus("Next round...")
        }
    }
}
