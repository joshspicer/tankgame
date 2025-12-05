//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI and interactions
class FireButton {
    private var buttonNode: SKNode?
    private var buttonBase: SKShapeNode?
    private var buttonGlow: SKShapeNode?
    private var buttonRing: SKShapeNode?
    private var fireLabel: SKLabelNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button
    func setup(in scene: SKScene, at position: CGPoint) {
        let containerNode = SKNode()
        containerNode.position = position
        containerNode.zPosition = 100
        scene.addChild(containerNode)
        buttonNode = containerNode
        
        let buttonRadius = GameTheme.Dimensions.fireButtonRadius
        let glowRadius = GameTheme.Dimensions.fireButtonGlowRadius
        
        // Outer glow
        let newButtonGlow = SKShapeNode(circleOfRadius: glowRadius)
        newButtonGlow.fillColor = GameTheme.Colors.fireButtonGlow
        newButtonGlow.strokeColor = .clear
        newButtonGlow.alpha = 0.4
        newButtonGlow.zPosition = -2
        containerNode.addChild(newButtonGlow)
        buttonGlow = newButtonGlow
        
        // Outer ring
        let newButtonRing = SKShapeNode(circleOfRadius: buttonRadius + 3)
        newButtonRing.fillColor = .clear
        newButtonRing.strokeColor = GameTheme.Colors.danger.withAlphaComponent(0.5)
        newButtonRing.lineWidth = 2
        newButtonRing.glowWidth = 3
        newButtonRing.zPosition = -1
        containerNode.addChild(newButtonRing)
        buttonRing = newButtonRing
        
        // Button shadow
        let shadowButton = SKShapeNode(circleOfRadius: buttonRadius + 2)
        shadowButton.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadowButton.strokeColor = .clear
        shadowButton.position = CGPoint(x: 2, y: -2)
        containerNode.addChild(shadowButton)
        
        // Main button
        let newFireButton = SKShapeNode(circleOfRadius: buttonRadius)
        newFireButton.fillColor = GameTheme.Colors.fireButtonBase
        newFireButton.strokeColor = GameTheme.Colors.fireButtonHighlight.withAlphaComponent(0.7)
        newFireButton.lineWidth = 3
        newFireButton.glowWidth = 2
        newFireButton.alpha = 0.95
        containerNode.addChild(newFireButton)
        buttonBase = newFireButton
        
        // Inner highlight for 3D effect
        let innerHighlight = SKShapeNode(circleOfRadius: buttonRadius * 0.7)
        innerHighlight.fillColor = GameTheme.Colors.fireButtonHighlight.withAlphaComponent(0.3)
        innerHighlight.strokeColor = .clear
        innerHighlight.position = CGPoint(x: -4, y: 4)
        newFireButton.addChild(innerHighlight)
        
        // Fire label
        let newFireLabel = SKLabelNode(fontNamed: GameTheme.Fonts.titleFont)
        newFireLabel.text = "FIRE"
        newFireLabel.fontSize = 15
        newFireLabel.fontColor = GameTheme.Colors.textPrimary
        newFireLabel.verticalAlignmentMode = .center
        newFireLabel.horizontalAlignmentMode = .center
        newFireLabel.zPosition = 1
        containerNode.addChild(newFireLabel)
        fireLabel = newFireLabel
        
        // Add pulsing glow animation
        addGlowAnimation()
    }
    
    /// Add pulsing glow animation to the fire button
    private func addGlowAnimation() {
        guard let glow = buttonGlow else { return }
        
        let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: GameTheme.Animations.pulseSpeed)
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: GameTheme.Animations.pulseSpeed)
        fadeIn.timingMode = .easeInEaseOut
        fadeOut.timingMode = .easeInEaseOut
        let pulseSequence = SKAction.sequence([fadeIn, fadeOut])
        let repeatPulse = SKAction.repeatForever(pulseSequence)
        glow.run(repeatPulse)
        
        // Subtle scale pulse for the ring
        guard let ring = buttonRing else { return }
        let scaleUp = SKAction.scale(to: 1.05, duration: GameTheme.Animations.pulseSpeed * 0.8)
        let scaleDown = SKAction.scale(to: 1.0, duration: GameTheme.Animations.pulseSpeed * 0.8)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatScale = SKAction.repeatForever(scaleSequence)
        ring.run(repeatScale)
    }
    
    /// Animate button press
    private func animatePress() {
        guard let button = buttonBase, let glow = buttonGlow else { return }
        
        // Scale down quickly
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        scaleUp.timingMode = .easeOut
        let scaleSequence = SKAction.sequence([scaleDown, scaleUp])
        button.run(scaleSequence)
        
        // Flash the glow
        let flashUp = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        let flashDown = SKAction.fadeAlpha(to: 0.4, duration: 0.15)
        let flashSequence = SKAction.sequence([flashUp, flashDown])
        glow.run(flashSequence)
        
        // Brief color flash on button
        let originalColor = button.fillColor
        button.fillColor = GameTheme.Colors.fireButtonHighlight
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak button] in
            button?.fillColor = originalColor
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
        
        let hitRadius = GameTheme.Dimensions.fireButtonRadius + 15 // Slightly larger hit area
        if distance < hitRadius {
            animatePress()
            onTap?()
            return true
        }
        
        return false
    }
    #endif
}
