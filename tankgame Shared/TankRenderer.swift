//
//  TankRenderer.swift
//  tankgame Shared
//
//  Tank rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of tanks with animations
class TankRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Tank colors for up to 4 players
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    // Batman mode tank colors - darker variants
    let batmanTankColors: [SKColor] = [
        SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0),    // Dark blue-gray
        SKColor(red: 0.3, green: 0.15, blue: 0.15, alpha: 1.0),  // Dark red
        SKColor(red: 0.15, green: 0.25, blue: 0.15, alpha: 1.0), // Dark green
        SKColor(red: 0.3, green: 0.25, blue: 0.1, alpha: 1.0)    // Dark orange
    ]
    
    // Tank sprite renderer
    private let tankSpriteRenderer: TankSpriteRenderer
    private let animationHelper: RainbowAnimationHelper
    private let batmanAnimationHelper: BatmanAnimationHelper
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.tankSpriteRenderer = TankSpriteRenderer(tileSize: tileSize)
        self.animationHelper = RainbowAnimationHelper()
        self.batmanAnimationHelper = BatmanAnimationHelper()
    }
    
    /// Render all tanks
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        let isBatmanMode = GameSettings.shared.isBatmanMode
        let colors = isBatmanMode ? batmanTankColors : tankColors
        
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let color = colors[i]
                let tankSprite = createTankNode(color: color, direction: tank.direction, isBatmanMode: isBatmanMode)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }
    
    /// Render all tanks with smooth animation
    func renderTanksWithSmoothing(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?], duration: TimeInterval) {
        let isBatmanMode = GameSettings.shared.isBatmanMode
        let colors = isBatmanMode ? batmanTankColors : tankColors
        
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
                    let color = colors[i]
                    let tankSprite = createTankNode(color: color, direction: tank.direction, isBatmanMode: isBatmanMode)
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
    
    /// Create a tank sprite node
    private func createTankNode(color: SKColor, direction: Direction, isBatmanMode: Bool = false) -> SKNode {
        let tankNode = SKNode()
        
        // Tank body (square)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.7, height: tileSize * 0.7))
        tankNode.addChild(body)
        
        // Tank barrel (rectangle)
        let barrel = SKSpriteNode(color: color.withAlphaComponent(0.8), size: CGSize(width: tileSize * 0.2, height: tileSize * 0.5))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
        tankNode.addChild(barrel)
        
        // Add animation based on mode
        if isBatmanMode {
            batmanAnimationHelper.addBatmanAnimation(to: body, phaseOffset: 0)
            batmanAnimationHelper.addBatmanAnimation(to: barrel, phaseOffset: 0.15)
        } else {
            animationHelper.addRainbowAnimation(to: body, phaseOffset: 0)
            animationHelper.addRainbowAnimation(to: barrel, phaseOffset: 0.15)
        }
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
