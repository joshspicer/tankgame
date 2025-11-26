//
//  DinosaurRenderer.swift
//  tankgame Shared
//
//  Handles rendering of dinosaurs with animations
//

import SpriteKit

/// Handles rendering of dinosaurs in the game scene
class DinosaurRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    
    private let spriteRenderer: DinosaurSpriteRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.spriteRenderer = DinosaurSpriteRenderer(tileSize: tileSize)
    }
    
    /// Render all dinosaurs
    func renderDinosaurs(_ dinosaurs: [Dinosaur], dinosaurExploding: [Bool], in dinosaurNodes: [SKNode?]) {
        for i in 0..<dinosaurs.count {
            guard let dinosaurNode = dinosaurNodes[i] else { continue }
            dinosaurNode.removeAllChildren()
            
            let dinosaur = dinosaurs[i]
            if dinosaur.isAlive || dinosaurExploding[i] {
                let dinosaurSprite = spriteRenderer.createDinosaurNode(direction: dinosaur.direction)
                dinosaurSprite.position = gridPosition(row: dinosaur.row, col: dinosaur.col)
                dinosaurNode.addChild(dinosaurSprite)
            }
        }
    }
    
    /// Render all dinosaurs with smooth animation
    func renderDinosaursWithSmoothing(_ dinosaurs: [Dinosaur], dinosaurExploding: [Bool], in dinosaurNodes: [SKNode?], duration: TimeInterval) {
        for i in 0..<dinosaurs.count {
            guard let dinosaurNode = dinosaurNodes[i] else { continue }
            
            let dinosaur = dinosaurs[i]
            if dinosaur.isAlive || dinosaurExploding[i] {
                let targetPosition = gridPosition(row: dinosaur.row, col: dinosaur.col)
                
                // If dinosaur sprite exists, animate to new position
                if let dinosaurSprite = dinosaurNode.children.first {
                    // Animate position
                    let moveAction = SKAction.move(to: targetPosition, duration: duration)
                    moveAction.timingMode = .easeOut
                    dinosaurSprite.run(moveAction)
                    
                    // Animate rotation smoothly
                    let currentRotation = dinosaurSprite.zRotation
                    let targetRotation = CGFloat(dinosaur.direction.angle)
                    let rotationDiff = shortestRotationDifference(from: currentRotation, to: targetRotation)
                    
                    if abs(rotationDiff) > 0.01 {
                        let rotateAction = SKAction.rotate(byAngle: rotationDiff, duration: duration)
                        rotateAction.timingMode = .easeOut
                        dinosaurSprite.run(rotateAction)
                    }
                } else {
                    // Create new sprite if doesn't exist
                    let dinosaurSprite = spriteRenderer.createDinosaurNode(direction: dinosaur.direction)
                    dinosaurSprite.position = targetPosition
                    dinosaurNode.addChild(dinosaurSprite)
                }
            } else {
                dinosaurNode.removeAllChildren()
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
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
