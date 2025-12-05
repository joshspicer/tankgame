//
//  LizardSpriteRenderer.swift
//  tankgame Shared
//
//  Handles lizard sprite creation and rendering
//

import SpriteKit

/// Creates and manages lizard sprite nodes with classic retro styling
class LizardSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a lizard sprite node with classic retro visual design
    func createLizardNode(direction: Direction) -> SKNode {
        let lizardNode = SKNode()
        
        // Use retro lizard color
        let baseColor = RetroColors.lizard
        
        // Lizard body (elongated oval shape) - solid color
        let body = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.7))
        body.alpha = 0.9
        lizardNode.addChild(body)
        
        // Lizard head (smaller oval at front)
        let head = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.3, height: tileSize * 0.25))
        head.position = CGPoint(x: 0, y: tileSize * 0.35)
        head.alpha = 0.95
        lizardNode.addChild(head)
        
        // Lizard eyes (small dots)
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -tileSize * 0.08, y: tileSize * 0.4)
        lizardNode.addChild(leftEye)
        
        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        rightEye.fillColor = .black
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: tileSize * 0.08, y: tileSize * 0.4)
        lizardNode.addChild(rightEye)
        
        // Lizard tail (tapered back)
        let tail = SKSpriteNode(color: baseColor.withAlphaComponent(0.7), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.4))
        tail.position = CGPoint(x: 0, y: -tileSize * 0.4)
        lizardNode.addChild(tail)
        
        // Lizard legs (4 small legs)
        let legColor = baseColor.withAlphaComponent(0.6)
        
        // Front left leg
        let frontLeftLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.2, height: tileSize * 0.08))
        frontLeftLeg.position = CGPoint(x: -tileSize * 0.25, y: tileSize * 0.15)
        frontLeftLeg.zRotation = 0.3
        lizardNode.addChild(frontLeftLeg)
        
        // Front right leg
        let frontRightLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.2, height: tileSize * 0.08))
        frontRightLeg.position = CGPoint(x: tileSize * 0.25, y: tileSize * 0.15)
        frontRightLeg.zRotation = -0.3
        lizardNode.addChild(frontRightLeg)
        
        // Back left leg
        let backLeftLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.2, height: tileSize * 0.08))
        backLeftLeg.position = CGPoint(x: -tileSize * 0.25, y: -tileSize * 0.15)
        backLeftLeg.zRotation = -0.3
        lizardNode.addChild(backLeftLeg)
        
        // Back right leg
        let backRightLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.2, height: tileSize * 0.08))
        backRightLeg.position = CGPoint(x: tileSize * 0.25, y: -tileSize * 0.15)
        backRightLeg.zRotation = 0.3
        lizardNode.addChild(backRightLeg)
        
        // Rotate based on direction
        lizardNode.zRotation = CGFloat(direction.angle)
        
        return lizardNode
    }
}
