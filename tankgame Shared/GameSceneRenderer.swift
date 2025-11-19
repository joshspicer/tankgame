//
//  GameSceneRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles all rendering operations for the game scene
class GameSceneRenderer {
    // Constants
    let tileSize: CGFloat
    let gridSize: Int
    
    // Tank colors for up to 4 players
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    // MARK: - Grid Rendering
    
    /// Render the game grid
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let color: SKColor
                switch cell {
                case .wall:
                    color = .black
                case .destructibleWall:
                    color = .brown
                case .empty:
                    color = .white
                }
                let tile = SKSpriteNode(color: color, size: CGSize(width: tileSize - 2, height: tileSize - 2))
                tile.position = gridPosition(row: row, col: col)
                gridNode.addChild(tile)
            }
        }
    }
    
    // MARK: - Tank Rendering
    
    /// Render all tanks
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
    
    /// Create a tank sprite node
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
    
    // MARK: - Power-up Rendering
    
    /// Render power-ups on the grid
    func renderPowerUps(_ powerUps: [PowerUp], in powerUpNode: SKNode) {
        powerUpNode.removeAllChildren()
        
        for powerUp in powerUps where powerUp.isActive {
            let size = CGSize(width: tileSize * 0.6, height: tileSize * 0.6)
            let powerUpSprite = SKSpriteNode(color: .clear, size: size)
            powerUpSprite.position = gridPosition(row: powerUp.row, col: powerUp.col)
            powerUpSprite.zPosition = 3
            
            // Add emoji label
            let label = SKLabelNode(text: powerUp.type.emoji)
            label.fontSize = tileSize * 0.5
            label.verticalAlignmentMode = .center
            powerUpSprite.addChild(label)
            
            // Add pulsing animation
            let scaleUp = SKAction.scale(to: 1.3, duration: 0.5)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            powerUpSprite.run(SKAction.repeatForever(pulse))
            
            // Add rotation for visual interest
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
            powerUpSprite.run(SKAction.repeatForever(rotate))
            
            powerUpNode.addChild(powerUpSprite)
        }
    }
    
    /// Render health indicators above tanks
    func renderHealthIndicators(_ tanks: [Tank], currentTime: TimeInterval, in healthNode: SKNode) {
        healthNode.removeAllChildren()
        
        for (index, tank) in tanks.enumerated() {
            guard tank.isAlive else { continue }
            
            let position = gridPosition(row: tank.row, col: tank.col)
            let healthPosition = CGPoint(x: position.x, y: position.y + tileSize * 0.6)
            
            // Health hearts
            for i in 0..<tank.health {
                let heart = SKLabelNode(text: "❤️")
                heart.fontSize = tileSize * 0.2
                heart.position = CGPoint(
                    x: healthPosition.x + CGFloat(i - 1) * tileSize * 0.2,
                    y: healthPosition.y
                )
                heart.zPosition = 10
                healthNode.addChild(heart)
            }
            
            // Active power-up indicators
            let activePowerUps = tank.activePowerUps.filter { !$0.isExpired(currentTime: currentTime) }
            for (i, powerUp) in activePowerUps.enumerated() {
                let indicator = SKLabelNode(text: powerUp.type.emoji)
                indicator.fontSize = tileSize * 0.15
                indicator.position = CGPoint(
                    x: healthPosition.x + CGFloat(i) * tileSize * 0.2,
                    y: healthPosition.y - tileSize * 0.25
                )
                indicator.alpha = 0.8
                indicator.zPosition = 10
                healthNode.addChild(indicator)
            }
        }
    }
    
    // MARK: - Projectile Rendering
    
    /// Render all projectiles
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
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
    
    /// Add rainbow color animation to a sprite
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
