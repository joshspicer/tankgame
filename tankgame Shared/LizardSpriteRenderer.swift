//
//  LizardSpriteRenderer.swift
//  tankgame Shared
//
//  Handles lizard sprite creation and rendering
//

import SpriteKit

/// Creates and manages lizard sprite nodes
class LizardSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a lizard sprite node with classic solid styling
    func createLizardNode(direction: Direction) -> SKNode {
        let lizardNode = SKNode()
        
        // Classic green color for lizard
        let baseColor = SKColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
        let darkColor = SKColor(red: 0.1, green: 0.4, blue: 0.2, alpha: 1.0)
        
        // Lizard body (elongated oval shape)
        let body = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.7))
        lizardNode.addChild(body)
        
        // Lizard head (smaller oval at front)
        let head = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.3, height: tileSize * 0.25))
        head.position = CGPoint(x: 0, y: tileSize * 0.35)
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
        let tail = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.15, height: tileSize * 0.4))
        tail.position = CGPoint(x: 0, y: -tileSize * 0.4)
        lizardNode.addChild(tail)
        
        // Lizard legs (4 small legs)
        let legColor = darkColor
        
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
