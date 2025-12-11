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
    
    // Constants
    private let buttonRadius: CGFloat = 35
    private let touchRadius: CGFloat = 45
    
    init() {}
    
    /// Setup the fire button
    func setup(in scene: SKScene, at position: CGPoint) {
        let newFireButton = SKShapeNode(circleOfRadius: buttonRadius)
        newFireButton.position = position
        newFireButton.fillColor = .red
        newFireButton.strokeColor = .clear
        newFireButton.lineWidth = 0
        newFireButton.alpha = 0.6
        scene.addChild(newFireButton)
        buttonNode = newFireButton
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
        
        if distance < touchRadius {
            onTap?()
            return true
        }
        
        return false
    }
    #endif
}
