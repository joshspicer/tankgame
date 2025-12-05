//
//  ModernExplosionEffects.swift
//  tankgame Shared
//
//  Enhanced explosion animations with modern particle effects
//

import SpriteKit

/// Enhanced explosion animations with modern particle effects
class ModernExplosionEffects {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create an enhanced explosion effect at a specific position
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Create shockwave ring
        createShockwave(at: position, in: parentNode)
        
        // Create main explosion particles
        createMainParticles(at: position, color: color, in: parentNode)
        
        // Create spark particles
        createSparks(at: position, color: color, in: parentNode)
        
        // Create debris particles
        createDebris(at: position, in: parentNode)
        
        // Create central flash effect
        createCentralFlash(at: position, color: color, in: parentNode, completion: completion)
        
        // Create screen shake effect
        createScreenShake(in: parentNode)
    }
    
    /// Create expanding shockwave ring
    private func createShockwave(at position: CGPoint, in parentNode: SKNode) {
        let shockwave = SKShapeNode(circleOfRadius: tileSize * 0.3)
        shockwave.strokeColor = SKColor(white: 1, alpha: 0.9)
        shockwave.fillColor = .clear
        shockwave.lineWidth = 4
        shockwave.position = position
        shockwave.zPosition = 12
        shockwave.glowWidth = 3
        parentNode.addChild(shockwave)
        
        let expand = SKAction.scale(to: 4.0, duration: 0.35)
        let fadeOut = SKAction.fadeOut(withDuration: 0.35)
        let group = SKAction.group([expand, fadeOut])
        let remove = SKAction.removeFromParent()
        
        shockwave.run(SKAction.sequence([group, remove]))
    }
    
    /// Create main explosion particles
    private func createMainParticles(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let particleCount = 16
        
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 6...12))
            particle.fillColor = i % 2 == 0 ? color : SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
            particle.strokeColor = .white
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 10
            particle.glowWidth = 2
            
            // Calculate random direction with spread
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi + CGFloat.random(in: -0.2...0.2)
            let velocity = CGFloat.random(in: 120...200)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Create complex animation
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.15)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.35)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(particle)
            particle.run(SKAction.sequence([group, remove]))
        }
    }
    
    /// Create spark particles
    private func createSparks(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let sparkCount = 24
        
        for i in 0..<sparkCount {
            let spark = SKShapeNode(ellipseOf: CGSize(width: 2, height: CGFloat.random(in: 8...16)))
            spark.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)
            spark.strokeColor = .clear
            spark.position = position
            spark.zPosition = 11
            
            let angle = (CGFloat(i) / CGFloat(sparkCount)) * 2 * .pi + CGFloat.random(in: -0.1...0.1)
            spark.zRotation = angle - .pi / 2
            
            let velocity = CGFloat.random(in: 180...300)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.4)
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let shrink = SKAction.scaleY(to: 0.1, duration: 0.4)
            
            let group = SKAction.group([moveAction, fadeOut, shrink])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(spark)
            spark.run(SKAction.sequence([group, remove]))
        }
    }
    
    /// Create debris particles
    private func createDebris(at position: CGPoint, in parentNode: SKNode) {
        let debrisCount = 8
        
        for i in 0..<debrisCount {
            let size = CGFloat.random(in: 4...8)
            let debris = SKShapeNode(rectOf: CGSize(width: size, height: size))
            debris.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
            debris.strokeColor = SKColor(white: 0.5, alpha: 0.5)
            debris.lineWidth = 1
            debris.position = position
            debris.zPosition = 9
            
            let angle = CGFloat(i) / CGFloat(debrisCount) * 2 * .pi + CGFloat.random(in: -0.3...0.3)
            let velocity = CGFloat.random(in: 80...150)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Arc trajectory with gravity
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.6)
            let gravity = SKAction.moveBy(x: 0, y: -100, duration: 0.6)
            let moveGroup = SKAction.group([moveAction, gravity])
            moveGroup.timingMode = .easeOut
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -4...4), duration: 0.6)
            
            let group = SKAction.group([moveGroup, fadeOut, rotate])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(debris)
            debris.run(SKAction.sequence([group, remove]))
        }
    }
    
    /// Create central flash effect
    private func createCentralFlash(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Inner bright core
        let innerFlash = SKShapeNode(circleOfRadius: tileSize * 0.3)
        innerFlash.fillColor = .white
        innerFlash.strokeColor = .yellow
        innerFlash.lineWidth = 3
        innerFlash.position = position
        innerFlash.zPosition = 13
        innerFlash.glowWidth = 10
        
        let innerScale = SKAction.scale(to: 2.0, duration: 0.15)
        let innerFade = SKAction.fadeOut(withDuration: 0.2)
        let innerGroup = SKAction.group([innerScale, innerFade])
        let innerRemove = SKAction.removeFromParent()
        
        parentNode.addChild(innerFlash)
        innerFlash.run(SKAction.sequence([innerGroup, innerRemove]))
        
        // Outer colored flash
        let outerFlash = SKShapeNode(circleOfRadius: tileSize * 0.5)
        outerFlash.fillColor = color.withAlphaComponent(0.8)
        outerFlash.strokeColor = .white
        outerFlash.lineWidth = 4
        outerFlash.position = position
        outerFlash.zPosition = 12
        outerFlash.alpha = 0.9
        outerFlash.glowWidth = 8
        
        let outerScale = SKAction.scale(to: 3.0, duration: 0.4)
        outerScale.timingMode = .easeOut
        let outerFade = SKAction.fadeOut(withDuration: 0.4)
        let outerGroup = SKAction.group([outerScale, outerFade])
        let outerRemove = SKAction.removeFromParent()
        
        parentNode.addChild(outerFlash)
        outerFlash.run(SKAction.sequence([outerGroup, outerRemove]), completion: completion)
    }
    
    /// Create screen shake effect
    private func createScreenShake(in parentNode: SKNode) {
        guard let scene = parentNode.scene else { return }
        
        let shakeAmount: CGFloat = 8
        let shakeDuration: TimeInterval = 0.4
        let shakeCount = 6
        
        var actions: [SKAction] = []
        for i in 0..<shakeCount {
            let intensity = CGFloat(shakeCount - i) / CGFloat(shakeCount)
            let offsetX = CGFloat.random(in: -shakeAmount...shakeAmount) * intensity
            let offsetY = CGFloat.random(in: -shakeAmount...shakeAmount) * intensity
            let moveAction = SKAction.moveBy(x: offsetX, y: offsetY, duration: shakeDuration / Double(shakeCount * 2))
            let returnAction = SKAction.moveBy(x: -offsetX, y: -offsetY, duration: shakeDuration / Double(shakeCount * 2))
            actions.append(moveAction)
            actions.append(returnAction)
        }
        
        scene.run(SKAction.sequence(actions))
    }
}
