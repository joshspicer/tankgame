//
//  TankRenderer.swift
//  tankgame Shared
//
//  Tank rendering logic extracted from GameSceneRenderer
//

import SpriteKit
#if os(iOS) || os(tvOS)
import UIKit
#endif

/// Handles rendering of tanks with animations
class TankRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Tank colors for up to 4 players
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    // Player skins (indexed by player index)
    var playerSkins: [Int: TankSkin] = [:]
    
    // Cached particle texture
    private var cachedParticleTexture: SKTexture?
    
    // Sprite renderers
    private let tankSpriteRenderer: TankSpriteRenderer
    private let dolphinSpriteRenderer: DolphinSpriteRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.tankSpriteRenderer = TankSpriteRenderer(tileSize: tileSize)
        self.dolphinSpriteRenderer = DolphinSpriteRenderer(tileSize: tileSize)
    }
    
    /// Set the skin for a player
    func setSkin(_ skin: TankSkin, forPlayer playerIndex: Int) {
        playerSkins[playerIndex] = skin
    }
    
    /// Render all tanks
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let skin = playerSkins[i]
                let color = skin?.primaryColor ?? tankColors[i]
                let tankSprite = createTankNode(color: color, direction: tank.direction, skin: skin, playerIndex: i)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }
    
    /// Render all tanks with smooth animation
    func renderTanksWithSmoothing(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?], duration: TimeInterval) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let targetPosition = gridPosition(row: tank.row, col: tank.col)
                
                // If tank sprite exists, animate to new position
                if let tankSprite = tankNode.children.first {
                    // Animate position
                    let moveAction = SKAction.move(to: targetPosition, duration: duration)
                    moveAction.timingMode = .easeOut
                    tankSprite.run(moveAction)
                    
                    // Animate rotation smoothly
                    let currentRotation = tankSprite.zRotation
                    let targetRotation = CGFloat(tank.direction.angle)
                    let rotationDiff = shortestRotationDifference(from: currentRotation, to: targetRotation)
                    
                    if abs(rotationDiff) > 0.01 {
                        let rotateAction = SKAction.rotate(byAngle: rotationDiff, duration: duration)
                        rotateAction.timingMode = .easeOut
                        tankSprite.run(rotateAction)
                    }
                } else {
                    // Create new sprite if doesn't exist
                    let skin = playerSkins[i]
                    let color = skin?.primaryColor ?? tankColors[i]
                    let tankSprite = createTankNode(color: color, direction: tank.direction, skin: skin, playerIndex: i)
                    tankSprite.position = targetPosition
                    tankNode.addChild(tankSprite)
                }
            } else {
                tankNode.removeAllChildren()
            }
        }
    }
    
    /// Calculate the shortest rotation difference between two angles
    private func shortestRotationDifference(from: CGFloat, to: CGFloat) -> CGFloat {
        var diff = to - from
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return diff
    }
    
    /// Create a tank sprite node based on current sprite mode
    private func createTankNode(color: SKColor, direction: Direction, skin: TankSkin? = nil, playerIndex: Int = 0) -> SKNode {
        let baseNode: SKNode
        switch GameSettings.shared.spriteMode {
        case .dolphin:
            baseNode = dolphinSpriteRenderer.createDolphinNode(color: color, direction: direction)
        case .tank:
            baseNode = tankSpriteRenderer.createTankNode(color: color, direction: direction)
        }
        
        // Apply skin effects if available
        if let skin = skin {
            if skin.hasGlowEffect {
                addGlowEffect(to: baseNode, color: color)
            }
            
            if let particleEffect = skin.particleEffect, particleEffect != .none {
                addParticleEffect(particleEffect, to: baseNode, color: color)
            }
        }
        
        return baseNode
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
    
    // MARK: - Skin Effects
    
    /// Add glow effect to a node
    private func addGlowEffect(to node: SKNode, color: SKColor) {
        let glowNode = SKEffectNode()
        glowNode.shouldRasterize = true
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8.0])
        
        let glowSprite = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.9, height: tileSize * 0.9))
        glowSprite.alpha = 0.5
        glowNode.addChild(glowSprite)
        glowNode.zPosition = -1
        
        // Pulsing glow
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
        let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.5)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        glowNode.run(SKAction.repeatForever(pulse))
        
        node.addChild(glowNode)
    }
    
    /// Create or return cached circular texture for particles
    private func getParticleTexture() -> SKTexture {
        if let cached = cachedParticleTexture {
            return cached
        }
        
        let texture = createParticleTexture()
        cachedParticleTexture = texture
        return texture
    }
    
    /// Create a simple circular texture for particles
    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: rect)
        }
        return SKTexture(image: image)
        #else
        // macOS fallback - use a simple shape node converted to texture
        let shapeNode = SKShapeNode(circleOfRadius: 8)
        shapeNode.fillColor = .white
        shapeNode.strokeColor = .clear
        let view = SKView()
        return view.texture(from: shapeNode) ?? SKTexture()
        #endif
    }
    
    /// Add particle effect to a node
    private func addParticleEffect(_ effectType: TankSkin.ParticleEffectType, to node: SKNode, color: SKColor) {
        let emitter = SKEmitterNode()
        let particleTexture = getParticleTexture()
        
        switch effectType {
        case .fire:
            emitter.particleTexture = particleTexture
            emitter.particleBirthRate = 50
            emitter.particleLifetime = 0.5
            emitter.particleSpeed = 20
            emitter.particleSpeedRange = 10
            emitter.particleAlpha = 0.8
            emitter.particleAlphaSpeed = -1.5
            emitter.particleScale = 0.2
            emitter.particleScaleRange = 0.1
            emitter.particleColor = .orange
            emitter.particleColorBlendFactor = 1.0
            emitter.emissionAngle = .pi
            emitter.emissionAngleRange = .pi / 4
            
        case .sparkle:
            emitter.particleTexture = particleTexture
            emitter.particleBirthRate = 20
            emitter.particleLifetime = 1.0
            emitter.particleSpeed = 30
            emitter.particleSpeedRange = 20
            emitter.particleAlpha = 1.0
            emitter.particleAlphaSpeed = -1.0
            emitter.particleScale = 0.15
            emitter.particleScaleRange = 0.1
            emitter.particleColor = color
            emitter.particleColorBlendFactor = 1.0
            emitter.emissionAngleRange = .pi * 2
            
        case .smoke:
            emitter.particleTexture = particleTexture
            emitter.particleBirthRate = 30
            emitter.particleLifetime = 1.5
            emitter.particleSpeed = 15
            emitter.particleSpeedRange = 5
            emitter.particleAlpha = 0.4
            emitter.particleAlphaSpeed = -0.3
            emitter.particleScale = 0.3
            emitter.particleScaleSpeed = 0.2
            emitter.particleColor = .gray
            emitter.particleColorBlendFactor = 1.0
            emitter.emissionAngle = .pi
            emitter.emissionAngleRange = .pi / 6
            
        case .none:
            return
        }
        
        emitter.position = CGPoint(x: 0, y: -tileSize * 0.3)
        emitter.zPosition = -1
        node.addChild(emitter)
    }
}
