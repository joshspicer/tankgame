//
//  ModernGameSceneUI.swift
//  tankgame Shared
//
//  Modern UI elements for the game scene with enhanced visuals
//

import SpriteKit

/// Modern styled UI elements for the game scene
class ModernGameSceneUI {
    private var statusLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    private var statusBackground: SKShapeNode?
    private var scoreBackground: SKShapeNode?
    
    init() {}
    
    /// Setup UI elements with modern styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status background panel
        let statusBg = SKShapeNode(rectOf: CGSize(width: 280, height: 36), cornerRadius: 18)
        statusBg.fillColor = SKColor.black.withAlphaComponent(0.5)
        statusBg.strokeColor = SKColor.white.withAlphaComponent(0.3)
        statusBg.lineWidth = 1.5
        statusBg.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 50)
        statusBg.zPosition = 99
        scene.addChild(statusBg)
        statusBackground = statusBg
        
        // Create status label with modern font
        let newStatusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        newStatusLabel.fontSize = 16
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 56)
        newStatusLabel.fontColor = SKColor.white
        newStatusLabel.text = "Waiting for game..."
        newStatusLabel.zPosition = 100
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score background panel
        let scoreBg = SKShapeNode(rectOf: CGSize(width: 220, height: 32), cornerRadius: 16)
        scoreBg.fillColor = SKColor.black.withAlphaComponent(0.5)
        scoreBg.strokeColor = SKColor.white.withAlphaComponent(0.3)
        scoreBg.lineWidth = 1.5
        scoreBg.position = CGPoint(x: sceneSize.width / 2, y: 34)
        scoreBg.zPosition = 99
        scene.addChild(scoreBg)
        scoreBackground = scoreBg
        
        // Create score label
        let newScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        newScoreLabel.fontSize = 14
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 28)
        newScoreLabel.fontColor = SKColor.white.withAlphaComponent(0.9)
        newScoreLabel.text = "Score: 0 - 0"
        newScoreLabel.zPosition = 100
        scene.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Update status text with optional animation
    func updateStatus(_ text: String, animate: Bool = false) {
        statusLabel?.text = text
        
        if animate {
            let scaleUp = SKAction.scale(to: 1.15, duration: 0.15)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
            statusLabel?.run(SKAction.sequence([scaleUp, scaleDown]))
            statusBackground?.run(SKAction.sequence([scaleUp, scaleDown]))
        }
    }
    
    /// Update score display
    func updateScore(wins: [Int]) {
        if wins.count == 2 {
            scoreLabel?.text = "🏆 \(wins[0]) - \(wins[1]) 🏆"
        } else {
            // For 3-4 players, show all scores
            let scoreText = wins.enumerated().map { "P\($0.offset+1): \($0.element)" }.joined(separator: "  |  ")
            scoreLabel?.text = scoreText
        }
    }
    
    /// Show round end message with celebration effect
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        let text: String
        let isWinner: Bool
        
        if let winner = winner {
            if winner == localPlayerIndex {
                text = "🎉 YOU WIN! 🎉"
                isWinner = true
            } else {
                text = "Player \(winner + 1) Wins!"
                isWinner = false
            }
        } else {
            text = "⚔️ DRAW! ⚔️"
            isWinner = false
        }
        
        statusLabel?.text = text
        
        // Victory animation
        if isWinner {
            let colorCycle = SKAction.sequence([
                SKAction.run { [weak self] in self?.statusLabel?.fontColor = SKColor.yellow },
                SKAction.wait(forDuration: 0.2),
                SKAction.run { [weak self] in self?.statusLabel?.fontColor = SKColor.green },
                SKAction.wait(forDuration: 0.2),
                SKAction.run { [weak self] in self?.statusLabel?.fontColor = SKColor.cyan },
                SKAction.wait(forDuration: 0.2)
            ])
            statusLabel?.run(SKAction.repeat(colorCycle, count: 5)) { [weak self] in
                self?.statusLabel?.fontColor = SKColor.white
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "Next round starting..."
        }
    }
}
