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
    private var isPressed = false
    
    init() {}
    
    /// Setup the fire button
    func setup(in scene: SKScene, at position: CGPoint) {
        let newFireButton = SKShapeNode(circleOfRadius: 40)
        newFireButton.position = position
        newFireButton.fillColor = .red
        newFireButton.strokeColor = .white
        newFireButton.lineWidth = 3
        newFireButton.alpha = 0.7
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Add fire label
        let fireLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
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
    /// Check if a touch began within the fire button
    /// - Returns: true if touch was handled by button
    func handleTouchBegan(at location: CGPoint) -> Bool {
        guard let button = buttonNode else { return false }
        
        let dx = location.x - button.position.x
        let dy = location.y - button.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < 50 {
            isPressed = true
            // Visual feedback: make button brighter when pressed
            button.alpha = 1.0
            return true
        }
        
        return false
    }
    
    /// Check if a touch ended within the fire button and fire if it was pressed
    /// - Returns: true if touch was handled by button
    func handleTouchEnded(at location: CGPoint) -> Bool {
        guard let button = buttonNode else { return false }
        
        // Reset visual state
        button.alpha = 0.7
        
        if isPressed {
            isPressed = false
            
            // Check if release was still within button area
            let dx = location.x - button.position.x
            let dy = location.y - button.position.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance < 50 {
                onTap?()
                return true
            }
        }
        
        return false
    }
    
    /// Reset button state (for touch cancelled)
    func reset() {
        isPressed = false
        buttonNode?.alpha = 0.7
    }
    #endif
}
