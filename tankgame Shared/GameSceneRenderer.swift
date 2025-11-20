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
                let tile = SKSpriteNode(color: cell == .wall ? .black : .white, size: CGSize(width: tileSize - 2, height: tileSize - 2))
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
                let tankSprite = createTankNode(color: color, direction: tank.direction, hasShield: tank.hasShield)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }
    
    /// Create a tank sprite node
    private func createTankNode(color: SKColor, direction: Direction, hasShield: Bool = false) -> SKNode {
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
        
        // Add shield effect if active
        if hasShield {
            let shieldSize = CGSize(width: tileSize * 0.9, height: tileSize * 0.9)
            let shield = SKShapeNode(circleOfRadius: tileSize * 0.45)
            shield.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.8)
            shield.fillColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.2)
            shield.lineWidth = 3
            shield.zPosition = 10
            
            // Add pulsing animation to shield
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.5)
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
            let pulse = SKAction.sequence([fadeIn, fadeOut])
            shield.run(SKAction.repeatForever(pulse))
            
            tankNode.addChild(shield)
        }
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
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
    
    // MARK: - Power-Up Rendering
    
    /// Render all power-ups
    func renderPowerUps(_ powerUps: [PowerUp], in powerUpsNode: SKNode) {
        powerUpsNode.removeAllChildren()
        
        for powerUp in powerUps {
            guard powerUp.isActive else { continue }
            
            // Create power-up sprite
            let size = CGSize(width: tileSize * 0.6, height: tileSize * 0.6)
            let powerUpSprite = SKSpriteNode(color: .white, size: size)
            powerUpSprite.position = gridPosition(row: powerUp.row, col: powerUp.col)
            powerUpSprite.zPosition = 3
            
            // Set color based on type
            let colorValues = powerUp.type.color
            let color = SKColor(red: colorValues.r, green: colorValues.g, blue: colorValues.b, alpha: 1.0)
            powerUpSprite.color = color
            
            // Add pulsing animation
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
            let scaleDown = SKAction.scale(to: 0.9, duration: 0.5)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            powerUpSprite.run(SKAction.repeatForever(pulse))
            
            // Add rotation animation
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
            powerUpSprite.run(SKAction.repeatForever(rotate))
            
            powerUpsNode.addChild(powerUpSprite)
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
