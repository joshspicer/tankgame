//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI with modern styling and interactions
class FireButton {
    private var buttonNode: SKShapeNode?
    private var innerGlow: SKShapeNode?
    private var fireLabel: SKLabelNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        // Create outer ring with gradient effect
        let newFireButton = SKShapeNode(circleOfRadius: 44)
        newFireButton.position = position
        newFireButton.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        newFireButton.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        newFireButton.lineWidth = 4
        newFireButton.alpha = 0.9
        newFireButton.zPosition = 200
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Add inner glow ring
        let glow = SKShapeNode(circleOfRadius: 36)
        glow.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.5)
        glow.strokeColor = .clear
        glow.zPosition = 1
        newFireButton.addChild(glow)
        innerGlow = glow
        
        // Add pulsing animation to inner glow
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.5)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        glow.run(SKAction.repeatForever(pulse))
        
        // Add fire label with modern styling
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "FIRE"
        label.fontSize = 15
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 2
        newFireButton.addChild(label)
        fireLabel = label
        
        // Add crosshair icon
        let crosshair = createCrosshair()
        crosshair.position = CGPoint(x: 0, y: 18)
        crosshair.zPosition = 2
        newFireButton.addChild(crosshair)
        
        // Add subtle rotation animation
        let rotateRight = SKAction.rotate(byAngle: 0.05, duration: 1.0)
        let rotateLeft = SKAction.rotate(byAngle: -0.05, duration: 1.0)
        let sway = SKAction.sequence([rotateRight, rotateLeft])
        newFireButton.run(SKAction.repeatForever(sway))
    }
    
    /// Create crosshair decoration
    private func createCrosshair() -> SKNode {
        let crosshairNode = SKNode()
        
        // Horizontal line
        let hLine = SKSpriteNode(color: .white, size: CGSize(width: 16, height: 2))
        hLine.alpha = 0.8
        crosshairNode.addChild(hLine)
        
        // Vertical line
        let vLine = SKSpriteNode(color: .white, size: CGSize(width: 2, height: 16))
        vLine.alpha = 0.8
        crosshairNode.addChild(vLine)
        
        // Center dot
        let dot = SKShapeNode(circleOfRadius: 2)
        dot.fillColor = .white
        dot.strokeColor = .clear
        dot.alpha = 0.9
        crosshairNode.addChild(dot)
        
        return crosshairNode
    }
    
    /// Get the button's position
    var position: CGPoint {
        return buttonNode?.position ?? .zero
    }
    
    /// Animate button press feedback
    private func animatePress() {
        guard let button = buttonNode else { return }
        
        // Quick scale animation
        let pressDown = SKAction.scale(to: 0.9, duration: 0.05)
        let pressUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([pressDown, pressUp])
        button.run(sequence)
        
        // Flash effect
        let flash = SKAction.sequence([
            SKAction.run { [weak button] in
                button?.fillColor = SKColor.white
            },
            SKAction.wait(forDuration: 0.05),
            SKAction.run { [weak button] in
                button?.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
            }
        ])
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
