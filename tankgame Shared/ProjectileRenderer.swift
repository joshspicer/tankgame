//
//  ProjectileRenderer.swift
//  tankgame Shared
//
//  Projectile rendering logic - clean retro style
//

import SpriteKit

/// Handles rendering of projectiles - simple clean design
class ProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render all projectiles as simple solid shapes
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            // Simple solid circle projectile
            let bullet = SKShapeNode(circleOfRadius: tileSize * 0.15)
            bullet.fillColor = RetroTheme.Colors.projectile
            bullet.strokeColor = SKColor(red: 1.0, green: 1.0, blue: 0.6, alpha: 1.0)
            bullet.lineWidth = 2
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
