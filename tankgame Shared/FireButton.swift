//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI and interactions
class FireButton {
    private static let buttonRadius: CGFloat = 40
    private static let touchRadius: CGFloat = 50
    private static let strokeWidth: CGFloat = 3
    private static let buttonAlpha: CGFloat = 0.7
    
    private var buttonNode: SKShapeNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button
    func setup(in scene: SKScene, at position: CGPoint) {
        let newFireButton = SKShapeNode(circleOfRadius: Self.buttonRadius)
        newFireButton.position = position
        newFireButton.fillColor = .red
        newFireButton.strokeColor = .white
        newFireButton.lineWidth = Self.strokeWidth
        newFireButton.alpha = Self.buttonAlpha
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
    /// Check if a touch is within the fire button and handle it
    /// - Returns: true if touch was handled by button
    func handleTouch(at location: CGPoint) -> Bool {
        guard let button = buttonNode else { return false }
        
        let dx = location.x - button.position.x
        let dy = location.y - button.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < Self.touchRadius {
            onTap?()
            return true
        }
        
        return false
    }
    #endif
}
