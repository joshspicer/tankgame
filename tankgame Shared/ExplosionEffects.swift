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
    
    /// Create an explosion effect at a specific position
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Color of the explosion
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Create multiple particle rings
        createParticleRing(at: position, color: color, in: parentNode, particleCount: 12, velocity: 150, delay: 0)
        createParticleRing(at: position, color: GameTheme.Colors.explosionOuter, in: parentNode, particleCount: 8, velocity: 100, delay: 0.05)
        
        // Create central flash effect with multiple layers
        createCentralFlash(at: position, in: parentNode, completion: completion)
        
        // Add shockwave ring
        createShockwave(at: position, in: parentNode)
        
        // Add sparks
        createSparks(at: position, color: color, in: parentNode)
    }
    
    /// Create a ring of exploding particles
    private func createParticleRing(at position: CGPoint, color: SKColor, in parentNode: SKNode, particleCount: Int, velocity: CGFloat, delay: TimeInterval) {
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 8)
            particle.fillColor = color
            particle.strokeColor = GameTheme.Colors.explosionCore
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 20
            particle.alpha = 0
            
            // Calculate random direction with slight variation
            let baseAngle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let angleVariation = CGFloat.random(in: -0.2...0.2)
            let angle = baseAngle + angleVariation
            let velocityVariation = CGFloat.random(in: 0.8...1.2)
            let dx = cos(angle) * velocity * velocityVariation
            let dy = sin(angle) * velocity * velocityVariation
            
            // Delayed start
            let waitAction = SKAction.wait(forDuration: delay)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
            
            // Create movement animation with easing
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let scaleUp = SKAction.scale(to: 1.8, duration: 0.2)
            let scaleDown = SKAction.scale(to: 0.2, duration: 0.3)
            scaleUp.timingMode = .easeOut
            scaleDown.timingMode = .easeIn
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let animationGroup = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([waitAction, fadeIn, animationGroup, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
    }
    
    /// Create the central flash effect
    private func createCentralFlash(at position: CGPoint, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Outer flash
        let outerFlash = SKShapeNode(circleOfRadius: tileSize * 0.6)
        outerFlash.fillColor = GameTheme.Colors.explosionOuter
        outerFlash.strokeColor = GameTheme.Colors.accent
        outerFlash.lineWidth = 3
        outerFlash.glowWidth = 4
        outerFlash.position = position
        outerFlash.zPosition = 22
        outerFlash.alpha = 0.8
        
        // Inner flash (brighter core)
        let innerFlash = SKShapeNode(circleOfRadius: tileSize * 0.35)
        innerFlash.fillColor = GameTheme.Colors.explosionCore
        innerFlash.strokeColor = SKColor.white
        innerFlash.lineWidth = 2
        innerFlash.position = position
        innerFlash.zPosition = 23
        innerFlash.alpha = 1.0
        
        // Animate outer flash
        let outerScale = SKAction.scale(to: 3.0, duration: 0.35)
        let outerFade = SKAction.fadeOut(withDuration: 0.35)
        outerScale.timingMode = .easeOut
        let outerGroup = SKAction.group([outerScale, outerFade])
        let outerRemove = SKAction.removeFromParent()
        let outerSequence = SKAction.sequence([outerGroup, outerRemove])
        
        // Animate inner flash
        let innerScale = SKAction.scale(to: 2.5, duration: 0.25)
        let innerFade = SKAction.fadeOut(withDuration: 0.25)
        innerScale.timingMode = .easeOut
        let innerGroup = SKAction.group([innerScale, innerFade])
        let innerRemove = SKAction.removeFromParent()
        let innerSequence = SKAction.sequence([innerGroup, innerRemove])
        
        parentNode.addChild(outerFlash)
        parentNode.addChild(innerFlash)
        
        outerFlash.run(outerSequence)
        innerFlash.run(innerSequence, completion: completion)
    }
    
    /// Create an expanding shockwave ring
    private func createShockwave(at position: CGPoint, in parentNode: SKNode) {
        let shockwave = SKShapeNode(circleOfRadius: tileSize * 0.3)
        shockwave.fillColor = .clear
        shockwave.strokeColor = GameTheme.Colors.explosionCore.withAlphaComponent(0.6)
        shockwave.lineWidth = 3
        shockwave.glowWidth = 2
        shockwave.position = position
        shockwave.zPosition = 19
        shockwave.alpha = 0.8
        
        let expand = SKAction.scale(to: 4.0, duration: 0.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        expand.timingMode = .easeOut
        let group = SKAction.group([expand, fadeOut])
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([group, remove])
        
        parentNode.addChild(shockwave)
        shockwave.run(sequence)
    }
    
    /// Create spark particles
    private func createSparks(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        for _ in 0..<6 {
            let spark = SKShapeNode(rectOf: CGSize(width: 3, height: 12), cornerRadius: 1)
            spark.fillColor = GameTheme.Colors.explosionCore
            spark.strokeColor = .clear
            spark.position = position
            spark.zPosition = 21
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let velocity = CGFloat.random(in: 80...180)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            spark.zRotation = angle + .pi / 2
            
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.3)
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let scale = SKAction.scale(to: 0.3, duration: 0.3)
            let group = SKAction.group([move, fade, scale])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(spark)
            spark.run(sequence)
        }
    }
}
