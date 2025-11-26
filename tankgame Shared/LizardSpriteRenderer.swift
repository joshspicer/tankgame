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
    private let animationHelper: RainbowAnimationHelper
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Create a lizard sprite node with visual details
    func createLizardNode(direction: Direction) -> SKNode {
        let lizardNode = SKNode()
        
        // Base color for lizard (green)
        let baseColor = SKColor.systemGreen
        
        // Lizard body (elongated oval shape)
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
        
        // Add rainbow animation to body parts
        animationHelper.addRainbowAnimation(to: body, phaseOffset: 0)
        animationHelper.addRainbowAnimation(to: head, phaseOffset: 0.1)
        animationHelper.addRainbowAnimation(to: tail, phaseOffset: 0.2)
        animationHelper.addRainbowAnimation(to: frontLeftLeg, phaseOffset: 0.3)
        animationHelper.addRainbowAnimation(to: frontRightLeg, phaseOffset: 0.35)
        animationHelper.addRainbowAnimation(to: backLeftLeg, phaseOffset: 0.4)
        animationHelper.addRainbowAnimation(to: backRightLeg, phaseOffset: 0.45)
        
        // Add a subtle idle animation (slight bobbing)
        let bobUp = SKAction.moveBy(x: 0, y: 2, duration: 0.5)
        let bobDown = SKAction.moveBy(x: 0, y: -2, duration: 0.5)
        bobUp.timingMode = .easeInEaseOut
        bobDown.timingMode = .easeInEaseOut
        let bobSequence = SKAction.sequence([bobUp, bobDown])
        let bobForever = SKAction.repeatForever(bobSequence)
        lizardNode.run(bobForever)
        
        // Rotate based on direction
        lizardNode.zRotation = CGFloat(direction.angle)
        
        return lizardNode
    }
}
