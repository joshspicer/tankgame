//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI - clean retro style
class FireButton {
    private var buttonNode: SKShapeNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button with retro styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let newFireButton = SKShapeNode(circleOfRadius: RetroTheme.Dimensions.fireButtonRadius)
        newFireButton.position = position
        newFireButton.fillColor = RetroTheme.Colors.fireButton
        newFireButton.strokeColor = RetroTheme.Colors.text
        newFireButton.lineWidth = RetroTheme.Dimensions.borderWidth
        newFireButton.alpha = RetroTheme.Dimensions.controlOpacity
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Add fire label with retro font
        let fireLabel = SKLabelNode(fontNamed: RetroTheme.Fonts.primary)
        fireLabel.text = "FIRE"
        fireLabel.fontSize = RetroTheme.Fonts.smallSize
        fireLabel.fontColor = RetroTheme.Colors.text
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
