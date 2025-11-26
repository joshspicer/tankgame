//
//  BunnySpriteRenderer.swift
//  tankgame Shared
//
//  Renders bunny sprites as an alternative to tank sprites
//

import SpriteKit

/// Handles bunny sprite creation and rendering
class BunnySpriteRenderer {
    let tileSize: CGFloat
    
    // Bunny colors for up to 4 players
    let bunnyColors: [SKColor] = [.systemPink, .systemOrange, .systemMint, .systemPurple]
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a bunny sprite node
    func createBunnyNode(color: SKColor, direction: Direction) -> SKNode {
        let bunnyNode = SKNode()
        
        // Bunny body (oval shape)
        let bodyWidth = tileSize * 0.55
        let bodyHeight = tileSize * 0.65
        let body = SKShapeNode(ellipseOf: CGSize(width: bodyWidth, height: bodyHeight))
        body.fillColor = color
        body.strokeColor = color.withAlphaComponent(0.7)
        body.lineWidth = 2
        bunnyNode.addChild(body)
        
        // Left ear
        let leftEar = createEar(color: color)
        leftEar.position = CGPoint(x: -tileSize * 0.15, y: tileSize * 0.35)
        leftEar.zRotation = 0.15
        bunnyNode.addChild(leftEar)
        
        // Right ear
        let rightEar = createEar(color: color)
        rightEar.position = CGPoint(x: tileSize * 0.15, y: tileSize * 0.35)
        rightEar.zRotation = -0.15
        bunnyNode.addChild(rightEar)
        
        // Bunny face (small white circle for snout area)
        let face = SKShapeNode(circleOfRadius: tileSize * 0.12)
        face.fillColor = .white
        face.strokeColor = .clear
        face.position = CGPoint(x: 0, y: -tileSize * 0.05)
        bunnyNode.addChild(face)
        
        // Bunny nose (pink triangle-ish shape)
        let nose = SKShapeNode(circleOfRadius: tileSize * 0.05)
        nose.fillColor = .systemPink
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 0, y: -tileSize * 0.02)
        bunnyNode.addChild(nose)
        
        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -tileSize * 0.1, y: tileSize * 0.08)
        bunnyNode.addChild(leftEye)
        
        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        rightEye.fillColor = .black
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: tileSize * 0.1, y: tileSize * 0.08)
        bunnyNode.addChild(rightEye)
        
        // Eye highlights (white dots)
        let leftHighlight = SKShapeNode(circleOfRadius: tileSize * 0.02)
        leftHighlight.fillColor = .white
        leftHighlight.strokeColor = .clear
        leftHighlight.position = CGPoint(x: -tileSize * 0.08, y: tileSize * 0.1)
        bunnyNode.addChild(leftHighlight)
        
        let rightHighlight = SKShapeNode(circleOfRadius: tileSize * 0.02)
        rightHighlight.fillColor = .white
        rightHighlight.strokeColor = .clear
        rightHighlight.position = CGPoint(x: tileSize * 0.12, y: tileSize * 0.1)
        bunnyNode.addChild(rightHighlight)
        
        // Fluffy tail (small circle at bottom)
        let tail = SKShapeNode(circleOfRadius: tileSize * 0.1)
        tail.fillColor = .white
        tail.strokeColor = color.withAlphaComponent(0.3)
        tail.lineWidth = 1
        tail.position = CGPoint(x: 0, y: -tileSize * 0.35)
        bunnyNode.addChild(tail)
        
        // Add hopping animation
        addHopAnimation(to: bunnyNode)
        
        // Add rainbow color animation to body
        addRainbowAnimationToShape(body, phaseOffset: 0)
        
        // Add rainbow animation to ears if they have shape children
        if let leftEarShape = leftEar.children.first as? SKShapeNode {
            addRainbowAnimationToShape(leftEarShape, phaseOffset: 0.1)
        }
        if let rightEarShape = rightEar.children.first as? SKShapeNode {
            addRainbowAnimationToShape(rightEarShape, phaseOffset: 0.1)
        }
        
        // Rotate based on direction
        bunnyNode.zRotation = CGFloat(direction.angle)
        
        return bunnyNode
    }
    
    /// Create an ear shape
    private func createEar(color: SKColor) -> SKNode {
        let earContainer = SKNode()
        
        // Outer ear (rounded rectangle approximation using ellipse)
        let ear = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.15, height: tileSize * 0.35))
        ear.fillColor = color
        ear.strokeColor = color.withAlphaComponent(0.7)
        ear.lineWidth = 1
        earContainer.addChild(ear)
        
        // Inner ear (pink)
        let innerEar = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.08, height: tileSize * 0.25))
        innerEar.fillColor = .systemPink.withAlphaComponent(0.6)
        innerEar.strokeColor = .clear
        earContainer.addChild(innerEar)
        
        return earContainer
    }
    
    /// Add a subtle hopping animation
    private func addHopAnimation(to node: SKNode) {
        let hopUp = SKAction.moveBy(x: 0, y: 3, duration: 0.3)
        hopUp.timingMode = .easeOut
        let hopDown = SKAction.moveBy(x: 0, y: -3, duration: 0.3)
        hopDown.timingMode = .easeIn
        let wait = SKAction.wait(forDuration: 0.4)
        let hopSequence = SKAction.sequence([hopUp, hopDown, wait])
        let repeatHop = SKAction.repeatForever(hopSequence)
        node.run(repeatHop)
    }
    
    /// Add rainbow color animation to a shape node
    private func addRainbowAnimationToShape(_ shape: SKShapeNode?, phaseOffset: CGFloat = 0) {
        guard let shape = shape else { return }
        
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
        var colorActions: [SKAction] = []
        
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.7, brightness: 0.9, alpha: 1.0)
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
