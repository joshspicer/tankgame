//
//  ProjectileRenderer.swift
//  tankgame Shared
//
//  Projectile rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of projectiles with modern animations
class ProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    private let animationHelper: RainbowAnimationHelper
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Render all projectiles with enhanced visuals
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            let bulletNode = createProjectileNode()
            bulletNode.position = gridPosition(row: projectile.row, col: projectile.col)
            projectilesNode.addChild(bulletNode)
        }
    }
    
    /// Create a single projectile node with modern styling
    private func createProjectileNode() -> SKNode {
        let node = SKNode()
        node.zPosition = 5
        
        // Outer glow
        let outerGlow = SKShapeNode(circleOfRadius: tileSize * 0.35)
        outerGlow.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.3)
        outerGlow.strokeColor = .clear
        outerGlow.zPosition = 0
        node.addChild(outerGlow)
        
        // Middle glow
        let middleGlow = SKShapeNode(circleOfRadius: tileSize * 0.25)
        middleGlow.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.6)
        middleGlow.strokeColor = .clear
        middleGlow.zPosition = 1
        node.addChild(middleGlow)
        
        // Core bullet
        let core = SKShapeNode(circleOfRadius: tileSize * 0.15)
        core.fillColor = SKColor.white
        core.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)
        core.lineWidth = 2
        core.zPosition = 2
        node.addChild(core)
        
        // Center bright spot
        let center = SKShapeNode(circleOfRadius: tileSize * 0.06)
        center.fillColor = SKColor.white
        center.strokeColor = .clear
        center.zPosition = 3
        node.addChild(center)
        
        // Add pulsing animation to glow layers
        let pulseUp = SKAction.scale(to: 1.3, duration: 0.15)
        let pulseDown = SKAction.scale(to: 0.9, duration: 0.15)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        outerGlow.run(repeatPulse)
        
        // Slightly offset middle pulse
        let middlePulseUp = SKAction.scale(to: 1.2, duration: 0.12)
        let middlePulseDown = SKAction.scale(to: 0.85, duration: 0.12)
        let middlePulse = SKAction.sequence([middlePulseUp, middlePulseDown])
        middleGlow.run(SKAction.repeatForever(middlePulse))
        
        // Add color cycling to core
        addColorCycle(to: core)
        
        // Add rotation animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)
        let repeatRotation = SKAction.repeatForever(rotate)
        node.run(repeatRotation)
        
        // Add trail particles
        addTrailEffect(to: node)
        
        return node
    }
    
    /// Add color cycling animation to a shape
    private func addColorCycle(to shape: SKShapeNode) {
        let colors: [SKColor] = [
            SKColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0),
            SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0),
            SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),
            SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0),
        ]
        
        var colorActions: [SKAction] = []
        for color in colors {
            let colorAction = SKAction.run { [weak shape] in
                shape?.strokeColor = color
            }
            let wait = SKAction.wait(forDuration: 0.1)
            colorActions.append(SKAction.sequence([colorAction, wait]))
        }
        
        let colorSequence = SKAction.sequence(colorActions)
        shape.run(SKAction.repeatForever(colorSequence))
    }
    
    /// Add trail particle effect (optimized for performance)
    private func addTrailEffect(to node: SKNode) {
        // Create periodic trail particles with longer interval for better performance
        let createTrail = SKAction.run { [weak node, weak self] in
            guard let node = node, let self = self else { return }
            
            // Only create if not too many children already (cleanup safety)
            if node.children.count > 20 { return }
            
            let trail = SKShapeNode(circleOfRadius: self.tileSize * 0.1)
            trail.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 0.5)
            trail.strokeColor = .clear
            trail.position = .zero
            trail.zPosition = -1
            node.addChild(trail)
            
            // Fade and shrink trail
            let fadeAndShrink = SKAction.group([
                SKAction.fadeOut(withDuration: 0.25),
                SKAction.scale(to: 0.2, duration: 0.25)
            ])
            let remove = SKAction.removeFromParent()
            trail.run(SKAction.sequence([fadeAndShrink, remove]))
        }
        
        // Increased interval from 0.05 to 0.08 for better performance
        let wait = SKAction.wait(forDuration: 0.08)
        let trailSequence = SKAction.sequence([createTrail, wait])
        node.run(SKAction.repeatForever(trailSequence))
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
