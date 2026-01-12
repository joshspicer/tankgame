//
//  LizardRenderer.swift
//  tankgame Shared
//
//  Handles rendering of lizards with animations
//

import SpriteKit

/// Handles rendering of lizards with animations
class LizardRenderer: GridPositionConvertible {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Lizard sprite renderer
    private let lizardSpriteRenderer: LizardSpriteRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.lizardSpriteRenderer = LizardSpriteRenderer(tileSize: tileSize)
    }
    
    /// Render all lizards
    func renderLizards(_ lizards: [Lizard], in lizardNode: SKNode) {
        lizardNode.removeAllChildren()
        
        for lizard in lizards {
            if lizard.isAlive {
                let sprite = lizardSpriteRenderer.createLizardNode(direction: lizard.direction)
                sprite.position = gridPosition(row: lizard.row, col: lizard.col)
                sprite.name = "lizard"
                lizardNode.addChild(sprite)
            }
        }
    }
    
    /// Render lizards with smooth animation
    func renderLizardsWithSmoothing(_ lizards: [Lizard], in lizardNode: SKNode, duration: TimeInterval) {
        // Get existing sprites
        let existingSprites = lizardNode.children.filter { $0.name == "lizard" }
        
        // If count doesn't match, rebuild all
        if existingSprites.count != lizards.filter({ $0.isAlive }).count {
            renderLizards(lizards, in: lizardNode)
            return
        }
        
        // Animate existing sprites
        var spriteIndex = 0
        for lizard in lizards {
            if lizard.isAlive && spriteIndex < existingSprites.count {
                let sprite = existingSprites[spriteIndex]
                let targetPosition = gridPosition(row: lizard.row, col: lizard.col)
                
                // Animate position
                let moveAction = SKAction.move(to: targetPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(moveAction)
                
                // Animate rotation
                let currentRotation = sprite.zRotation
                let targetRotation = CGFloat(lizard.direction.angle)
                let rotationDiff = RenderingUtilities.shortestRotationDifference(from: currentRotation, to: targetRotation)
                
                if abs(rotationDiff) > 0.01 {
                    let rotateAction = SKAction.rotate(byAngle: rotationDiff, duration: duration)
                    rotateAction.timingMode = .easeOut
                    sprite.run(rotateAction)
                }
                
                spriteIndex += 1
            }
        }
    }
}
