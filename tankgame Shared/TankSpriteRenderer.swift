//
//  TankSpriteRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles tank sprite creation and rendering with premium visuals
class TankSpriteRenderer {
    let tileSize: CGFloat
    private let animationHelper: RainbowAnimationHelper
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Create a premium tank sprite node with enhanced visual details
    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Tank shadow for depth
        let shadow = SKShapeNode(rectOf: CGSize(width: tileSize * 0.65, height: tileSize * 0.75), cornerRadius: 4)
        shadow.fillColor = SKColor(white: 0, alpha: 0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.zPosition = -1
        tankNode.addChild(shadow)
        
        // Tank treads (left side) with detail
        let leftTread = SKShapeNode(rectOf: CGSize(width: tileSize * 0.16, height: tileSize * 0.78), cornerRadius: 4)
        leftTread.position = CGPoint(x: -tileSize * 0.3, y: 0)
        leftTread.fillColor = darkenColor(color, by: 0.3)
        leftTread.strokeColor = darkenColor(color, by: 0.4)
        leftTread.lineWidth = 1
        tankNode.addChild(leftTread)
        
        // Left tread detail lines
        for i in -3...3 {
            let treadLine = SKSpriteNode(
                color: darkenColor(color, by: 0.5),
                size: CGSize(width: tileSize * 0.14, height: 2)
            )
            treadLine.position = CGPoint(x: -tileSize * 0.3, y: CGFloat(i) * tileSize * 0.1)
            tankNode.addChild(treadLine)
        }
        
        // Tank treads (right side) with detail
        let rightTread = SKShapeNode(rectOf: CGSize(width: tileSize * 0.16, height: tileSize * 0.78), cornerRadius: 4)
        rightTread.position = CGPoint(x: tileSize * 0.3, y: 0)
        rightTread.fillColor = darkenColor(color, by: 0.3)
        rightTread.strokeColor = darkenColor(color, by: 0.4)
        rightTread.lineWidth = 1
        tankNode.addChild(rightTread)
        
        // Right tread detail lines
        for i in -3...3 {
            let treadLine = SKSpriteNode(
                color: darkenColor(color, by: 0.5),
                size: CGSize(width: tileSize * 0.14, height: 2)
            )
            treadLine.position = CGPoint(x: tileSize * 0.3, y: CGFloat(i) * tileSize * 0.1)
            tankNode.addChild(treadLine)
        }
        
        // Tank body (main hull) with gradient effect
        let body = SKShapeNode(rectOf: CGSize(width: tileSize * 0.52, height: tileSize * 0.65), cornerRadius: 6)
        body.fillColor = color
        body.strokeColor = lightenColor(color, by: 0.2)
        body.lineWidth = 2
        tankNode.addChild(body)
        
        // Body highlight (top reflection)
        let bodyHighlight = SKShapeNode(rectOf: CGSize(width: tileSize * 0.4, height: tileSize * 0.15), cornerRadius: 3)
        bodyHighlight.position = CGPoint(x: 0, y: tileSize * 0.15)
        bodyHighlight.fillColor = lightenColor(color, by: 0.3).withAlphaComponent(0.5)
        bodyHighlight.strokeColor = .clear
        tankNode.addChild(bodyHighlight)
        
        // Turret base (circular platform) with metallic look
        let turretBase = SKShapeNode(circleOfRadius: tileSize * 0.22)
        turretBase.fillColor = darkenColor(color, by: 0.1)
        turretBase.strokeColor = lightenColor(color, by: 0.2)
        turretBase.lineWidth = 2
        turretBase.position = CGPoint(x: 0, y: 0)
        turretBase.glowWidth = 2
        tankNode.addChild(turretBase)
        
        // Turret highlight
        let turretHighlight = SKShapeNode(circleOfRadius: tileSize * 0.12)
        turretHighlight.fillColor = lightenColor(color, by: 0.3).withAlphaComponent(0.4)
        turretHighlight.strokeColor = .clear
        turretHighlight.position = CGPoint(x: -tileSize * 0.05, y: tileSize * 0.05)
        tankNode.addChild(turretHighlight)
        
        // Tank barrel (main gun) with detail
        let barrel = SKShapeNode(rectOf: CGSize(width: tileSize * 0.12, height: tileSize * 0.45), cornerRadius: 3)
        barrel.fillColor = darkenColor(color, by: 0.15)
        barrel.strokeColor = lightenColor(color, by: 0.1)
        barrel.lineWidth = 1
        barrel.position = CGPoint(x: 0, y: tileSize * 0.32)
        tankNode.addChild(barrel)
        
        // Barrel muzzle (gun tip) with metallic look
        let muzzle = SKShapeNode(rectOf: CGSize(width: tileSize * 0.16, height: tileSize * 0.1), cornerRadius: 2)
        muzzle.fillColor = SKColor(white: 0.25, alpha: 1.0)
        muzzle.strokeColor = SKColor(white: 0.4, alpha: 1.0)
        muzzle.lineWidth = 1
        muzzle.position = CGPoint(x: 0, y: tileSize * 0.52)
        tankNode.addChild(muzzle)
        
        // Muzzle flash indicator (small glow)
        let muzzleGlow = SKShapeNode(circleOfRadius: tileSize * 0.04)
        muzzleGlow.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.6)
        muzzleGlow.strokeColor = .clear
        muzzleGlow.position = CGPoint(x: 0, y: tileSize * 0.56)
        muzzleGlow.glowWidth = 3
        tankNode.addChild(muzzleGlow)
        
        // Add subtle glow animation to muzzle
        let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.3)
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.3)
        let pulse = SKAction.sequence([fadeIn, fadeOut])
        muzzleGlow.run(SKAction.repeatForever(pulse))
        
        // Add rainbow animation to colored parts
        animationHelper.addRainbowAnimationToShape(body, phaseOffset: 0.0)
        animationHelper.addRainbowAnimationToShape(turretBase, phaseOffset: 0.15)
        animationHelper.addRainbowAnimationToShape(leftTread, phaseOffset: 0.3)
        animationHelper.addRainbowAnimationToShape(rightTread, phaseOffset: 0.3)
        animationHelper.addRainbowAnimationToShape(barrel, phaseOffset: 0.2)
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    /// Darken a color by a percentage
    private func darkenColor(_ color: SKColor, by percentage: CGFloat) -> SKColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SKColor(
            red: max(0, r - percentage),
            green: max(0, g - percentage),
            blue: max(0, b - percentage),
            alpha: a
        )
    }
    
    /// Lighten a color by a percentage
    private func lightenColor(_ color: SKColor, by percentage: CGFloat) -> SKColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SKColor(
            red: min(1, r + percentage),
            green: min(1, g + percentage),
            blue: min(1, b + percentage),
            alpha: a
        )
    }
}
