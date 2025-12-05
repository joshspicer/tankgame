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
    
    /// Render the game grid with modern styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        // Add grid background with border
        let gridWidth = CGFloat(gridSize) * tileSize
        let gridHeight = CGFloat(gridSize) * tileSize
        
        // Outer border glow
        let outerGlow = SKShapeNode(rectOf: CGSize(width: gridWidth + 12, height: gridHeight + 12), cornerRadius: 6)
        outerGlow.fillColor = GameTheme.Colors.primary.withAlphaComponent(0.1)
        outerGlow.strokeColor = GameTheme.Colors.primary.withAlphaComponent(0.3)
        outerGlow.lineWidth = 2
        outerGlow.position = CGPoint(x: gridWidth / 2, y: gridHeight / 2)
        outerGlow.zPosition = -3
        gridNode.addChild(outerGlow)
        
        // Grid background
        let background = SKShapeNode(rectOf: CGSize(width: gridWidth + 4, height: gridHeight + 4), cornerRadius: 4)
        background.fillColor = GameTheme.Colors.backgroundDark
        background.strokeColor = GameTheme.Colors.gridBorder
        background.lineWidth = 2
        background.position = CGPoint(x: gridWidth / 2, y: gridHeight / 2)
        background.zPosition = -2
        gridNode.addChild(background)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let position = gridPosition(row: row, col: col)
                
                if cell == .wall {
                    // Wall tile with modern styling
                    let wallTile = createWallTile()
                    wallTile.position = position
                    gridNode.addChild(wallTile)
                } else {
                    // Floor tile with subtle styling
                    let floorTile = createFloorTile(row: row, col: col)
                    floorTile.position = position
                    gridNode.addChild(floorTile)
                }
            }
        }
        
        // Add grid lines overlay for visual polish
        addGridLines(to: gridNode)
    }
    
    /// Create a styled wall tile
    private func createWallTile() -> SKNode {
        let wallNode = SKNode()
        
        // Main wall body
        let wallSize = CGSize(width: tileSize - 3, height: tileSize - 3)
        let wall = SKSpriteNode(color: GameTheme.Colors.gridWall, size: wallSize)
        wall.zPosition = 1
        wallNode.addChild(wall)
        
        // Top highlight for 3D effect
        let highlightSize = CGSize(width: tileSize - 6, height: 4)
        let highlight = SKSpriteNode(color: GameTheme.Colors.gridWall.withAlphaComponent(1.3), size: highlightSize)
        highlight.position = CGPoint(x: 0, y: (tileSize - 6) / 2 - 2)
        highlight.alpha = 0.4
        highlight.zPosition = 2
        wallNode.addChild(highlight)
        
        // Shadow on bottom/right for depth
        let shadowBottom = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.3), size: CGSize(width: tileSize - 4, height: 3))
        shadowBottom.position = CGPoint(x: 1, y: -(tileSize - 6) / 2 + 1)
        shadowBottom.zPosition = 0
        wallNode.addChild(shadowBottom)
        
        return wallNode
    }
    
    /// Create a styled floor tile
    private func createFloorTile(row: Int, col: Int) -> SKNode {
        let floorNode = SKNode()
        
        // Alternating subtle pattern for checkerboard effect
        let isEven = (row + col) % 2 == 0
        let baseColor = isEven ? GameTheme.Colors.gridFloor : GameTheme.Colors.gridFloor.withAlphaComponent(0.85)
        
        let floorSize = CGSize(width: tileSize - 2, height: tileSize - 2)
        let floor = SKSpriteNode(color: baseColor, size: floorSize)
        floor.zPosition = 0
        floorNode.addChild(floor)
        
        return floorNode
    }
    
    /// Add subtle grid lines for visual polish
    private func addGridLines(to gridNode: SKNode) {
        let gridWidth = CGFloat(gridSize) * tileSize
        let gridHeight = CGFloat(gridSize) * tileSize
        
        // Vertical lines
        for col in 0...gridSize {
            let x = CGFloat(col) * tileSize
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: gridHeight))
            line.path = path
            line.strokeColor = GameTheme.Colors.gridBorder.withAlphaComponent(0.15)
            line.lineWidth = 1
            line.zPosition = 3
            gridNode.addChild(line)
        }
        
        // Horizontal lines
        for row in 0...gridSize {
            let y = CGFloat(row) * tileSize
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: gridWidth, y: y))
            line.path = path
            line.strokeColor = GameTheme.Colors.gridBorder.withAlphaComponent(0.15)
            line.lineWidth = 1
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
