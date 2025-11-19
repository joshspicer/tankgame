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
                var tileColor: SKColor
                
                switch cell {
                case .empty:
                    tileColor = .white
                case .wall:
                    tileColor = .black
                case .destructibleWall:
                    tileColor = .darkGray // Different color for destructible walls
                }
                
                let tile = SKSpriteNode(color: tileColor, size: CGSize(width: tileSize - 2, height: tileSize - 2))
                tile.position = gridPosition(row: row, col: col)
                
                // Add a pattern to destructible walls to make them distinct
                if cell == .destructibleWall {
                    let stripe1 = SKSpriteNode(color: .gray, size: CGSize(width: tileSize - 2, height: 4))
                    stripe1.position = CGPoint(x: 0, y: -8)
                    tile.addChild(stripe1)
                    
                    let stripe2 = SKSpriteNode(color: .gray, size: CGSize(width: tileSize - 2, height: 4))
                    stripe2.position = CGPoint(x: 0, y: 8)
                    tile.addChild(stripe2)
                }
                
                gridNode.addChild(tile)
            }
        }
    }
    
    // MARK: - Tank Rendering
    
    /// Render all tanks
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?], activePowerUps: [[PowerUpType: TimeInterval]] = []) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let color = tankColors[i]
                let powerUpsForTank = i < activePowerUps.count ? activePowerUps[i] : [:]
                let tankSprite = createTankNode(color: color, direction: tank.direction, health: tank.health, maxHealth: tank.maxHealth, activePowerUps: powerUpsForTank)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }
    
    /// Create a tank sprite node
    private func createTankNode(color: SKColor, direction: Direction, health: Int, maxHealth: Int, activePowerUps: [PowerUpType: TimeInterval]) -> SKNode {
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
        
        // Add health bar above tank
        let healthBarWidth = tileSize * 0.6
        let healthBarHeight = tileSize * 0.08
        let healthBarY = tileSize * 0.45
        
        // Background bar (red)
        let healthBarBg = SKSpriteNode(color: .red, size: CGSize(width: healthBarWidth, height: healthBarHeight))
        healthBarBg.position = CGPoint(x: 0, y: healthBarY)
        healthBarBg.zPosition = 1
        tankNode.addChild(healthBarBg)
        
        // Foreground bar (green) - scaled based on health
        let healthPercent = CGFloat(health) / CGFloat(maxHealth)
        let healthBarFg = SKSpriteNode(color: .green, size: CGSize(width: healthBarWidth * healthPercent, height: healthBarHeight))
        healthBarFg.position = CGPoint(x: -healthBarWidth * (1.0 - healthPercent) / 2.0, y: healthBarY)
        healthBarFg.zPosition = 2
        tankNode.addChild(healthBarFg)
        
        // Add power-up glow effects
        if activePowerUps[.speedBoost] != nil {
            let glowNode = SKShapeNode(circleOfRadius: tileSize * 0.5)
            glowNode.fillColor = .clear
            glowNode.strokeColor = .cyan
            glowNode.lineWidth = 3
            glowNode.alpha = 0.7
            glowNode.zPosition = -1
            tankNode.addChild(glowNode)
            
            // Pulsing animation for speed boost
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.3),
                SKAction.fadeAlpha(to: 0.7, duration: 0.3)
            ])
            glowNode.run(SKAction.repeatForever(pulse))
        }
        
        if activePowerUps[.rapidFire] != nil {
            let glowNode = SKShapeNode(circleOfRadius: tileSize * 0.5)
            glowNode.fillColor = .clear
            glowNode.strokeColor = .orange
            glowNode.lineWidth = 3
            glowNode.alpha = 0.7
            glowNode.zPosition = -1
            tankNode.addChild(glowNode)
            
            // Rotating animation for rapid fire
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 1.0)
            glowNode.run(SKAction.repeatForever(rotate))
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
            // Create trail effect
            let trail = createProjectileTrail(at: gridPosition(row: projectile.row, col: projectile.col))
            projectilesNode.addChild(trail)
            
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
    
    /// Create a trail effect for projectiles
    private func createProjectileTrail(at position: CGPoint) -> SKNode {
        let trailNode = SKNode()
        trailNode.position = position
        trailNode.zPosition = 4
        
        // Create 3 fading trail particles behind the projectile
        for i in 0..<3 {
            let trailParticle = SKShapeNode(circleOfRadius: tileSize * 0.15 * (1.0 - CGFloat(i) * 0.3))
            trailParticle.fillColor = .orange
            trailParticle.strokeColor = .clear
            trailParticle.alpha = 0.7 - CGFloat(i) * 0.2
            trailParticle.position = CGPoint(x: 0, y: -CGFloat(i) * tileSize * 0.1)
            
            // Fade out animation
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let scale = SKAction.scale(to: 0.5, duration: 0.2)
            let group = SKAction.group([fadeOut, scale])
            let remove = SKAction.removeFromParent()
            trailParticle.run(SKAction.sequence([group, remove]))
            
            trailNode.addChild(trailParticle)
        }
        
        return trailNode
    }
    
    // MARK: - Power-Up Rendering
    
    /// Render all power-ups
    func renderPowerUps(_ powerUps: [PowerUp], in powerUpsNode: SKNode) {
        powerUpsNode.removeAllChildren()
        
        for powerUp in powerUps {
            guard powerUp.isActive else { continue }
            
            let powerUpSprite = createPowerUpNode(type: powerUp.type)
            powerUpSprite.position = gridPosition(row: powerUp.row, col: powerUp.col)
            powerUpsNode.addChild(powerUpSprite)
        }
    }
    
    /// Create a power-up sprite node
    private func createPowerUpNode(type: PowerUpType) -> SKNode {
        let node = SKNode()
        
        // Background circle
        let bg = SKShapeNode(circleOfRadius: tileSize * 0.3)
        bg.fillColor = colorForPowerUp(type: type)
        bg.strokeColor = .white
        bg.lineWidth = 3
        bg.alpha = 0.9
        node.addChild(bg)
        
        // Icon (simple shape based on type)
        let icon: SKNode
        switch type {
        case .health:
            // Cross for health
            let vertical = SKSpriteNode(color: .white, size: CGSize(width: 4, height: 16))
            let horizontal = SKSpriteNode(color: .white, size: CGSize(width: 16, height: 4))
            icon = SKNode()
            icon.addChild(vertical)
            icon.addChild(horizontal)
        case .rapidFire:
            // Lightning bolt shape
            let bolt = SKShapeNode(circleOfRadius: 6)
            bolt.fillColor = .white
            icon = bolt
        case .speedBoost:
            // Arrow for speed
            let arrow = SKShapeNode(rect: CGRect(x: -4, y: -8, width: 8, height: 16))
            arrow.fillColor = .white
            icon = arrow
        }
        
        node.addChild(icon)
        
        // Pulsing animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        node.run(SKAction.repeatForever(pulse))
        
        // Rotation animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
        node.run(SKAction.repeatForever(rotate))
        
        return node
    }
    
    /// Get color for power-up type
    private func colorForPowerUp(type: PowerUpType) -> SKColor {
        switch type {
        case .health:
            return .green
        case .rapidFire:
            return .orange
        case .speedBoost:
            return .cyan
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
