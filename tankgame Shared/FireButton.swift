//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI and interactions
class FireButton {
    private var buttonNode: SKShapeNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        // Modern styled fire button
        let newFireButton = SKShapeNode(circleOfRadius: 45)
        newFireButton.position = position
        newFireButton.fillColor = SKColor(red: 0.85, green: 0.18, blue: 0.18, alpha: 0.95)
        newFireButton.strokeColor = SKColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 0.95)
        newFireButton.lineWidth = 3
        newFireButton.glowWidth = 8
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Inner glow ring
        let innerRing = SKShapeNode(circleOfRadius: 32)
        innerRing.fillColor = .clear
        innerRing.strokeColor = SKColor(red: 1.0, green: 0.55, blue: 0.55, alpha: 0.5)
        innerRing.lineWidth = 2
        newFireButton.addChild(innerRing)
        
        // Crosshair decoration
        let crosshairSize: CGFloat = 18
        let verticalLine = SKSpriteNode(color: SKColor(white: 1, alpha: 0.5), size: CGSize(width: 2, height: crosshairSize * 2))
        let horizontalLine = SKSpriteNode(color: SKColor(white: 1, alpha: 0.5), size: CGSize(width: crosshairSize * 2, height: 2))
        verticalLine.position = CGPoint(x: 0, y: 5)
        horizontalLine.position = CGPoint(x: 0, y: 5)
        newFireButton.addChild(verticalLine)
        newFireButton.addChild(horizontalLine)
        
        // Fire label with modern font
        let fireLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 12
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireLabel.position = CGPoint(x: 0, y: -20)
        newFireButton.addChild(fireLabel)
        
        // Add pulsing animation
        let scaleUp = SKAction.scale(to: 1.06, duration: 0.6)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.6)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        newFireButton.run(SKAction.repeatForever(pulse))
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
        
        if distance < 50 {
            onTap?()
            return true
        }
        
        return false
    }
    #endif
}
