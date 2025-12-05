//
//  ProjectileRenderer.swift
//  tankgame Shared
//
//  Projectile rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of projectiles with classic retro styling
class ProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render all projectiles with simple retro style
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            // Simple solid yellow bullet - classic retro style
            let bullet = SKSpriteNode(color: RetroColors.projectile, size: CGSize(width: tileSize * 0.35, height: tileSize * 0.35))
            bullet.zPosition = 5
            bullet.position = gridPosition(row: projectile.row, col: projectile.col)
            
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
