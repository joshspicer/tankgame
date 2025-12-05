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
    private var scoreLabel: SKLabelNode?
    private var scoreBackground: SKShapeNode?
    
    init() {}
    
    /// Setup UI elements with modern styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label with background pill
        let bgWidth: CGFloat = 260
        let bgHeight: CGFloat = 44
        
        statusBackground = SKShapeNode(rectOf: CGSize(width: bgWidth, height: bgHeight), cornerRadius: 22)
        statusBackground?.fillColor = SKColor(red: 0.1, green: 0.12, blue: 0.2, alpha: 0.85)
        statusBackground?.strokeColor = SKColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 0.6)
        statusBackground?.lineWidth = 2
        statusBackground?.glowWidth = 2
        statusBackground?.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 55)
        statusBackground?.zPosition = 99
        scene.addChild(statusBackground!)
        
        let newStatusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        newStatusLabel.fontSize = 18
        newStatusLabel.fontColor = .white
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 60)
        newStatusLabel.text = "Waiting for game..."
        newStatusLabel.zPosition = 100
        
        // Add shadow for depth
        let statusShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statusShadow.fontSize = 18
        statusShadow.fontColor = SKColor(white: 0, alpha: 0.4)
        statusShadow.position = CGPoint(x: 1, y: -1)
        statusShadow.text = newStatusLabel.text
        statusShadow.zPosition = -1
        newStatusLabel.addChild(statusShadow)
        
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score label with background
        scoreBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 36), cornerRadius: 18)
        scoreBackground?.fillColor = SKColor(red: 0.1, green: 0.12, blue: 0.2, alpha: 0.8)
        scoreBackground?.strokeColor = SKColor(red: 0.25, green: 0.35, blue: 0.5, alpha: 0.5)
        scoreBackground?.lineWidth = 1.5
        scoreBackground?.position = CGPoint(x: sceneSize.width / 2, y: 35)
        scoreBackground?.zPosition = 99
        scene.addChild(scoreBackground!)
        
        let newScoreLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        newScoreLabel.fontSize = 16
        newScoreLabel.fontColor = SKColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 1.0)
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 30)
        newScoreLabel.text = "Score: 0 - 0"
        newScoreLabel.zPosition = 100
        scene.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
    }
    
    /// Update status text
    func updateStatus(_ text: String) {
        statusLabel?.text = text
        // Update shadow text
        if let shadow = statusLabel?.children.first as? SKLabelNode {
            shadow.text = text
        }
    }
    
    /// Update score display
    func updateScore(wins: [Int]) {
        if wins.count == 2 {
            scoreLabel?.text = "Score: \(wins[0]) - \(wins[1])"
        } else {
            // For 3-4 players, show all scores
            let scoreText = wins.enumerated().map { "P\($0.offset+1): \($0.element)" }.joined(separator: " | ")
            scoreLabel?.text = scoreText
        }
    }
    
    /// Show round end message with enhanced styling
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        if let winner = winner {
            if winner == localPlayerIndex {
                statusLabel?.text = "🎉 You Win! 🎉"
                statusLabel?.fontColor = SKColor(red: 0.3, green: 1.0, blue: 0.4, alpha: 1.0)
            } else {
                statusLabel?.text = "Player \(winner + 1) Wins!"
                statusLabel?.fontColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
            }
        } else {
            statusLabel?.text = "Draw!"
            statusLabel?.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        }
        
        // Update shadow
        if let shadow = statusLabel?.children.first as? SKLabelNode {
            shadow.text = statusLabel?.text
        }
        
        // Add scale animation for emphasis
        statusLabel?.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "Next round starting..."
            self?.statusLabel?.fontColor = .white
            if let shadow = self?.statusLabel?.children.first as? SKLabelNode {
                shadow.text = "Next round starting..."
            }
        }
    }
}
