//
//  GridRenderer.swift
//  tankgame Shared
//
//  Grid rendering logic - clean retro style
//

import SpriteKit

/// Handles rendering of the game grid - clean retro design
class GridRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render the game grid with clean retro styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                
                // Use retro theme colors
                let cellColor: SKColor
                if cell == .wall {
                    cellColor = RetroTheme.Colors.gridWall
                } else {
                    // Subtle checkerboard pattern for floor
                    let isLight = (row + col) % 2 == 0
                    cellColor = isLight ? RetroTheme.Colors.gridFloor : RetroTheme.Colors.gridFloor.withAlphaComponent(0.85)
                }
                
                let tile = SKSpriteNode(color: cellColor, size: CGSize(width: tileSize - 1, height: tileSize - 1))
                tile.position = gridPosition(row: row, col: col)
                gridNode.addChild(tile)
            }
        }
        
        // Add grid border
        let borderRect = CGRect(
            x: 0,
            y: 0,
            width: CGFloat(gridSize) * tileSize,
            height: CGFloat(gridSize) * tileSize
        )
        let border = SKShapeNode(rect: borderRect)
        border.strokeColor = RetroTheme.Colors.textSecondary
        border.lineWidth = 2
        border.fillColor = .clear
        border.position = CGPoint(x: -tileSize / 2, y: -tileSize / 2)
        gridNode.addChild(border)
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
