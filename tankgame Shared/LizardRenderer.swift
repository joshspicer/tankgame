//
//  LizardRenderer.swift
//  tankgame Shared
//
//  Handles rendering of lizards with animations
//

import SpriteKit

/// Handles rendering of lizards with animations
class LizardRenderer: BaseRenderer {
    
    // Lizard sprite renderer
    private let lizardSpriteRenderer: LizardSpriteRenderer
    
    override init(tileSize: CGFloat, gridSize: Int) {
        self.lizardSpriteRenderer = LizardSpriteRenderer(tileSize: tileSize)
        super.init(tileSize: tileSize, gridSize: gridSize)
    }
    
    /// Render all lizards
    func renderLizards(_ lizards: [Lizard], in lizardNode: SKNode) {
        lizardNode.removeAllChildren()
        
        for lizard in lizards where lizard.isAlive {
            let sprite = lizardSpriteRenderer.createLizardNode(direction: lizard.direction)
            sprite.position = gridPosition(row: lizard.row, col: lizard.col)
            sprite.name = "lizard"
            lizardNode.addChild(sprite)
        }
    }
    
    /// Render lizards with smooth animation
    func renderLizardsWithSmoothing(_ lizards: [Lizard], in lizardNode: SKNode, duration: TimeInterval) {
        let existingSprites = lizardNode.children.filter { $0.name == "lizard" }
        let aliveLizards = lizards.filter { $0.isAlive }
        
        guard existingSprites.count == aliveLizards.count else {
            renderLizards(lizards, in: lizardNode)
            return
        }
        
        for (sprite, lizard) in zip(existingSprites, aliveLizards) {
            animateSpriteMovement(sprite, to: gridPosition(row: lizard.row, col: lizard.col), rotation: CGFloat(lizard.direction.angle), duration: duration)
        }
    }
}
