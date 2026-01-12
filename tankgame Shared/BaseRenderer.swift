//
//  BaseRenderer.swift
//  tankgame Shared
//
//  Shared rendering utilities for all renderers
//

import SpriteKit

/// Base class with common rendering utilities
class BaseRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
    
    /// Calculate the shortest rotation difference between two angles
    func shortestRotationDifference(from: CGFloat, to: CGFloat) -> CGFloat {
        var diff = to - from
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return diff
    }
    
    /// Animate a sprite to a new position and rotation
    func animateSpriteMovement(_ sprite: SKNode, to position: CGPoint, rotation: CGFloat, duration: TimeInterval) {
        let moveAction = SKAction.move(to: position, duration: duration)
        moveAction.timingMode = .easeOut
        sprite.run(moveAction)
        
        let rotationDiff = shortestRotationDifference(from: sprite.zRotation, to: rotation)
        if abs(rotationDiff) > 0.01 {
            let rotateAction = SKAction.rotate(byAngle: rotationDiff, duration: duration)
            rotateAction.timingMode = .easeOut
            sprite.run(rotateAction)
        }
    }
}
