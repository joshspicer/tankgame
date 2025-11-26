//
//  GridRenderer.swift
//  tankgame Shared
//
//  Grid rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of the game grid
class GridRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render the game grid
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        let isBatmanMode = GameSettings.shared.isBatmanMode
        
        // Choose colors based on mode
        let wallColor: SKColor = isBatmanMode ? BatmanAnimationHelper.darkColor : .black
        let emptyColor: SKColor = isBatmanMode ? SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0) : .white
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let tile = SKSpriteNode(color: cell == .wall ? wallColor : emptyColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
                tile.position = gridPosition(row: row, col: col)
                gridNode.addChild(tile)
            }
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
