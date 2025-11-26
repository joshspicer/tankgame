//
//  DinosaurSpriteRenderer.swift
//  tankgame Shared
//
//  Handles dinosaur sprite creation and rendering
//

import SpriteKit

/// Creates dinosaur sprite nodes with visual details
class DinosaurSpriteRenderer {
    let tileSize: CGFloat
    private let animationHelper: RainbowAnimationHelper
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Create a dinosaur sprite node with a simple T-Rex-like appearance
    func createDinosaurNode(direction: Direction) -> SKNode {
        let dinosaurNode = SKNode()
        
        // Dinosaur body (oval shape)
        let body = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.6, height: tileSize * 0.5))
        body.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        body.strokeColor = SKColor(red: 0.1, green: 0.5, blue: 0.2, alpha: 1.0)
        body.lineWidth = 2
        dinosaurNode.addChild(body)
        
        // Dinosaur head (smaller circle)
        let head = SKShapeNode(circleOfRadius: tileSize * 0.18)
        head.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        head.strokeColor = SKColor(red: 0.1, green: 0.5, blue: 0.2, alpha: 1.0)
        head.lineWidth = 2
        head.position = CGPoint(x: 0, y: tileSize * 0.3)
        dinosaurNode.addChild(head)
        
        // Eyes (two small white circles with black pupils)
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.06)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -tileSize * 0.08, y: tileSize * 0.33)
        dinosaurNode.addChild(leftEye)
        
        let leftPupil = SKShapeNode(circleOfRadius: tileSize * 0.03)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: -tileSize * 0.08, y: tileSize * 0.33)
        dinosaurNode.addChild(leftPupil)
        
        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.06)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: tileSize * 0.08, y: tileSize * 0.33)
        dinosaurNode.addChild(rightEye)
        
        let rightPupil = SKShapeNode(circleOfRadius: tileSize * 0.03)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: tileSize * 0.08, y: tileSize * 0.33)
        dinosaurNode.addChild(rightPupil)
        
        // Tail (triangle pointing backward)
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: 0, y: -tileSize * 0.25))
        tailPath.addLine(to: CGPoint(x: -tileSize * 0.1, y: -tileSize * 0.45))
        tailPath.addLine(to: CGPoint(x: tileSize * 0.1, y: -tileSize * 0.45))
        tailPath.closeSubpath()
        
        let tail = SKShapeNode(path: tailPath)
        tail.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        tail.strokeColor = SKColor(red: 0.1, green: 0.5, blue: 0.2, alpha: 1.0)
        tail.lineWidth = 2
        dinosaurNode.addChild(tail)
        
        // Small arms (two rectangles on sides)
        let leftArm = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0), size: CGSize(width: tileSize * 0.08, height: tileSize * 0.15))
        leftArm.position = CGPoint(x: -tileSize * 0.28, y: tileSize * 0.05)
        leftArm.zRotation = .pi / 6
        dinosaurNode.addChild(leftArm)
        
        let rightArm = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0), size: CGSize(width: tileSize * 0.08, height: tileSize * 0.15))
        rightArm.position = CGPoint(x: tileSize * 0.28, y: tileSize * 0.05)
        rightArm.zRotation = -.pi / 6
        dinosaurNode.addChild(rightArm)
        
        // Add rainbow animation to body and head
        animationHelper.addRainbowAnimationToShape(body, phaseOffset: 0)
        animationHelper.addRainbowAnimationToShape(head, phaseOffset: 0.1)
        animationHelper.addRainbowAnimationToShape(tail, phaseOffset: 0.2)
        animationHelper.addRainbowAnimation(to: leftArm, phaseOffset: 0.15)
        animationHelper.addRainbowAnimation(to: rightArm, phaseOffset: 0.15)
        
        // Rotate based on direction
        dinosaurNode.zRotation = CGFloat(direction.angle)
        
        return dinosaurNode
    }
}
