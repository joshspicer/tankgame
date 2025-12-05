//
//  TankSpriteRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles tank sprite creation and rendering with modern visuals
class TankSpriteRenderer {
    let tileSize: CGFloat
    private let animationHelper: RainbowAnimationHelper
    
    // Modern tank colors with better saturation
    private let tankHighlight = SKColor.white.withAlphaComponent(0.25)
    private let tankShadow = SKColor.black.withAlphaComponent(0.3)
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Create a tank sprite node with improved visual details and modern styling
    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Tank shadow for depth
        let shadow = SKSpriteNode(color: tankShadow, size: CGSize(width: tileSize * 0.7, height: tileSize * 0.8))
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.zPosition = -1
        shadow.alpha = 0.4
        tankNode.addChild(shadow)
        
        // Tank treads (left side) with detail
        let leftTread = SKSpriteNode(color: color.withAlphaComponent(0.7), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75))
        leftTread.position = CGPoint(x: -tileSize * 0.3, y: 0)
        tankNode.addChild(leftTread)
        
        // Left tread detail lines
        addTreadDetails(to: tankNode, xPosition: -tileSize * 0.3, color: color)
        
        // Tank treads (right side)
        let rightTread = SKSpriteNode(color: color.withAlphaComponent(0.7), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75))
        rightTread.position = CGPoint(x: tileSize * 0.3, y: 0)
        tankNode.addChild(rightTread)
        
        // Right tread detail lines
        addTreadDetails(to: tankNode, xPosition: tileSize * 0.3, color: color)
        
        // Tank body (main hull) with gradient-like effect
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.55, height: tileSize * 0.65))
        tankNode.addChild(body)
        
        // Body highlight (top-left shine)
        let bodyHighlight = SKSpriteNode(color: tankHighlight, size: CGSize(width: tileSize * 0.25, height: tileSize * 0.3))
        bodyHighlight.position = CGPoint(x: -tileSize * 0.08, y: tileSize * 0.1)
        tankNode.addChild(bodyHighlight)
        
        // Turret base (circular platform) with ring
        let turretBase = SKShapeNode(circleOfRadius: tileSize * 0.25)
        turretBase.fillColor = color.withAlphaComponent(0.95)
        turretBase.strokeColor = color
        turretBase.lineWidth = 3
        turretBase.glowWidth = 2
        turretBase.position = CGPoint(x: 0, y: 0)
        tankNode.addChild(turretBase)
        
        // Inner turret ring for detail
        let turretInner = SKShapeNode(circleOfRadius: tileSize * 0.18)
        turretInner.fillColor = .clear
        turretInner.strokeColor = tankHighlight
        turretInner.lineWidth = 1.5
        turretBase.addChild(turretInner)
        
        // Tank barrel (main gun)
        let barrel = SKSpriteNode(color: color.withAlphaComponent(0.85), size: CGSize(width: tileSize * 0.14, height: tileSize * 0.48))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.34)
        tankNode.addChild(barrel)
        
        // Barrel highlight
        let barrelHighlight = SKSpriteNode(color: tankHighlight, size: CGSize(width: tileSize * 0.04, height: tileSize * 0.4))
        barrelHighlight.position = CGPoint(x: -tileSize * 0.03, y: tileSize * 0.34)
        tankNode.addChild(barrelHighlight)
        
        // Barrel muzzle (gun tip) with detail
        let muzzle = SKSpriteNode(color: SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0), size: CGSize(width: tileSize * 0.18, height: tileSize * 0.1))
        muzzle.position = CGPoint(x: 0, y: tileSize * 0.56)
        tankNode.addChild(muzzle)
        
        // Muzzle flash indicator (small glow)
        let muzzleGlow = SKShapeNode(circleOfRadius: tileSize * 0.06)
        muzzleGlow.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.0)
        muzzleGlow.strokeColor = .clear
        muzzleGlow.position = CGPoint(x: 0, y: tileSize * 0.62)
        muzzleGlow.name = "muzzleGlow"
        tankNode.addChild(muzzleGlow)
        
        // Add rainbow animation to all colored parts using shared helper
        animationHelper.addRainbowAnimation(to: leftTread, phaseOffset: 0)
        animationHelper.addRainbowAnimation(to: rightTread, phaseOffset: 0)
        animationHelper.addRainbowAnimation(to: body, phaseOffset: 0.1)
        animationHelper.addRainbowAnimation(to: barrel, phaseOffset: 0.2)
        
        // Add rainbow animation to turret base using shared helper
        animationHelper.addRainbowAnimationToShape(turretBase, phaseOffset: 0.15)
        
        // Add subtle idle animation (slight hover)
        let hoverUp = SKAction.moveBy(x: 0, y: 1.5, duration: 1.0)
        let hoverDown = SKAction.moveBy(x: 0, y: -1.5, duration: 1.0)
        hoverUp.timingMode = .easeInEaseOut
        hoverDown.timingMode = .easeInEaseOut
        let hoverSequence = SKAction.sequence([hoverUp, hoverDown])
        tankNode.run(SKAction.repeatForever(hoverSequence))
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    // MARK: - Tread Configuration Constants
    private let treadDetailCount = 5
    private let treadWidthMultiplier: CGFloat = 0.18
    private let treadHeightMultiplier: CGFloat = 0.75
    private let treadAlpha: CGFloat = 0.4
    private let treadLineHeight: CGFloat = 2
    
    /// Add tread detail lines
    private func addTreadDetails(to tankNode: SKNode, xPosition: CGFloat, color: SKColor) {
        let treadHeight = tileSize * treadHeightMultiplier
        let spacing = treadHeight / CGFloat(treadDetailCount + 1)
        let startY = -treadHeight / 2
        
        for i in 1...treadDetailCount {
            let treadLine = SKShapeNode(rectOf: CGSize(width: tileSize * treadWidthMultiplier, height: treadLineHeight))
            treadLine.fillColor = color.withAlphaComponent(treadAlpha)
            treadLine.strokeColor = .clear
            treadLine.position = CGPoint(x: xPosition, y: startY + CGFloat(i) * spacing)
            tankNode.addChild(treadLine)
        }
    }
}
