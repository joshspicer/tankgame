//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI and interactions with modern styling
class FireButton {
    private var buttonNode: SKShapeNode?
    private var innerGlow: SKShapeNode?
    private var outerGlow: SKShapeNode?
    private var iconNode: SKLabelNode?
    var onTap: (() -> Void)?
    
    // Modern styling colors
    private let buttonColor = SKColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 1.0)
    private let glowColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.4)
    private let highlightColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
    
    init() {}
    
    /// Setup the fire button with modern glassmorphism style
    func setup(in scene: SKScene, at position: CGPoint) {
        // Outer glow effect
        let newOuterGlow = SKShapeNode(circleOfRadius: 55)
        newOuterGlow.fillColor = glowColor
        newOuterGlow.strokeColor = .clear
        newOuterGlow.position = position
        newOuterGlow.zPosition = -1
        scene.addChild(newOuterGlow)
        outerGlow = newOuterGlow
        
        // Pulse animation for outer glow
        let pulseOut = SKAction.scale(to: 1.15, duration: 0.8)
        let pulseIn = SKAction.scale(to: 1.0, duration: 0.8)
        pulseOut.timingMode = .easeInEaseOut
        pulseIn.timingMode = .easeInEaseOut
        let pulseSequence = SKAction.sequence([pulseOut, pulseIn])
        newOuterGlow.run(SKAction.repeatForever(pulseSequence))
        
        // Main button
        let newFireButton = SKShapeNode(circleOfRadius: 44)
        newFireButton.position = position
        newFireButton.fillColor = buttonColor
        newFireButton.strokeColor = SKColor.white.withAlphaComponent(0.7)
        newFireButton.lineWidth = 3
        newFireButton.glowWidth = 5
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Inner highlight ring for depth
        let innerHighlight = SKShapeNode(circleOfRadius: 36)
        innerHighlight.fillColor = .clear
        innerHighlight.strokeColor = SKColor.white.withAlphaComponent(0.15)
        innerHighlight.lineWidth = 2
        newFireButton.addChild(innerHighlight)
        
        // Inner glow for 3D effect
        let newInnerGlow = SKShapeNode(circleOfRadius: 28)
        newInnerGlow.fillColor = highlightColor.withAlphaComponent(0.4)
        newInnerGlow.strokeColor = .clear
        newInnerGlow.position = CGPoint(x: -4, y: 4)
        newFireButton.addChild(newInnerGlow)
        innerGlow = newInnerGlow
        
        // Fire icon/label
        let fireIcon = SKLabelNode(fontNamed: "Helvetica-Bold")
        fireIcon.text = "🔥"
        fireIcon.fontSize = 28
        fireIcon.verticalAlignmentMode = .center
        fireIcon.horizontalAlignmentMode = .center
        newFireButton.addChild(fireIcon)
        iconNode = fireIcon
        
        // FIRE text below icon
        let fireLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 11
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireLabel.position = CGPoint(x: 0, y: -18)
        newFireButton.addChild(fireLabel)
        
        // Idle breathing animation
        let breatheIn = SKAction.scale(to: 1.03, duration: 1.2)
        let breatheOut = SKAction.scale(to: 1.0, duration: 1.2)
        breatheIn.timingMode = .easeInEaseOut
        breatheOut.timingMode = .easeInEaseOut
        let breatheSequence = SKAction.sequence([breatheIn, breatheOut])
        newFireButton.run(SKAction.repeatForever(breatheSequence))
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
            // Trigger tap animation
            animateTap()
            onTap?()
            return true
        }
        
        return false
    }
    
    /// Animate button tap with visual feedback
    private func animateTap() {
        guard let button = buttonNode else { return }
        
        // Scale down then up
        let scaleDown = SKAction.scale(to: 0.85, duration: 0.08)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.15)
        scaleDown.timingMode = .easeIn
        scaleUp.timingMode = .easeOut
        
        // Flash effect
        let originalColor = buttonColor
        let flashColor = SKColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0)
        
        let flash = SKAction.run { [weak self] in
            self?.buttonNode?.fillColor = flashColor
        }
        let unflash = SKAction.run { [weak self] in
            self?.buttonNode?.fillColor = originalColor
        }
        
        // Outer glow burst
        let glowBurst = SKAction.scale(to: 1.4, duration: 0.1)
        let glowReturn = SKAction.scale(to: 1.0, duration: 0.2)
        glowBurst.timingMode = .easeOut
        glowReturn.timingMode = .easeInEaseOut
        
        let tapSequence = SKAction.sequence([flash, scaleDown, SKAction.group([scaleUp, unflash])])
        button.run(tapSequence)
        
        outerGlow?.run(SKAction.sequence([glowBurst, glowReturn]))
        
        // Icon pop animation
        let iconPop = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])
        iconNode?.run(iconPop)
    }
    #endif
}
