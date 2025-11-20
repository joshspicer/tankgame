//
//  RunButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the run button UI and interactions
class RunButton {
    private var buttonNode: SKShapeNode?
    var isPressed: Bool = false
    
    init() {}
    
    /// Setup the run button
    func setup(in scene: SKScene, at position: CGPoint) {
        let newRunButton = SKShapeNode(circleOfRadius: 40)
        newRunButton.position = position
        newRunButton.fillColor = .green
        newRunButton.strokeColor = .white
        newRunButton.lineWidth = 3
        newRunButton.alpha = 0.7
        scene.addChild(newRunButton)
        buttonNode = newRunButton
        
        // Add run label
        let runLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        runLabel.text = "RUN"
        runLabel.fontSize = 14
        runLabel.fontColor = .white
        runLabel.verticalAlignmentMode = .center
        newRunButton.addChild(runLabel)
    }
    
    /// Get the button's position
    var position: CGPoint {
        return buttonNode?.position ?? .zero
    }
    
    #if os(iOS) || os(tvOS)
    /// Handle touch began on the run button
    /// - Returns: true if touch was handled by button
    func handleTouchBegan(at location: CGPoint) -> Bool {
        guard let button = buttonNode else { return false }
        
        let dx = location.x - button.position.x
        let dy = location.y - button.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < 50 {
            isPressed = true
            buttonNode?.alpha = 1.0
            return true
        }
        
        return false
    }
    
    /// Handle touch ended on the run button
    /// - Returns: true if this was the run button being released
    func handleTouchEnded(at location: CGPoint) -> Bool {
        guard let button = buttonNode else { return false }
        
        let dx = location.x - button.position.x
        let dy = location.y - button.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if isPressed {
            isPressed = false
            buttonNode?.alpha = 0.7
            return distance < 50
        }
        
        return false
    }
    #endif
}
