//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations and visual effects with enhanced particles
class ExplosionEffects {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create an impressive explosion effect at a specific position
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Color of the explosion
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Create shockwave ring
        createShockwave(at: position, color: color, in: parentNode)
        
        // Create primary explosion particles
        createPrimaryParticles(at: position, color: color, in: parentNode)
        
        // Create secondary spark particles
        createSparkParticles(at: position, in: parentNode)
        
        // Create smoke puffs
        createSmokePuffs(at: position, in: parentNode)
        
        // Create central flash effect
        createCentralFlash(at: position, color: color, in: parentNode, completion: completion)
    }
    
    /// Create expanding shockwave ring
    private func createShockwave(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let shockwave = SKShapeNode(circleOfRadius: tileSize * 0.3)
        shockwave.strokeColor = color.withAlphaComponent(0.8)
        shockwave.fillColor = .clear
        shockwave.lineWidth = 4
        shockwave.position = position
        shockwave.zPosition = 15
        
        let expand = SKAction.scale(to: 4.0, duration: 0.4)
        expand.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: 0.4)
        let thin = SKAction.customAction(withDuration: 0.4) { node, time in
            (node as? SKShapeNode)?.lineWidth = max(0.5, 4 - (time / 0.4) * 3.5)
        }
        let group = SKAction.group([expand, fade, thin])
        let remove = SKAction.removeFromParent()
        
        parentNode.addChild(shockwave)
        shockwave.run(SKAction.sequence([group, remove]))
    }
    
    /// Create primary colored explosion particles
    private func createPrimaryParticles(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let particleCount = UXTheme.explosionPrimaryParticleCount
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 6...10))
            particle.fillColor = color
            particle.strokeColor = SKColor.white.withAlphaComponent(0.6)
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 12
            
            // Random direction with some variance
            let baseAngle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let angleVariance = CGFloat.random(in: -0.2...0.2)
            let angle = baseAngle + angleVariance
            let velocity = CGFloat.random(in: 120...180)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Create movement with deceleration
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.15)
            let scaleDown = SKAction.scale(to: 0.2, duration: 0.35)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(particle)
            particle.run(SKAction.sequence([group, remove]))
        }
    }
    
    /// Create secondary spark particles
    private func createSparkParticles(at position: CGPoint, in parentNode: SKNode) {
        let sparkCount = UXTheme.explosionSparkCount
        for _ in 0..<sparkCount {
            let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            spark.fillColor = SKColor.yellow
            spark.strokeColor = SKColor.orange
            spark.lineWidth = 1
            spark.position = position
            spark.zPosition = 13
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let velocity = CGFloat.random(in: 80...200)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: CGFloat.random(in: 0.3...0.6))
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let shrink = SKAction.scale(to: 0.1, duration: 0.4)
            
            let group = SKAction.group([moveAction, fadeOut, shrink])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(spark)
            
            // Stagger spark starts
            let delay = SKAction.wait(forDuration: Double.random(in: 0...0.1))
            spark.run(SKAction.sequence([delay, group, remove]))
        }
    }
    
    /// Create smoke puff effects
    private func createSmokePuffs(at position: CGPoint, in parentNode: SKNode) {
        let puffCount = UXTheme.explosionSmokeCount
        for i in 0..<puffCount {
            let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 12...20))
            puff.fillColor = SKColor(white: 0.3, alpha: 0.5)
            puff.strokeColor = .clear
            puff.position = position
            puff.zPosition = 11
            
            let angle = (CGFloat(i) / CGFloat(puffCount)) * 2 * .pi
            let distance = CGFloat.random(in: 30...60)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance + CGFloat.random(in: 20...40) // Rise slightly
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.8)
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.8)
            let expand = SKAction.scale(to: 2.5, duration: 0.8)
            
            let group = SKAction.group([moveAction, fadeOut, expand])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(puff)
            
            // Stagger puff starts
            let delay = SKAction.wait(forDuration: Double(i) * 0.05)
            puff.run(SKAction.sequence([delay, group, remove]))
        }
    }
    
    /// Create central flash effect
    private func createCentralFlash(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Inner bright flash
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.4)
        flash.fillColor = .white
        flash.strokeColor = color
        flash.lineWidth = 6
        flash.position = position
        flash.zPosition = 14
        flash.alpha = 1.0
        
        let flashScale = SKAction.scale(to: 3.0, duration: 0.3)
        flashScale.timingMode = .easeOut
        let flashFade = SKAction.fadeOut(withDuration: 0.3)
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence, completion: completion)
        
        // Secondary glow
        let glow = SKShapeNode(circleOfRadius: tileSize * 0.6)
        glow.fillColor = color.withAlphaComponent(0.4)
        glow.strokeColor = .clear
        glow.position = position
        glow.zPosition = 10
        glow.alpha = 0.8
        
        let glowScale = SKAction.scale(to: 2.5, duration: 0.5)
        glowScale.timingMode = .easeOut
        let glowFade = SKAction.fadeOut(withDuration: 0.5)
        let glowGroup = SKAction.group([glowScale, glowFade])
        let glowRemove = SKAction.removeFromParent()
        
        parentNode.addChild(glow)
        glow.run(SKAction.sequence([glowGroup, glowRemove]))
    }
}
