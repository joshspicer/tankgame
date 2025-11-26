//
//  RocketProjectileRenderer.swift
//  tankgame Shared
//
//  Rocket-specific projectile rendering with fire trails
//

import SpriteKit

/// Handles rendering of rocket projectiles with fire trail effects
class RocketProjectileRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    private let animationHelper: RainbowAnimationHelper
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Render all projectiles as rockets with fire trails
    func renderRockets(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            let rocketNode = createRocketNode(for: projectile)
            rocketNode.position = gridPosition(row: projectile.row, col: projectile.col)
            projectilesNode.addChild(rocketNode)
        }
    }
    
    /// Create a rocket sprite node with fire trail
    private func createRocketNode(for projectile: Projectile) -> SKNode {
        let rocketContainer = SKNode()
        rocketContainer.zPosition = 5
        
        // Rocket body - pointed tip
        let rocketSize = CGSize(width: tileSize * 0.25, height: tileSize * 0.6)
        
        // Create rocket body using path for pointed shape
        let rocketPath = CGMutablePath()
        let halfWidth = rocketSize.width / 2
        let halfHeight = rocketSize.height / 2
        
        // Pointed rocket shape
        rocketPath.move(to: CGPoint(x: 0, y: halfHeight + tileSize * 0.1)) // Tip
        rocketPath.addLine(to: CGPoint(x: -halfWidth, y: halfHeight * 0.3)) // Left shoulder
        rocketPath.addLine(to: CGPoint(x: -halfWidth, y: -halfHeight)) // Left base
        rocketPath.addLine(to: CGPoint(x: halfWidth, y: -halfHeight)) // Right base
        rocketPath.addLine(to: CGPoint(x: halfWidth, y: halfHeight * 0.3)) // Right shoulder
        rocketPath.closeSubpath()
        
        let rocketBody = SKShapeNode(path: rocketPath)
        rocketBody.fillColor = .orange
        rocketBody.strokeColor = .red
        rocketBody.lineWidth = 2
        rocketContainer.addChild(rocketBody)
        
        // Rocket fins
        let finSize = CGSize(width: tileSize * 0.15, height: tileSize * 0.2)
        
        // Left fin
        let leftFin = SKSpriteNode(color: .red, size: finSize)
        leftFin.position = CGPoint(x: -halfWidth - finSize.width / 4, y: -halfHeight + finSize.height / 2)
        rocketContainer.addChild(leftFin)
        
        // Right fin
        let rightFin = SKSpriteNode(color: .red, size: finSize)
        rightFin.position = CGPoint(x: halfWidth + finSize.width / 4, y: -halfHeight + finSize.height / 2)
        rocketContainer.addChild(rightFin)
        
        // Fire trail effect
        addFireTrail(to: rocketContainer, at: CGPoint(x: 0, y: -halfHeight))
        
        // Add smoke trail particles
        addSmokeTrail(to: rocketContainer, at: CGPoint(x: 0, y: -halfHeight - tileSize * 0.1))
        
        // Add rainbow pulsing animation
        addRocketAnimation(to: rocketBody)
        
        // Rotate based on direction
        rocketContainer.zRotation = rotationForDirection(projectile.direction)
        
        return rocketContainer
    }
    
    /// Add fire trail effect
    private func addFireTrail(to node: SKNode, at position: CGPoint) {
        // Inner flame (yellow/white core)
        let innerFlame = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.15, height: tileSize * 0.3))
        innerFlame.fillColor = .yellow
        innerFlame.strokeColor = .white
        innerFlame.lineWidth = 1
        innerFlame.position = CGPoint(x: position.x, y: position.y - tileSize * 0.1)
        innerFlame.alpha = 0.9
        node.addChild(innerFlame)
        
        // Outer flame (orange/red)
        let outerFlame = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.25, height: tileSize * 0.45))
        outerFlame.fillColor = .orange
        outerFlame.strokeColor = .red
        outerFlame.lineWidth = 2
        outerFlame.position = CGPoint(x: position.x, y: position.y - tileSize * 0.15)
        outerFlame.alpha = 0.7
        outerFlame.zPosition = -1
        node.addChild(outerFlame)
        
        // Animate flames flickering
        let flickerIn = SKAction.scale(to: 0.8, duration: 0.05)
        let flickerOut = SKAction.scale(to: 1.2, duration: 0.05)
        let flickerSequence = SKAction.sequence([flickerIn, flickerOut])
        let repeatFlicker = SKAction.repeatForever(flickerSequence)
        
        innerFlame.run(repeatFlicker)
        outerFlame.run(repeatFlicker)
        
        // Color animation for flames
        let yellowAction = SKAction.run { innerFlame.fillColor = .yellow }
        let whiteAction = SKAction.run { innerFlame.fillColor = .white }
        let wait = SKAction.wait(forDuration: 0.1)
        let colorSequence = SKAction.sequence([yellowAction, wait, whiteAction, wait])
        innerFlame.run(SKAction.repeatForever(colorSequence))
    }
    
    /// Add smoke trail particles
    private func addSmokeTrail(to node: SKNode, at position: CGPoint) {
        // Create multiple smoke particles
        for i in 0..<3 {
            let smoke = SKShapeNode(circleOfRadius: tileSize * 0.08)
            smoke.fillColor = .gray
            smoke.strokeColor = .darkGray
            smoke.lineWidth = 1
            smoke.alpha = CGFloat(0.6 - Double(i) * 0.15)
            smoke.position = CGPoint(x: position.x, y: position.y - CGFloat(i) * tileSize * 0.15)
            smoke.zPosition = -2
            node.addChild(smoke)
            
            // Animate smoke dissipating
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            fadeIn.timingMode = .easeIn
            fadeOut.timingMode = .easeOut
            let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
            smoke.run(SKAction.repeatForever(fadeSequence))
            
            // Slight drift animation
            let driftLeft = SKAction.moveBy(x: CGFloat.random(in: -3...3), y: 0, duration: 0.2)
            let driftRight = SKAction.moveBy(x: CGFloat.random(in: -3...3), y: 0, duration: 0.2)
            let driftSequence = SKAction.sequence([driftLeft, driftRight])
            smoke.run(SKAction.repeatForever(driftSequence))
        }
    }
    
    /// Add animation to rocket body
    private func addRocketAnimation(to shape: SKShapeNode) {
        // Pulsing glow effect
        let glowUp = SKAction.run { shape.glowWidth = 3 }
        let glowDown = SKAction.run { shape.glowWidth = 1 }
        let wait = SKAction.wait(forDuration: 0.15)
        let glowSequence = SKAction.sequence([glowUp, wait, glowDown, wait])
        shape.run(SKAction.repeatForever(glowSequence))
        
        // Color shifting
        let colors: [SKColor] = [.orange, .red, .yellow, .orange]
        var colorActions: [SKAction] = []
        for color in colors {
            let colorAction = SKAction.run { shape.fillColor = color }
            let waitAction = SKAction.wait(forDuration: 0.2)
            colorActions.append(contentsOf: [colorAction, waitAction])
        }
        let colorSequence = SKAction.sequence(colorActions)
        shape.run(SKAction.repeatForever(colorSequence))
    }
    
    /// Get rotation angle for direction
    private func rotationForDirection(_ direction: Direction) -> CGFloat {
        return CGFloat(direction.angle)
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
