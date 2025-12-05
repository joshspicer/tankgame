//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI and interactions with premium styling
class FireButton {
    private var buttonNode: SKNode?
    private var buttonBackground: SKShapeNode?
    private var buttonRing: SKShapeNode?
    private var glowNode: SKEffectNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button with premium visual design
    func setup(in scene: SKScene, at position: CGPoint) {
        // Create container node
        let containerNode = SKNode()
        containerNode.position = position
        scene.addChild(containerNode)
        buttonNode = containerNode
        
        // Outer glow ring
        let outerGlow = SKShapeNode(circleOfRadius: 52)
        outerGlow.fillColor = .clear
        outerGlow.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.3)
        outerGlow.lineWidth = 4
        outerGlow.glowWidth = 8
        containerNode.addChild(outerGlow)
        
        // Animated ring
        let ring = SKShapeNode(circleOfRadius: 46)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.6)
        ring.lineWidth = 2
        containerNode.addChild(ring)
        buttonRing = ring
        
        // Add rotation animation to ring
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
        ring.run(SKAction.repeatForever(rotateAction))
        
        // Main button background with gradient effect
        let mainButton = SKShapeNode(circleOfRadius: 42)
        mainButton.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        mainButton.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        mainButton.lineWidth = 3
        containerNode.addChild(mainButton)
        buttonBackground = mainButton
        
        // Inner highlight
        let highlight = SKShapeNode(circleOfRadius: 28)
        highlight.position = CGPoint(x: 0, y: 6)
        highlight.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.4)
        highlight.strokeColor = .clear
        containerNode.addChild(highlight)
        
        // Add fire icon/label
        let fireLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 14
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireLabel.horizontalAlignmentMode = .center
        fireLabel.position = CGPoint(x: 0, y: 0)
        fireLabel.zPosition = 1
        containerNode.addChild(fireLabel)
        
        // Add crosshair icon
        let crosshair = SKLabelNode(text: "⊕")
        crosshair.fontSize = 12
        crosshair.fontColor = SKColor(white: 1.0, alpha: 0.6)
        crosshair.verticalAlignmentMode = .center
        crosshair.position = CGPoint(x: 0, y: -14)
        crosshair.zPosition = 1
        containerNode.addChild(crosshair)
        
        // Add subtle pulse animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.8)
        let scaleDown = SKAction.scale(to: 0.98, duration: 0.8)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        containerNode.run(SKAction.repeatForever(pulse))
    }
    
    /// Get the button's position
    var position: CGPoint {
        return buttonNode?.position ?? .zero
    }
    
    /// Animate button press
    private func animatePress() {
        guard let button = buttonBackground else { return }
        
        // Flash and scale animation
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let flash = SKAction.sequence([
            SKAction.run { button.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0) },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { button.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0) }
        ])
        
        buttonNode?.run(SKAction.sequence([scaleDown, scaleUp]))
        button.run(flash)
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
            animatePress()
            onTap?()
            return true
        }
        
        return false
    }
    #endif
}
