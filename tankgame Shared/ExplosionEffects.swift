//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations with classic retro visual effects
class ExplosionEffects {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a simple retro explosion effect at a specific position
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Color of the explosion (player color)
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Create simple expanding particles
        let particleCount = 8
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 6)
            particle.fillColor = RetroColors.explosionOuter
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 10
            
            // Calculate direction
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let velocity: CGFloat = 100
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Simple movement and fade animation
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let group = SKAction.group([moveAction, fadeOut])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
        
        // Create central flash effect - simple white circle
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.4)
        flash.fillColor = RetroColors.explosionCore
        flash.strokeColor = .clear
        flash.position = position
        flash.zPosition = 11
        flash.alpha = 1.0
        
        let flashScale = SKAction.scale(to: 2.0, duration: 0.3)
        let flashFade = SKAction.fadeOut(withDuration: 0.3)
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence, completion: completion)
    }
}
