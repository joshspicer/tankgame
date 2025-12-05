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
    
    // Modern styling colors
    private let backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.85)
    private let accentColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
    
    init() {}
    
    /// Setup UI elements with modern glassmorphism style
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Status label background
        let statusBg = SKShapeNode(rectOf: CGSize(width: 240, height: 36), cornerRadius: 18)
        statusBg.fillColor = backgroundColor
        statusBg.strokeColor = SKColor.white.withAlphaComponent(0.2)
        statusBg.lineWidth = 1
        statusBg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 50)
        statusBg.zPosition = 99
        scene.addChild(statusBg)
        statusBackground = statusBg
        
        // Create status label
        let newStatusLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        newStatusLabel.fontSize = 16
        newStatusLabel.fontColor = .white
        newStatusLabel.position = CGPoint(x: 0, y: -6)
        newStatusLabel.text = "Preparing Battle..."
        statusBg.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Score label background
        let scoreBg = SKShapeNode(rectOf: CGSize(width: 200, height: 32), cornerRadius: 16)
        scoreBg.fillColor = backgroundColor
        scoreBg.strokeColor = accentColor.withAlphaComponent(0.3)
        scoreBg.lineWidth = 1
        scoreBg.position = CGPoint(x: sceneSize.width / 2, y: 35)
        scoreBg.zPosition = 99
        scene.addChild(scoreBg)
        scoreBackground = scoreBg
        
        // Create score label
        let newScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        newScoreLabel.fontSize = 14
        newScoreLabel.fontColor = SKColor.white.withAlphaComponent(0.9)
        newScoreLabel.position = CGPoint(x: 0, y: -5)
        newScoreLabel.text = "⚔️ Score: 0 - 0 ⚔️"
        scoreBg.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Update status text with optional animation
    func updateStatus(_ text: String, animated: Bool = true) {
        guard let label = statusLabel, let bg = statusBackground else { return }
        
        if animated {
            // Fade out, change, fade in
            let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.15)
            let changeText = SKAction.run { label.text = text }
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
            let sequence = SKAction.sequence([fadeOut, changeText, fadeIn])
            bg.run(sequence)
        } else {
            label.text = text
        }
    }
    
    /// Update score display with animation
    func updateScore(wins: [Int]) {
        guard let label = scoreLabel, let bg = scoreBackground else { return }
        
        let scoreText: String
        if wins.count == 2 {
            scoreText = "⚔️ Score: \(wins[0]) - \(wins[1]) ⚔️"
        } else {
            // For 3-4 players, show all scores
            let playerScores = wins.enumerated().map { "P\($0.offset+1):\($0.element)" }.joined(separator: " ")
            scoreText = "⚔️ \(playerScores) ⚔️"
        }
        
        // Animate score change
        let popUp = SKAction.scale(to: 1.1, duration: 0.1)
        let popDown = SKAction.scale(to: 1.0, duration: 0.1)
        let changeText = SKAction.run { label.text = scoreText }
        let sequence = SKAction.sequence([popUp, changeText, popDown])
        bg.run(sequence)
    }
    
    /// Show round end message with celebration effect
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        guard let label = statusLabel, let bg = statusBackground else { return }
        
        let message: String
        let color: SKColor
        
        if let winner = winner {
            if winner == localPlayerIndex {
                message = "🏆 VICTORY! 🏆"
                color = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
            } else {
                message = "💀 Player \(winner + 1) Wins"
                color = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
            }
        } else {
            message = "⚡ DRAW! ⚡"
            color = SKColor.white
        }
        
        // Animate the result
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
        let changeColor = SKAction.run {
            label.fontColor = color
            label.text = message
        }
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        let wait = SKAction.wait(forDuration: 2.5)
        let reset = SKAction.run { [weak self] in
            label.fontColor = .white
            self?.updateStatus("Next round...", animated: false)
        }
        
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeInEaseOut
        
        let sequence = SKAction.sequence([scaleUp, changeColor, scaleDown, wait, reset])
        bg.run(sequence)
        
        // Add pulse effect for victory
        if winner == localPlayerIndex {
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            bg.run(SKAction.repeat(pulse, count: 3))
        }
    }
}
