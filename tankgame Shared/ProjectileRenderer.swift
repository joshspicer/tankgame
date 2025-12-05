//
//  ProjectileRenderer.swift
//  tankgame Shared
//
//  Projectile rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of projectiles with premium animations
class ProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    private let animationHelper: RainbowAnimationHelper
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Render all projectiles with premium effects
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            // Create bullet container
            let bulletNode = SKNode()
            bulletNode.zPosition = 5
            bulletNode.position = gridPosition(row: projectile.row, col: projectile.col)
            
            // Outer glow
            let outerGlow = SKShapeNode(circleOfRadius: tileSize * 0.35)
            outerGlow.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.3)
            outerGlow.strokeColor = .clear
            outerGlow.glowWidth = 8
            bulletNode.addChild(outerGlow)
            
            // Core bullet
            let bullet = SKShapeNode(circleOfRadius: tileSize * 0.2)
            bullet.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
            bullet.strokeColor = SKColor(red: 1.0, green: 0.7, blue: 0.1, alpha: 1.0)
            bullet.lineWidth = 2
            bullet.glowWidth = 4
            bulletNode.addChild(bullet)
            
            // Inner bright core
            let core = SKShapeNode(circleOfRadius: tileSize * 0.08)
            core.fillColor = .white
            core.strokeColor = .clear
            bulletNode.addChild(core)
            
            // Add rainbow color animation to the bullet
            addBulletColorAnimation(to: bullet)
            
            // Add pulsing scale animation
            let scaleUp = SKAction.scale(to: 1.15, duration: 0.15)
            let scaleDown = SKAction.scale(to: 0.9, duration: 0.15)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            let repeatPulse = SKAction.repeatForever(pulse)
            bulletNode.run(repeatPulse)
            
            // Add rotation animation
            let rotationDuration: TimeInterval = 0.3
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: rotationDuration)
            let repeatRotation = SKAction.repeatForever(rotate)
            bulletNode.run(repeatRotation)
            
            // Add trail effect
            addTrailEffect(to: bulletNode, direction: projectile.direction)
            
            projectilesNode.addChild(bulletNode)
        }
    }
    
    /// Add color animation to bullet
    private func addBulletColorAnimation(to shape: SKShapeNode) {
        let animationDuration: TimeInterval = 0.8
        let colors: [(fill: SKColor, stroke: SKColor)] = [
            (SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0), SKColor(red: 1.0, green: 0.7, blue: 0.1, alpha: 1.0)),
            (SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0), SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)),
            (SKColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 1.0), SKColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 1.0)),
            (SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0), SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
        ]
        
        var colorActions: [SKAction] = []
        for colorPair in colors {
            let colorAction = SKAction.run { [weak shape] in
                shape?.fillColor = colorPair.fill
                shape?.strokeColor = colorPair.stroke
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(colors.count))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }
        
        let colorSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(colorSequence)
        shape.run(repeatForever)
    }
    
    /// Add trail effect behind projectile
    private func addTrailEffect(to bulletNode: SKNode, direction: Direction) {
        // Calculate trail offset based on direction (opposite to movement)
        let trailOffset: CGPoint
        switch direction {
        case .up:
            trailOffset = CGPoint(x: 0, y: -tileSize * 0.15)
        case .down:
            trailOffset = CGPoint(x: 0, y: tileSize * 0.15)
        case .left:
            trailOffset = CGPoint(x: tileSize * 0.15, y: 0)
        case .right:
            trailOffset = CGPoint(x: -tileSize * 0.15, y: 0)
        case .upLeft:
            trailOffset = CGPoint(x: tileSize * 0.1, y: -tileSize * 0.1)
        case .upRight:
            trailOffset = CGPoint(x: -tileSize * 0.1, y: -tileSize * 0.1)
        case .downLeft:
            trailOffset = CGPoint(x: tileSize * 0.1, y: tileSize * 0.1)
        case .downRight:
            trailOffset = CGPoint(x: -tileSize * 0.1, y: tileSize * 0.1)
        }
        
        // Create multiple trail segments
        for i in 1...3 {
            let trail = SKShapeNode(circleOfRadius: tileSize * (0.12 - CGFloat(i) * 0.03))
            trail.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.5 - CGFloat(i) * 0.15)
            trail.strokeColor = .clear
            trail.position = CGPoint(
                x: trailOffset.x * CGFloat(i),
                y: trailOffset.y * CGFloat(i)
            )
            trail.zPosition = -1
            bulletNode.addChild(trail)
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
