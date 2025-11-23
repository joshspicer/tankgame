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
    
    // Tank sprite renderer
    private let tankSpriteRenderer: TankSpriteRenderer
    
    // Power-up renderer
    private let powerUpRenderer: PowerUpRenderer
    
    // Shield effect renderer
    private let shieldEffectRenderer: ShieldEffectRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.tankSpriteRenderer = TankSpriteRenderer(tileSize: tileSize)
        self.powerUpRenderer = PowerUpRenderer(tileSize: tileSize, gridSize: gridSize)
        self.shieldEffectRenderer = ShieldEffectRenderer(tileSize: tileSize)
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
                let tankSprite = tankSpriteRenderer.createTankNode(color: color, direction: tank.direction)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
                
                // Add shield effect if tank has shield
                if tank.hasShield {
                    shieldEffectRenderer.addShieldToTank(tankSprite)
                }
            }
        }
    }

    /// Render all tanks with smooth animation
    func renderTanksWithSmoothing(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?], duration: TimeInterval) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let targetPosition = gridPosition(row: tank.row, col: tank.col)
                
                // If tank sprite exists, animate to new position
                if let tankSprite = tankNode.children.first {
                    // Animate position
                    let moveAction = SKAction.move(to: targetPosition, duration: duration)
                    moveAction.timingMode = .easeOut
                    tankSprite.run(moveAction)
                    
                    // Animate rotation smoothly
                    let currentRotation = tankSprite.zRotation
                    let targetRotation = CGFloat(tank.direction.angle)
                    let rotationDiff = shortestRotationDifference(from: currentRotation, to: targetRotation)
                    
                    if abs(rotationDiff) > 0.01 {
                        let rotateAction = SKAction.rotate(byAngle: rotationDiff, duration: duration)
                        rotateAction.timingMode = .easeOut
                        tankSprite.run(rotateAction)
                    }
                    
                    // Update shield effect based on tank state
                    if tank.hasShield && !shieldEffectRenderer.tankHasShield(tankSprite) {
                        shieldEffectRenderer.addShieldToTank(tankSprite)
                    } else if !tank.hasShield && shieldEffectRenderer.tankHasShield(tankSprite) {
                        shieldEffectRenderer.removeShieldFromTank(tankSprite)
                    }
                } else {
                    // Create new sprite if doesn't exist
                    let color = tankColors[i]
                    let tankSprite = tankSpriteRenderer.createTankNode(color: color, direction: tank.direction)
                    tankSprite.position = targetPosition
                    tankNode.addChild(tankSprite)
                    
                    // Add shield if needed
                    if tank.hasShield {
                        shieldEffectRenderer.addShieldToTank(tankSprite)
                    }
                }
            } else {
                tankNode.removeAllChildren()
            }
        }
    }
    
    /// Calculate the shortest rotation difference between two angles
    private func shortestRotationDifference(from: CGFloat, to: CGFloat) -> CGFloat {
        var diff = to - from
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return diff
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
    
    // MARK: - Power-Up Rendering
    
    /// Render all power-ups
    func renderPowerUps(_ powerUps: [PowerUp], in powerUpsNode: SKNode) {
        powerUpRenderer.renderPowerUps(powerUps, in: powerUpsNode)
    }
}
