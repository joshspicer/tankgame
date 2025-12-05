//
//  ProjectileRenderer.swift
//  tankgame Shared
//
//  Projectile rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of projectiles with animations
class ProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render all projectiles with modern styling
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            let bulletNode = createProjectileNode()
            bulletNode.position = gridPosition(row: projectile.row, col: projectile.col)
            projectilesNode.addChild(bulletNode)
        }
    }
    
    /// Create a styled projectile node
    private func createProjectileNode() -> SKNode {
        let containerNode = SKNode()
        containerNode.zPosition = 15
        
        // Outer glow
        let outerGlow = SKShapeNode(circleOfRadius: tileSize * 0.35)
        outerGlow.fillColor = GameTheme.Colors.projectileGlow
        outerGlow.strokeColor = .clear
        outerGlow.alpha = 0.5
        outerGlow.zPosition = -1
        containerNode.addChild(outerGlow)
        
        // Inner glow
        let innerGlow = SKShapeNode(circleOfRadius: tileSize * 0.25)
        innerGlow.fillColor = GameTheme.Colors.projectileCore.withAlphaComponent(0.6)
        innerGlow.strokeColor = .clear
        innerGlow.zPosition = 0
        containerNode.addChild(innerGlow)
        
        // Core
        let core = SKShapeNode(circleOfRadius: tileSize * 0.15)
        core.fillColor = GameTheme.Colors.projectileCore
        core.strokeColor = SKColor.white.withAlphaComponent(0.8)
        core.lineWidth = 1
        core.glowWidth = 2
        core.zPosition = 1
        containerNode.addChild(core)
        
        // Pulsing animation for glow
        let pulseUp = SKAction.fadeAlpha(to: 0.8, duration: 0.15)
        let pulseDown = SKAction.fadeAlpha(to: 0.4, duration: 0.15)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulseSequence)
        outerGlow.run(repeatPulse)
        
        // Scale pulse for core
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.2)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatScale = SKAction.repeatForever(scaleSequence)
        core.run(repeatScale)
        
        // Subtle rotation for visual interest
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.8)
        let repeatRotate = SKAction.repeatForever(rotate)
        innerGlow.run(repeatRotate)
        
        return containerNode
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
