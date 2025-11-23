//
//  PowerUpRenderer.swift
//  tankgame Shared
//
//  Created by agent on 11/23/25.
//

import SpriteKit

/// Handles rendering of power-ups on the game grid
class PowerUpRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
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
    
    /// Convert grid coordinates to scene position
    private func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
