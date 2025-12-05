//
//  GridRenderer.swift
//  tankgame Shared
//
//  Grid rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of the game grid with premium styling
class GridRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Premium colors
    private let floorColors: [SKColor] = [
        SKColor(red: 0.15, green: 0.18, blue: 0.22, alpha: 1.0),
        SKColor(red: 0.17, green: 0.20, blue: 0.24, alpha: 1.0)
    ]
    private let wallColor = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
    private let wallHighlightColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render the game grid with premium styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                
                if cell == .wall {
                    // Premium wall tile
                    let wallTile = createWallTile()
                    wallTile.position = gridPosition(row: row, col: col)
                    gridNode.addChild(wallTile)
                } else {
                    // Premium floor tile with checkered pattern
                    let floorTile = createFloorTile(row: row, col: col)
                    floorTile.position = gridPosition(row: row, col: col)
                    gridNode.addChild(floorTile)
                }
            }
        }
        
        // Add grid border
        addGridBorder(to: gridNode)
    }
    
    /// Create a premium wall tile with 3D effect
    private func createWallTile() -> SKNode {
        let tileNode = SKNode()
        
        // Main wall body
        let main = SKSpriteNode(color: wallColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        main.zPosition = 1
        tileNode.addChild(main)
        
        // Top highlight edge
        let topEdge = SKSpriteNode(color: wallHighlightColor, size: CGSize(width: tileSize - 2, height: 4))
        topEdge.position = CGPoint(x: 0, y: (tileSize - 6) / 2)
        topEdge.zPosition = 2
        tileNode.addChild(topEdge)
        
        // Left highlight edge
        let leftEdge = SKSpriteNode(color: wallHighlightColor.withAlphaComponent(0.7), size: CGSize(width: 4, height: tileSize - 2))
        leftEdge.position = CGPoint(x: -(tileSize - 6) / 2, y: 0)
        leftEdge.zPosition = 2
        tileNode.addChild(leftEdge)
        
        return tileNode
    }
    
    /// Create a premium floor tile with subtle pattern
    private func createFloorTile(row: Int, col: Int) -> SKNode {
        let tileNode = SKNode()
        
        // Checkered pattern
        let colorIndex = (row + col) % 2
        let baseColor = floorColors[colorIndex]
        
        let main = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        main.zPosition = 0
        tileNode.addChild(main)
        
        // Subtle inner border for depth
        let innerBorder = SKShapeNode(rectOf: CGSize(width: tileSize - 6, height: tileSize - 6), cornerRadius: 2)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = SKColor(white: 0.3, alpha: 0.15)
        innerBorder.lineWidth = 1
        innerBorder.zPosition = 0.5
        tileNode.addChild(innerBorder)
        
        return tileNode
    }
    
    /// Add a premium border around the grid
    private func addGridBorder(to gridNode: SKNode) {
        let gridWidth = CGFloat(gridSize) * tileSize
        let gridHeight = CGFloat(gridSize) * tileSize
        let centerX = gridWidth / 2 - tileSize / 2
        let centerY = gridHeight / 2 - tileSize / 2
        
        // Outer glow border
        let outerBorder = SKShapeNode(rectOf: CGSize(width: gridWidth + 8, height: gridHeight + 8), cornerRadius: 8)
        outerBorder.position = CGPoint(x: centerX, y: centerY)
        outerBorder.fillColor = .clear
        outerBorder.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.3)
        outerBorder.lineWidth = 2
        outerBorder.glowWidth = 4
        outerBorder.zPosition = -1
        gridNode.addChild(outerBorder)
        
        // Inner border
        let innerBorder = SKShapeNode(rectOf: CGSize(width: gridWidth + 2, height: gridHeight + 2), cornerRadius: 4)
        innerBorder.position = CGPoint(x: centerX, y: centerY)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = SKColor(white: 0.4, alpha: 0.5)
        innerBorder.lineWidth = 1
        innerBorder.zPosition = -0.5
        gridNode.addChild(innerBorder)
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
