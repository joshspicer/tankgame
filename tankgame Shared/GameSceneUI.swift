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
    private var statusBackground: SKShapeNode?
    private var scoreLabel: SKLabelNode?
    private var scoreBackground: SKShapeNode?
    private var playerScoreLabels: [SKLabelNode] = []
    
    init() {}
    
    /// Setup UI elements
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label with background
        let statusBgWidth: CGFloat = 280
        let statusBgHeight: CGFloat = 40
        
        let newStatusBackground = SKShapeNode(rectOf: CGSize(width: statusBgWidth, height: statusBgHeight), cornerRadius: 12)
        newStatusBackground.fillColor = GameTheme.Colors.backgroundMedium.withAlphaComponent(0.9)
        newStatusBackground.strokeColor = GameTheme.Colors.primary.withAlphaComponent(0.4)
        newStatusBackground.lineWidth = 1.5
        newStatusBackground.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 55)
        newStatusBackground.zPosition = 50
        scene.addChild(newStatusBackground)
        statusBackground = newStatusBackground
        
        let newStatusLabel = SKLabelNode(fontNamed: GameTheme.Fonts.bodyFont)
        newStatusLabel.fontSize = GameTheme.Fonts.bodySize
        newStatusLabel.fontColor = GameTheme.Colors.textPrimary
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 60)
        newStatusLabel.text = "Waiting for game..."
        newStatusLabel.zPosition = 51
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score display with background
        let scoreBgWidth: CGFloat = 200
        let scoreBgHeight: CGFloat = 32
        
        let newScoreBackground = SKShapeNode(rectOf: CGSize(width: scoreBgWidth, height: scoreBgHeight), cornerRadius: 10)
        newScoreBackground.fillColor = GameTheme.Colors.backgroundMedium.withAlphaComponent(0.85)
        newScoreBackground.strokeColor = GameTheme.Colors.secondary.withAlphaComponent(0.4)
        newScoreBackground.lineWidth = 1
        newScoreBackground.position = CGPoint(x: sceneSize.width / 2, y: 35)
        newScoreBackground.zPosition = 50
        scene.addChild(newScoreBackground)
        scoreBackground = newScoreBackground
        
        let newScoreLabel = SKLabelNode(fontNamed: GameTheme.Fonts.bodyFont)
        newScoreLabel.fontSize = GameTheme.Fonts.smallSize
        newScoreLabel.fontColor = GameTheme.Colors.textSecondary
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 30)
        newScoreLabel.text = "Score: 0 - 0"
        newScoreLabel.zPosition = 51
        scene.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Update status text with animation
    func updateStatus(_ text: String) {
        guard let label = statusLabel else { return }
        
        // Fade out, change text, fade in
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let changeText = SKAction.run { label.text = text }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([fadeOut, changeText, fadeIn])
        label.run(sequence)
        
        // Pulse the background
        if let bg = statusBackground {
            let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            scaleUp.timingMode = .easeOut
            scaleDown.timingMode = .easeIn
            let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
            bg.run(pulseSequence)
        }
    }
    
    /// Update score display with animation
    func updateScore(wins: [Int]) {
        guard let label = scoreLabel else { return }
        
        var newText: String
        if wins.count == 2 {
            newText = "🏆 \(wins[0]) - \(wins[1]) 🏆"
        } else {
            // For 3-4 players, show all scores with icons
            let icons = ["🔵", "🔴", "🟢", "🟠"]
            newText = wins.enumerated().map { 
                let icon = $0.offset < icons.count ? icons[$0.offset] : "•"
                return "\(icon)\($0.element)" 
            }.joined(separator: " ")
        }
        
        // Only animate if text actually changed
        if label.text != newText {
            let scaleUp = SKAction.scale(to: 1.15, duration: 0.08)
            let changeText = SKAction.run { label.text = newText }
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
            scaleUp.timingMode = .easeOut
            scaleDown.timingMode = .easeIn
            let sequence = SKAction.sequence([scaleUp, changeText, scaleDown])
            label.run(sequence)
            
            // Flash the score background
            if let bg = scoreBackground {
                let originalColor = bg.strokeColor
                bg.strokeColor = GameTheme.Colors.accent
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak bg] in
                    bg?.strokeColor = originalColor
                }
            }
        }
    }
    
    /// Show round end message with celebration effect
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        guard let label = statusLabel, let bg = statusBackground else { return }
        
        var messageText: String
        var messageColor: SKColor
        
        if let winner = winner {
            if winner == localPlayerIndex {
                messageText = "🎉 You Win! 🎉"
                messageColor = GameTheme.Colors.secondary
            } else {
                messageText = "💥 Player \(winner + 1) Wins! 💥"
                messageColor = GameTheme.Colors.accent
            }
        } else {
            messageText = "⚡ Draw! ⚡"
            messageColor = GameTheme.Colors.textSecondary
        }
        
        // Update background color temporarily
        let originalStroke = bg.strokeColor
        bg.strokeColor = messageColor
        
        // Animate the message
        label.text = messageText
        label.fontColor = messageColor
        
        // Celebration animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeat(pulse, count: 3)
        
        label.run(repeatPulse)
        bg.run(repeatPulse)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self, weak bg, weak label] in
            label?.fontColor = GameTheme.Colors.textPrimary
            bg?.strokeColor = originalStroke
            self?.updateStatus("Next round starting...")
        }
    }
}
