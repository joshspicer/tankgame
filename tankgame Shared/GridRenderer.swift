//
//  GridRenderer.swift
//  tankgame Shared
//
//  Grid rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of the game grid with modern styling
class GridRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render the game grid with enhanced visuals
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        // Add subtle grid background
        let gridWidth = CGFloat(gridSize) * tileSize
        let gridHeight = CGFloat(gridSize) * tileSize
        let gridBg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: gridWidth, height: gridHeight), cornerRadius: 8)
        gridBg.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
        gridBg.strokeColor = SKColor(red: 0.2, green: 0.25, blue: 0.4, alpha: 0.5)
        gridBg.lineWidth = 2
        gridBg.zPosition = -10
        gridNode.addChild(gridBg)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let position = gridPosition(row: row, col: col)
                
                if cell == .wall {
                    // Wall tiles with 3D effect
                    let wallTile = createWallTile()
                    wallTile.position = position
                    gridNode.addChild(wallTile)
                } else {
                    // Floor tiles with subtle pattern
                    let floorTile = createFloorTile(row: row, col: col)
                    floorTile.position = position
                    gridNode.addChild(floorTile)
                }
            }
        }
    }
    
    /// Create a wall tile with 3D effect
    private func createWallTile() -> SKNode {
        let container = SKNode()
        
        // Main wall block
        let wallSize = CGSize(width: tileSize - 4, height: tileSize - 4)
        let wall = SKSpriteNode(color: SKColor(red: 0.2, green: 0.22, blue: 0.3, alpha: 1.0), size: wallSize)
        wall.zPosition = 1
        container.addChild(wall)
        
        // Top highlight (3D effect)
        let highlightSize = CGSize(width: tileSize - 4, height: 6)
        let highlight = SKSpriteNode(color: SKColor(red: 0.35, green: 0.38, blue: 0.5, alpha: 1.0), size: highlightSize)
        highlight.position = CGPoint(x: 0, y: (tileSize - 4) / 2 - 3)
        highlight.zPosition = 2
        container.addChild(highlight)
        
        // Side shadow (3D effect)
        let shadowSize = CGSize(width: 6, height: tileSize - 4)
        let shadow = SKSpriteNode(color: SKColor(red: 0.1, green: 0.12, blue: 0.18, alpha: 1.0), size: shadowSize)
        shadow.position = CGPoint(x: (tileSize - 4) / 2 - 3, y: 0)
        shadow.zPosition = 2
        container.addChild(shadow)
        
        // Corner accent
        let cornerSize = CGSize(width: 6, height: 6)
        let corner = SKSpriteNode(color: SKColor(red: 0.15, green: 0.17, blue: 0.24, alpha: 1.0), size: cornerSize)
        corner.position = CGPoint(x: (tileSize - 4) / 2 - 3, y: (tileSize - 4) / 2 - 3)
        corner.zPosition = 3
        container.addChild(corner)
        
        return container
    }
    
    /// Create a floor tile with subtle checkerboard pattern
    private func createFloorTile(row: Int, col: Int) -> SKNode {
        let container = SKNode()
        
        let tileInnerSize = CGSize(width: tileSize - 2, height: tileSize - 2)
        
        // Alternating floor colors for subtle checkerboard
        let isEven = (row + col) % 2 == 0
        let baseColor = isEven
            ? SKColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 1.0)
            : SKColor(red: 0.78, green: 0.82, blue: 0.88, alpha: 1.0)
        
        let floor = SKSpriteNode(color: baseColor, size: tileInnerSize)
        floor.zPosition = 0
        container.addChild(floor)
        
        // Subtle inner border
        let border = SKShapeNode(rect: CGRect(x: -tileInnerSize.width/2 + 2, y: -tileInnerSize.height/2 + 2, 
                                               width: tileInnerSize.width - 4, height: tileInnerSize.height - 4))
        border.fillColor = .clear
        border.strokeColor = SKColor(red: 0.7, green: 0.75, blue: 0.82, alpha: 0.3)
        border.lineWidth = 1
        border.zPosition = 0.5
        container.addChild(border)
        
        return container
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
