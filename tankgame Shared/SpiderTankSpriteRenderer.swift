//
//  SpiderTankSpriteRenderer.swift
//  tankgame Shared
//
//  Spider-themed tank sprite creation
//

import SpriteKit

/// Handles spider tank sprite creation and rendering
class SpiderTankSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a spider tank sprite node
    func createSpiderTankNode(color: SKColor, direction: Direction) -> SKNode {
        let spiderNode = SKNode()
        
        // Spider body (oval shape - abdomen)
        let abdomen = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.4, height: tileSize * 0.5))
        abdomen.fillColor = color
        abdomen.strokeColor = color.withAlphaComponent(0.7)
        abdomen.lineWidth = 2
        abdomen.position = CGPoint(x: 0, y: -tileSize * 0.1)
        spiderNode.addChild(abdomen)
        
        // Spider head (smaller circle)
        let head = SKShapeNode(circleOfRadius: tileSize * 0.18)
        head.fillColor = color.withAlphaComponent(0.9)
        head.strokeColor = color.withAlphaComponent(0.6)
        head.lineWidth = 2
        head.position = CGPoint(x: 0, y: tileSize * 0.25)
        spiderNode.addChild(head)
        
        // Create 8 spider legs (4 on each side)
        createSpiderLegs(parent: spiderNode, color: color, isLeft: true)
        createSpiderLegs(parent: spiderNode, color: color, isLeft: false)
        
        // Spider eyes (two small circles on the head)
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.04)
        leftEye.fillColor = .white
        leftEye.strokeColor = .black
        leftEye.lineWidth = 1
        leftEye.position = CGPoint(x: -tileSize * 0.07, y: tileSize * 0.32)
        spiderNode.addChild(leftEye)
        
        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.04)
        rightEye.fillColor = .white
        rightEye.strokeColor = .black
        rightEye.lineWidth = 1
        rightEye.position = CGPoint(x: tileSize * 0.07, y: tileSize * 0.32)
        spiderNode.addChild(rightEye)
        
        // Add fangs (small triangular shapes)
        let leftFang = createFang(color: color)
        leftFang.position = CGPoint(x: -tileSize * 0.05, y: tileSize * 0.40)
        leftFang.zRotation = -CGFloat.pi / 8
        spiderNode.addChild(leftFang)
        
        let rightFang = createFang(color: color)
        rightFang.position = CGPoint(x: tileSize * 0.05, y: tileSize * 0.40)
        rightFang.zRotation = CGFloat.pi / 8
        spiderNode.addChild(rightFang)
        
        // Add rainbow animation to body parts
        addRainbowAnimationToShape(abdomen, phaseOffset: 0)
        addRainbowAnimationToShape(head, phaseOffset: 0.15)
        
        // Rotate based on direction
        spiderNode.zRotation = CGFloat(direction.angle)
        
        return spiderNode
    }
    
    /// Create spider legs on one side
    private func createSpiderLegs(parent: SKNode, color: SKColor, isLeft: Bool) {
        let xMultiplier: CGFloat = isLeft ? -1 : 1
        let legOffsets: [(y: CGFloat, angle: CGFloat)] = [
            (0.12, 0.3),   // Front leg
            (0.0, 0.1),    // Front-middle leg
            (-0.12, -0.1), // Back-middle leg
            (-0.24, -0.3)  // Back leg
        ]
        
        for (index, offset) in legOffsets.enumerated() {
            let leg = createLeg(color: color)
            leg.position = CGPoint(x: xMultiplier * tileSize * 0.18, y: tileSize * offset.y)
            leg.zRotation = xMultiplier * (CGFloat.pi / 2 + offset.angle)
            leg.name = "leg_\(isLeft ? "L" : "R")_\(index)"
            parent.addChild(leg)
        }
    }
    
    /// Create a single spider leg
    private func createLeg(color: SKColor) -> SKNode {
        let legNode = SKNode()
        
        // Upper leg segment
        let upperLeg = SKSpriteNode(color: color.withAlphaComponent(0.8), size: CGSize(width: tileSize * 0.05, height: tileSize * 0.2))
        upperLeg.position = CGPoint(x: tileSize * 0.1, y: 0)
        upperLeg.anchorPoint = CGPoint(x: 0, y: 0.5)
        upperLeg.zRotation = -CGFloat.pi / 6
        legNode.addChild(upperLeg)
        
        // Lower leg segment (angled down)
        let lowerLeg = SKSpriteNode(color: color.withAlphaComponent(0.7), size: CGSize(width: tileSize * 0.04, height: tileSize * 0.18))
        lowerLeg.position = CGPoint(x: tileSize * 0.22, y: -tileSize * 0.08)
        lowerLeg.anchorPoint = CGPoint(x: 0, y: 0.5)
        lowerLeg.zRotation = -CGFloat.pi / 3
        legNode.addChild(lowerLeg)
        
        // Add animation to leg segments
        addRainbowAnimation(to: upperLeg, phaseOffset: 0.2)
        addRainbowAnimation(to: lowerLeg, phaseOffset: 0.25)
        
        return legNode
    }
    
    /// Create a fang shape
    private func createFang(color: SKColor) -> SKNode {
        let fang = SKSpriteNode(color: color.withAlphaComponent(0.9), size: CGSize(width: tileSize * 0.03, height: tileSize * 0.08))
        return fang
    }
    
    /// Add rainbow color animation to a sprite
    private func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
        var colorActions: [SKAction] = []
        
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
            let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: animationDuration / Double(numberOfColors))
            colorActions.append(colorAction)
        }
        
        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)
        
        sprite.run(repeatForever)
    }
    
    /// Add rainbow color animation to a shape node
    private func addRainbowAnimationToShape(_ shape: SKShapeNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
        var colorActions: [SKAction] = []
        
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 0.9)
            let colorAction = SKAction.run {
                shape.fillColor = color
                shape.strokeColor = color.withAlphaComponent(0.5)
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(numberOfColors))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }
        
        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)
        
        shape.run(repeatForever)
    }
}
