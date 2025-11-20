//
//  FireButton.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

#if os(iOS)
import UIKit
#endif

/// Manages the fire button UI and interactions
class FireButton {
    private var buttonNode: SKShapeNode?
    private var isPressed = false
    var onTap: (() -> Void)?
    
    #if os(iOS)
    // Haptic feedback generator (reused for efficiency)
    private var impactFeedback: UIImpactFeedbackGenerator?
    #endif
    
    init() {
        #if os(iOS)
        impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        #endif
    }
    
    /// Setup the fire button
    func setup(in scene: SKScene, at position: CGPoint) {
        let newFireButton = SKShapeNode(circleOfRadius: 50)
        newFireButton.position = position
        newFireButton.fillColor = .red
        newFireButton.strokeColor = .white
        newFireButton.lineWidth = 4
        newFireButton.alpha = 0.8
        scene.addChild(newFireButton)
        buttonNode = newFireButton
        
        // Add fire label
        let fireLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 16
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
        
        // Larger hit area (60 points) for easier tapping
        if distance < 60 {
            // Trigger haptic feedback
            #if os(iOS)
            impactFeedback?.impactOccurred()
            #endif
            
            // Visual feedback animation
            animatePress()
            onTap?()
            return true
        }
        
        return false
    }
    
    /// Animate button press for visual feedback
    private func animatePress() {
        guard let button = buttonNode, !isPressed else { return }
        
        isPressed = true
        
        // Scale down animation
        let scaleDown = SKAction.scale(to: 0.85, duration: 0.08)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.08)
        let brighten = SKAction.run {
            button.alpha = 1.0
        }
        let dim = SKAction.run { [weak self] in
            button.alpha = 0.8
            self?.isPressed = false
        }
        
        let sequence = SKAction.sequence([scaleDown, brighten, scaleUp, dim])
        button.run(sequence)
    }
    #endif
}
