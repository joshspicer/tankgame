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
    
    /// Render the game grid with modern styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        // Add background panel
        let backgroundSize = CGFloat(gridSize) * tileSize
        let backgroundRect = CGRect(
            x: 0,
            y: 0,
            width: backgroundSize,
            height: backgroundSize
        )
        let background = SKShapeNode(rect: backgroundRect, cornerRadius: 12)
        background.fillColor = SKColor(white: 0.15, alpha: 0.9)
        background.strokeColor = SKColor.white.withAlphaComponent(0.2)
        background.lineWidth = 2
        background.zPosition = -2
        gridNode.addChild(background)
        
        // Render grid tiles
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let tile = createTile(for: cell, row: row, col: col)
                tile.position = gridPosition(row: row, col: col)
                gridNode.addChild(tile)
            }
        }
        
        // Add subtle grid lines
        addGridLines(to: gridNode)
    }
    
    /// Create a tile node for a grid cell with modern styling
    private func createTile(for cell: GridCell, row: Int, col: Int) -> SKNode {
        let tileNode = SKNode()
        let innerSize = tileSize - 4
        
        if cell == .wall {
            // Modern wall design
            let wallTile = SKShapeNode(rectOf: CGSize(width: innerSize, height: innerSize), cornerRadius: 6)
            wallTile.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
            wallTile.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.8)
            wallTile.lineWidth = 2
            wallTile.zPosition = 1
            tileNode.addChild(wallTile)
            
            // Add subtle texture pattern
            let pattern = SKShapeNode(rectOf: CGSize(width: innerSize * 0.7, height: innerSize * 0.7), cornerRadius: 4)
            pattern.fillColor = SKColor(white: 0.25, alpha: 0.3)
            pattern.strokeColor = .clear
            pattern.zPosition = 2
            tileNode.addChild(pattern)
            
        } else {
            // Modern floor design with checker pattern
            let isEvenTile = (row + col) % 2 == 0
            let baseColor = isEvenTile ? 
                SKColor(red: 0.85, green: 0.88, blue: 0.9, alpha: 1.0) :
                SKColor(red: 0.9, green: 0.92, blue: 0.95, alpha: 1.0)
            
            let floorTile = SKShapeNode(rectOf: CGSize(width: innerSize, height: innerSize), cornerRadius: 4)
            floorTile.fillColor = baseColor
            floorTile.strokeColor = SKColor(white: 0.7, alpha: 0.3)
            floorTile.lineWidth = 1
            floorTile.zPosition = 0
            tileNode.addChild(floorTile)
        }
        
        return tileNode
    }
    
    /// Add subtle grid lines overlay
    private func addGridLines(to gridNode: SKNode) {
        let gridLineColor = SKColor.white.withAlphaComponent(0.08)
        
        // Vertical lines
        for i in 0...gridSize {
            let x = CGFloat(i) * tileSize
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: CGFloat(gridSize) * tileSize))
            line.fillColor = gridLineColor
            line.strokeColor = .clear
            line.position = CGPoint(x: x, y: CGFloat(gridSize) * tileSize / 2)
            line.zPosition = 3
            gridNode.addChild(line)
        }
        
        // Horizontal lines
        for i in 0...gridSize {
            let y = CGFloat(i) * tileSize
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat(gridSize) * tileSize, height: 1))
            line.fillColor = gridLineColor
            line.strokeColor = .clear
            line.position = CGPoint(x: CGFloat(gridSize) * tileSize / 2, y: y)
            line.zPosition = 3
            gridNode.addChild(line)
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
