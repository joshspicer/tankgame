//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations and visual effects with premium styling
class ExplosionEffects {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a premium explosion effect at a specific position
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Color of the explosion
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Create multiple particle layers for a richer explosion
        
        // Layer 1: Inner bright particles
        createInnerParticles(at: position, color: color, in: parentNode)
        
        // Layer 2: Outer colored particles
        createOuterParticles(at: position, color: color, in: parentNode)
        
        // Layer 3: Sparks
        createSparks(at: position, in: parentNode)
        
        // Create central flash effect
        createCentralFlash(at: position, color: color, in: parentNode, completion: completion)
        
        // Create shockwave ring
        createShockwave(at: position, color: color, in: parentNode)
        
        // Screen shake effect (subtle pulse on parent)
        let shakeAmount: CGFloat = 3
        let shake = SKAction.sequence([
            SKAction.moveBy(x: shakeAmount, y: 0, duration: 0.02),
            SKAction.moveBy(x: -shakeAmount * 2, y: 0, duration: 0.02),
            SKAction.moveBy(x: shakeAmount, y: 0, duration: 0.02)
        ])
        parentNode.run(shake)
    }
    
    /// Create inner bright particles
    private func createInnerParticles(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let particleCount = 8
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 6)
            particle.fillColor = .white
            particle.strokeColor = color
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 12
            
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi + .random(in: -0.2...0.2)
            let velocity: CGFloat = 100 + .random(in: 0...50)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.4)
            
            let group = SKAction.group([moveAction, fadeOut, scaleDown])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(particle)
            particle.run(SKAction.sequence([group, remove]))
        }
    }
    
    /// Create outer colored particles
    private func createOuterParticles(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let particleCount = 16
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 8)
            particle.fillColor = color
            particle.strokeColor = .white
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 10
            
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let velocity: CGFloat = 120 + .random(in: 0...60)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.6)
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let scaleUp = SKAction.scale(to: 1.8, duration: 0.2)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.4)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(particle)
            particle.run(SKAction.sequence([group, remove]))
        }
    }
    
    /// Create spark particles
    private func createSparks(at position: CGPoint, in parentNode: SKNode) {
        let sparkCount = 12
        for _ in 0..<sparkCount {
            let spark = SKShapeNode(rectOf: CGSize(width: 2, height: 8), cornerRadius: 1)
            spark.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0)
            spark.strokeColor = .clear
            spark.position = position
            spark.zPosition = 13
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let velocity: CGFloat = 80 + .random(in: 0...100)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            spark.zRotation = angle
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.3 + .random(in: 0...0.2))
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let scaleDown = SKAction.scale(to: 0.2, duration: 0.3)
            
            let group = SKAction.group([moveAction, fadeOut, scaleDown])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(spark)
            spark.run(SKAction.sequence([group, remove]))
        }
    }
    
    /// Create central flash effect
    private func createCentralFlash(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // White flash
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.5)
        flash.fillColor = .white
        flash.strokeColor = color
        flash.lineWidth = 4
        flash.position = position
        flash.zPosition = 14
        flash.alpha = 1.0
        
        let flashScale = SKAction.scale(to: 2.0, duration: 0.15)
        let flashFade = SKAction.fadeOut(withDuration: 0.15)
        let flashGroup = SKAction.group([flashScale, flashFade])
        
        // Secondary color flash
        let colorFlash = SKShapeNode(circleOfRadius: tileSize * 0.4)
        colorFlash.fillColor = color
        colorFlash.strokeColor = .clear
        colorFlash.position = position
        colorFlash.zPosition = 13
        colorFlash.alpha = 0.8
        
        let colorScale = SKAction.scale(to: 3.0, duration: 0.3)
        let colorFade = SKAction.fadeOut(withDuration: 0.3)
        let colorGroup = SKAction.group([colorScale, colorFade])
        
        parentNode.addChild(flash)
        parentNode.addChild(colorFlash)
        
        flash.run(SKAction.sequence([flashGroup, SKAction.removeFromParent()]), completion: completion)
        colorFlash.run(SKAction.sequence([colorGroup, SKAction.removeFromParent()]))
    }
    
    /// Create expanding shockwave ring
    private func createShockwave(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let ring = SKShapeNode(circleOfRadius: tileSize * 0.3)
        ring.fillColor = .clear
        ring.strokeColor = color.withAlphaComponent(0.6)
        ring.lineWidth = 4
        ring.position = position
        ring.zPosition = 9
        ring.glowWidth = 2
        
        let expand = SKAction.scale(to: 4.0, duration: 0.4)
        expand.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let lineWidth = SKAction.run {
            ring.lineWidth = 1
        }
        
        let group = SKAction.group([expand, fadeOut])
        let sequence = SKAction.sequence([lineWidth, group, SKAction.removeFromParent()])
        
        parentNode.addChild(ring)
        ring.run(sequence)
    }
}
