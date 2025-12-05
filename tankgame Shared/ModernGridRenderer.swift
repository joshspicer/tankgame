//
//  ModernGridRenderer.swift
//  tankgame Shared
//
//  Enhanced grid rendering with modern tile styling and visual effects
//

import SpriteKit

/// Modern grid renderer with enhanced tile visuals and effects
class ModernGridRenderer {
    
    // MARK: - Properties
    
    let tileSize: CGFloat
    let gridSize: Int
    
    // MARK: - Colors
    
    struct Colors {
        // Floor tile colors - subtle gradient effect
        static let floorPrimary = SKColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 1.0)
        static let floorSecondary = SKColor(red: 0.80, green: 0.84, blue: 0.88, alpha: 1.0)
        static let floorAccent = SKColor(red: 0.75, green: 0.80, blue: 0.85, alpha: 1.0)
        
        // Wall colors - darker, more prominent
        static let wallPrimary = SKColor(red: 0.15, green: 0.18, blue: 0.25, alpha: 1.0)
        static let wallHighlight = SKColor(red: 0.25, green: 0.28, blue: 0.35, alpha: 1.0)
        static let wallShadow = SKColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0)
        
        // Grid lines
        static let gridLine = SKColor(red: 0.7, green: 0.75, blue: 0.8, alpha: 0.3)
        
        // Background
        static let background = SKColor(red: 0.12, green: 0.14, blue: 0.2, alpha: 1.0)
    }
    
    // MARK: - Initialization
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    // MARK: - Grid Rendering
    
    /// Render the game grid with modern styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        // Add background for the entire grid area
        addGridBackground(to: gridNode)
        
        // Render each cell
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let tileNode = createTile(for: cell, row: row, col: col)
                tileNode.position = gridPosition(row: row, col: col)
                gridNode.addChild(tileNode)
            }
        }
        
        // Add subtle grid lines overlay
        addGridLines(to: gridNode)
    }
    
    // MARK: - Tile Creation
    
    private func createTile(for cell: GridCell, row: Int, col: Int) -> SKNode {
        switch cell {
        case .empty:
            return createFloorTile(row: row, col: col)
        case .wall:
            return createWallTile(row: row, col: col)
        }
    }
    
    private func createFloorTile(row: Int, col: Int) -> SKNode {
        let tileNode = SKNode()
        
        // Checkerboard pattern for visual interest
        let isEvenTile = (row + col) % 2 == 0
        let baseColor = isEvenTile ? Colors.floorPrimary : Colors.floorSecondary
        
        // Main tile
        let tile = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        tile.zPosition = 0
        tileNode.addChild(tile)
        
        // Subtle inner shadow for depth
        let innerShadow = SKShapeNode(rectOf: CGSize(width: tileSize - 4, height: tileSize - 4), cornerRadius: 2)
        innerShadow.fillColor = .clear
        innerShadow.strokeColor = Colors.floorAccent
        innerShadow.lineWidth = 1
        innerShadow.alpha = 0.5
        innerShadow.zPosition = 1
        tileNode.addChild(innerShadow)
        
        return tileNode
    }
    
    private func createWallTile(row: Int, col: Int) -> SKNode {
        let tileNode = SKNode()
        
        // Shadow layer (offset for 3D effect)
        let shadow = SKSpriteNode(color: Colors.wallShadow, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = 0
        tileNode.addChild(shadow)
        
        // Main wall tile
        let wall = SKSpriteNode(color: Colors.wallPrimary, size: CGSize(width: tileSize - 2, height: tileSize - 2))
        wall.zPosition = 1
        tileNode.addChild(wall)
        
        // Top highlight for 3D effect
        let highlight = SKShapeNode(rectOf: CGSize(width: tileSize - 4, height: 4))
        highlight.fillColor = Colors.wallHighlight
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: (tileSize - 2) / 2 - 3)
        highlight.zPosition = 2
        tileNode.addChild(highlight)
        
        // Left highlight
        let leftHighlight = SKShapeNode(rectOf: CGSize(width: 4, height: tileSize - 8))
        leftHighlight.fillColor = Colors.wallHighlight.withAlphaComponent(0.5)
        leftHighlight.strokeColor = .clear
        leftHighlight.position = CGPoint(x: -(tileSize - 2) / 2 + 3, y: 0)
        leftHighlight.zPosition = 2
        tileNode.addChild(leftHighlight)
        
        // Wall pattern/texture (subtle cross pattern)
        addWallPattern(to: tileNode)
        
        return tileNode
    }
    
    private func addWallPattern(to node: SKNode) {
        let patternSize: CGFloat = 8
        let spacing: CGFloat = 16
        
        for x in stride(from: -tileSize/3, to: tileSize/3, by: spacing) {
            for y in stride(from: -tileSize/3, to: tileSize/3, by: spacing) {
                let dot = SKShapeNode(circleOfRadius: 1.5)
                dot.fillColor = Colors.wallHighlight.withAlphaComponent(0.3)
                dot.strokeColor = .clear
                dot.position = CGPoint(x: x, y: y)
                dot.zPosition = 3
                node.addChild(dot)
            }
        }
    }
    
    // MARK: - Grid Background and Lines
    
    private func addGridBackground(to node: SKNode) {
        let totalWidth = CGFloat(gridSize) * tileSize
        let totalHeight = CGFloat(gridSize) * tileSize
        
        let background = SKSpriteNode(color: Colors.background, size: CGSize(width: totalWidth + 4, height: totalHeight + 4))
        background.position = CGPoint(x: totalWidth / 2, y: totalHeight / 2)
        background.zPosition = -2
        node.addChild(background)
        
        // Outer border
        let border = SKShapeNode(rectOf: CGSize(width: totalWidth + 8, height: totalHeight + 8), cornerRadius: 4)
        border.fillColor = .clear
        border.strokeColor = SKColor.white.withAlphaComponent(0.2)
        border.lineWidth = 2
        border.position = CGPoint(x: totalWidth / 2, y: totalHeight / 2)
        border.zPosition = 10
        node.addChild(border)
    }
    
    private func addGridLines(to node: SKNode) {
        let totalWidth = CGFloat(gridSize) * tileSize
        let totalHeight = CGFloat(gridSize) * tileSize
        
        // Horizontal lines
        for row in 0...gridSize {
            let line = SKShapeNode(rectOf: CGSize(width: totalWidth, height: 1))
            line.fillColor = Colors.gridLine
            line.strokeColor = .clear
            line.position = CGPoint(x: totalWidth / 2, y: CGFloat(row) * tileSize)
            line.zPosition = 5
            node.addChild(line)
        }
        
        // Vertical lines
        for col in 0...gridSize {
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: totalHeight))
            line.fillColor = Colors.gridLine
            line.strokeColor = .clear
            line.position = CGPoint(x: CGFloat(col) * tileSize, y: totalHeight / 2)
            line.zPosition = 5
            node.addChild(line)
        }
    }
    
    // MARK: - Position Helpers
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
