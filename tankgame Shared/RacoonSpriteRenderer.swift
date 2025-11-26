//
//  RacoonSpriteRenderer.swift
//  tankgame Shared
//
//  Handles racoon sprite creation and rendering
//

import SpriteKit

/// Handles racoon sprite creation and rendering
class RacoonSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a racoon sprite node with cute visual details
    func createRacoonNode(color: SKColor, direction: Direction) -> SKNode {
        let racoonNode = SKNode()
        
        // Racoon body (oval shape)
        let bodyWidth = tileSize * 0.6
        let bodyHeight = tileSize * 0.7
        let body = SKShapeNode(ellipseOf: CGSize(width: bodyWidth, height: bodyHeight))
        body.fillColor = .gray
        body.strokeColor = .darkGray
        body.lineWidth = 2
        racoonNode.addChild(body)
        
        // Racoon face mask (dark stripe across eyes)
        let maskWidth = tileSize * 0.55
        let maskHeight = tileSize * 0.15
        let faceMask = SKShapeNode(rectOf: CGSize(width: maskWidth, height: maskHeight), cornerRadius: 5)
        faceMask.fillColor = .black
        faceMask.strokeColor = .clear
        faceMask.position = CGPoint(x: 0, y: tileSize * 0.15)
        racoonNode.addChild(faceMask)
        
        // Left eye
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.06)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -tileSize * 0.12, y: tileSize * 0.15)
        racoonNode.addChild(leftEye)
        
        // Left pupil
        let leftPupil = SKShapeNode(circleOfRadius: tileSize * 0.03)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: -tileSize * 0.12, y: tileSize * 0.15)
        racoonNode.addChild(leftPupil)
        
        // Right eye
        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.06)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: tileSize * 0.12, y: tileSize * 0.15)
        racoonNode.addChild(rightEye)
        
        // Right pupil
        let rightPupil = SKShapeNode(circleOfRadius: tileSize * 0.03)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: tileSize * 0.12, y: tileSize * 0.15)
        racoonNode.addChild(rightPupil)
        
        // Nose
        let nose = SKShapeNode(circleOfRadius: tileSize * 0.05)
        nose.fillColor = .black
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 0, y: tileSize * 0.05)
        racoonNode.addChild(nose)
        
        // Left ear
        let leftEar = createEar()
        leftEar.position = CGPoint(x: -tileSize * 0.22, y: tileSize * 0.32)
        racoonNode.addChild(leftEar)
        
        // Right ear
        let rightEar = createEar()
        rightEar.position = CGPoint(x: tileSize * 0.22, y: tileSize * 0.32)
        racoonNode.addChild(rightEar)
        
        // Striped tail (pointing in movement direction)
        let tail = createStripedTail(color: color)
        tail.position = CGPoint(x: 0, y: -tileSize * 0.45)
        racoonNode.addChild(tail)
        
        // Player color indicator (bandana/collar)
        let bandana = SKShapeNode(rectOf: CGSize(width: tileSize * 0.4, height: tileSize * 0.08), cornerRadius: 2)
        bandana.fillColor = color
        bandana.strokeColor = color.withAlphaComponent(0.7)
        bandana.lineWidth = 1
        bandana.position = CGPoint(x: 0, y: -tileSize * 0.05)
        racoonNode.addChild(bandana)
        
        // Add rainbow animation to bandana
        addRainbowAnimationToShape(bandana, phaseOffset: 0)
        
        // Rotate based on direction
        racoonNode.zRotation = CGFloat(direction.angle)
        
        return racoonNode
    }
    
    /// Create a racoon ear
    private func createEar() -> SKShapeNode {
        let earPath = CGMutablePath()
        let earSize = tileSize * 0.12
        earPath.move(to: CGPoint(x: -earSize/2, y: 0))
        earPath.addLine(to: CGPoint(x: 0, y: earSize))
        earPath.addLine(to: CGPoint(x: earSize/2, y: 0))
        earPath.closeSubpath()
        
        let ear = SKShapeNode(path: earPath)
        ear.fillColor = .gray
        ear.strokeColor = .darkGray
        ear.lineWidth = 1
        return ear
    }
    
    /// Create a striped tail
    private func createStripedTail(color: SKColor) -> SKNode {
        let tailNode = SKNode()
        
        let tailLength = tileSize * 0.35
        let tailWidth = tileSize * 0.12
        let stripeCount = 4
        let stripeHeight = tailLength / CGFloat(stripeCount)
        
        for i in 0..<stripeCount {
            let stripe = SKSpriteNode(
                color: i % 2 == 0 ? .gray : .black,
                size: CGSize(width: tailWidth, height: stripeHeight)
            )
            stripe.position = CGPoint(x: 0, y: -CGFloat(i) * stripeHeight - stripeHeight/2)
            tailNode.addChild(stripe)
        }
        
        return tailNode
    }
    
    /// Add rainbow color animation to a shape node
    private func addRainbowAnimationToShape(_ shape: SKShapeNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
        var colorActions: [SKAction] = []
        
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
            let colorAction = SKAction.run {
                shape.fillColor = color
                shape.strokeColor = color.withAlphaComponent(0.7)
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(numberOfColors))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }
        
        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)
        
        shape.run(repeatForever)
    }
}
