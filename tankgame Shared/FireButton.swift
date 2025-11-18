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
    private var cooldownOverlay: SKShapeNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button
    func setup(in scene: SKScene, at position: CGPoint) {
        let newFireButton = SKShapeNode(circleOfRadius: 40)
        newFireButton.position = position
        newFireButton.fillColor = .red
        newFireButton.strokeColor = .white
        newFireButton.lineWidth = 3
        newFireButton.alpha = 0.7
        newFireButton.zPosition = 0
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Setup cooldown overlay (initially hidden) - between button and label
        let overlay = SKShapeNode(circleOfRadius: 40)
        overlay.fillColor = .black
        overlay.strokeColor = .clear
        overlay.alpha = 0
        overlay.zPosition = 1
        newFireButton.addChild(overlay)
        cooldownOverlay = overlay
        
        // Add fire label on top
        let fireLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 14
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireLabel.zPosition = 2
        newFireButton.addChild(fireLabel)
    }
    
    /// Get the button's position
    var position: CGPoint {
        return buttonNode?.position ?? .zero
    }
    
    /// Update cooldown visual indicator
    /// - Parameter progress: Progress from 0 (ready) to 1 (just shot)
    func updateCooldown(progress: CGFloat) {
        guard let overlay = cooldownOverlay else { return }
        
        if progress > 0 {
            // Show cooldown overlay with opacity based on progress
            overlay.alpha = 0.6 * progress
        } else {
            // Hide overlay when ready
            overlay.alpha = 0
        }
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
