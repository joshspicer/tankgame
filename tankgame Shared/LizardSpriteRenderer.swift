//
//  LizardSpriteRenderer.swift
//  tankgame Shared
//
//  Handles lizard sprite creation and rendering
//

import SpriteKit

/// Creates and manages lizard sprite nodes - Classic retro style
class LizardSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a simple lizard sprite node
    func createLizardNode(direction: Direction) -> SKNode {
        let lizardNode = SKNode()
        
        // Base color for lizard (classic green)
        let baseColor = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0)
        let darkColor = SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1.0)
        
        // Lizard body (simple rectangle)
        let body = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.4, height: tileSize * 0.6))
        lizardNode.addChild(body)
        
        // Lizard head (smaller rectangle at front)
        let head = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.25, height: tileSize * 0.2))
        head.position = CGPoint(x: 0, y: tileSize * 0.3)
        lizardNode.addChild(head)
        
        // Lizard eyes (simple dots)
        let leftEye = SKSpriteNode(color: .black, size: CGSize(width: tileSize * 0.06, height: tileSize * 0.06))
        leftEye.position = CGPoint(x: -tileSize * 0.06, y: tileSize * 0.35)
        lizardNode.addChild(leftEye)
        
        let rightEye = SKSpriteNode(color: .black, size: CGSize(width: tileSize * 0.06, height: tileSize * 0.06))
        rightEye.position = CGPoint(x: tileSize * 0.06, y: tileSize * 0.35)
        lizardNode.addChild(rightEye)
        
        // Lizard tail (simple rectangle)
        let tail = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.1, height: tileSize * 0.3))
        tail.position = CGPoint(x: 0, y: -tileSize * 0.35)
        lizardNode.addChild(tail)
        
        // Rotate based on direction
        lizardNode.zRotation = CGFloat(direction.angle)
        
        return lizardNode
    }
}
