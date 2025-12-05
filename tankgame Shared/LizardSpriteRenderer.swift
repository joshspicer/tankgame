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
    
    /// Create a lizard sprite node with visual details
    func createLizardNode(direction: Direction) -> SKNode {
        let lizardNode = SKNode()
        
        // Base color for lizard (themed green)
        let baseColor = GameTheme.Colors.secondary
        let darkColor = baseColor.withAlphaComponent(0.7)
        let lightColor = baseColor.withAlphaComponent(0.95)
        
        // Shadow for depth
        let shadow = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.25), size: CGSize(width: tileSize * 0.52, height: tileSize * 0.72))
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        lizardNode.addChild(shadow)
        
        // Lizard body (elongated oval shape)
        let body = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.7))
        body.alpha = 0.95
        body.zPosition = 1
        lizardNode.addChild(body)
        
        // Body pattern/stripe
        let bodyStripe = SKSpriteNode(color: lightColor, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.55))
        bodyStripe.alpha = 0.4
        bodyStripe.zPosition = 2
        lizardNode.addChild(bodyStripe)
        
        // Lizard head (smaller oval at front)
        let head = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.32, height: tileSize * 0.28))
        head.position = CGPoint(x: 0, y: tileSize * 0.38)
        head.alpha = 0.98
        head.zPosition = 3
        lizardNode.addChild(head)
        
        // Head highlight
        let headHighlight = SKSpriteNode(color: lightColor, size: CGSize(width: tileSize * 0.18, height: tileSize * 0.12))
        headHighlight.position = CGPoint(x: 0, y: tileSize * 0.42)
        headHighlight.alpha = 0.4
        headHighlight.zPosition = 4
        lizardNode.addChild(headHighlight)
        
        // Lizard eyes (glowing dots)
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.055)
        leftEye.fillColor = SKColor.white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -tileSize * 0.09, y: tileSize * 0.42)
        leftEye.zPosition = 5
        lizardNode.addChild(leftEye)
        
        let leftPupil = SKShapeNode(circleOfRadius: tileSize * 0.03)
        leftPupil.fillColor = SKColor.black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: -tileSize * 0.085, y: tileSize * 0.42)
        leftPupil.zPosition = 6
        lizardNode.addChild(leftPupil)
        
        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.055)
        rightEye.fillColor = SKColor.white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: tileSize * 0.09, y: tileSize * 0.42)
        rightEye.zPosition = 5
        lizardNode.addChild(rightEye)
        
        let rightPupil = SKShapeNode(circleOfRadius: tileSize * 0.03)
        rightPupil.fillColor = SKColor.black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: tileSize * 0.085, y: tileSize * 0.42)
        rightPupil.zPosition = 6
        lizardNode.addChild(rightPupil)
        
        // Lizard tail (tapered back)
        let tail = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.14, height: tileSize * 0.42))
        tail.position = CGPoint(x: 0, y: -tileSize * 0.42)
        tail.zPosition = 0
        lizardNode.addChild(tail)
        
        // Tail tip
        let tailTip = SKSpriteNode(color: darkColor.withAlphaComponent(0.6), size: CGSize(width: tileSize * 0.08, height: tileSize * 0.15))
        tailTip.position = CGPoint(x: 0, y: -tileSize * 0.58)
        tailTip.zPosition = 0
        lizardNode.addChild(tailTip)
        
        // Lizard legs (4 small legs with better shaping)
        let legColor = darkColor
        
        // Front left leg
        let frontLeftLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.22, height: tileSize * 0.08))
        frontLeftLeg.position = CGPoint(x: -tileSize * 0.26, y: tileSize * 0.15)
        frontLeftLeg.zRotation = 0.35
        frontLeftLeg.zPosition = 0
        lizardNode.addChild(frontLeftLeg)
        
        // Front right leg
        let frontRightLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.22, height: tileSize * 0.08))
        frontRightLeg.position = CGPoint(x: tileSize * 0.26, y: tileSize * 0.15)
        frontRightLeg.zRotation = -0.35
        frontRightLeg.zPosition = 0
        lizardNode.addChild(frontRightLeg)
        
        // Back left leg
        let backLeftLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.22, height: tileSize * 0.08))
        backLeftLeg.position = CGPoint(x: -tileSize * 0.26, y: -tileSize * 0.15)
        backLeftLeg.zRotation = -0.35
        backLeftLeg.zPosition = 0
        lizardNode.addChild(backLeftLeg)
        
        // Back right leg
        let backRightLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.22, height: tileSize * 0.08))
        backRightLeg.position = CGPoint(x: tileSize * 0.26, y: -tileSize * 0.15)
        backRightLeg.zRotation = 0.35
        backRightLeg.zPosition = 0
        lizardNode.addChild(backRightLeg)
        
        // Add a subtle idle animation (bobbing and leg wiggle)
        addIdleAnimation(to: lizardNode, frontLeftLeg: frontLeftLeg, frontRightLeg: frontRightLeg, 
                        backLeftLeg: backLeftLeg, backRightLeg: backRightLeg)
        
        // Rotate based on direction
        lizardNode.zRotation = CGFloat(direction.angle)
        
        return lizardNode
    }
    
    /// Add idle animation to the lizard
    private func addIdleAnimation(to node: SKNode, frontLeftLeg: SKSpriteNode, frontRightLeg: SKSpriteNode,
                                  backLeftLeg: SKSpriteNode, backRightLeg: SKSpriteNode) {
        // Bobbing animation
        let bobUp = SKAction.moveBy(x: 0, y: 2, duration: 0.6)
        let bobDown = SKAction.moveBy(x: 0, y: -2, duration: 0.6)
        bobUp.timingMode = .easeInEaseOut
        bobDown.timingMode = .easeInEaseOut
        let bobSequence = SKAction.sequence([bobUp, bobDown])
        let bobForever = SKAction.repeatForever(bobSequence)
        node.run(bobForever)
        
        // Leg wiggle animations (alternating)
        let wiggleLeft = SKAction.rotate(byAngle: 0.15, duration: 0.3)
        let wiggleRight = SKAction.rotate(byAngle: -0.15, duration: 0.3)
        let wiggleSequence1 = SKAction.sequence([wiggleLeft, wiggleRight, wiggleRight, wiggleLeft])
        let wiggleSequence2 = SKAction.sequence([wiggleRight, wiggleLeft, wiggleLeft, wiggleRight])
        
        frontLeftLeg.run(SKAction.repeatForever(wiggleSequence1))
        backRightLeg.run(SKAction.repeatForever(wiggleSequence1))
        frontRightLeg.run(SKAction.repeatForever(wiggleSequence2))
        backLeftLeg.run(SKAction.repeatForever(wiggleSequence2))
    }
}
