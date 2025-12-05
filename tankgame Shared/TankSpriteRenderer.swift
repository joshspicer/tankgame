//
//  TankSpriteRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles tank sprite creation and rendering - clean retro style
class TankSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a clean, simple tank sprite node
    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Simple tank body - main rectangle
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.6))
        tankNode.addChild(body)
        
        // Tank treads - simple rectangles on sides
        let treadColor = darkenColor(color, by: 0.3)
        let leftTread = SKSpriteNode(color: treadColor, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.65))
        leftTread.position = CGPoint(x: -tileSize * 0.28, y: 0)
        tankNode.addChild(leftTread)
        
        let rightTread = SKSpriteNode(color: treadColor, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.65))
        rightTread.position = CGPoint(x: tileSize * 0.28, y: 0)
        tankNode.addChild(rightTread)
        
        // Simple turret - small circle
        let turret = SKShapeNode(circleOfRadius: tileSize * 0.15)
        turret.fillColor = lightenColor(color, by: 0.15)
        turret.strokeColor = .clear
        turret.position = CGPoint(x: 0, y: -tileSize * 0.05)
        tankNode.addChild(turret)
        
        // Tank barrel - simple rectangle
        let barrel = SKSpriteNode(color: treadColor, size: CGSize(width: tileSize * 0.1, height: tileSize * 0.35))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.28)
        tankNode.addChild(barrel)
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    /// Darken a color by a percentage
    private func darkenColor(_ color: SKColor, by amount: CGFloat) -> SKColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(red: max(red - amount, 0), green: max(green - amount, 0), blue: max(blue - amount, 0), alpha: alpha)
    }
    
    /// Lighten a color by a percentage
    private func lightenColor(_ color: SKColor, by amount: CGFloat) -> SKColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(red: min(red + amount, 1), green: min(green + amount, 1), blue: min(blue + amount, 1), alpha: alpha)
    }
}
