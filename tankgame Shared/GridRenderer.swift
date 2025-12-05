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
        
        // Create subtle grid lines first
        addGridLines(to: gridNode)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let position = gridPosition(row: row, col: col)
                
                if cell == .wall {
                    createWallTile(at: position, in: gridNode)
                } else {
                    createFloorTile(at: position, in: gridNode, row: row, col: col)
                }
            }
        }
    }
    
    /// Create a floor tile with subtle pattern
    private func createFloorTile(at position: CGPoint, in gridNode: SKNode, row: Int, col: Int) {
        let tile = SKSpriteNode(color: UXTheme.gridFloor, size: CGSize(width: tileSize - 1, height: tileSize - 1))
        tile.position = position
        tile.zPosition = 0
        gridNode.addChild(tile)
        
        // Add subtle checkerboard pattern
        if (row + col) % 2 == 0 {
            let overlay = SKSpriteNode(color: UXTheme.gridPattern, size: CGSize(width: tileSize - 1, height: tileSize - 1))
            overlay.position = position
            overlay.zPosition = 1
            gridNode.addChild(overlay)
        }
        
        // Add corner dots for texture
        addCornerDots(at: position, in: gridNode)
    }
    
    /// Create a wall tile with 3D effect
    private func createWallTile(at position: CGPoint, in gridNode: SKNode) {
        // Main wall block
        let tile = SKSpriteNode(color: UXTheme.gridWall, size: CGSize(width: tileSize - 1, height: tileSize - 1))
        tile.position = position
        tile.zPosition = 2
        gridNode.addChild(tile)
        
        // Top highlight edge for 3D effect
        let highlightSize: CGFloat = tileSize - 1
        let highlight = SKSpriteNode(
            color: UXTheme.gridWallHighlight,
            size: CGSize(width: highlightSize, height: 4)
        )
        highlight.position = CGPoint(x: position.x, y: position.y + (tileSize - 1) / 2 - 2)
        highlight.zPosition = 3
        gridNode.addChild(highlight)
        
        // Left highlight edge
        let leftHighlight = SKSpriteNode(
            color: UXTheme.gridWallHighlight,
            size: CGSize(width: 4, height: highlightSize)
        )
        leftHighlight.position = CGPoint(x: position.x - (tileSize - 1) / 2 + 2, y: position.y)
        leftHighlight.zPosition = 3
        gridNode.addChild(leftHighlight)
        
        // Bottom shadow edge for depth
        let shadow = SKSpriteNode(
            color: SKColor.black.withAlphaComponent(0.3),
            size: CGSize(width: highlightSize, height: 3)
        )
        shadow.position = CGPoint(x: position.x, y: position.y - (tileSize - 1) / 2 + 1)
        shadow.zPosition = 3
        gridNode.addChild(shadow)
    }
    
    /// Add subtle corner dots for floor texture
    private func addCornerDots(at position: CGPoint, in gridNode: SKNode) {
        let dotSize: CGFloat = 2
        let offset = (tileSize - 1) / 2 - 6
        let dotColor = SKColor.white.withAlphaComponent(0.03)
        
        let positions = [
            CGPoint(x: -offset, y: -offset),
            CGPoint(x: offset, y: -offset),
            CGPoint(x: -offset, y: offset),
            CGPoint(x: offset, y: offset)
        ]
        
        for dotPos in positions {
            let dot = SKShapeNode(circleOfRadius: dotSize)
            dot.fillColor = dotColor
            dot.strokeColor = .clear
            dot.position = CGPoint(x: position.x + dotPos.x, y: position.y + dotPos.y)
            dot.zPosition = 1
            gridNode.addChild(dot)
        }
    }
    
    /// Add subtle grid lines
    private func addGridLines(to gridNode: SKNode) {
        let lineColor = SKColor.white.withAlphaComponent(0.03)
        let totalSize = CGFloat(gridSize) * tileSize
        
        // Vertical lines
        for col in 0...gridSize {
            let x = CGFloat(col) * tileSize
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: totalSize))
            line.path = path
            line.strokeColor = lineColor
            line.lineWidth = 1
            line.zPosition = -1
            gridNode.addChild(line)
        }
        
        // Horizontal lines
        for row in 0...gridSize {
            let y = CGFloat(row) * tileSize
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: totalSize, y: y))
            line.path = path
            line.strokeColor = lineColor
            line.lineWidth = 1
            line.zPosition = -1
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
