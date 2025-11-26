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
        let isFunkyMode = FunkyMode.shared.isEnabled
        
        // Create explosion particles - more particles in funky mode
        let particleCount = isFunkyMode ? 20 : 12
        let duration = isFunkyMode ? 0.8 : 0.6
        
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: isFunkyMode ? 12 : 8)
            particle.fillColor = color
            particle.strokeColor = .white
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 10
            
            // Calculate random direction
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let velocity: CGFloat = isFunkyMode ? 200 : 150
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Create movement animation
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: duration)
            let fadeOut = SKAction.fadeOut(withDuration: duration)
            let scaleUp = SKAction.scale(to: isFunkyMode ? 2.5 : 2.0, duration: isFunkyMode ? 0.4 : 0.3)
            let scaleDown = SKAction.scale(to: 0.1, duration: isFunkyMode ? 0.4 : 0.3)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
        
        // Create central flash effect - bigger and brighter in funky mode
        let flash = SKShapeNode(circleOfRadius: tileSize * (isFunkyMode ? 0.8 : 0.5))
        flash.fillColor = isFunkyMode ? .yellow : .white
        flash.strokeColor = isFunkyMode ? .orange : .yellow
        flash.lineWidth = isFunkyMode ? 6 : 4
        flash.position = position
        flash.zPosition = 11
        flash.alpha = 0.9
        
        let flashScale = SKAction.scale(to: isFunkyMode ? 3.5 : 2.5, duration: isFunkyMode ? 0.5 : 0.4)
        let flashFade = SKAction.fadeOut(withDuration: isFunkyMode ? 0.5 : 0.4)
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence) {
            // Add screen shake in funky mode
            if isFunkyMode {
                self.addScreenShake(to: parentNode.scene)
            }
            completion()
        }
    }
    
    /// Add screen shake effect to the scene
    private func addScreenShake(to scene: SKScene?) {
        guard let scene = scene else { return }
        
        let shakeAmount: CGFloat = 8
        let shakeDuration: TimeInterval = 0.05
        let numberOfShakes = 4
        
        var shakeActions: [SKAction] = []
        for _ in 0..<numberOfShakes {
            let moveLeft = SKAction.moveBy(x: -shakeAmount, y: 0, duration: shakeDuration)
            let moveRight = SKAction.moveBy(x: shakeAmount * 2, y: 0, duration: shakeDuration)
            let moveBack = SKAction.moveBy(x: -shakeAmount, y: 0, duration: shakeDuration)
            shakeActions.append(contentsOf: [moveLeft, moveRight, moveBack])
        }
        
        let shakeSequence = SKAction.sequence(shakeActions)
        scene.run(shakeSequence)
    }
}
