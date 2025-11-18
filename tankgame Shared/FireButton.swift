//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the fire button UI and interactions
/// Allows players to shoot projectiles
final class FireButton {
    // MARK: - Properties
    
    /// The visual button node
    private var buttonNode: SKShapeNode?
    
    /// Callback invoked when the button is tapped
    var onTap: (() -> Void)?
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Setup
    
    /// Sets up the fire button in the scene
    /// - Parameters:
    ///   - scene: Scene to add the button to
    ///   - position: Position for the button center
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
    
    // MARK: - Position
    
    /// Gets the position of the button
    var position: CGPoint {
        return buttonNode?.position ?? .zero
    }
    
    #if os(iOS) || os(tvOS)
    // MARK: - Touch Handling
    
    /// Checks if a touch is within the fire button and triggers the tap callback
    /// - Parameter location: Touch location in scene coordinates
    /// - Returns: true if touch was handled by the button, false otherwise
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
