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
    
    /// Render the game grid
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        let isFunkyMode = FunkyMode.shared.isEnabled
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let baseColor: SKColor = cell == .wall ? .black : .white
                let tile = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
                tile.position = gridPosition(row: row, col: col)
                
                // In funky mode, add rainbow animation to empty cells
                if isFunkyMode && cell == .empty {
                    // Calculate phase offset based on position for wave effect
                    let phaseOffset = CGFloat(row + col) / CGFloat(gridSize * 2)
                    RainbowAnimationHelper.addRainbowAnimation(to: tile, phaseOffset: phaseOffset)
                    
                    // Add subtle pulsing effect with capped duration
                    let pulseDuration = min(0.5 + Double(row + col) * 0.03, 1.0)
                    let scaleUp = SKAction.scale(to: 1.05, duration: pulseDuration)
                    let scaleDown = SKAction.scale(to: 0.95, duration: pulseDuration)
                    let pulse = SKAction.sequence([scaleUp, scaleDown])
                    let repeatPulse = SKAction.repeatForever(pulse)
                    tile.run(repeatPulse)
                }
                
                gridNode.addChild(tile)
            }
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
