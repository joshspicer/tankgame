//
//  ThemedTankSpriteRenderer.swift
//  tankgame Shared
//
//  Renders tanks with customizable themes from tank packs
//

import SpriteKit

/// Renders tank sprites based on selected tank pack themes
class ThemedTankSpriteRenderer {
    let tileSize: CGFloat
    private let animationHelper: RainbowAnimationHelper
    
    // Sparkle effect constants
    private var sparkleRadius: CGFloat { tileSize * 0.03 }
    private var sparkleSpread: CGFloat { tileSize * 0.25 }
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Create a themed tank node based on the current pack
    func createThemedTankNode(playerIndex: Int, direction: Direction) -> SKNode {
        let pack = TankPackManager.shared.selectedPack
        let colors = pack.style.primaryColors
        let color = colors[playerIndex % colors.count].skColor
        
        return createTankNode(
            color: color,
            direction: direction,
            bodyShape: pack.style.bodyShape,
            barrelStyle: pack.style.barrelStyle,
            animationType: pack.style.animationType
        )
    }
    
    /// Create a tank node with custom styling
    func createTankNode(
        color: SKColor,
        direction: Direction,
        bodyShape: TankPack.TankStyle.BodyShape,
        barrelStyle: TankPack.TankStyle.BarrelStyle,
        animationType: TankPack.TankStyle.AnimationType
    ) -> SKNode {
        let tankNode = SKNode()
        
        // Create treads
        let leftTread = createTread(color: color, xPosition: -tileSize * 0.3)
        let rightTread = createTread(color: color, xPosition: tileSize * 0.3)
        tankNode.addChild(leftTread)
        tankNode.addChild(rightTread)
        
        // Create body based on shape
        let body = createBody(color: color, shape: bodyShape)
        tankNode.addChild(body)
        
        // Create turret base
        let turretBase = createTurretBase(color: color)
        tankNode.addChild(turretBase)
        
        // Create barrel based on style
        let barrelNodes = createBarrel(color: color, style: barrelStyle)
        for barrel in barrelNodes {
            tankNode.addChild(barrel)
        }
        
        // Apply animations based on type
        applyAnimation(
            to: tankNode,
            animationType: animationType,
            baseColor: color
        )
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    // MARK: - Component Creation
    
    private func createTread(color: SKColor, xPosition: CGFloat) -> SKSpriteNode {
        let tread = SKSpriteNode(
            color: color.withAlphaComponent(0.6),
            size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75)
        )
        tread.position = CGPoint(x: xPosition, y: 0)
        return tread
    }
    
    private func createBody(color: SKColor, shape: TankPack.TankStyle.BodyShape) -> SKNode {
        switch shape {
        case .square:
            let body = SKSpriteNode(
                color: color,
                size: CGSize(width: tileSize * 0.55, height: tileSize * 0.65)
            )
            return body
            
        case .rounded:
            let body = SKShapeNode(rectOf: CGSize(width: tileSize * 0.55, height: tileSize * 0.65), cornerRadius: tileSize * 0.1)
            body.fillColor = color
            body.strokeColor = color.withAlphaComponent(0.5)
            body.lineWidth = 2
            return body
            
        case .diamond:
            let path = CGMutablePath()
            let halfWidth = tileSize * 0.35
            let halfHeight = tileSize * 0.4
            path.move(to: CGPoint(x: 0, y: halfHeight))
            path.addLine(to: CGPoint(x: halfWidth, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -halfHeight))
            path.addLine(to: CGPoint(x: -halfWidth, y: 0))
            path.closeSubpath()
            
            let body = SKShapeNode(path: path)
            body.fillColor = color
            body.strokeColor = color.withAlphaComponent(0.5)
            body.lineWidth = 2
            return body
            
        case .hexagon:
            let path = CGMutablePath()
            let radius = tileSize * 0.35
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3 - .pi / 2
                let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
            
            let body = SKShapeNode(path: path)
            body.fillColor = color
            body.strokeColor = color.withAlphaComponent(0.5)
            body.lineWidth = 2
            return body
        }
    }
    
    private func createTurretBase(color: SKColor) -> SKShapeNode {
        let turretBase = SKShapeNode(circleOfRadius: tileSize * 0.25)
        turretBase.fillColor = color.withAlphaComponent(0.9)
        turretBase.strokeColor = color.withAlphaComponent(0.5)
        turretBase.lineWidth = 2
        turretBase.position = CGPoint(x: 0, y: 0)
        return turretBase
    }
    
