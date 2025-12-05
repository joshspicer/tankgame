//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene (status and score labels) with premium styling
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    private var statusBackground: SKShapeNode?
    private var scoreBackground: SKShapeNode?
    
    init() {}
    
    /// Setup UI elements with premium styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status background with glass effect
        let statusBgWidth: CGFloat = 300
        let statusBgHeight: CGFloat = 40
        let statusBg = SKShapeNode(rectOf: CGSize(width: statusBgWidth, height: statusBgHeight), cornerRadius: 12)
        statusBg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 45)
        statusBg.fillColor = SKColor(white: 0.1, alpha: 0.8)
        statusBg.strokeColor = SKColor(white: 1.0, alpha: 0.2)
        statusBg.lineWidth = 1
        statusBg.zPosition = 100
        scene.addChild(statusBg)
        statusBackground = statusBg
        
        // Create status label with modern font
        let newStatusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        newStatusLabel.fontSize = 18
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 52)
        newStatusLabel.text = "Waiting for game..."
        newStatusLabel.fontColor = .white
        newStatusLabel.zPosition = 101
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score background with glass effect
        let scoreBgWidth: CGFloat = 280
        let scoreBgHeight: CGFloat = 32
        let scoreBg = SKShapeNode(rectOf: CGSize(width: scoreBgWidth, height: scoreBgHeight), cornerRadius: 10)
        scoreBg.position = CGPoint(x: sceneSize.width / 2, y: 28)
        scoreBg.fillColor = SKColor(white: 0.1, alpha: 0.8)
        scoreBg.strokeColor = SKColor(white: 1.0, alpha: 0.2)
        scoreBg.lineWidth = 1
        scoreBg.zPosition = 100
        scene.addChild(scoreBg)
        scoreBackground = scoreBg
        
        // Create score label with modern font
        let newScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        newScoreLabel.fontSize = 16
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 22)
        newScoreLabel.text = "Score: 0 - 0"
        newScoreLabel.fontColor = SKColor(white: 0.9, alpha: 1.0)
        newScoreLabel.zPosition = 101
        scene.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Update status text with animation
    func updateStatus(_ text: String) {
        statusLabel?.text = text
        
        // Add pulse animation
        if let label = statusLabel {
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            label.run(SKAction.sequence([scaleUp, scaleDown]))
        }
    }
    
    /// Update score display with colored player indicators
    func updateScore(wins: [Int]) {
        if wins.count == 2 {
            scoreLabel?.text = "🔵 \(wins[0])  vs  \(wins[1]) 🔴"
        } else {
            // For 3-4 players, show all scores with colors
            let colors = ["🔵", "🔴", "🟢", "🟠"]
            let scoreText = wins.enumerated().map { "\(colors[$0.offset]) \($0.element)" }.joined(separator: "  ")
            scoreLabel?.text = scoreText
        }
    }
    
    /// Show round end message with victory animation
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        if let winner = winner {
            if winner == localPlayerIndex {
                statusLabel?.text = "🎉 You Win! 🎉"
                statusLabel?.fontColor = SKColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
            } else {
                statusLabel?.text = "Player \(winner + 1) Wins!"
                statusLabel?.fontColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
            }
        } else {
            statusLabel?.text = "⚔️ Draw! ⚔️"
            statusLabel?.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        }
        
        // Victory animation
        if let label = statusLabel {
            let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleUp, scaleDown])
            label.run(sequence)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "Next round starting..."
            self?.statusLabel?.fontColor = .white
        }
    }
}
