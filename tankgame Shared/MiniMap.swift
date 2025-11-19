//
//  MiniMap.swift
//  tankgame Shared
//
//  Mini-map display for better spatial awareness
//

import SpriteKit

class MiniMap {
    private var miniMapNode: SKNode?
    private let miniMapSize: CGFloat = 100
    private let cellSize: CGFloat
    private let gridSize: Int
    
    init(gridSize: Int) {
        self.gridSize = gridSize
        self.cellSize = miniMapSize / CGFloat(gridSize)
    }
    
    /// Setup the mini-map display
    func setup(in scene: SKScene, sceneSize: CGSize) {
        let container = SKNode()
        
        // Position in top-left corner with some padding
        container.position = CGPoint(x: 60, y: sceneSize.height - 120)
        
        // Add semi-transparent background
        let background = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.5), 
                                     size: CGSize(width: miniMapSize + 10, height: miniMapSize + 10))
        background.position = CGPoint(x: miniMapSize / 2, y: miniMapSize / 2)
        container.addChild(background)
        
        scene.addChild(container)
        miniMapNode = container
    }
    
    /// Update the mini-map with current game state
    func update(grid: [[GridCell]], tanks: [Tank], projectiles: [Projectile]) {
        guard let container = miniMapNode else { return }
        
        // Clear previous content except background
        for child in container.children where child is SKSpriteNode && child.color != SKColor.black.withAlphaComponent(0.5) {
            child.removeFromParent()
        }
        
        // Draw grid
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                var color: SKColor
                switch cell {
                case .wall:
                    color = .darkGray
                case .destructibleWall:
                    color = SKColor.brown.withAlphaComponent(0.8)
                case .empty:
                    color = SKColor.white.withAlphaComponent(0.3)
                }
                
                let tile = SKSpriteNode(color: color, 
                                       size: CGSize(width: cellSize - 1, height: cellSize - 1))
                tile.position = miniMapPosition(row: row, col: col)
                container.addChild(tile)
            }
        }
        
        // Draw tanks
        let tankColors: [SKColor] = [.blue, .red, .green, .orange]
        for (index, tank) in tanks.enumerated() where tank.isAlive {
            let tankDot = SKSpriteNode(color: tankColors[index], 
                                      size: CGSize(width: cellSize * 1.5, height: cellSize * 1.5))
            tankDot.position = miniMapPosition(row: tank.row, col: tank.col)
            tankDot.zPosition = 2
            container.addChild(tankDot)
        }
        
        // Draw projectiles
        for projectile in projectiles {
            let bullet = SKSpriteNode(color: .yellow, 
                                     size: CGSize(width: cellSize * 0.8, height: cellSize * 0.8))
            bullet.position = miniMapPosition(row: projectile.row, col: projectile.col)
            bullet.zPosition = 1
            container.addChild(bullet)
        }
    }
    
    /// Convert grid coordinates to mini-map position
    private func miniMapPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * cellSize + cellSize / 2,
            y: miniMapSize - (CGFloat(row) * cellSize + cellSize / 2)
        )
    }
}
