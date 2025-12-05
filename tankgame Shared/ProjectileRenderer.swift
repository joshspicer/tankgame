//
//  ProjectileRenderer.swift
//  tankgame Shared
//
//  Projectile rendering with modern visual effects
//

import SpriteKit

/// Handles rendering of projectiles with enhanced visual effects
class ProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    private let animationHelper: RainbowAnimationHelper
    
    // Modern projectile colors
    private let coreColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
    private let glowColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.6)
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Render all projectiles with enhanced visuals
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            let bulletNode = createBulletNode()
            bulletNode.position = gridPosition(row: projectile.row, col: projectile.col)
            bulletNode.zPosition = 5
            
            // Rotate based on projectile direction
            bulletNode.zRotation = CGFloat(projectile.direction.angle)
            
            projectilesNode.addChild(bulletNode)
        }
    }
    
    /// Create an enhanced bullet node with glow and trail effect
    private func createBulletNode() -> SKNode {
        let bulletNode = SKNode()
        
        // Outer glow
        let outerGlow = SKShapeNode(circleOfRadius: tileSize * 0.35)
        outerGlow.fillColor = glowColor
        outerGlow.strokeColor = .clear
        outerGlow.alpha = 0.5
        outerGlow.zPosition = -1
        bulletNode.addChild(outerGlow)
        
        // Glow pulse animation
        let glowPulseUp = SKAction.scale(to: 1.3, duration: 0.15)
        let glowPulseDown = SKAction.scale(to: 1.0, duration: 0.15)
        glowPulseUp.timingMode = .easeOut
        glowPulseDown.timingMode = .easeIn
        let glowPulse = SKAction.sequence([glowPulseUp, glowPulseDown])
        outerGlow.run(SKAction.repeatForever(glowPulse))
        
        // Inner glow ring
        let innerGlow = SKShapeNode(circleOfRadius: tileSize * 0.25)
        innerGlow.fillColor = coreColor.withAlphaComponent(0.7)
        innerGlow.strokeColor = .clear
        bulletNode.addChild(innerGlow)
        
        // Core projectile
        let core = SKShapeNode(circleOfRadius: tileSize * 0.15)
        core.fillColor = coreColor
        core.strokeColor = SKColor.white
        core.lineWidth = 2
        core.glowWidth = 3
        bulletNode.addChild(core)
        
        // Add rainbow color animation to core
        animationHelper.addRainbowAnimationToShape(core, phaseOffset: 0.5)
        
        // Pulsing scale animation for core
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.12)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.12)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        core.run(SKAction.repeatForever(pulse))
        
        // Trail effect (small particles behind)
        let trailEmitter = createTrailEffect()
        trailEmitter.position = CGPoint(x: 0, y: -tileSize * 0.2)
        bulletNode.addChild(trailEmitter)
        
        // Rotation animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.4)
        innerGlow.run(SKAction.repeatForever(rotate))
        
        return bulletNode
    }
    
    /// Create a simple trail effect
    private func createTrailEffect() -> SKNode {
        let trailNode = SKNode()
        
        // Create a few trailing particles
        for i in 0..<3 {
            let trailPart = SKShapeNode(circleOfRadius: tileSize * CGFloat(0.08 - Double(i) * 0.02))
            trailPart.fillColor = glowColor.withAlphaComponent(CGFloat(0.6 - Double(i) * 0.15))
            trailPart.strokeColor = .clear
            trailPart.position = CGPoint(x: 0, y: CGFloat(-i) * tileSize * 0.1)
            trailNode.addChild(trailPart)
        }
        
        return trailNode
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
