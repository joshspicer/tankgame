//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene with modern, polished design
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var statusBackground: SKShapeNode?
    private var scoreLabel: SKLabelNode?
    private var scoreBackground: SKShapeNode?
    
    init() {}
    
    /// Setup UI elements with modern styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label background (pill shape at top)
        let statusBgWidth: CGFloat = 260
        let statusBgHeight: CGFloat = 40
        let statusBgRect = CGRect(x: -statusBgWidth/2, y: -statusBgHeight/2, width: statusBgWidth, height: statusBgHeight)
        let statusBg = SKShapeNode(rect: statusBgRect, cornerRadius: 20)
        statusBg.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.85)
        statusBg.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.5)
        statusBg.lineWidth = 2
        statusBg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 50)
        statusBg.zPosition = 100
        scene.addChild(statusBg)
        statusBackground = statusBg
        
        // Create status label (use Helvetica Neue as reliable fallback)
        let newStatusLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        newStatusLabel.fontSize = 18
        newStatusLabel.fontColor = .white
        newStatusLabel.position = CGPoint.zero
        newStatusLabel.verticalAlignmentMode = .center
        newStatusLabel.horizontalAlignmentMode = .center
        newStatusLabel.text = "⚔️ Waiting for game..."
        statusBg.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score label background (pill shape at bottom)
        let scoreBgWidth: CGFloat = 200
        let scoreBgHeight: CGFloat = 36
        let scoreBgRect = CGRect(x: -scoreBgWidth/2, y: -scoreBgHeight/2, width: scoreBgWidth, height: scoreBgHeight)
        let scoreBg = SKShapeNode(rect: scoreBgRect, cornerRadius: 18)
        scoreBg.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.85)
        scoreBg.strokeColor = SKColor(red: 0.4, green: 0.6, blue: 0.3, alpha: 0.5)
        scoreBg.lineWidth = 2
        scoreBg.position = CGPoint(x: sceneSize.width / 2, y: 30)
        scoreBg.zPosition = 100
        scene.addChild(scoreBg)
        scoreBackground = scoreBg
        
        // Create score label (use Helvetica Neue as reliable fallback)
        let newScoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Medium")
        newScoreLabel.fontSize = 16
        newScoreLabel.fontColor = .white
        newScoreLabel.position = CGPoint.zero
        newScoreLabel.verticalAlignmentMode = .center
        newScoreLabel.horizontalAlignmentMode = .center
        newScoreLabel.text = "🏆 Score: 0 - 0"
        scoreBg.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Update status text with animation
    func updateStatus(_ text: String) {
        statusLabel?.text = "⚔️ \(text)"
        
        // Pulse animation on update
        if let bg = statusBackground {
            let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            bg.run(pulse)
        }
    }
    
    /// Update score display with animation
    func updateScore(wins: [Int]) {
        if wins.count == 2 {
            scoreLabel?.text = "🏆 Score: \(wins[0]) - \(wins[1])"
        } else {
            // For 3-4 players, show all scores with icons
            let playerIcons = ["🔵", "🔴", "🟢", "🟠"]
            let scoreText = wins.enumerated().map { "\(playerIcons[$0.offset])\($0.element)" }.joined(separator: "  ")
            scoreLabel?.text = scoreText
        }
        
        // Subtle pulse animation
        if let bg = scoreBackground {
            let scaleUp = SKAction.scale(to: 1.03, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            bg.run(pulse)
        }
    }
    
    /// Show round end message with celebration effect
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        if let winner = winner {
            if winner == localPlayerIndex {
                statusLabel?.text = "🎉 VICTORY! 🎉"
                showCelebrationEffect()
            } else {
                statusLabel?.text = "💥 Player \(winner + 1) Wins!"
            }
        } else {
            statusLabel?.text = "🤝 Draw!"
        }
        
        // Enhanced status animation
        if let bg = statusBackground {
            let scaleUp = SKAction.scale(to: 1.15, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
            scaleUp.timingMode = .easeOut
            scaleDown.timingMode = .easeIn
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            bg.run(pulse)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "⏳ Next round starting..."
        }
    }
    
    /// Show celebration particle effect
    private func showCelebrationEffect() {
        guard let scene = statusBackground?.scene else { return }
        
        // Create celebratory particles
        for i in 0..<15 {
            let particle = SKShapeNode(circleOfRadius: 6)
            let colors: [SKColor] = [.yellow, .orange, .cyan, .magenta, .green]
            particle.fillColor = colors[i % colors.count]
            particle.strokeColor = .white
            particle.lineWidth = 1
            particle.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 50)
            particle.zPosition = 150
            scene.addChild(particle)
            
            // Animate outward
            let angle = (CGFloat(i) / 15.0) * 2 * .pi
            let distance: CGFloat = 120
            let moveAction = SKAction.moveBy(
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                duration: 0.8
            )
            let fadeAction = SKAction.fadeOut(withDuration: 0.8)
            let scaleAction = SKAction.scale(to: 0.3, duration: 0.8)
            let group = SKAction.group([moveAction, fadeAction, scaleAction])
            let remove = SKAction.removeFromParent()
            
            particle.run(SKAction.sequence([group, remove]))
        }
    }
}