    private func createBarrel(color: SKColor, style: TankPack.TankStyle.BarrelStyle) -> [SKNode] {
        var nodes: [SKNode] = []
        
        switch style {
        case .standard:
            let barrel = SKSpriteNode(
                color: color.withAlphaComponent(0.8),
                size: CGSize(width: tileSize * 0.15, height: tileSize * 0.5)
            )
            barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
            nodes.append(barrel)
            
            let muzzle = SKSpriteNode(
                color: .darkGray,
                size: CGSize(width: tileSize * 0.18, height: tileSize * 0.12)
            )
            muzzle.position = CGPoint(x: 0, y: tileSize * 0.56)
            nodes.append(muzzle)
            
        case .double:
            for xOffset in [-tileSize * 0.1, tileSize * 0.1] {
                let barrel = SKSpriteNode(
                    color: color.withAlphaComponent(0.8),
                    size: CGSize(width: tileSize * 0.1, height: tileSize * 0.5)
                )
                barrel.position = CGPoint(x: xOffset, y: tileSize * 0.35)
                nodes.append(barrel)
            }
            
            let muzzle = SKSpriteNode(
                color: .darkGray,
                size: CGSize(width: tileSize * 0.28, height: tileSize * 0.1)
            )
            muzzle.position = CGPoint(x: 0, y: tileSize * 0.56)
            nodes.append(muzzle)
            
        case .wide:
            let barrel = SKSpriteNode(
                color: color.withAlphaComponent(0.8),
                size: CGSize(width: tileSize * 0.25, height: tileSize * 0.45)
            )
            barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
            nodes.append(barrel)
            
            let muzzle = SKSpriteNode(
                color: .darkGray,
                size: CGSize(width: tileSize * 0.28, height: tileSize * 0.15)
            )
            muzzle.position = CGPoint(x: 0, y: tileSize * 0.54)
            nodes.append(muzzle)
            
        case .pointed:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -tileSize * 0.1, y: 0))
            path.addLine(to: CGPoint(x: tileSize * 0.1, y: 0))
            path.addLine(to: CGPoint(x: 0, y: tileSize * 0.5))
            path.closeSubpath()
            
            let barrel = SKShapeNode(path: path)
            barrel.fillColor = color.withAlphaComponent(0.8)
            barrel.strokeColor = color.withAlphaComponent(0.5)
            barrel.lineWidth = 1
            barrel.position = CGPoint(x: 0, y: tileSize * 0.15)
            nodes.append(barrel)
        }
        
        return nodes
    }
    
    // MARK: - Animation
    
    private func applyAnimation(
        to tankNode: SKNode,
        animationType: TankPack.TankStyle.AnimationType,
        baseColor: SKColor
    ) {
        switch animationType {
        case .rainbow:
            applyRainbowAnimation(to: tankNode)
            
        case .pulse:
            applyPulseAnimation(to: tankNode)
            
        case .glow:
            applyGlowAnimation(to: tankNode, baseColor: baseColor)
            
        case .static_:
            // No animation
            break
            
        case .sparkle:
            applySparkleAnimation(to: tankNode, baseColor: baseColor)
        }
    }
    
    private func applyRainbowAnimation(to node: SKNode) {
        for child in node.children {
            if let sprite = child as? SKSpriteNode {
                animationHelper.addRainbowAnimation(to: sprite, phaseOffset: CGFloat.random(in: 0...0.3))
            }
            applyRainbowAnimation(to: child)
        }
    }
    
    private func applyPulseAnimation(to node: SKNode) {
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        node.run(repeatPulse)
    }
    
    private func applyGlowAnimation(to node: SKNode, baseColor: SKColor) {
        let glowNode = SKEffectNode()
        glowNode.shouldRasterize = true
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 3.0])
        
        // Add a glow effect using alpha pulsing
        let fadeOut = SKAction.fadeAlpha(to: 0.6, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let glow = SKAction.sequence([fadeOut, fadeIn])
        let repeatGlow = SKAction.repeatForever(glow)
        node.run(repeatGlow)
    }
    
    private func applySparkleAnimation(to node: SKNode, baseColor: SKColor) {
        // Calculate sparkle parameters based on tile size
        let radius = sparkleRadius
        let spread = sparkleSpread
        
        // Create sparkle emitter
        let sparkleAction = SKAction.run { [weak node] in
            guard let node = node else { return }
            
            let sparkle = SKShapeNode(circleOfRadius: radius)
            sparkle.fillColor = .white
            sparkle.strokeColor = .clear
            sparkle.position = CGPoint(
                x: CGFloat.random(in: -spread...spread),
                y: CGFloat.random(in: -spread...spread)
            )
            sparkle.alpha = 0
            node.addChild(sparkle)
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let wait = SKAction.wait(forDuration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let remove = SKAction.removeFromParent()
            sparkle.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
        }
        
        let delay = SKAction.wait(forDuration: 0.3)
        let sparkleSequence = SKAction.sequence([sparkleAction, delay])
        let repeatSparkle = SKAction.repeatForever(sparkleSequence)
        node.run(repeatSparkle)
    }
}
