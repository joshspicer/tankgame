//
//  GridRenderer.swift
//  tankgame Shared
//
//  Grid rendering logic with modern visual styling
//

import SpriteKit

/// Handles rendering of the game grid with modern visual effects
class GridRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Modern color palette
    private let floorColor = SKColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1.0)
    private let floorAccentColor = SKColor(red: 0.22, green: 0.26, blue: 0.32, alpha: 1.0)
    private let wallColor = SKColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 1.0)
    private let wallAccentColor = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
    private let gridLineColor = SKColor(red: 0.25, green: 0.3, blue: 0.38, alpha: 0.3)
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render the game grid with modern visual styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        // Add grid background
        let gridBackground = SKShapeNode(rectOf: CGSize(width: CGFloat(gridSize) * tileSize + 4, height: CGFloat(gridSize) * tileSize + 4), cornerRadius: 8)
        gridBackground.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.14, alpha: 1.0)
        gridBackground.strokeColor = SKColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 0.5)
        gridBackground.lineWidth = 2
        gridBackground.position = CGPoint(x: CGFloat(gridSize) * tileSize / 2, y: CGFloat(gridSize) * tileSize / 2)
        gridBackground.zPosition = -2
        gridNode.addChild(gridBackground)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let position = gridPosition(row: row, col: col)
                
                if cell == .wall {
                    // Create wall tile with 3D effect
                    let wallTile = createWallTile()
                    wallTile.position = position
                    gridNode.addChild(wallTile)
                } else {
                    // Create floor tile with subtle pattern
                    let floorTile = createFloorTile(row: row, col: col)
                    floorTile.position = position
                    gridNode.addChild(floorTile)
                }
            }
        }
        
        // Add grid lines for visual clarity
        addGridLines(in: gridNode)
    }
    
    /// Create a floor tile with checkerboard-like pattern
    private func createFloorTile(row: Int, col: Int) -> SKNode {
        let tileNode = SKNode()
        
        // Alternate colors for subtle checkerboard
        let isAlternate = (row + col) % 2 == 0
        let baseColor = isAlternate ? floorColor : floorAccentColor
        
        let tile = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        tile.zPosition = -1
        tileNode.addChild(tile)
        
        // Add subtle corner markers
        let cornerSize: CGFloat = 4
        let cornerOffset = (tileSize - 2) / 2 - cornerSize / 2 - 2
        let cornerColor = gridLineColor
        
        for xMult in [-1.0, 1.0] {
            for yMult in [-1.0, 1.0] {
                let corner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize), cornerRadius: 1)
                corner.fillColor = cornerColor
                corner.strokeColor = .clear
                corner.position = CGPoint(x: cornerOffset * xMult, y: cornerOffset * yMult)
                corner.zPosition = 0
                tileNode.addChild(corner)
            }
        }
        
        return tileNode
    }
    
    /// Create a wall tile with 3D depth effect
    private func createWallTile() -> SKNode {
        let tileNode = SKNode()
        
        // Base shadow layer
        let shadow = SKSpriteNode(color: wallAccentColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = 0
        tileNode.addChild(shadow)
        
        // Main wall surface
        let wall = SKSpriteNode(color: wallColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        wall.zPosition = 1
        tileNode.addChild(wall)
        
        // Top highlight
        let highlightTop = SKSpriteNode(color: SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0), size: CGSize(width: tileSize - 6, height: 3))
        highlightTop.position = CGPoint(x: 0, y: (tileSize - 2) / 2 - 4)
        highlightTop.zPosition = 2
        tileNode.addChild(highlightTop)
        
        // Left highlight
        let highlightLeft = SKSpriteNode(color: SKColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1.0), size: CGSize(width: 3, height: tileSize - 10))
        highlightLeft.position = CGPoint(x: -(tileSize - 2) / 2 + 4, y: 0)
        highlightLeft.zPosition = 2
        tileNode.addChild(highlightLeft)
        
        return tileNode
    }
    
    /// Add subtle grid lines
    private func addGridLines(in gridNode: SKNode) {
        // Vertical lines
        for col in 0...gridSize {
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: CGFloat(gridSize) * tileSize))
            line.fillColor = gridLineColor
            line.strokeColor = .clear
            line.position = CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(gridSize) * tileSize / 2)
            line.zPosition = 0.5
            gridNode.addChild(line)
        }
        
        // Horizontal lines
        for row in 0...gridSize {
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat(gridSize) * tileSize, height: 1))
            line.fillColor = gridLineColor
            line.strokeColor = .clear
            line.position = CGPoint(x: CGFloat(gridSize) * tileSize / 2, y: CGFloat(row) * tileSize)
            line.zPosition = 0.5
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
