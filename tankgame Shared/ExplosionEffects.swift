//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations - Classic retro style
class ExplosionEffects {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a classic explosion effect at a specific position
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Color of the explosion
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Create simple explosion particles - classic style
        let particleCount = 8
        for i in 0..<particleCount {
            let particle = SKSpriteNode(color: color, size: CGSize(width: 10, height: 10))
            particle.position = position
            particle.zPosition = 10
            
            // Calculate direction
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let velocity: CGFloat = 100
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Simple movement and fade
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let group = SKAction.group([moveAction, fadeOut])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
        
        // Create simple central flash
        let flash = SKSpriteNode(color: .white, size: CGSize(width: tileSize * 0.6, height: tileSize * 0.6))
        flash.position = position
        flash.zPosition = 11
        
        let flashFade = SKAction.fadeOut(withDuration: 0.3)
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashFade, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence, completion: completion)
    }
}
