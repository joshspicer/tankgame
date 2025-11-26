//
//  DinosaurSpriteRenderer.swift
//  tankgame Shared
//
//  Handles dinosaur sprite creation and rendering
//

import SpriteKit

/// Handles dinosaur sprite creation with visual details
class DinosaurSpriteRenderer {
    let tileSize: CGFloat
    private let animationHelper: RainbowAnimationHelper
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }
    
    /// Create a dinosaur sprite node with T-Rex style visuals
    func createDinosaurNode(direction: Direction) -> SKNode {
        let dinoNode = SKNode()
        
        // Dinosaur body (oval shape for T-Rex body)
        let body = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.6, height: tileSize * 0.5))
        body.fillColor = .systemGreen
        body.strokeColor = .darkGray
        body.lineWidth = 2
        body.position = CGPoint(x: 0, y: 0)
        dinoNode.addChild(body)
        
        // Dinosaur head (smaller circle, positioned forward)
        let head = SKShapeNode(circleOfRadius: tileSize * 0.18)
        head.fillColor = .systemGreen
        head.strokeColor = .darkGray
        head.lineWidth = 2
        head.position = CGPoint(x: 0, y: tileSize * 0.28)
        dinoNode.addChild(head)
        
        // Eyes (two small white circles with black pupils)
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        leftEye.fillColor = .white
        leftEye.strokeColor = .black
        leftEye.lineWidth = 1
        leftEye.position = CGPoint(x: -tileSize * 0.06, y: tileSize * 0.32)
        dinoNode.addChild(leftEye)
        
        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        rightEye.fillColor = .white
        rightEye.strokeColor = .black
        rightEye.lineWidth = 1
        rightEye.position = CGPoint(x: tileSize * 0.06, y: tileSize * 0.32)
        dinoNode.addChild(rightEye)
        
        // Pupils
        let leftPupil = SKShapeNode(circleOfRadius: tileSize * 0.025)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: -tileSize * 0.06, y: tileSize * 0.33)
        dinoNode.addChild(leftPupil)
        
        let rightPupil = SKShapeNode(circleOfRadius: tileSize * 0.025)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: tileSize * 0.06, y: tileSize * 0.33)
        dinoNode.addChild(rightPupil)
        
        // Tail (triangle shape)
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: 0, y: -tileSize * 0.25))
        tailPath.addLine(to: CGPoint(x: -tileSize * 0.1, y: -tileSize * 0.45))
        tailPath.addLine(to: CGPoint(x: tileSize * 0.1, y: -tileSize * 0.45))
        tailPath.closeSubpath()
        
        let tail = SKShapeNode(path: tailPath)
        tail.fillColor = .systemGreen
        tail.strokeColor = .darkGray
        tail.lineWidth = 2
        dinoNode.addChild(tail)
        
        // Small arms (two small rectangles)
        let leftArm = SKSpriteNode(color: .systemGreen, size: CGSize(width: tileSize * 0.08, height: tileSize * 0.15))
        leftArm.position = CGPoint(x: -tileSize * 0.25, y: tileSize * 0.05)
        dinoNode.addChild(leftArm)
        
        let rightArm = SKSpriteNode(color: .systemGreen, size: CGSize(width: tileSize * 0.08, height: tileSize * 0.15))
        rightArm.position = CGPoint(x: tileSize * 0.25, y: tileSize * 0.05)
        dinoNode.addChild(rightArm)
        
        // Legs (two larger rectangles at bottom)
        let leftLeg = SKSpriteNode(color: .systemGreen, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.2))
        leftLeg.position = CGPoint(x: -tileSize * 0.15, y: -tileSize * 0.15)
        dinoNode.addChild(leftLeg)
        
        let rightLeg = SKSpriteNode(color: .systemGreen, size: CGSize(width: tileSize * 0.12, height: tileSize * 0.2))
        rightLeg.position = CGPoint(x: tileSize * 0.15, y: -tileSize * 0.15)
        dinoNode.addChild(rightLeg)
        
        // Add rainbow animation to body parts
        addRainbowAnimationToShape(body, phaseOffset: 0)
        addRainbowAnimationToShape(head, phaseOffset: 0.1)
        addRainbowAnimationToShape(tail, phaseOffset: 0.2)
        animationHelper.addRainbowAnimation(to: leftArm, phaseOffset: 0.15)
        animationHelper.addRainbowAnimation(to: rightArm, phaseOffset: 0.15)
        animationHelper.addRainbowAnimation(to: leftLeg, phaseOffset: 0.25)
        animationHelper.addRainbowAnimation(to: rightLeg, phaseOffset: 0.25)
        
        // Rotate based on direction
        dinoNode.zRotation = CGFloat(direction.angle)
        
        return dinoNode
    }
    
    /// Add rainbow color animation to a shape node
    private func addRainbowAnimationToShape(_ shape: SKShapeNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
        var colorActions: [SKAction] = []
        
        // Create a smooth rainbow by cycling through hue values
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.8, brightness: 0.85, alpha: 1.0)
            let colorAction = SKAction.run {
                shape.fillColor = color
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(numberOfColors))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }
        
        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)
        
        shape.run(repeatForever)
    }
}
