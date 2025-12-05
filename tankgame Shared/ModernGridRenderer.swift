//
//  ModernGridRenderer.swift
//  tankgame Shared
//
//  Enhanced grid rendering with modern visual styling
//

import SpriteKit

/// Enhanced grid rendering with modern visual styling
class ModernGridRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render the game grid with modern styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        // Add subtle background glow
        let gridWidth = CGFloat(gridSize) * tileSize
        let gridHeight = CGFloat(gridSize) * tileSize
        let backgroundGlow = SKShapeNode(rectOf: CGSize(width: gridWidth + 20, height: gridHeight + 20), cornerRadius: 8)
        backgroundGlow.fillColor = SKColor(red: 0.15, green: 0.2, blue: 0.35, alpha: 0.5)
        backgroundGlow.strokeColor = SKColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 0.6)
        backgroundGlow.lineWidth = 2
        backgroundGlow.glowWidth = 4
        backgroundGlow.position = CGPoint(x: gridWidth / 2, y: gridHeight / 2)
        backgroundGlow.zPosition = -2
        gridNode.addChild(backgroundGlow)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let tile = createModernTile(for: cell)
                tile.position = gridPosition(row: row, col: col)
                gridNode.addChild(tile)
            }
        }
        
        // Add grid lines
        addGridLines(to: gridNode)
    }
    
    /// Create a modern styled tile
    private func createModernTile(for cell: GridCell) -> SKNode {
        let tileNode = SKNode()
        
        let size = CGSize(width: tileSize - 2, height: tileSize - 2)
        
        if cell == .wall {
            // Wall tile - darker with depth effect
            let tile = SKShapeNode(rectOf: size, cornerRadius: 4)
            tile.fillColor = SKColor(red: 0.08, green: 0.1, blue: 0.15, alpha: 1.0)
            tile.strokeColor = SKColor(red: 0.15, green: 0.18, blue: 0.25, alpha: 0.8)
            tile.lineWidth = 1
            tileNode.addChild(tile)
            
            // Add inner shadow effect
            let innerShadow = SKShapeNode(rectOf: CGSize(width: size.width - 8, height: size.height - 8), cornerRadius: 2)
            innerShadow.fillColor = SKColor(white: 0, alpha: 0.3)
            innerShadow.strokeColor = .clear
            innerShadow.position = CGPoint(x: 2, y: -2)
            tileNode.addChild(innerShadow)
            
            // Add top highlight
            let highlight = SKShapeNode(rectOf: CGSize(width: size.width - 8, height: 4), cornerRadius: 2)
            highlight.fillColor = SKColor(white: 1, alpha: 0.1)
            highlight.strokeColor = .clear
            highlight.position = CGPoint(x: 0, y: size.height / 2 - 6)
            tileNode.addChild(highlight)
        } else {
            // Empty tile - lighter with subtle pattern
            let tile = SKShapeNode(rectOf: size, cornerRadius: 2)
            tile.fillColor = SKColor(red: 0.22, green: 0.27, blue: 0.38, alpha: 1.0)
            tile.strokeColor = SKColor(red: 0.28, green: 0.33, blue: 0.45, alpha: 0.6)
            tile.lineWidth = 0.5
            tileNode.addChild(tile)
            
            // Add subtle inner highlight
            let innerHighlight = SKShapeNode(rectOf: CGSize(width: size.width - 4, height: size.height / 2 - 2), cornerRadius: 1)
            innerHighlight.fillColor = SKColor(white: 1, alpha: 0.03)
            innerHighlight.strokeColor = .clear
            innerHighlight.position = CGPoint(x: 0, y: size.height / 4 - 1)
            tileNode.addChild(innerHighlight)
        }
        
        return tileNode
    }
    
    /// Add subtle grid lines
    private func addGridLines(to gridNode: SKNode) {
        let lineColor = SKColor(white: 1, alpha: 0.08)
        
        // Vertical lines
        for col in 0...gridSize {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: CGFloat(col) * tileSize, y: 0))
            path.addLine(to: CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(gridSize) * tileSize))
            line.path = path
            line.strokeColor = lineColor
            line.lineWidth = 0.5
            line.zPosition = 1
            gridNode.addChild(line)
        }
        
        // Horizontal lines
        for row in 0...gridSize {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: CGFloat(row) * tileSize))
            path.addLine(to: CGPoint(x: CGFloat(gridSize) * tileSize, y: CGFloat(row) * tileSize))
            line.path = path
            line.strokeColor = lineColor
            line.lineWidth = 0.5
            line.zPosition = 1
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
