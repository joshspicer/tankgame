//
//  ExplosionEffects.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages explosion animations and visual effects with enhanced visuals
class ExplosionEffects {
    let tileSize: CGFloat
    
    // Modern explosion colors
    private let explosionColors: [SKColor] = [
        SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0),   // Orange
        SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0),   // Red-orange
        SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),   // Yellow
        SKColor(red: 1.0, green: 0.2, blue: 0.1, alpha: 1.0),   // Red
    ]
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create an enhanced explosion effect at a specific position
    /// - Parameters:
    ///   - position: Position for the explosion center
    ///   - color: Base color of the explosion (tank color)
    ///   - parentNode: Node to add explosion particles to
    ///   - completion: Called when the explosion animation completes
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Screen shake effect (subtle)
        createScreenShake(in: parentNode.scene)
        
        // Inner explosion burst
        createInnerBurst(at: position, color: color, in: parentNode)
        
        // Main explosion particles
        createMainParticles(at: position, color: color, in: parentNode)
        
        // Debris particles
        createDebris(at: position, in: parentNode)
        
        // Shockwave ring
        createShockwave(at: position, in: parentNode)
        
        // Central flash effect
        createCentralFlash(at: position, in: parentNode, completion: completion)
    }
    
    /// Create screen shake effect
    private func createScreenShake(in scene: SKScene?) {
        guard let scene = scene else { return }
        
        let shakeAmount: CGFloat = 8
        let shakeDuration: TimeInterval = 0.08
        
        let moveRight = SKAction.moveBy(x: shakeAmount, y: 0, duration: shakeDuration)
        let moveLeft = SKAction.moveBy(x: -shakeAmount * 2, y: 0, duration: shakeDuration)
        let moveCenter = SKAction.moveBy(x: shakeAmount, y: 0, duration: shakeDuration)
        let moveUp = SKAction.moveBy(x: 0, y: shakeAmount, duration: shakeDuration)
        let moveDown = SKAction.moveBy(x: 0, y: -shakeAmount, duration: shakeDuration)
        
        let shake = SKAction.sequence([moveRight, moveLeft, moveCenter, moveUp, moveDown])
        scene.run(shake)
    }
    
    /// Create inner burst effect
    private func createInnerBurst(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        for i in 0..<6 {
            let burstParticle = SKShapeNode(circleOfRadius: 12)
            burstParticle.fillColor = explosionColors[i % explosionColors.count]
            burstParticle.strokeColor = .white
            burstParticle.lineWidth = 1
            burstParticle.position = position
            burstParticle.zPosition = 12
            burstParticle.alpha = 0.9
            
            let angle = (CGFloat(i) / 6.0) * 2 * .pi
            let velocity: CGFloat = 80
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let scaleUp = SKAction.scale(to: 0.3, duration: 0.3)
            
            let group = SKAction.group([moveAction, fadeOut, scaleUp])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(burstParticle)
            burstParticle.run(SKAction.sequence([group, remove]))
        }
    }
    
    /// Create main explosion particles
    private func createMainParticles(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let particleCount = 16
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 6...10))
            particle.fillColor = explosionColors[i % explosionColors.count]
            particle.strokeColor = .white
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 10
            
            // Calculate random direction with spread
            let baseAngle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let angleVariation = CGFloat.random(in: -0.3...0.3)
            let angle = baseAngle + angleVariation
            
            let velocity = CGFloat.random(in: 120...180)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Create movement animation
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            moveAction.timingMode = .easeOut
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scaleUp = SKAction.scale(to: 2.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
    }
    
    /// Create debris particles (small dark pieces)
    private func createDebris(at position: CGPoint, in parentNode: SKNode) {
        let debrisCount = 8
        for _ in 0..<debrisCount {
            let debris = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 3...6), height: CGFloat.random(in: 3...6)))
            debris.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
            debris.strokeColor = .clear
            debris.position = position
            debris.zPosition = 9
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let velocity = CGFloat.random(in: 60...120)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let moveAction = SKAction.moveBy(x: dx, y: dy - 40, duration: 0.8)
            moveAction.timingMode = .easeOut
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: 2...6), duration: 0.8)
            
            let group = SKAction.group([moveAction, fadeOut, rotate])
            let remove = SKAction.removeFromParent()
            
            parentNode.addChild(debris)
            debris.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), group, remove]))
        }
    }
    
    /// Create shockwave ring effect
    private func createShockwave(at position: CGPoint, in parentNode: SKNode) {
        let shockwave = SKShapeNode(circleOfRadius: tileSize * 0.3)
        shockwave.fillColor = .clear
        shockwave.strokeColor = SKColor.white.withAlphaComponent(0.6)
        shockwave.lineWidth = 4
        shockwave.position = position
        shockwave.zPosition = 8
        
        let expandScale = SKAction.scale(to: 4.0, duration: 0.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let thinLine = SKAction.customAction(withDuration: 0.4) { node, elapsedTime in
            if let shape = node as? SKShapeNode {
                let progress = elapsedTime / 0.4
                shape.lineWidth = 4 * (1 - progress)
            }
        }
        
        expandScale.timingMode = .easeOut
        
        let group = SKAction.group([expandScale, fadeOut, thinLine])
        let remove = SKAction.removeFromParent()
        
        parentNode.addChild(shockwave)
        shockwave.run(SKAction.sequence([group, remove]))
    }
    
    /// Create central flash effect
    private func createCentralFlash(at position: CGPoint, in parentNode: SKNode, completion: @escaping () -> Void) {
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.4)
        flash.fillColor = .white
        flash.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        flash.lineWidth = 6
        flash.glowWidth = 10
        flash.position = position
        flash.zPosition = 11
        flash.alpha = 1.0
        
        let flashScale = SKAction.scale(to: 3.0, duration: 0.35)
        let flashFade = SKAction.fadeOut(withDuration: 0.35)
        flashScale.timingMode = .easeOut
        
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence, completion: completion)
    }
}
