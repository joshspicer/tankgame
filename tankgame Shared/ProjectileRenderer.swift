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
    
    private let animationHelper: RainbowAnimationHelper
    private let batmanAnimationHelper: BatmanAnimationHelper
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.animationHelper = RainbowAnimationHelper()
        self.batmanAnimationHelper = BatmanAnimationHelper()
    }
    
    /// Render all projectiles
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        let isBatmanMode = GameSettings.shared.isBatmanMode
        
        for projectile in projectiles {
            // Make projectile larger and more visible
            // Use Batman yellow accent color or regular yellow
            let bulletColor: SKColor = isBatmanMode ? BatmanAnimationHelper.accentColor : .yellow
            let bullet = SKSpriteNode(color: bulletColor, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.5))
            bullet.zPosition = 5
            bullet.position = gridPosition(row: projectile.row, col: projectile.col)
            
            // Add color animation based on mode
            if isBatmanMode {
                batmanAnimationHelper.addBatmanAnimation(to: bullet, phaseOffset: 0.5)
            } else {
                animationHelper.addRainbowAnimation(to: bullet, phaseOffset: 0.5)
            }
            
            // Add pulsing scale animation
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            let repeatPulse = SKAction.repeatForever(pulse)
            bullet.run(repeatPulse)
            
            // Add rotation animation based on direction
            let rotationDuration: TimeInterval = 0.5
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: rotationDuration)
            let repeatRotation = SKAction.repeatForever(rotate)
            bullet.run(repeatRotation)
            
            projectilesNode.addChild(bullet)
        }
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
