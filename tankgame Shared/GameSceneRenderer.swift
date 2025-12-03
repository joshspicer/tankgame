//
//  GameSceneRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit
#if os(iOS) || os(tvOS)
import UIKit
#endif

/// Handles all rendering operations for the game scene
class GameSceneRenderer {
    // Constants
    let tileSize: CGFloat
    let gridSize: Int
    
    // Tank colors for up to 4 players (fallback if no skin selected)
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    // Player skins (indexed by player index)
    var playerSkins: [Int: TankSkin] = [:]
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Set the skin for a player
    func setSkin(_ skin: TankSkin, forPlayer playerIndex: Int) {
        playerSkins[playerIndex] = skin
    }
    
    // MARK: - Grid Rendering
    
    /// Render the game grid
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let tile = SKSpriteNode(color: cell == .wall ? .black : .white, size: CGSize(width: tileSize - 2, height: tileSize - 2))
                tile.position = gridPosition(row: row, col: col)
                gridNode.addChild(tile)
            }
        }
    }
    
    // MARK: - Tank Rendering
    
    /// Render all tanks
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let skin = playerSkins[i]
                let color = skin?.primaryColor ?? tankColors[i]
                let tankSprite = createTankNode(color: color, direction: tank.direction, skin: skin)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }
    
    /// Create a tank sprite node
    private func createTankNode(color: SKColor, direction: Direction, skin: TankSkin? = nil) -> SKNode {
        let tankNode = SKNode()
        
        // Tank body (square)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.7, height: tileSize * 0.7))
        tankNode.addChild(body)
        
        // Tank barrel (rectangle)
        let barrel = SKSpriteNode(color: color.withAlphaComponent(0.8), size: CGSize(width: tileSize * 0.2, height: tileSize * 0.5))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
        tankNode.addChild(barrel)
        
        // Apply skin effects
        if let skin = skin {
            if skin.hasRainbowEffect {
                addRainbowAnimation(to: body, phaseOffset: 0)
                addRainbowAnimation(to: barrel, phaseOffset: 0.15)
            }
            
            if skin.hasGlowEffect {
                addGlowEffect(to: tankNode, color: color)
            }
            
            if let particleEffect = skin.particleEffect {
                addParticleEffect(particleEffect, to: tankNode, color: color)
            }
        } else {
            // Default rainbow animation for all tanks
            addRainbowAnimation(to: body, phaseOffset: 0)
            addRainbowAnimation(to: barrel, phaseOffset: 0.15)
        }
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    // MARK: - Projectile Rendering
    
    /// Render all projectiles
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        
        for projectile in projectiles {
            // Make projectile larger and more visible
            let bullet = SKSpriteNode(color: .yellow, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.5))
            bullet.zPosition = 5
            bullet.position = gridPosition(row: projectile.row, col: projectile.col)
            
            // Add rainbow color animation
            addRainbowAnimation(to: bullet, phaseOffset: 0.5)
            
            // Add pulsing scale animation
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            let repeatPulse = SKAction.repeatForever(pulse)
            bullet.run(repeatPulse)
            
            // Add rotation animation based on direction
            let rotationDuration: TimeInterval = 0.5
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: rotationDuration)
            let repeatRotation = SKAction.repeatForever(rotate)
            bullet.run(repeatRotation)
            
            projectilesNode.addChild(bullet)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
    
    /// Add rainbow color animation to a sprite
    private func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
        var colorActions: [SKAction] = []
        
        // Create a smooth rainbow by cycling through hue values
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
            let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: animationDuration / Double(numberOfColors))
            colorActions.append(colorAction)
        }
        
        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)
        
        sprite.run(repeatForever)
    }
    
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
        let particleTexture = createParticleTexture()
        
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
