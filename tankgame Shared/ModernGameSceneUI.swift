//
//  ModernGameSceneUI.swift
//  tankgame Shared
//
//  Modernized UI elements for the game scene with enhanced visuals
//

import SpriteKit

/// Manages modernized UI elements in the game scene
class ModernGameSceneUI {
    private var statusLabel: SKLabelNode?
    private var statusBackground: SKShapeNode?
    private var scoreContainer: SKNode?
    private var playerScoreNodes: [SKNode] = []
    private var roundLabel: SKLabelNode?
    
    // Visual constants
    private let primaryColor: SKColor = .systemBlue
    private let accentColor: SKColor = .systemYellow
    
    init() {}
    
    /// Setup UI elements with modern styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        setupStatusDisplay(in: scene, sceneSize: sceneSize)
        setupScoreDisplay(in: scene, sceneSize: sceneSize)
    }
    
    /// Setup the status display at the top
    private func setupStatusDisplay(in scene: SKScene, sceneSize: CGSize) {
        // Create status background
        let bgWidth = sceneSize.width * 0.6
        let bgHeight: CGFloat = 44
        
        let background = SKShapeNode(rectOf: CGSize(width: bgWidth, height: bgHeight), cornerRadius: 12)
        background.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 50)
        background.fillColor = SKColor.black.withAlphaComponent(0.6)
        background.strokeColor = primaryColor.withAlphaComponent(0.4)
        background.lineWidth = 2
        background.glowWidth = 3
        background.zPosition = 100
        scene.addChild(background)
        statusBackground = background
        
        // Create status label
        let newStatusLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        newStatusLabel.fontSize = 18
        newStatusLabel.fontColor = .white
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 55)
        newStatusLabel.verticalAlignmentMode = .center
        newStatusLabel.text = "Waiting for game..."
        newStatusLabel.zPosition = 101
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
    }
    
    /// Setup the score display at the bottom
    private func setupScoreDisplay(in scene: SKScene, sceneSize: CGSize) {
        let container = SKNode()
        container.position = CGPoint(x: sceneSize.width / 2, y: 35)
        container.zPosition = 100
        scene.addChild(container)
        scoreContainer = container
        
        // Initial score setup for 2 players (will be reconfigured when game starts)
        createScoreNodes(playerCount: 2, in: container)
    }
    
    /// Create score nodes for the given player count
    private func createScoreNodes(playerCount: Int, in container: SKNode) {
        // Clear existing nodes
        container.removeAllChildren()
        playerScoreNodes.removeAll()
        
        let colors: [SKColor] = [.systemBlue, .systemRed, .systemGreen, .systemOrange]
        let totalWidth: CGFloat = CGFloat(playerCount) * 90 + CGFloat(playerCount - 1) * 15
        let startX = -totalWidth / 2 + 45
        
        for i in 0..<playerCount {
            let scoreNode = createPlayerScoreNode(playerIndex: i, color: colors[i])
            scoreNode.position = CGPoint(x: startX + CGFloat(i) * 105, y: 0)
            container.addChild(scoreNode)
            playerScoreNodes.append(scoreNode)
        }
    }
    
    /// Create a single player score node
    private func createPlayerScoreNode(playerIndex: Int, color: SKColor) -> SKNode {
        let container = SKNode()
        container.name = "playerScore_\(playerIndex)"
        
        // Background pill
        let background = SKShapeNode(rectOf: CGSize(width: 90, height: 36), cornerRadius: 18)
        background.fillColor = SKColor.black.withAlphaComponent(0.5)
        background.strokeColor = color.withAlphaComponent(0.6)
        background.lineWidth = 2
        background.glowWidth = 3
        container.addChild(background)
        
        // Player indicator dot
        let dot = SKShapeNode(circleOfRadius: 6)
        dot.fillColor = color
        dot.strokeColor = .white
        dot.lineWidth = 1
        dot.position = CGPoint(x: -30, y: 0)
        dot.name = "dot"
        container.addChild(dot)
        
        // Player label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "P\(playerIndex + 1)"
        label.fontSize = 12
        label.fontColor = color
        label.position = CGPoint(x: -10, y: -4)
        label.horizontalAlignmentMode = .left
        label.name = "label"
        container.addChild(label)
        
        // Score number
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 16
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 30, y: -5)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.name = "score"
        container.addChild(scoreLabel)
        
        return container
    }
    
    /// Update status text with animation
    func updateStatus(_ text: String) {
        guard let label = statusLabel else { return }
        
        // Fade out, change text, fade in
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        let changeText = SKAction.run { label.text = text }
        let fadeIn = SKAction.fadeIn(withDuration: 0.15)
        let sequence = SKAction.sequence([fadeOut, changeText, fadeIn])
        label.run(sequence)
        
        // Pulse the background
        if let bg = statusBackground {
            let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            bg.run(SKAction.sequence([scaleUp, scaleDown]))
        }
    }
    
    /// Update score display
    func updateScore(wins: [Int]) {
        // Reconfigure if player count changed
        if wins.count != playerScoreNodes.count, let container = scoreContainer {
            createScoreNodes(playerCount: wins.count, in: container)
        }
        
        // Update each player's score
        for (index, score) in wins.enumerated() {
            guard index < playerScoreNodes.count else { continue }
            
            let scoreNode = playerScoreNodes[index]
            if let scoreLabel = scoreNode.childNode(withName: "score") as? SKLabelNode {
                let oldScore = Int(scoreLabel.text ?? "0") ?? 0
                if score != oldScore {
                    // Animate score change
                    animateScoreChange(scoreLabel, newScore: score)
                }
            }
        }
    }
    
    /// Animate a score change
    private func animateScoreChange(_ label: SKLabelNode, newScore: Int) {
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
        let changeText = SKAction.run { label.text = "\(newScore)" }
        let colorFlash = SKAction.run { label.fontColor = .yellow }
        let wait = SKAction.wait(forDuration: 0.2)
        let resetColor = SKAction.run { label.fontColor = .white }
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        
        let sequence = SKAction.sequence([scaleUp, changeText, colorFlash, wait, resetColor, scaleDown])
        label.run(sequence)
    }
    
    /// Show round end message with animation
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        var message: String
        var color: SKColor
        
        if let winner = winner {
            if winner == localPlayerIndex {
                message = "🎉 VICTORY! 🎉"
                color = .systemGreen
            } else {
                message = "💥 Player \(winner + 1) Wins! 💥"
                color = .systemRed
            }
        } else {
            message = "⚔️ DRAW! ⚔️"
            color = .systemYellow
        }
        
        guard let label = statusLabel, let bg = statusBackground else { return }
        
        // Animate status change
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let updateLabel = SKAction.run {
            label.text = message
            label.fontColor = color
            bg.strokeColor = color
            bg.glowWidth = 8
        }
        let wait = SKAction.wait(forDuration: 0.3)
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.15),
            SKAction.scale(to: 1.2, duration: 0.15)
        ])
        let repeatPulse = SKAction.repeat(pulse, count: 3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let resetStyle = SKAction.run {
            label.fontColor = .white
            bg.strokeColor = self.primaryColor.withAlphaComponent(0.4)
            bg.glowWidth = 3
        }
        
        bg.run(SKAction.sequence([scaleUp, updateLabel, wait, repeatPulse, scaleDown, resetStyle]))
        
        // Show "next round" message after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.updateStatus("Next round starting...")
        }
    }
    
    /// Highlight a player's score (e.g., when they score)
    func highlightPlayerScore(_ playerIndex: Int) {
        guard playerIndex < playerScoreNodes.count else { return }
        
        let scoreNode = playerScoreNodes[playerIndex]
        
        // Pulse animation
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        scoreNode.run(sequence)
        
        // Flash the dot
        if let dot = scoreNode.childNode(withName: "dot") as? SKShapeNode {
            let originalColor = dot.fillColor
            dot.fillColor = .white
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dot.fillColor = originalColor
            }
        }
    }
    
    /// Show a temporary floating message
    func showFloatingMessage(_ text: String, at position: CGPoint, in scene: SKScene, color: SKColor = .white) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 24
        label.fontColor = color
        label.position = position
        label.zPosition = 200
        label.alpha = 0
        scene.addChild(label)
        
        // Animate float up and fade
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([
            fadeIn,
            SKAction.group([moveUp, SKAction.sequence([SKAction.wait(forDuration: 0.7), fadeOut])]),
            remove
        ])
        
        label.run(sequence)
    }
}
