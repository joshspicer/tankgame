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
    private var outerRing: SKShapeNode?
    private var innerCircle: SKShapeNode?
    private var buttonLabel: SKLabelNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button with modern design
    func setup(in scene: SKScene, at position: CGPoint) {
        let container = SKNode()
        container.position = position
        scene.addChild(container)
        buttonNode = container
        
        // Outer glow ring
        let glowRing = SKShapeNode(circleOfRadius: 52)
        glowRing.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.2)
        glowRing.strokeColor = .clear
        glowRing.zPosition = -1
        container.addChild(glowRing)
        
        // Pulsing animation for glow
        let pulseUp = SKAction.scale(to: 1.15, duration: 0.8)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.8)
        pulseUp.timingMode = .easeInEaseOut
        pulseDown.timingMode = .easeInEaseOut
        let pulse = SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown]))
        glowRing.run(pulse)
        
        // Outer ring (border)
        let ring = SKShapeNode(circleOfRadius: 44)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.8)
        ring.lineWidth = 3
        container.addChild(ring)
        outerRing = ring
        
        // Inner filled circle with gradient effect (simulated)
        let inner = SKShapeNode(circleOfRadius: 38)
        inner.fillColor = SKColor(red: 0.9, green: 0.15, blue: 0.1, alpha: 1.0)
        inner.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1.0)
        inner.lineWidth = 2
        container.addChild(inner)
        innerCircle = inner
        
        // Inner highlight (gives 3D effect)
        let highlight = SKShapeNode(circleOfRadius: 30)
        highlight.fillColor = SKColor(red: 1.0, green: 0.35, blue: 0.25, alpha: 0.6)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -4, y: 4)
        container.addChild(highlight)
        
        // Fire label with icon (use Helvetica Neue as reliable fallback)
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "FIRE"
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -1)
        container.addChild(label)
        buttonLabel = label
        
        // Small crosshair icon above text
        let crosshair = SKLabelNode(text: "🎯")
        crosshair.fontSize = 10
        crosshair.position = CGPoint(x: 0, y: 12)
        crosshair.verticalAlignmentMode = .center
        container.addChild(crosshair)
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
            onTap?()
            animatePress()
            return true
        }
        
        return false
    }
    
    /// Animate button press
    private func animatePress() {
        guard let inner = innerCircle, let ring = outerRing else { return }
        
        // Scale down then up with spring effect
        let scaleDown = SKAction.scale(to: 0.85, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.15)
        scaleUp.timingMode = .easeOut
        
        // Color flash
        let originalColor = inner.fillColor
        let flashColor = SKColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0)
        let colorFlash = SKAction.run { inner.fillColor = flashColor }
        let colorRestore = SKAction.run { inner.fillColor = originalColor }
        let colorWait = SKAction.wait(forDuration: 0.1)
        
        inner.run(SKAction.sequence([scaleDown, scaleUp]))
        inner.run(SKAction.sequence([colorFlash, colorWait, colorRestore]))
        ring.run(SKAction.sequence([scaleDown, scaleUp]))
    }
    #endif
}
