//
//  GameSceneRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles all rendering operations for the game scene
/// Responsible for drawing the grid, tanks, and projectiles
final class GameSceneRenderer {
    // MARK: - Properties
    
    /// Size of each grid tile in points
    let tileSize: CGFloat
    
    /// Number of cells in the grid (width and height)
    let gridSize: Int
    
    /// Colors assigned to each player (up to 4 players)
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    // MARK: - Initialization
    
    /// Creates a new renderer with specified grid parameters
    /// - Parameters:
    ///   - tileSize: Size of each grid tile in points
    ///   - gridSize: Number of cells in the grid (typically 8)
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    // MARK: - Grid Rendering
    
    /// Renders the game grid with walls and empty cells
    /// - Parameters:
    ///   - grid: 2D array representing the game grid
    ///   - gridNode: Parent node to add grid tiles to
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let tile = SKSpriteNode(color: cell == .wall ? .black : .white, size: CGSize(width: tileSize - 2, height: tileSize - 2))
                tile.position = gridPosition(row: row, col: col)
                gridNode.addChild(tile)
            }
        }
    }
    
    // MARK: - Tank Rendering
    
    /// Renders all player tanks with their current states
    /// - Parameters:
    ///   - tanks: Array of tank objects to render
    ///   - tankExploding: Array indicating which tanks are currently exploding
    ///   - tankNodes: Parent nodes for each tank
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let color = tankColors[i]
                let tankSprite = createTankNode(color: color, direction: tank.direction)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }
    
    /// Creates a tank sprite with body, barrel, and rainbow animation
    /// - Parameters:
    ///   - color: Base color for the tank
    ///   - direction: Direction the tank is facing
    /// - Returns: Composite node representing the tank
    private func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Tank body (square)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.7, height: tileSize * 0.7))
        tankNode.addChild(body)
        
        // Tank barrel (rectangle)
        let barrel = SKSpriteNode(color: color.withAlphaComponent(0.8), size: CGSize(width: tileSize * 0.2, height: tileSize * 0.5))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
        tankNode.addChild(barrel)
        
        // Add rainbow animation to body and barrel
        addRainbowAnimation(to: body, phaseOffset: 0)
        addRainbowAnimation(to: barrel, phaseOffset: 0.15)
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    // MARK: - Projectile Rendering
    
    /// Renders all active projectiles with animations
    /// - Parameters:
    ///   - projectiles: Array of projectiles to render
    ///   - projectilesNode: Parent node to add projectile sprites to
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            // Make projectile larger and more visible
            let bullet = SKSpriteNode(color: .yellow, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.5))
            bullet.zPosition = 5
            bullet.position = gridPosition(row: projectile.row, col: projectile.col)
            
            // Add rainbow color animation
            addRainbowAnimation(to: bullet, phaseOffset: 0.5)
            
            // Add pulsing scale animation
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            let repeatPulse = SKAction.repeatForever(pulse)
            bullet.run(repeatPulse)
            
            // Add rotation animation based on direction
            let rotationDuration: TimeInterval = 0.5
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: rotationDuration)
            let repeatRotation = SKAction.repeatForever(rotate)
            bullet.run(repeatRotation)
            
            projectilesNode.addChild(bullet)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Converts grid coordinates to scene position in points
    /// - Parameters:
    ///   - row: Grid row (0 = top)
    ///   - col: Grid column (0 = left)
    /// - Returns: CGPoint in scene coordinates (centered on cell)
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
    
    /// Adds a smooth rainbow color animation to a sprite
    /// - Parameters:
    ///   - sprite: Sprite to animate
    ///   - phaseOffset: Starting phase offset (0.0-1.0) for color cycle
    private func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
        var colorActions: [SKAction] = []
        
        // Create a smooth rainbow by cycling through hue values
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
            let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: animationDuration / Double(numberOfColors))
            colorActions.append(colorAction)
        }
        
        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)
        
        sprite.run(repeatForever)
    }
}
