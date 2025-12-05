//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations - clean retro style
class ExplosionEffects {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a simple retro explosion effect at a specific position
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Color of the explosion
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Simple expanding ring effect
        let ring = SKShapeNode(circleOfRadius: tileSize * 0.3)
        ring.fillColor = .clear
        ring.strokeColor = color
        ring.lineWidth = 4
        ring.position = position
        ring.zPosition = 10
        
        let expandAction = SKAction.scale(to: 3.0, duration: 0.4)
        let fadeAction = SKAction.fadeOut(withDuration: 0.4)
        let groupAction = SKAction.group([expandAction, fadeAction])
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([groupAction, removeAction])
        
        parentNode.addChild(ring)
        ring.run(sequence)
        
        // Simple particles in 4 cardinal directions
        let directions: [(CGFloat, CGFloat)] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        for (dx, dy) in directions {
            let particle = SKShapeNode(circleOfRadius: 6)
            particle.fillColor = RetroTheme.Colors.projectile
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 10
            
            let moveAction = SKAction.moveBy(x: dx * 60, y: dy * 60, duration: 0.3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let group = SKAction.group([moveAction, fadeOut])
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(seq)
        }
        
        // Central flash
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.25)
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.position = position
        flash.zPosition = 11
        
        let flashScale = SKAction.scale(to: 2.0, duration: 0.2)
        let flashFade = SKAction.fadeOut(withDuration: 0.2)
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence, completion: completion)
    }
}
