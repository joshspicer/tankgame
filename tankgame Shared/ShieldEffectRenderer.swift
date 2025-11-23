//
//  ShieldEffectRenderer.swift
//  tankgame Shared
//
//  Created by agent on 11/23/25.
//

import SpriteKit

/// Handles rendering of shield visual effects on tanks
class ShieldEffectRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a shield effect node for a tank
    func createShieldEffect() -> SKShapeNode {
        let shield = SKShapeNode(circleOfRadius: tileSize * 0.45)
        shield.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.8)
        shield.fillColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.2)
        shield.lineWidth = 3
        shield.zPosition = 10
        shield.name = "shield" // Tag for easy identification
        
        // Add pulsing animation to shield
        let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
        let pulse = SKAction.sequence([fadeIn, fadeOut])
        shield.run(SKAction.repeatForever(pulse), withKey: "shieldPulse")
        
        return shield
    }
    
    /// Add shield effect to a tank node
    func addShieldToTank(_ tankNode: SKNode) {
        // Remove existing shield if present
        tankNode.childNode(withName: "shield")?.removeFromParent()
        
        // Add new shield
        let shield = createShieldEffect()
        tankNode.addChild(shield)
    }
    
    /// Remove shield effect from a tank node
    func removeShieldFromTank(_ tankNode: SKNode) {
        tankNode.childNode(withName: "shield")?.removeFromParent()
    }
    
    /// Check if tank has shield visual
    func tankHasShield(_ tankNode: SKNode) -> Bool {
        return tankNode.childNode(withName: "shield") != nil
    }
}
