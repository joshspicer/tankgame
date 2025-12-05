//
//  ModernGameSceneUI.swift
//  tankgame Shared
//
//  Enhanced game scene UI with modern styling and animations
//

import SpriteKit

/// Modern game scene UI with enhanced status displays and visual feedback
class ModernGameSceneUI {
    
    // MARK: - Nodes
    
    private var statusContainer: SKNode?
    private var statusBackground: SKShapeNode?
    private var statusLabel: SKLabelNode?
    private var scoreContainer: SKNode?
    private var scoreBackground: SKShapeNode?
    private var scoreLabel: SKLabelNode?
    private var playerIndicators: [SKNode] = []
    
    // MARK: - Colors
    
    struct Colors {
        static let statusBackground = SKColor(white: 0.0, alpha: 0.6)
        static let statusText = SKColor.white
        static let scoreBackground = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.7)
        static let scoreText = SKColor.white
        static let winnerGlow = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        static let loserGlow = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    }
    
    init() {}
    
    // MARK: - Setup
    
    /// Setup UI elements with modern styling
    func setup(in scene: SKScene, sceneSize: CGSize) {
        setupStatusContainer(in: scene, sceneSize: sceneSize)
        setupScoreContainer(in: scene, sceneSize: sceneSize)
    }
    
    private func setupStatusContainer(in scene: SKScene, sceneSize: CGSize) {
        // Container node for status
        let container = SKNode()
        container.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 45)
        container.zPosition = 50
        scene.addChild(container)
        statusContainer = container
        
        // Background pill shape
        let bgWidth: CGFloat = 200
        let bgHeight: CGFloat = 36
        let background = SKShapeNode(rectOf: CGSize(width: bgWidth, height: bgHeight), cornerRadius: bgHeight / 2)
        background.fillColor = Colors.statusBackground
        background.strokeColor = SKColor.white.withAlphaComponent(0.2)
        background.lineWidth = 1
        container.addChild(background)
        statusBackground = background
        
        // Status label
        let label = SKLabelNode(fontNamed: "Arial-BoldMT")
        label.fontSize = 16
        label.fontColor = Colors.statusText
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.text = "Waiting for game..."
        container.addChild(label)
        statusLabel = label
    }
    
    private func setupScoreContainer(in scene: SKScene, sceneSize: CGSize) {
        // Container node for score
        let container = SKNode()
        container.position = CGPoint(x: sceneSize.width / 2, y: 25)
        container.zPosition = 50
        scene.addChild(container)
        scoreContainer = container
        
        // Background pill shape
        let bgWidth: CGFloat = 160
        let bgHeight: CGFloat = 32
        let background = SKShapeNode(rectOf: CGSize(width: bgWidth, height: bgHeight), cornerRadius: bgHeight / 2)
        background.fillColor = Colors.scoreBackground
        background.strokeColor = SKColor.white.withAlphaComponent(0.15)
        background.lineWidth = 1
        container.addChild(background)
        scoreBackground = background
        
        // Score label
        let label = SKLabelNode(fontNamed: "Arial")
        label.fontSize = 14
        label.fontColor = Colors.scoreText
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.text = "Score: 0 - 0"
        container.addChild(label)
        scoreLabel = label
    }
    
    // MARK: - Updates
    
    /// Update status text with animation
    func updateStatus(_ text: String) {
        guard let label = statusLabel, let container = statusContainer else { return }
        
        // Animate text change
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let changeText = SKAction.run { [weak label] in
            label?.text = text
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        
        label.run(SKAction.sequence([fadeOut, changeText, fadeIn]))
        
        // Pulse the container
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        container.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    /// Update score display with animation
    func updateScore(wins: [Int]) {
        guard let label = scoreLabel, let background = scoreBackground else { return }
        
        let scoreText: String
        if wins.count == 2 {
            scoreText = "Score: \(wins[0]) - \(wins[1])"
        } else {
            scoreText = wins.enumerated().map { "P\($0.offset+1): \($0.element)" }.joined(separator: " | ")
        }
        
        // Animate score change
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.15)
        let changeText = SKAction.run { [weak label] in
            label?.text = scoreText
        }
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        
        label.run(SKAction.sequence([scaleUp, changeText, scaleDown]))
        
        // Brief glow effect
        let glow = SKAction.run { [weak background] in
            background?.glowWidth = 5
        }
        let removeGlow = SKAction.run { [weak background] in
            background?.glowWidth = 0
        }
        background.run(SKAction.sequence([glow, SKAction.wait(forDuration: 0.3), removeGlow]))
    }
    
    /// Show round end message with celebration effects
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        guard let label = statusLabel, let background = statusBackground else { return }
        
        let messageText: String
        let isWinner: Bool
        
        if let winner = winner {
            if winner == localPlayerIndex {
                messageText = "🏆 You Win! 🏆"
                isWinner = true
            } else {
                messageText = "Player \(winner + 1) Wins!"
                isWinner = false
            }
        } else {
            messageText = "🤝 Draw! 🤝"
            isWinner = false
        }
        
        // Update text
        label.text = messageText
        label.fontSize = 18
        
        // Expand background
        let expandWidth = SKAction.resize(toWidth: 250, duration: 0.2)
        background.run(expandWidth)
        
        if isWinner {
            // Winner celebration - golden glow and pulse
            background.strokeColor = Colors.winnerGlow
            background.glowWidth = 8
            
            let colorCycle = createGoldenGlowAnimation()
            background.run(colorCycle, withKey: "winnerGlow")
            
            // Confetti-like particles
            spawnCelebrationParticles()
        } else {
            background.strokeColor = Colors.loserGlow
        }
        
        // Schedule reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.resetRoundEndDisplay()
        }
    }
    
    private func createGoldenGlowAnimation() -> SKAction {
        let colors: [SKColor] = [
            SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0),
            SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0),
            SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        ]
        
        var colorActions: [SKAction] = []
        for color in colors {
            let action = SKAction.run { [weak self] in
                self?.statusBackground?.strokeColor = color
            }
            colorActions.append(action)
            colorActions.append(SKAction.wait(forDuration: 0.2))
        }
        
        return SKAction.repeatForever(SKAction.sequence(colorActions))
    }
    
    private func spawnCelebrationParticles() {
        guard let container = statusContainer else { return }
        
        for _ in 0..<10 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = [SKColor.yellow, SKColor.orange, SKColor.red, SKColor.green].randomElement() ?? .yellow
            particle.strokeColor = .clear
            particle.position = CGPoint(
                x: CGFloat.random(in: -100...100),
                y: 0
            )
            particle.zPosition = -1
            container.addChild(particle)
            
            // Animate particle
            let moveUp = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: 50...100), duration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -.pi...CGFloat.pi), duration: 1.0)
            let group = SKAction.group([moveUp, fadeOut, rotate])
            let remove = SKAction.removeFromParent()
            
            particle.run(SKAction.sequence([group, remove]))
        }
    }
    
    private func resetRoundEndDisplay() {
        guard let label = statusLabel, let background = statusBackground else { return }
        
        background.removeAction(forKey: "winnerGlow")
        
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
        let reset = SKAction.run { [weak label, weak background] in
            label?.text = "Next round starting..."
            label?.fontSize = 16
            background?.strokeColor = SKColor.white.withAlphaComponent(0.2)
            background?.glowWidth = 0
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let resize = SKAction.resize(toWidth: 200, duration: 0.2)
        
        label.run(SKAction.sequence([fadeOut, reset, fadeIn]))
        background.run(resize)
    }
}
