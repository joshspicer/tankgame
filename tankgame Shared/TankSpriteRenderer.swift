//
//  TankSpriteRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles tank sprite creation and rendering - Classic retro style
class TankSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a classic retro tank sprite with clean, simple design
    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Darker shade for treads
        let darkColor = darkenColor(color, by: 0.3)
        
        // Tank treads (left side) - solid color
        let leftTread = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.7))
        leftTread.position = CGPoint(x: -tileSize * 0.28, y: 0)
        tankNode.addChild(leftTread)
        
        // Tank treads (right side) - solid color
        let rightTread = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.7))
        rightTread.position = CGPoint(x: tileSize * 0.28, y: 0)
        tankNode.addChild(rightTread)
        
        // Tank body (main hull) - solid color
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.55))
        tankNode.addChild(body)
        
        // Tank barrel (main gun) - simple rectangle
        let barrel = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.45))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
        tankNode.addChild(barrel)
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    /// Darken a color by a percentage
    private func darkenColor(_ color: SKColor, by amount: CGFloat) -> SKColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SKColor(red: max(0, r - amount), green: max(0, g - amount), blue: max(0, b - amount), alpha: a)
    }
}
