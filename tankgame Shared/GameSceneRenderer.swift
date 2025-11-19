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
                let tankSprite = createTankNode(color: color, direction: tank.direction)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }
    
    /// Create a tank sprite node
    private func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Shadow for depth (underneath)
        let shadow = SKSpriteNode(color: .black.withAlphaComponent(0.3), 
                                 size: CGSize(width: tileSize * 0.75, height: tileSize * 0.75))
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        tankNode.addChild(shadow)
        
        // Tank treads (left and right)
        let leftTread = SKSpriteNode(color: color.withAlphaComponent(0.6), 
                                    size: CGSize(width: tileSize * 0.25, height: tileSize * 0.75))
        leftTread.position = CGPoint(x: -tileSize * 0.25, y: 0)
        tankNode.addChild(leftTread)
        
        let rightTread = SKSpriteNode(color: color.withAlphaComponent(0.6), 
                                     size: CGSize(width: tileSize * 0.25, height: tileSize * 0.75))
        rightTread.position = CGPoint(x: tileSize * 0.25, y: 0)
        tankNode.addChild(rightTread)
        
        // Tank body (main hull)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.6, height: tileSize * 0.65))
        tankNode.addChild(body)
        
        // Turret (slightly smaller than body)
        let turret = SKSpriteNode(color: color.withAlphaComponent(0.9), 
                                 size: CGSize(width: tileSize * 0.45, height: tileSize * 0.45))
        turret.position = CGPoint(x: 0, y: 0)
        tankNode.addChild(turret)
        
        // Barrel (thinner and longer)
        let barrel = SKSpriteNode(color: color.withAlphaComponent(0.8), 
                                 size: CGSize(width: tileSize * 0.15, height: tileSize * 0.55))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.38)
        tankNode.addChild(barrel)
        
        // Barrel tip highlight
        let barrelTip = SKSpriteNode(color: .white.withAlphaComponent(0.7), 
                                    size: CGSize(width: tileSize * 0.15, height: tileSize * 0.1))
        barrelTip.position = CGPoint(x: 0, y: tileSize * 0.6)
        tankNode.addChild(barrelTip)
        
        // Add rainbow animation with different phases for depth
        addRainbowAnimation(to: body, phaseOffset: 0)
        addRainbowAnimation(to: turret, phaseOffset: 0.08)
        addRainbowAnimation(to: barrel, phaseOffset: 0.15)
        addRainbowAnimation(to: leftTread, phaseOffset: 0.25)
        addRainbowAnimation(to: rightTread, phaseOffset: 0.25)
        
        // Add subtle idle pulsing animation
        let pulseUp = SKAction.scale(to: 1.02, duration: 1.0)
        let pulseDown = SKAction.scale(to: 0.98, duration: 1.0)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulseSequence)
        body.run(repeatPulse)
        turret.run(repeatPulse)
        
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
