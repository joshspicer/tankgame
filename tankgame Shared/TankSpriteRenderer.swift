//
//  TankSpriteRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles tank sprite creation and rendering
class TankSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a tank sprite node with classic retro styling
    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Darker shade for treads
        let darkColor = color.blended(withFraction: 0.4, of: .black) ?? color
        
        // Tank treads (left side)
        let leftTread = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75))
        leftTread.position = CGPoint(x: -tileSize * 0.3, y: 0)
        tankNode.addChild(leftTread)
        
        // Tank treads (right side)
        let rightTread = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75))
        rightTread.position = CGPoint(x: tileSize * 0.3, y: 0)
        tankNode.addChild(rightTread)
        
        // Tank body (main hull)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.55, height: tileSize * 0.65))
        tankNode.addChild(body)
        
        // Turret base (circular platform) - simple solid fill
        let turretBase = SKShapeNode(circleOfRadius: tileSize * 0.2)
        turretBase.fillColor = color
        turretBase.strokeColor = darkColor
        turretBase.lineWidth = 2
        turretBase.position = CGPoint(x: 0, y: 0)
        tankNode.addChild(turretBase)
        
        // Tank barrel (main gun)
        let barrel = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.45))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.32)
        tankNode.addChild(barrel)
        
        // Barrel muzzle (gun tip)
        let muzzle = SKSpriteNode(color: .black, size: CGSize(width: tileSize * 0.14, height: tileSize * 0.08))
        muzzle.position = CGPoint(x: 0, y: tileSize * 0.52)
        tankNode.addChild(muzzle)
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
}
