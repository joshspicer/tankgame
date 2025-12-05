//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI and interactions with classic retro styling
class FireButton {
    private var buttonNode: SKShapeNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button with retro style
    func setup(in scene: SKScene, at position: CGPoint) {
        let newFireButton = SKShapeNode(circleOfRadius: 40)
        newFireButton.position = position
        newFireButton.fillColor = RetroColors.fireButton
        newFireButton.strokeColor = RetroColors.fireButtonBorder
        newFireButton.lineWidth = 3
        newFireButton.alpha = 0.85
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Add fire label with retro font
        let fireLabel = SKLabelNode(fontNamed: RetroFonts.button)
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 14
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        newFireButton.addChild(fireLabel)
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
