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
    
    // Tank colors for up to 4 players (fallback)
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    // Tank sprite renderer
    private let themedSpriteRenderer: ThemedTankSpriteRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.themedSpriteRenderer = ThemedTankSpriteRenderer(tileSize: tileSize)
    }
    
    /// Render all tanks
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let tankSprite = createThemedTankNode(playerIndex: i, direction: tank.direction)
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
                    let tankSprite = createThemedTankNode(playerIndex: i, direction: tank.direction)
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
    
    /// Create a themed tank sprite node based on selected tank pack
    private func createThemedTankNode(playerIndex: Int, direction: Direction) -> SKNode {
        return themedSpriteRenderer.createThemedTankNode(playerIndex: playerIndex, direction: direction)
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
