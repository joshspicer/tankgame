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
    
    /// Create a tank sprite node with improved visual details
    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Create darker/lighter variants for depth
        let darkColor = color.withAlphaComponent(0.7)
        let lightColor = color.withAlphaComponent(0.95)
        
        // Tank treads (left side) with detail
        let leftTreadOuter = SKSpriteNode(color: GameTheme.Colors.backgroundLight, size: CGSize(width: tileSize * 0.18, height: tileSize * 0.78))
        leftTreadOuter.position = CGPoint(x: -tileSize * 0.32, y: 0)
        leftTreadOuter.zPosition = -1
        tankNode.addChild(leftTreadOuter)
        
        let leftTread = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.14, height: tileSize * 0.75))
        leftTread.position = CGPoint(x: -tileSize * 0.32, y: 0)
        tankNode.addChild(leftTread)
        
        // Tank treads (right side) with detail
        let rightTreadOuter = SKSpriteNode(color: GameTheme.Colors.backgroundLight, size: CGSize(width: tileSize * 0.18, height: tileSize * 0.78))
        rightTreadOuter.position = CGPoint(x: tileSize * 0.32, y: 0)
        rightTreadOuter.zPosition = -1
        tankNode.addChild(rightTreadOuter)
        
        let rightTread = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.14, height: tileSize * 0.75))
        rightTread.position = CGPoint(x: tileSize * 0.32, y: 0)
        tankNode.addChild(rightTread)
        
        // Tank body shadow
        let bodyShadow = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.3), size: CGSize(width: tileSize * 0.58, height: tileSize * 0.68))
        bodyShadow.position = CGPoint(x: 2, y: -2)
        bodyShadow.zPosition = 0
        tankNode.addChild(bodyShadow)
        
        // Tank body (main hull)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.55, height: tileSize * 0.65))
        body.zPosition = 1
        tankNode.addChild(body)
        
        // Body highlight for 3D effect
        let bodyHighlight = SKSpriteNode(color: lightColor, size: CGSize(width: tileSize * 0.45, height: tileSize * 0.08))
        bodyHighlight.position = CGPoint(x: 0, y: tileSize * 0.22)
        bodyHighlight.alpha = 0.5
        bodyHighlight.zPosition = 2
        tankNode.addChild(bodyHighlight)
        
        // Turret base (circular platform) with ring
        let turretRing = SKShapeNode(circleOfRadius: tileSize * 0.28)
        turretRing.fillColor = darkColor
        turretRing.strokeColor = .clear
        turretRing.zPosition = 3
        tankNode.addChild(turretRing)
        
        let turretBase = SKShapeNode(circleOfRadius: tileSize * 0.23)
        turretBase.fillColor = color
        turretBase.strokeColor = lightColor
        turretBase.lineWidth = 1.5
        turretBase.zPosition = 4
        tankNode.addChild(turretBase)
        
        // Turret highlight
        let turretHighlight = SKShapeNode(circleOfRadius: tileSize * 0.12)
        turretHighlight.fillColor = lightColor
        turretHighlight.strokeColor = .clear
        turretHighlight.position = CGPoint(x: -tileSize * 0.05, y: tileSize * 0.05)
        turretHighlight.alpha = 0.4
        turretHighlight.zPosition = 5
        tankNode.addChild(turretHighlight)
        
        // Tank barrel shadow
        let barrelShadow = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.3), size: CGSize(width: tileSize * 0.16, height: tileSize * 0.52))
        barrelShadow.position = CGPoint(x: 2, y: tileSize * 0.34)
        barrelShadow.zPosition = 5
        tankNode.addChild(barrelShadow)
        
        // Tank barrel (main gun)
        let barrel = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.14, height: tileSize * 0.5))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
        barrel.zPosition = 6
        tankNode.addChild(barrel)
        
        // Barrel highlight
        let barrelHighlight = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.06, height: tileSize * 0.48))
        barrelHighlight.position = CGPoint(x: -tileSize * 0.02, y: tileSize * 0.35)
        barrelHighlight.alpha = 0.6
        barrelHighlight.zPosition = 7
        tankNode.addChild(barrelHighlight)
        
        // Barrel muzzle (gun tip)
        let muzzle = SKSpriteNode(color: GameTheme.Colors.backgroundMedium, size: CGSize(width: tileSize * 0.18, height: tileSize * 0.1))
        muzzle.position = CGPoint(x: 0, y: tileSize * 0.57)
        muzzle.zPosition = 8
        tankNode.addChild(muzzle)
        
        // Muzzle glow ring
        let muzzleGlow = SKShapeNode(circleOfRadius: tileSize * 0.06)
        muzzleGlow.fillColor = color.withAlphaComponent(0.3)
        muzzleGlow.strokeColor = color.withAlphaComponent(0.5)
        muzzleGlow.lineWidth = 1
        muzzleGlow.position = CGPoint(x: 0, y: tileSize * 0.6)
        muzzleGlow.zPosition = 9
        tankNode.addChild(muzzleGlow)
        
        // Add subtle idle animation (breathing effect)
        addIdleAnimation(to: tankNode)
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    /// Add subtle idle animation to the tank
    private func addIdleAnimation(to node: SKNode) {
        let scaleUp = SKAction.scale(to: 1.02, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
    }
}
