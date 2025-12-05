//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations and visual effects
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
        // Simple classic explosion - fewer particles, cleaner look
        let particleCount = 8
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 6)
            particle.fillColor = color
            particle.strokeColor = .white
            particle.lineWidth = 1
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
        
        // Simple central flash - clean white circle
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.4)
        flash.fillColor = .white
        flash.strokeColor = color
        flash.lineWidth = 3
        flash.position = position
        flash.zPosition = 11
        
        let flashScale = SKAction.scale(to: 2.0, duration: 0.3)
        let flashFade = SKAction.fadeOut(withDuration: 0.3)
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence, completion: completion)
    }
}
