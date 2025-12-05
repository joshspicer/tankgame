//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations and visual effects with modern styling
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
        // Create particle layers with optimized counts for performance
        createOuterParticles(at: position, color: color, in: parentNode)
        createInnerParticles(at: position, color: color, in: parentNode)
        createSparks(at: position, in: parentNode)
        
        // Create central flash effect
        createCentralFlash(at: position, color: color, in: parentNode, completion: completion)
        
        // Add screen shake effect via parent
        addShakeEffect(to: parentNode)
        
        // Add smoke effect (reduced count)
        createSmoke(at: position, in: parentNode)
    }
    
    /// Create outer explosion particles (optimized count)
    private func createOuterParticles(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let particleCount = 10  // Reduced from 16 for better performance
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...14))
            particle.fillColor = color
            particle.strokeColor = SKColor.white.withAlphaComponent(0.8)
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 10
            particle.alpha = 0.9
            
            // Calculate direction with slight randomization
            let baseAngle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let angle = baseAngle + CGFloat.random(in: -0.2...0.2)
            let velocity = CGFloat.random(in: 120...180)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Create movement animation
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
    }
    
    /// Create inner explosion particles (brighter, faster - optimized count)
    private func createInnerParticles(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let particleCount = 6  // Reduced from 8 for better performance
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...10))
            particle.fillColor = SKColor.white
            particle.strokeColor = color
            particle.lineWidth = 3
            particle.position = position
            particle.zPosition = 11
            particle.alpha = 1.0
            
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi + .pi / 8
            let velocity = CGFloat.random(in: 80...120)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.35)
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.35)
            let scaleDown = SKAction.scale(to: 0.2, duration: 0.35)
            
            let group = SKAction.group([moveAction, fadeOut, scaleDown])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
    }
    
    /// Create spark particles (optimized count)
    private func createSparks(at position: CGPoint, in parentNode: SKNode) {
        let sparkCount = 8  // Reduced from 12 for better performance
        for _ in 0..<sparkCount {
            let spark = SKShapeNode(rectOf: CGSize(width: 2, height: CGFloat.random(in: 10...18)))
            spark.fillColor = SKColor.yellow
            spark.strokeColor = .clear
            spark.position = position
            spark.zPosition = 12
            spark.alpha = 0.9
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let velocity = CGFloat.random(in: 150...250)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            spark.zRotation = angle
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: CGFloat.random(in: 0.3...0.5))
            moveAction.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            
            let group = SKAction.group([moveAction, fadeOut])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(spark)
            spark.run(sequence)
        }
    }
    
    /// Create central flash effect
    private func createCentralFlash(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Inner flash
        let innerFlash = SKShapeNode(circleOfRadius: tileSize * 0.3)
        innerFlash.fillColor = .white
        innerFlash.strokeColor = .clear
        innerFlash.position = position
        innerFlash.zPosition = 13
        innerFlash.alpha = 1.0
        
        // Outer flash
        let outerFlash = SKShapeNode(circleOfRadius: tileSize * 0.6)
        outerFlash.fillColor = color.withAlphaComponent(0.8)
        outerFlash.strokeColor = SKColor.yellow
        outerFlash.lineWidth = 4
        outerFlash.position = position
        outerFlash.zPosition = 12
        outerFlash.alpha = 0.9
        
        // Inner flash animation
        let innerScale = SKAction.scale(to: 3.0, duration: 0.3)
        let innerFade = SKAction.fadeOut(withDuration: 0.3)
        let innerGroup = SKAction.group([innerScale, innerFade])
        let innerRemove = SKAction.removeFromParent()
        let innerSequence = SKAction.sequence([innerGroup, innerRemove])
        
        // Outer flash animation
        let outerScale = SKAction.scale(to: 2.5, duration: 0.4)
        let outerFade = SKAction.fadeOut(withDuration: 0.4)
        let outerGroup = SKAction.group([outerScale, outerFade])
        let outerRemove = SKAction.removeFromParent()
        let outerSequence = SKAction.sequence([outerGroup, outerRemove])
        
        parentNode.addChild(outerFlash)
        parentNode.addChild(innerFlash)
        
        innerFlash.run(innerSequence)
        outerFlash.run(outerSequence, completion: completion)
    }
    
    /// Add screen shake effect
    private func addShakeEffect(to node: SKNode) {
        let shakeAmount: CGFloat = 8
        let shakeDuration: TimeInterval = 0.08
        
        let shake = SKAction.sequence([
            SKAction.moveBy(x: shakeAmount, y: 0, duration: shakeDuration),
            SKAction.moveBy(x: -shakeAmount * 2, y: 0, duration: shakeDuration),
            SKAction.moveBy(x: shakeAmount * 1.5, y: shakeAmount, duration: shakeDuration),
            SKAction.moveBy(x: -shakeAmount, y: -shakeAmount * 1.5, duration: shakeDuration),
            SKAction.moveBy(x: shakeAmount * 0.5, y: shakeAmount * 0.5, duration: shakeDuration),
            SKAction.moveBy(x: 0, y: 0, duration: shakeDuration)
        ])
        
        node.run(shake)
    }
    
    /// Create smoke effect
    private func createSmoke(at position: CGPoint, in parentNode: SKNode) {
        let smokeCount = 5
        for i in 0..<smokeCount {
            let smoke = SKShapeNode(circleOfRadius: CGFloat.random(in: 15...25))
            smoke.fillColor = SKColor(white: 0.3, alpha: 0.3)
            smoke.strokeColor = .clear
            smoke.position = CGPoint(
                x: position.x + CGFloat.random(in: -20...20),
                y: position.y + CGFloat.random(in: -20...20)
            )
            smoke.zPosition = 9
            smoke.alpha = 0
            
            let delay = Double(i) * 0.05
            let fadeIn = SKAction.fadeAlpha(to: 0.4, duration: 0.1)
            let rise = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: 40...80), duration: 1.0)
            rise.timingMode = .easeOut
            let expand = SKAction.scale(to: 2.0, duration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            
            let moveGroup = SKAction.group([rise, expand])
            let fullSequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                fadeIn,
                moveGroup,
                fadeOut,
                SKAction.removeFromParent()
            ])
            
            parentNode.addChild(smoke)
            smoke.run(fullSequence)
        }
    }
}
