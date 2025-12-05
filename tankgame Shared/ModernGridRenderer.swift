//
//  ModernGridRenderer.swift
//  tankgame Shared
//
//  Modernized grid rendering with enhanced visuals
//

import SpriteKit

/// Handles rendering of the game grid with modern styling
class ModernGridRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Visual constants
    private let emptyColor: SKColor = SKColor(red: 0.15, green: 0.18, blue: 0.22, alpha: 1.0)
    private let wallColor: SKColor = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
    private let gridLineColor: SKColor = SKColor(white: 0.25, alpha: 0.5)
    private let accentColor: SKColor = .systemCyan
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Render the game grid with modern styling
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        // Create background layer
        createBackground(in: gridNode)
        
        // Create grid cells
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let tileNode = createTileNode(cell: cell, row: row, col: col)
                tileNode.position = gridPosition(row: row, col: col)
                gridNode.addChild(tileNode)
            }
        }
        
        // Create grid overlay lines
        createGridLines(in: gridNode)
        
        // Add corner accents
        createCornerAccents(in: gridNode)
    }
    
    /// Create background for the entire grid
    private func createBackground(in gridNode: SKNode) {
        let totalSize = CGFloat(gridSize) * tileSize
        let background = SKShapeNode(rectOf: CGSize(width: totalSize + 4, height: totalSize + 4), cornerRadius: 8)
        background.position = CGPoint(x: totalSize / 2, y: totalSize / 2)
        background.fillColor = SKColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1.0)
        background.strokeColor = accentColor.withAlphaComponent(0.3)
        background.lineWidth = 2
        background.glowWidth = 5
        background.zPosition = -10
        gridNode.addChild(background)
    }
    
    /// Create a single tile node
    private func createTileNode(cell: GridCell, row: Int, col: Int) -> SKNode {
        let container = SKNode()
        container.zPosition = 0
        
        let tileGap: CGFloat = 2
        let actualTileSize = tileSize - tileGap
        
        if cell == .wall {
            // Create wall with 3D effect
            createWallTile(in: container, size: actualTileSize)
        } else {
            // Create empty floor tile with subtle texture
            createFloorTile(in: container, size: actualTileSize, row: row, col: col)
        }
        
        return container
    }
    
    /// Create a wall tile with 3D depth effect
    private func createWallTile(in container: SKNode, size: CGFloat) {
        // Base wall
        let base = SKSpriteNode(color: wallColor, size: CGSize(width: size, height: size))
        base.zPosition = 1
        container.addChild(base)
        
        // Top highlight (lighter edge)
        let topHighlight = SKSpriteNode(
            color: SKColor(white: 0.2, alpha: 0.6),
            size: CGSize(width: size, height: 4)
        )
        topHighlight.position = CGPoint(x: 0, y: size / 2 - 2)
        topHighlight.zPosition = 2
        container.addChild(topHighlight)
        
        // Bottom shadow
        let bottomShadow = SKSpriteNode(
            color: SKColor.black.withAlphaComponent(0.4),
            size: CGSize(width: size, height: 4)
        )
        bottomShadow.position = CGPoint(x: 0, y: -size / 2 + 2)
        bottomShadow.zPosition = 2
        container.addChild(bottomShadow)
        
        // Inner pattern (brick-like)
        createWallPattern(in: container, size: size)
        
        // Add subtle inner glow
        let innerGlow = SKShapeNode(rectOf: CGSize(width: size - 8, height: size - 8), cornerRadius: 2)
        innerGlow.fillColor = .clear
        innerGlow.strokeColor = SKColor(white: 0.15, alpha: 0.5)
        innerGlow.lineWidth = 1
        innerGlow.zPosition = 3
        container.addChild(innerGlow)
    }
    
    /// Create a brick-like pattern for wall tiles
    private func createWallPattern(in container: SKNode, size: CGFloat) {
        let brickWidth = size / 2 - 2
        let brickHeight: CGFloat = size / 3 - 1
        let brickColor = SKColor(white: 0.12, alpha: 1.0)
        
        // Two rows of bricks
        let positions: [(CGFloat, CGFloat, CGFloat)] = [
            (-size/4, size/6, brickWidth),
            (size/4, size/6, brickWidth),
            (0, -size/6, size - 4)
        ]
        
        for (x, y, width) in positions {
            let brick = SKShapeNode(rectOf: CGSize(width: width, height: brickHeight), cornerRadius: 1)
            brick.position = CGPoint(x: x, y: y)
            brick.fillColor = brickColor
            brick.strokeColor = SKColor(white: 0.08, alpha: 1.0)
            brick.lineWidth = 1
            brick.zPosition = 2
            container.addChild(brick)
        }
    }
    
    /// Create a floor tile with subtle styling
    private func createFloorTile(in container: SKNode, size: CGFloat, row: Int, col: Int) {
        // Checkerboard pattern with subtle variation
        let isLight = (row + col) % 2 == 0
        let baseAlpha: CGFloat = isLight ? 1.0 : 0.85
        let tileColor = emptyColor.withAlphaComponent(baseAlpha)
        
        // Base floor
        let base = SKSpriteNode(color: tileColor, size: CGSize(width: size, height: size))
        base.zPosition = 0
        container.addChild(base)
        
        // Subtle inner shadow for depth
        let innerShadow = SKShapeNode(rectOf: CGSize(width: size - 4, height: size - 4), cornerRadius: 2)
        innerShadow.fillColor = .clear
        innerShadow.strokeColor = SKColor.black.withAlphaComponent(0.2)
        innerShadow.lineWidth = 1
        innerShadow.zPosition = 1
        container.addChild(innerShadow)
        
        // Random subtle detail (occasional dot pattern)
        if Int.random(in: 0...5) == 0 {
            let dot = SKShapeNode(circleOfRadius: 2)
            dot.fillColor = SKColor.white.withAlphaComponent(0.05)
            dot.strokeColor = .clear
            dot.position = CGPoint(
                x: CGFloat.random(in: -size/4...size/4),
                y: CGFloat.random(in: -size/4...size/4)
            )
            dot.zPosition = 1
            container.addChild(dot)
        }
    }
    
    /// Create grid overlay lines
    private func createGridLines(in gridNode: SKNode) {
        let totalSize = CGFloat(gridSize) * tileSize
        let linesNode = SKNode()
        linesNode.zPosition = 5
        
        // Vertical lines
        for i in 1..<gridSize {
            let x = CGFloat(i) * tileSize
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: totalSize))
            line.position = CGPoint(x: x, y: totalSize / 2)
            line.fillColor = gridLineColor
            line.strokeColor = .clear
            linesNode.addChild(line)
        }
        
        // Horizontal lines
        for i in 1..<gridSize {
            let y = CGFloat(i) * tileSize
            let line = SKShapeNode(rectOf: CGSize(width: totalSize, height: 1))
            line.position = CGPoint(x: totalSize / 2, y: y)
            line.fillColor = gridLineColor
            line.strokeColor = .clear
            linesNode.addChild(line)
        }
        
        gridNode.addChild(linesNode)
    }
    
    /// Create corner accent decorations
    private func createCornerAccents(in gridNode: SKNode) {
        let totalSize = CGFloat(gridSize) * tileSize
        let accentSize: CGFloat = 15
        
        let corners: [(CGFloat, CGFloat, CGFloat)] = [
            (0, totalSize, 0),                    // Top-left
            (totalSize, totalSize, -CGFloat.pi/2), // Top-right
            (0, 0, CGFloat.pi/2),                  // Bottom-left
            (totalSize, 0, CGFloat.pi)            // Bottom-right
        ]
        
        for (x, y, rotation) in corners {
            let accent = createCornerAccent(size: accentSize)
            accent.position = CGPoint(x: x, y: y)
            accent.zRotation = rotation
            accent.zPosition = 10
            gridNode.addChild(accent)
        }
    }
    
    /// Create a single corner accent
    private func createCornerAccent(size: CGFloat) -> SKNode {
        let container = SKNode()
        
        // L-shaped corner
        let hLine = SKShapeNode(rectOf: CGSize(width: size, height: 2))
        hLine.position = CGPoint(x: size / 2, y: 0)
        hLine.fillColor = accentColor.withAlphaComponent(0.6)
        hLine.strokeColor = .clear
        hLine.glowWidth = 2
        container.addChild(hLine)
        
        let vLine = SKShapeNode(rectOf: CGSize(width: 2, height: size))
        vLine.position = CGPoint(x: 0, y: -size / 2)
        vLine.fillColor = accentColor.withAlphaComponent(0.6)
        vLine.strokeColor = .clear
        vLine.glowWidth = 2
        container.addChild(vLine)
        
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
