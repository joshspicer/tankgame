//
//  ModernGridRenderer.swift
//  tankgame Shared
//
//  Enhanced grid rendering with modern visual styling
//

import SpriteKit

/// Modern styled grid renderer with enhanced visuals
class ModernGridRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Color palette for modern grid
    private let floorColorPrimary = SKColor(red: 0.22, green: 0.28, blue: 0.38, alpha: 1.0)
    private let floorColorSecondary = SKColor(red: 0.18, green: 0.24, blue: 0.34, alpha: 1.0)
    private let wallColor = SKColor(red: 0.12, green: 0.15, blue: 0.22, alpha: 1.0)
    private let wallHighlight = SKColor(red: 0.25, green: 0.30, blue: 0.42, alpha: 1.0)
    private let gridLineColor = SKColor.white.withAlphaComponent(0.08)
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render the game grid with modern styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        // Add subtle grid background pattern
        addGridBackground(to: gridNode)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let position = gridPosition(row: row, col: col)
                
                if cell == .wall {
                    addWallTile(at: position, in: gridNode)
                } else {
                    addFloorTile(at: position, row: row, col: col, in: gridNode)
                }
            }
        }
        
        // Add grid lines overlay
        addGridLines(to: gridNode)
    }
    
    /// Add subtle background pattern
    private func addGridBackground(to gridNode: SKNode) {
        let bgSize = CGSize(
            width: CGFloat(gridSize) * tileSize,
            height: CGFloat(gridSize) * tileSize
        )
        let background = SKSpriteNode(color: floorColorSecondary, size: bgSize)
        background.position = CGPoint(x: bgSize.width / 2, y: bgSize.height / 2)
        background.zPosition = -2
        gridNode.addChild(background)
    }
    
    /// Add grid lines for visual polish
    private func addGridLines(to gridNode: SKNode) {
        let gridWidth = CGFloat(gridSize) * tileSize
        let gridHeight = CGFloat(gridSize) * tileSize
        
        // Vertical lines
        for i in 0...gridSize {
            let x = CGFloat(i) * tileSize
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: gridHeight))
            line.path = path
            line.strokeColor = gridLineColor
            line.lineWidth = 1
            line.zPosition = 2
            gridNode.addChild(line)
        }
        
        // Horizontal lines
        for i in 0...gridSize {
            let y = CGFloat(i) * tileSize
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: gridWidth, y: y))
            line.path = path
            line.strokeColor = gridLineColor
            line.lineWidth = 1
            line.zPosition = 2
            gridNode.addChild(line)
        }
    }
    
    /// Add a modern styled floor tile
    private func addFloorTile(at position: CGPoint, row: Int, col: Int, in gridNode: SKNode) {
        // Checkerboard pattern
        let isAlternate = (row + col) % 2 == 0
        let baseColor = isAlternate ? floorColorPrimary : floorColorSecondary
        
        let tile = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize - 1, height: tileSize - 1))
        tile.position = position
        tile.zPosition = 0
        gridNode.addChild(tile)
    }
    
    /// Add a modern styled wall tile with depth effect
    private func addWallTile(at position: CGPoint, in gridNode: SKNode) {
        // Wall shadow (depth effect)
        let shadow = SKSpriteNode(
            color: SKColor.black.withAlphaComponent(0.4),
            size: CGSize(width: tileSize - 2, height: tileSize - 2)
        )
        shadow.position = CGPoint(x: position.x + 2, y: position.y - 2)
        shadow.zPosition = 0
        gridNode.addChild(shadow)
        
        // Main wall block
        let wall = SKSpriteNode(color: wallColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        wall.position = position
        wall.zPosition = 1
        gridNode.addChild(wall)
        
        // Highlight edge (top-left)
        let highlightSize = CGSize(width: tileSize - 4, height: 3)
        let highlight = SKSpriteNode(color: wallHighlight, size: highlightSize)
        highlight.position = CGPoint(x: position.x, y: position.y + (tileSize - 6) / 2)
        highlight.zPosition = 1.5
        gridNode.addChild(highlight)
        
        // Side highlight
        let sideHighlight = SKSpriteNode(
            color: wallHighlight,
            size: CGSize(width: 3, height: tileSize - 8)
        )
        sideHighlight.position = CGPoint(x: position.x - (tileSize - 8) / 2, y: position.y)
        sideHighlight.zPosition = 1.5
        gridNode.addChild(sideHighlight)
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
