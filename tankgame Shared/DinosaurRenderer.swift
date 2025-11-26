//
//  DinosaurRenderer.swift
//  tankgame Shared
//
//  Handles rendering of dinosaurs with animations
//

import SpriteKit

/// Handles rendering of dinosaurs with animations
class DinosaurRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    // Dinosaur sprite renderer
    private let spriteRenderer: DinosaurSpriteRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.spriteRenderer = DinosaurSpriteRenderer(tileSize: tileSize)
    }
    
    /// Render all dinosaurs
    func renderDinosaurs(_ dinosaurs: [Dinosaur], in dinosaurNode: SKNode) {
        dinosaurNode.removeAllChildren()
        
        for dinosaur in dinosaurs where dinosaur.isAlive {
            let dinoSprite = spriteRenderer.createDinosaurNode(direction: dinosaur.direction)
            dinoSprite.position = gridPosition(row: dinosaur.row, col: dinosaur.col)
            dinosaurNode.addChild(dinoSprite)
        }
    }
    
    /// Render all dinosaurs with smooth animation
    func renderDinosaursWithSmoothing(_ dinosaurs: [Dinosaur], existingNodes: [SKNode], in dinosaurNode: SKNode, duration: TimeInterval) {
        // If node counts don't match, do a full re-render
        let aliveCount = dinosaurs.filter { $0.isAlive }.count
        if existingNodes.count != aliveCount {
            renderDinosaurs(dinosaurs, in: dinosaurNode)
            return
        }
        
        var nodeIndex = 0
        for dinosaur in dinosaurs where dinosaur.isAlive {
            guard nodeIndex < existingNodes.count else { break }
            let dinoSprite = existingNodes[nodeIndex]
            let targetPosition = gridPosition(row: dinosaur.row, col: dinosaur.col)
            
            // Animate position
            let moveAction = SKAction.move(to: targetPosition, duration: duration)
            moveAction.timingMode = .easeOut
            dinoSprite.run(moveAction)
            
            // Animate rotation smoothly
            let currentRotation = dinoSprite.zRotation
            let targetRotation = CGFloat(dinosaur.direction.angle)
            let rotationDiff = shortestRotationDifference(from: currentRotation, to: targetRotation)
            
            if abs(rotationDiff) > 0.01 {
                let rotateAction = SKAction.rotate(byAngle: rotationDiff, duration: duration)
                rotateAction.timingMode = .easeOut
                dinoSprite.run(rotateAction)
            }
            
            nodeIndex += 1
        }
    }
    
    /// Calculate the shortest rotation difference between two angles
    private func shortestRotationDifference(from: CGFloat, to: CGFloat) -> CGFloat {
        var diff = to - from
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return diff
    }
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
