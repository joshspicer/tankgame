//
//  ModernExplosionEffects.swift
//  tankgame Shared
//
//  Enhanced explosion animations with modern visual effects
//

import SpriteKit

/// Modern styled explosion effects with enhanced particles and shockwaves
class ModernExplosionEffects {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a modern explosion effect with multiple layers
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Primary color of the explosion
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Layer 1: Shockwave ring
        createShockwave(at: position, in: parentNode)
        
        // Layer 2: Core flash
        createCoreFlash(at: position, color: color, in: parentNode)
        
        // Layer 3: Particle burst
        createParticleBurst(at: position, color: color, in: parentNode)
        
        // Layer 4: Smoke/debris particles
        createDebrisParticles(at: position, in: parentNode, completion: completion)
        
        // Layer 5: Screen flash effect
        createScreenFlash(in: parentNode)
    }
    
    /// Create expanding shockwave ring
    private func createShockwave(at position: CGPoint, in parentNode: SKNode) {
        let shockwave = SKShapeNode(circleOfRadius: tileSize * 0.3)
        shockwave.position = position
        shockwave.fillColor = .clear
        shockwave.strokeColor = SKColor.white.withAlphaComponent(0.8)
        shockwave.lineWidth = 4
        shockwave.glowWidth = 6
        shockwave.zPosition = 15
        parentNode.addChild(shockwave)
        
        let expand = SKAction.scale(to: 4.0, duration: 0.4)
        expand.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: 0.4)
        let group = SKAction.group([expand, fade])
        let remove = SKAction.removeFromParent()
        
        shockwave.run(SKAction.sequence([group, remove]))
    }
    
    /// Create central flash effect
    private func createCoreFlash(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        // Outer glow
        let outerGlow = SKShapeNode(circleOfRadius: tileSize * 0.6)
        outerGlow.position = position
        outerGlow.fillColor = color.withAlphaComponent(0.6)
        outerGlow.strokeColor = .clear
        outerGlow.zPosition = 11
        parentNode.addChild(outerGlow)
        
        // Core white flash
        let coreFlash = SKShapeNode(circleOfRadius: tileSize * 0.4)
        coreFlash.position = position
        coreFlash.fillColor = .white
        coreFlash.strokeColor = color
        coreFlash.lineWidth = 3
        coreFlash.zPosition = 12
        parentNode.addChild(coreFlash)
        
        // Animate outer glow
        let expandOuter = SKAction.scale(to: 2.5, duration: 0.3)
        let fadeOuter = SKAction.fadeOut(withDuration: 0.3)
        outerGlow.run(SKAction.sequence([
            SKAction.group([expandOuter, fadeOuter]),
            SKAction.removeFromParent()
        ]))
        
        // Animate core flash
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let scaleDown = SKAction.scale(to: 0.0, duration: 0.25)
        let fadeCore = SKAction.fadeOut(withDuration: 0.25)
        coreFlash.run(SKAction.sequence([
            scaleUp,
            SKAction.group([scaleDown, fadeCore]),
            SKAction.removeFromParent()
        ]))
    }
    
    /// Create particle burst effect
    private func createParticleBurst(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let particleCount = 16
        
        for i in 0..<particleCount {
            // Calculate angle with some randomness
            let baseAngle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let angleVariation = CGFloat.random(in: -0.2...0.2)
            let angle = baseAngle + angleVariation
            
            // Create particle
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...10))
            particle.position = position
            particle.fillColor = i % 2 == 0 ? color : color.withAlphaComponent(0.7)
            particle.strokeColor = SKColor.white.withAlphaComponent(0.5)
            particle.lineWidth = 1
            particle.zPosition = 10
            parentNode.addChild(particle)
            
            // Random velocity
            let velocity = CGFloat.random(in: 120...220)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            let duration = TimeInterval.random(in: 0.4...0.7)
            
            // Movement with deceleration
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: duration)
            moveAction.timingMode = .easeOut
            
            // Rotation
            let rotate = SKAction.rotate(byAngle: .pi * CGFloat.random(in: 2...4), duration: duration)
            
            // Scale animation
            let scaleUp = SKAction.scale(to: 1.3, duration: duration * 0.3)
            let scaleDown = SKAction.scale(to: 0.2, duration: duration * 0.7)
            let scaleSeq = SKAction.sequence([scaleUp, scaleDown])
            
            // Fade
            let fade = SKAction.fadeOut(withDuration: duration)
            
            let group = SKAction.group([moveAction, rotate, scaleSeq, fade])
            particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
    }
    
    /// Create debris/smoke particles
    private func createDebrisParticles(at position: CGPoint, in parentNode: SKNode, completion: @escaping () -> Void) {
        let debrisCount = 8
        var completedCount = 0
        
        for i in 0..<debrisCount {
            let debris = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            debris.position = position
            debris.fillColor = SKColor(white: CGFloat.random(in: 0.2...0.5), alpha: 0.8)
            debris.strokeColor = .clear
            debris.zPosition = 9
            parentNode.addChild(debris)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let velocity = CGFloat.random(in: 50...100)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity + 60 // Slight upward bias
            let duration = TimeInterval.random(in: 0.6...1.0)
            
            let move = SKAction.moveBy(x: dx, y: dy, duration: duration)
            move.timingMode = .easeOut
            
            let fade = SKAction.fadeOut(withDuration: duration)
            let scale = SKAction.scale(to: 0.5, duration: duration)
            
            let group = SKAction.group([move, fade, scale])
            let remove = SKAction.removeFromParent()
            
            debris.run(SKAction.sequence([group, remove])) {
                completedCount += 1
                if completedCount == debrisCount {
                    completion()
                }
            }
        }
        
        // Handle edge case where debris count is 0
        if debrisCount == 0 {
            completion()
        }
    }
    
    /// Create brief screen flash effect
    private func createScreenFlash(in parentNode: SKNode) {
        // Create a brief white overlay that quickly fades
        if let scene = parentNode.scene {
            let flash = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.3), size: scene.size)
            flash.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
            flash.zPosition = 100
            flash.alpha = 0
            scene.addChild(flash)
            
            let fadeIn = SKAction.fadeAlpha(to: 0.2, duration: 0.05)
            let fadeOut = SKAction.fadeOut(withDuration: 0.15)
            let remove = SKAction.removeFromParent()
            
            flash.run(SKAction.sequence([fadeIn, fadeOut, remove]))
        }
    }
    
    /// Create a mini explosion effect for projectiles
    func createProjectileExplosion(at position: CGPoint, in parentNode: SKNode) {
        // Small burst effect
        let sparkCount = 6
        
        for i in 0..<sparkCount {
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.position = position
            spark.fillColor = .yellow
            spark.strokeColor = .orange
            spark.lineWidth = 1
            spark.zPosition = 10
            parentNode.addChild(spark)
            
            let angle = (CGFloat(i) / CGFloat(sparkCount)) * 2 * .pi
            let velocity: CGFloat = 40
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.2)
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: 0.2)
            let scale = SKAction.scale(to: 0.3, duration: 0.2)
            
            spark.run(SKAction.sequence([
                SKAction.group([move, fade, scale]),
                SKAction.removeFromParent()
            ]))
        }
    }
}
