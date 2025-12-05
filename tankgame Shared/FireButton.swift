//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI and interactions with modern styling
class FireButton {
    private var buttonNode: SKNode?
    private var buttonBackground: SKShapeNode?
    private var buttonGlow: SKShapeNode?
    private var pulseAction: SKAction?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let containerNode = SKNode()
        containerNode.position = position
        containerNode.zPosition = 100
        scene.addChild(containerNode)
        buttonNode = containerNode
        
        // Outer glow ring
        let glow = SKShapeNode(circleOfRadius: 48)
        glow.fillColor = UXTheme.fireButtonGlow
        glow.strokeColor = .clear
        glow.alpha = 0.4
        glow.zPosition = -1
        containerNode.addChild(glow)
        buttonGlow = glow
        
        // Pulse animation for glow
        let pulseUp = SKAction.scale(to: 1.15, duration: 0.8)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.8)
        let fadeUp = SKAction.fadeAlpha(to: 0.6, duration: 0.8)
        let fadeDown = SKAction.fadeAlpha(to: 0.3, duration: 0.8)
        let pulseSequence = SKAction.sequence([
            SKAction.group([pulseUp, fadeUp]),
            SKAction.group([pulseDown, fadeDown])
        ])
        glow.run(SKAction.repeatForever(pulseSequence))
        
        // Main button background
        let background = SKShapeNode(circleOfRadius: 42)
        background.fillColor = UXTheme.fireButton
        background.strokeColor = SKColor.white.withAlphaComponent(0.3)
        background.lineWidth = 3
        containerNode.addChild(background)
        buttonBackground = background
        
        // Inner highlight (3D effect)
        let highlight = SKShapeNode(circleOfRadius: 32)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.15)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -4, y: 4)
        containerNode.addChild(highlight)
        
        // Fire icon container
        let iconContainer = SKNode()
        containerNode.addChild(iconContainer)
        
        // Fire crosshair design
        createCrosshairIcon(in: iconContainer)
        
        // Fire label
        let fireLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 13
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireLabel.position = CGPoint(x: 0, y: -20)
        containerNode.addChild(fireLabel)
    }
    
    /// Create a stylized crosshair icon
    private func createCrosshairIcon(in node: SKNode) {
        let color = SKColor.white
        let lineWidth: CGFloat = 3
        let size: CGFloat = 16
        
        // Center dot
        let centerDot = SKShapeNode(circleOfRadius: 3)
        centerDot.fillColor = color
        centerDot.strokeColor = .clear
        centerDot.position = CGPoint(x: 0, y: 6)
        node.addChild(centerDot)
        
        // Crosshair lines
        let directions: [(CGFloat, CGFloat)] = [(0, 1), (0, -1), (-1, 0), (1, 0)]
        for (dx, dy) in directions {
            let line = SKSpriteNode(color: color, size: CGSize(width: lineWidth, height: size * 0.5))
            line.position = CGPoint(x: dx * (size * 0.5 + 4), y: dy * (size * 0.5 + 4) + 6)
            line.zRotation = atan2(dy, dx) - .pi / 2
            node.addChild(line)
        }
    }
    
    /// Get the button's position
    var position: CGPoint {
        return buttonNode?.position ?? .zero
    }
    
    #if os(iOS) || os(tvOS)
    /// Check if a touch is within the fire button and handle it
    /// - Returns: true if touch was handled by button
    func handleTouch(at location: CGPoint) -> Bool {
        guard let button = buttonNode else { return false }
        
        let dx = location.x - button.position.x
        let dy = location.y - button.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < 55 {
            // Visual feedback - press animation
            animatePress()
            onTap?()
            return true
        }
        
        return false
    }
    
    /// Animate button press
    private func animatePress() {
        guard let button = buttonNode, let background = buttonBackground, let glow = buttonGlow else { return }
        
        // Scale down quickly
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        scaleUp.timingMode = .easeOut
        
        // Flash effect
        let flashUp = SKAction.run { [weak background] in
            background?.fillColor = SKColor.white
        }
        let flashDown = SKAction.run { [weak background] in
            background?.fillColor = UXTheme.fireButton
        }
        let flashWait = SKAction.wait(forDuration: 0.05)
        
        // Glow burst
        let glowBurst = SKAction.scale(to: 1.5, duration: 0.1)
        let glowReturn = SKAction.scale(to: 1.0, duration: 0.2)
        let glowFade = SKAction.fadeAlpha(to: 0.8, duration: 0.1)
        let glowNormal = SKAction.fadeAlpha(to: 0.4, duration: 0.2)
        
        button.run(SKAction.sequence([scaleDown, scaleUp]))
        background.run(SKAction.sequence([flashUp, flashWait, flashDown]))
        glow.run(SKAction.sequence([
            SKAction.group([glowBurst, glowFade]),
            SKAction.group([glowReturn, glowNormal])
        ]))
    }
    #endif
}
