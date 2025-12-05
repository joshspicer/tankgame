//
//  LizardSpriteRenderer.swift
//  tankgame Shared
//
//  Handles lizard sprite creation - clean retro style
//

import SpriteKit

/// Creates and manages lizard sprite nodes - clean retro style
class LizardSpriteRenderer {
    let tileSize: CGFloat
    
    /// Simple lizard color
    private let lizardColor = SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a simple lizard sprite node
    func createLizardNode(direction: Direction) -> SKNode {
        let lizardNode = SKNode()
        
        // Simple lizard body (elongated rectangle)
        let body = SKSpriteNode(color: lizardColor, size: CGSize(width: tileSize * 0.4, height: tileSize * 0.6))
        lizardNode.addChild(body)
        
        // Simple head (small rectangle at front)
        let head = SKSpriteNode(color: lizardColor, size: CGSize(width: tileSize * 0.25, height: tileSize * 0.2))
        head.position = CGPoint(x: 0, y: tileSize * 0.32)
        lizardNode.addChild(head)
        
        // Simple eyes (small dots)
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.04)
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -tileSize * 0.07, y: tileSize * 0.36)
        lizardNode.addChild(leftEye)
        
        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.04)
        rightEye.fillColor = .black
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: tileSize * 0.07, y: tileSize * 0.36)
        lizardNode.addChild(rightEye)
        
        // Simple tail
        let tailColor = darkenColor(lizardColor, by: 0.1)
        let tail = SKSpriteNode(color: tailColor, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.3))
        tail.position = CGPoint(x: 0, y: -tileSize * 0.35)
        lizardNode.addChild(tail)
        
        // Rotate based on direction
        lizardNode.zRotation = CGFloat(direction.angle)
        
        return lizardNode
    }
    
    /// Darken a color by a percentage
    private func darkenColor(_ color: SKColor, by amount: CGFloat) -> SKColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(red: max(red - amount, 0), green: max(green - amount, 0), blue: max(blue - amount, 0), alpha: alpha)
    }
}
