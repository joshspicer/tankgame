//
//  ModernProjectileRenderer.swift
//  tankgame Shared
//
//  Enhanced projectile rendering with modern visual effects
//

import SpriteKit

/// Modern styled projectile renderer with enhanced visuals
class ModernProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    private let animationHelper: RainbowAnimationHelper
    
    // Projectile color palette
    private let projectileCore = SKColor(red: 1.0, green: 0.95, blue: 0.4, alpha: 1.0)
    private let projectileGlow = SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 0.6)
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Render all projectiles with modern styling
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for (index, projectile) in projectiles.enumerated() {
            let bulletNode = createModernBullet(phaseOffset: CGFloat(index) * 0.2)
            bulletNode.position = gridPosition(row: projectile.row, col: projectile.col)
            bulletNode.zPosition = 5
            projectilesNode.addChild(bulletNode)
            
            // Add trail effect
            addTrailEffect(to: bulletNode, direction: projectile.direction)
        }
    }
    
    /// Create a modern styled bullet node
    private func createModernBullet(phaseOffset: CGFloat) -> SKNode {
        let container = SKNode()
        
        // Outer glow
        let outerGlow = SKShapeNode(circleOfRadius: tileSize * 0.35)
        outerGlow.fillColor = projectileGlow.withAlphaComponent(0.3)
        outerGlow.strokeColor = .clear
        outerGlow.zPosition = 0
        container.addChild(outerGlow)
        
        // Inner glow
        let innerGlow = SKShapeNode(circleOfRadius: tileSize * 0.28)
        innerGlow.fillColor = projectileGlow
        innerGlow.strokeColor = .clear
        innerGlow.zPosition = 1
        container.addChild(innerGlow)
        
        // Core
        let core = SKShapeNode(circleOfRadius: tileSize * 0.2)
        core.fillColor = projectileCore
        core.strokeColor = SKColor.white.withAlphaComponent(0.8)
        core.lineWidth = 2
        core.glowWidth = 3
        core.zPosition = 2
        container.addChild(core)
        
        // Highlight
        let highlight = SKShapeNode(circleOfRadius: tileSize * 0.08)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.8)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -tileSize * 0.05, y: tileSize * 0.05)
        highlight.zPosition = 3
        container.addChild(highlight)
        
        // Add rainbow animation to core
        animationHelper.addRainbowAnimationToShape(core, phaseOffset: phaseOffset)
        
        // Add pulsing animation
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.25)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.25)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        container.run(SKAction.repeatForever(pulse))
        
        // Add glow pulse to outer ring
        let glowFadeIn = SKAction.fadeAlpha(to: 0.5, duration: 0.3)
        let glowFadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.3)
        outerGlow.run(SKAction.repeatForever(SKAction.sequence([glowFadeIn, glowFadeOut])))
        
        // Add rotation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.8)
        container.run(SKAction.repeatForever(rotate))
        
        return container
    }
    
    /// Add motion trail effect behind the projectile
    private func addTrailEffect(to node: SKNode, direction: Direction) {
        // Calculate trail direction (opposite of movement)
        let trailOffset = getTrailOffset(for: direction)
        
        // Create trail particles
        for i in 0..<3 {
            let trail = SKShapeNode(circleOfRadius: tileSize * 0.1 - CGFloat(i) * 0.02)
            trail.fillColor = projectileGlow.withAlphaComponent(0.3 - CGFloat(i) * 0.1)
            trail.strokeColor = .clear
            trail.position = CGPoint(
                x: trailOffset.x * CGFloat(i + 1) * 0.4,
                y: trailOffset.y * CGFloat(i + 1) * 0.4
            )
            trail.zPosition = -1
            node.addChild(trail)
            
            // Fade animation for trail
            let fadeIn = SKAction.fadeAlpha(to: 0.3 - CGFloat(i) * 0.1, duration: 0.15)
            let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 0.15)
            trail.run(SKAction.repeatForever(SKAction.sequence([fadeIn, fadeOut])))
        }
    }
    
    /// Get the offset direction for the trail based on projectile direction
    private func getTrailOffset(for direction: Direction) -> CGPoint {
        switch direction {
        case .up:
            return CGPoint(x: 0, y: -tileSize * 0.3)
        case .down:
            return CGPoint(x: 0, y: tileSize * 0.3)
        case .left:
            return CGPoint(x: tileSize * 0.3, y: 0)
        case .right:
            return CGPoint(x: -tileSize * 0.3, y: 0)
        case .upLeft:
            return CGPoint(x: tileSize * 0.2, y: -tileSize * 0.2)
        case .upRight:
            return CGPoint(x: -tileSize * 0.2, y: -tileSize * 0.2)
        case .downLeft:
            return CGPoint(x: tileSize * 0.2, y: tileSize * 0.2)
        case .downRight:
            return CGPoint(x: -tileSize * 0.2, y: tileSize * 0.2)
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
