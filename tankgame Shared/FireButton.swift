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
    
    /// Setup the fire button with classic clean styling
    func setup(in scene: SKScene, at position: CGPoint) {
        // Classic simple fire button - clean solid design
        let newFireButton = SKShapeNode(circleOfRadius: 35)
        newFireButton.position = position
        newFireButton.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        newFireButton.strokeColor = SKColor(white: 0.9, alpha: 1.0)
        newFireButton.lineWidth = 3
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Simple fire label - clean retro font
        let fireLabel = SKLabelNode(fontNamed: "Courier-Bold")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 12
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
