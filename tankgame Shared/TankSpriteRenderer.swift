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
    private let animationHelper: RainbowAnimationHelper
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Create a tank sprite node with improved visual details
    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Tank treads (left side)
        let leftTread = SKSpriteNode(color: color.withAlphaComponent(0.6), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75))
        leftTread.position = CGPoint(x: -tileSize * 0.3, y: 0)
        tankNode.addChild(leftTread)
        
        // Tank treads (right side)
        let rightTread = SKSpriteNode(color: color.withAlphaComponent(0.6), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75))
        rightTread.position = CGPoint(x: tileSize * 0.3, y: 0)
        tankNode.addChild(rightTread)
        
        // Tank body (main hull)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.55, height: tileSize * 0.65))
        tankNode.addChild(body)
        
        // Turret base (circular platform)
        let turretBase = SKShapeNode(circleOfRadius: tileSize * 0.25)
        turretBase.fillColor = color.withAlphaComponent(0.9)
        turretBase.strokeColor = color.withAlphaComponent(0.5)
        turretBase.lineWidth = 2
        turretBase.position = CGPoint(x: 0, y: 0)
        tankNode.addChild(turretBase)
        
        // Tank barrel (main gun)
        let barrel = SKSpriteNode(color: color.withAlphaComponent(0.8), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.5))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
        tankNode.addChild(barrel)
        
        // Barrel muzzle (gun tip)
        let muzzle = SKSpriteNode(color: .darkGray, size: CGSize(width: tileSize * 0.18, height: tileSize * 0.12))
        muzzle.position = CGPoint(x: 0, y: tileSize * 0.56)
        tankNode.addChild(muzzle)
        
        // Add rainbow animation to all colored parts (uses RainbowAnimationHelper which checks settings)
        animationHelper.addRainbowAnimation(to: leftTread, phaseOffset: 0)
        animationHelper.addRainbowAnimation(to: rightTread, phaseOffset: 0)
        animationHelper.addRainbowAnimation(to: body, phaseOffset: 0.1)
        animationHelper.addRainbowAnimation(to: barrel, phaseOffset: 0.2)
        animationHelper.addRainbowAnimation(to: turretBase, baseColor: color, phaseOffset: 0.15)
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
}
