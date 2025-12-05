//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene with modern styling
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var statusBackground: SKShapeNode?
    private var scoreLabel: SKLabelNode?
    private var scoreBackground: SKShapeNode?
    
    init() {}
    
    /// Setup UI elements with modern styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label with background
        let newStatusBackground = SKShapeNode(rectOf: CGSize(width: 300, height: 44), cornerRadius: 22)
        newStatusBackground.fillColor = SKColor.black.withAlphaComponent(0.6)
        newStatusBackground.strokeColor = SKColor.white.withAlphaComponent(0.3)
        newStatusBackground.lineWidth = 2
        newStatusBackground.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 50)
        newStatusBackground.zPosition = 100
        scene.addChild(newStatusBackground)
        statusBackground = newStatusBackground
        
        let newStatusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        newStatusLabel.fontSize = 18
        newStatusLabel.fontColor = .white
        newStatusLabel.position = .zero
        newStatusLabel.verticalAlignmentMode = .center
        newStatusLabel.horizontalAlignmentMode = .center
        newStatusLabel.text = "Waiting for game..."
        newStatusBackground.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Add glow effect to status background
        addGlowEffect(to: newStatusBackground, color: SKColor.cyan)
        
        // Create score label with background
        let newScoreBackground = SKShapeNode(rectOf: CGSize(width: 240, height: 36), cornerRadius: 18)
        newScoreBackground.fillColor = SKColor.black.withAlphaComponent(0.5)
        newScoreBackground.strokeColor = SKColor.white.withAlphaComponent(0.2)
        newScoreBackground.lineWidth = 1.5
        newScoreBackground.position = CGPoint(x: sceneSize.width / 2, y: 30)
        newScoreBackground.zPosition = 100
        scene.addChild(newScoreBackground)
        scoreBackground = newScoreBackground
        
        let newScoreLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        newScoreLabel.fontSize = 15
        newScoreLabel.fontColor = SKColor.white.withAlphaComponent(0.9)
        newScoreLabel.position = .zero
        newScoreLabel.verticalAlignmentMode = .center
        newScoreLabel.horizontalAlignmentMode = .center
        newScoreLabel.text = "Score: 0 - 0"
        newScoreBackground.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Add glow effect to a shape node
    private func addGlowEffect(to node: SKShapeNode, color: SKColor) {
        node.glowWidth = 3
    }
    
    /// Update status text with animation
    func updateStatus(_ text: String) {
        guard let label = statusLabel else { return }
        
        // Animate text change
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let changeText = SKAction.run { [weak label] in
            label?.text = text
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([fadeOut, changeText, fadeIn])
        label.run(sequence)
        
        // Add pulse effect to background
        if let background = statusBackground {
            let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            background.run(SKAction.sequence([scaleUp, scaleDown]))
        }
    }
    
    /// Update score display with animation
    func updateScore(wins: [Int]) {
        guard let label = scoreLabel else { return }
        
        let text: String
        if wins.count == 2 {
            text = "⭐ \(wins[0]) - \(wins[1]) ⭐"
        } else {
            // For 3-4 players, show all scores with icons
            let scoreText = wins.enumerated().map { "P\($0.offset+1): \($0.element)" }.joined(separator: " │ ")
            text = "🏆 \(scoreText)"
        }
        
        // Only animate if score changed
        if label.text != text {
            let bounce = SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.15)
            ])
            label.run(bounce)
        }
        
        label.text = text
    }
    
    /// Show round end message with dramatic effect
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        guard let label = statusLabel, let background = statusBackground else { return }
        
        let text: String
        let color: SKColor
        
        if let winner = winner {
            if winner == localPlayerIndex {
                text = "🎉 VICTORY! 🎉"
                color = SKColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1.0)
            } else {
                text = "💥 Player \(winner + 1) Wins!"
                color = SKColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
            }
        } else {
            text = "🤝 Draw!"
            color = SKColor(red: 0.9, green: 0.8, blue: 0.3, alpha: 1.0)
        }
        
        // Update label
        label.text = text
        
        // Animate background color
        background.fillColor = color.withAlphaComponent(0.7)
        background.strokeColor = .white
        
        // Scale animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        background.run(pulse)
        
        // Reset after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "⏳ Next round starting..."
            self?.statusBackground?.fillColor = SKColor.black.withAlphaComponent(0.6)
            self?.statusBackground?.strokeColor = SKColor.white.withAlphaComponent(0.3)
        }
    }
}
