//
//  ProjectileRenderer.swift
//  tankgame Shared
//
//  Projectile rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of projectiles
class ProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render all projectiles with classic solid styling
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            // Simple solid bullet - classic style
            let bullet = SKShapeNode(circleOfRadius: tileSize * 0.15)
            bullet.fillColor = .white
            bullet.strokeColor = .black
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
