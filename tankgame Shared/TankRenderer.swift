//
//  TankRenderer.swift
//  tankgame Shared
//
//  Tank rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of tanks with classic retro styling
class TankRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Sprite renderers
    private let tankSpriteRenderer: TankSpriteRenderer
    private let dolphinSpriteRenderer: DolphinSpriteRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.tankSpriteRenderer = TankSpriteRenderer(tileSize: tileSize)
        self.dolphinSpriteRenderer = DolphinSpriteRenderer(tileSize: tileSize)
    }
    
    /// Render all tanks
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let color = RetroColors.playerColors[i]
                let tankSprite = createTankNode(color: color, direction: tank.direction)
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
                    let color = RetroColors.playerColors[i]
                    let tankSprite = createTankNode(color: color, direction: tank.direction)
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
    private func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        switch GameSettings.shared.spriteMode {
        case .dolphin:
            return dolphinSpriteRenderer.createDolphinNode(color: color, direction: direction)
        case .tank:
            return tankSpriteRenderer.createTankNode(color: color, direction: direction)
        }
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
