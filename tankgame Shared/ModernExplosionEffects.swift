//
//  ModernExplosionEffects.swift
//  tankgame Shared
//
//  Enhanced explosion effects with more particles, screen shake, and visual impact
//

import SpriteKit

/// Modern explosion effects with enhanced visuals and screen shake
class ModernExplosionEffects {
    
    // MARK: - Properties
    
    let tileSize: CGFloat
    weak var scene: SKScene?
    
    // MARK: - Configuration
    
    struct Config {
        static let particleCount = 20
        static let sparkCount = 12
        static let smokeCount = 6
        static let shakeDuration: TimeInterval = 0.3
        static let shakeIntensity: CGFloat = 8
    }
    
    // MARK: - Colors
    
    struct Colors {
        static let explosionCore = SKColor.white
        static let explosionOuter = SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0)
        static let sparks = [
            SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0),
            SKColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1.0),
            SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0)
        ]
        static let smoke = SKColor(white: 0.3, alpha: 0.6)
    }
    
    // MARK: - Initialization
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Set the scene reference for screen shake
    func setScene(_ scene: SKScene) {
        self.scene = scene
    }
    
    // MARK: - Explosion Creation
    
    /// Create an enhanced explosion effect
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        
        // Trigger screen shake
        triggerScreenShake()
        
        // Create main explosion layers
        createCoreExplosion(at: position, color: color, in: parentNode)
        createOuterRing(at: position, color: color, in: parentNode)
        createParticles(at: position, color: color, in: parentNode)
        createSparks(at: position, in: parentNode)
        createSmoke(at: position, in: parentNode)
        
        // Flash effect
        createFlash(at: position, in: parentNode, completion: completion)
    }
    
    // MARK: - Explosion Components
    
    private func createCoreExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let core = SKShapeNode(circleOfRadius: tileSize * 0.3)
        core.fillColor = Colors.explosionCore
        core.strokeColor = color
        core.lineWidth = 4
        core.position = position
        core.zPosition = 15
        core.alpha = 1.0
        parentNode.addChild(core)
        
        // Animate core
        let expand = SKAction.scale(to: 2.5, duration: 0.15)
        let fade = SKAction.fadeOut(withDuration: 0.2)
        let colorize = SKAction.run { [weak core] in
            core?.fillColor = color
        }
        let sequence = SKAction.sequence([
            SKAction.group([expand, colorize]),
            fade,
            SKAction.removeFromParent()
        ])
        core.run(sequence)
    }
    
    private func createOuterRing(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        let ring = SKShapeNode(circleOfRadius: tileSize * 0.4)
        ring.fillColor = .clear
        ring.strokeColor = Colors.explosionOuter
        ring.lineWidth = 6
        ring.glowWidth = 4
        ring.position = position
        ring.zPosition = 14
        parentNode.addChild(ring)
        
        // Animate ring
        let expand = SKAction.scale(to: 4.0, duration: 0.4)
        let thin = SKAction.run { [weak ring] in
            ring?.lineWidth = 1
            ring?.glowWidth = 0
        }
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let sequence = SKAction.sequence([
            SKAction.group([expand, SKAction.sequence([SKAction.wait(forDuration: 0.1), thin])]),
            fade,
            SKAction.removeFromParent()
        ])
        ring.run(sequence)
    }
    
    private func createParticles(at position: CGPoint, color: SKColor, in parentNode: SKNode) {
        for i in 0..<Config.particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...10))
            particle.fillColor = color
            particle.strokeColor = Colors.explosionCore
            particle.lineWidth = 1
            particle.position = position
            particle.zPosition = 12
            parentNode.addChild(particle)
            
            // Calculate direction with some randomization
            let baseAngle = (CGFloat(i) / CGFloat(Config.particleCount)) * 2 * .pi
            let angle = baseAngle + CGFloat.random(in: -0.2...0.2)
            let velocity: CGFloat = CGFloat.random(in: 100...200)
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Animate particle
            let duration = TimeInterval(CGFloat.random(in: 0.4...0.7))
            let move = SKAction.moveBy(x: dx, y: dy, duration: duration)
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: duration)
            let scale = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: duration * 0.3),
                SKAction.scale(to: 0.1, duration: duration * 0.7)
            ])
            
            let group = SKAction.group([move, fade, scale])
            let remove = SKAction.removeFromParent()
            particle.run(SKAction.sequence([group, remove]))
        }
    }
    
    private func createSparks(at position: CGPoint, in parentNode: SKNode) {
        for _ in 0..<Config.sparkCount {
            // Create spark line
            let sparkLength: CGFloat = CGFloat.random(in: 15...35)
            let spark = SKShapeNode(rectOf: CGSize(width: 2, height: sparkLength))
            spark.fillColor = Colors.sparks.randomElement() ?? Colors.sparks[0]
            spark.strokeColor = .clear
            spark.position = position
            spark.zPosition = 13
            parentNode.addChild(spark)
            
            // Random direction
            let angle = CGFloat.random(in: 0...(2 * .pi))
            spark.zRotation = angle - .pi / 2
            
            // Animate spark
            let velocity: CGFloat = CGFloat.random(in: 200...350)
            let duration = TimeInterval(CGFloat.random(in: 0.2...0.4))
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            let move = SKAction.moveBy(x: dx, y: dy, duration: duration)
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: duration)
            let shrink = SKAction.scaleX(to: 0.5, duration: duration)
            
            let group = SKAction.group([move, fade, shrink])
            let remove = SKAction.removeFromParent()
            spark.run(SKAction.sequence([group, remove]))
        }
    }
    
    private func createSmoke(at position: CGPoint, in parentNode: SKNode) {
        for i in 0..<Config.smokeCount {
            let delay = TimeInterval(i) * 0.05
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let smoke = SKShapeNode(circleOfRadius: CGFloat.random(in: 15...25))
                smoke.fillColor = Colors.smoke
                smoke.strokeColor = .clear
                smoke.position = CGPoint(
                    x: position.x + CGFloat.random(in: -20...20),
                    y: position.y + CGFloat.random(in: -10...10)
                )
                smoke.zPosition = 11
                smoke.alpha = 0.6
                parentNode.addChild(smoke)
                
                // Animate smoke rising
                let rise = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: 40...80), duration: 1.0)
                rise.timingMode = .easeOut
                let expand = SKAction.scale(to: 2.0, duration: 1.0)
                let fade = SKAction.fadeOut(withDuration: 1.0)
                
                let group = SKAction.group([rise, expand, fade])
                let remove = SKAction.removeFromParent()
                smoke.run(SKAction.sequence([group, remove]))
            }
        }
    }
    
    private func createFlash(at position: CGPoint, in parentNode: SKNode, completion: @escaping () -> Void) {
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.6)
        flash.fillColor = Colors.explosionCore
        flash.strokeColor = Colors.explosionOuter
        flash.lineWidth = 4
        flash.position = position
        flash.zPosition = 16
        flash.alpha = 1.0
        parentNode.addChild(flash)
        
        let expand = SKAction.scale(to: 3.0, duration: 0.35)
        expand.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: 0.35)
        let group = SKAction.group([expand, fade])
        let remove = SKAction.removeFromParent()
        
        flash.run(SKAction.sequence([group, remove]), completion: completion)
    }
    
    // MARK: - Screen Shake
    
    private func triggerScreenShake() {
        guard let scene = scene else { return }
        
        let originalPosition = scene.position
        var shakeActions: [SKAction] = []
        
        let shakeCount = 6
        for i in 0..<shakeCount {
            let intensity = Config.shakeIntensity * (1.0 - CGFloat(i) / CGFloat(shakeCount))
            let offsetX = CGFloat.random(in: -intensity...intensity)
            let offsetY = CGFloat.random(in: -intensity...intensity)
            
            let move = SKAction.move(to: CGPoint(
                x: originalPosition.x + offsetX,
                y: originalPosition.y + offsetY
            ), duration: Config.shakeDuration / TimeInterval(shakeCount))
            shakeActions.append(move)
        }
        
        // Return to original position
        let reset = SKAction.move(to: originalPosition, duration: 0.05)
        shakeActions.append(reset)
        
        scene.run(SKAction.sequence(shakeActions))
    }
}
