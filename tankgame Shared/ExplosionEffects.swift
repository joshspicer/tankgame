//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations and visual effects
/// Creates particle effects when tanks are destroyed
final class ExplosionEffects {
    // MARK: - Properties
    
    /// Size of each grid tile for scaling effects
    let tileSize: CGFloat
    
    // MARK: - Initialization
    
    /// Creates a new explosion effects manager
    /// - Parameter tileSize: Size of grid tiles for appropriate scaling
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    // MARK: - Effects
    
    /// Creates an explosion effect at a specific position
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Base color for the explosion particles
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Create explosion particles
        let particleCount = 12
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 8)
            particle.fillColor = color
            particle.strokeColor = .white
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 10
            
            // Calculate random direction
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let velocity: CGFloat = 150
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Create movement animation
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.6)
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let scaleUp = SKAction.scale(to: 2.0, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
        
        // Create central flash effect
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.5)
        flash.fillColor = .white
        flash.strokeColor = .yellow
        flash.lineWidth = 4
        flash.position = position
        flash.zPosition = 11
        flash.alpha = 0.9
        
        let flashScale = SKAction.scale(to: 2.5, duration: 0.4)
        let flashFade = SKAction.fadeOut(withDuration: 0.4)
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence, completion: completion)
    }
}
