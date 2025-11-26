//
//  DolphinSpriteRenderer.swift
//  tankgame Shared
//
//  Handles dolphin sprite creation and rendering
//

import SpriteKit

/// Handles dolphin sprite creation and rendering
class DolphinSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a dolphin sprite node with ocean-themed visuals
    func createDolphinNode(color: SKColor, direction: Direction) -> SKNode {
        let dolphinNode = SKNode()
        
        // Dolphin body (oval shape)
        let body = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.5, height: tileSize * 0.75))
        body.fillColor = color
        body.strokeColor = color.withAlphaComponent(0.7)
        body.lineWidth = 2
        dolphinNode.addChild(body)
        
        // Dolphin snout/nose (pointing in direction of travel)
        let snout = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.25))
        snout.fillColor = color.withAlphaComponent(0.9)
        snout.strokeColor = .clear
        snout.position = CGPoint(x: 0, y: tileSize * 0.4)
        dolphinNode.addChild(snout)
        
        // Dorsal fin (top fin)
        let dorsalFin = createTriangleFin(
            size: CGSize(width: tileSize * 0.15, height: tileSize * 0.25),
            color: color.withAlphaComponent(0.85)
        )
        dorsalFin.position = CGPoint(x: tileSize * 0.1, y: 0)
        dorsalFin.zRotation = -.pi / 4
        dolphinNode.addChild(dorsalFin)
        
        // Left flipper
        let leftFlipper = createFlipper(color: color.withAlphaComponent(0.75))
        leftFlipper.position = CGPoint(x: -tileSize * 0.25, y: -tileSize * 0.05)
        leftFlipper.zRotation = .pi / 6
        dolphinNode.addChild(leftFlipper)
        
        // Right flipper
        let rightFlipper = createFlipper(color: color.withAlphaComponent(0.75))
        rightFlipper.position = CGPoint(x: tileSize * 0.25, y: -tileSize * 0.05)
        rightFlipper.zRotation = -.pi / 6
        dolphinNode.addChild(rightFlipper)
        
        // Tail flukes (at the back)
        let tailFlukes = createTailFlukes(color: color.withAlphaComponent(0.8))
        tailFlukes.position = CGPoint(x: 0, y: -tileSize * 0.4)
        dolphinNode.addChild(tailFlukes)
        
        // Eye (small white circle with black pupil)
        let eye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        eye.fillColor = .white
        eye.strokeColor = .black
        eye.lineWidth = 1
        eye.position = CGPoint(x: -tileSize * 0.1, y: tileSize * 0.2)
        dolphinNode.addChild(eye)
        
        let pupil = SKShapeNode(circleOfRadius: tileSize * 0.025)
        pupil.fillColor = .black
        pupil.strokeColor = .clear
        pupil.position = CGPoint(x: -tileSize * 0.1, y: tileSize * 0.2)
        dolphinNode.addChild(pupil)
        
        // Add ocean wave animation
        addOceanAnimation(to: body, baseColor: color)
        
        // Rotate based on direction
        dolphinNode.zRotation = CGFloat(direction.angle)
        
        return dolphinNode
    }
    
    /// Create a triangle-shaped fin
    private func createTriangleFin(size: CGSize, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size.height / 2))
        path.addLine(to: CGPoint(x: -size.width / 2, y: -size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: -size.height / 2))
        path.closeSubpath()
        
        let fin = SKShapeNode(path: path)
        fin.fillColor = color
        fin.strokeColor = .clear
        return fin
    }
    
    /// Create a flipper shape
    private func createFlipper(color: SKColor) -> SKShapeNode {
        let flipper = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.15, height: tileSize * 0.08))
        flipper.fillColor = color
        flipper.strokeColor = .clear
        return flipper
    }
    
    /// Create the tail flukes
    private func createTailFlukes(color: SKColor) -> SKNode {
        let tailNode = SKNode()
        
        // Left fluke
        let leftFluke = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.1))
        leftFluke.fillColor = color
        leftFluke.strokeColor = .clear
        leftFluke.position = CGPoint(x: -tileSize * 0.1, y: 0)
        leftFluke.zRotation = .pi / 4
        tailNode.addChild(leftFluke)
        
        // Right fluke
        let rightFluke = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.1))
        rightFluke.fillColor = color
        rightFluke.strokeColor = .clear
        rightFluke.position = CGPoint(x: tileSize * 0.1, y: 0)
        rightFluke.zRotation = -.pi / 4
        tailNode.addChild(rightFluke)
        
        return tailNode
    }
    
    /// Add ocean-themed color animation (blues and teals)
    private func addOceanAnimation(to shape: SKShapeNode, baseColor: SKColor) {
        let animationDuration: TimeInterval = 2.5
        let numberOfColors = 8
        
        // Create ocean color palette based on the player's base color
        var colorActions: [SKAction] = []
        
        for i in 0...numberOfColors {
            // Create variations of blues and teals mixed with player color
            let progress = CGFloat(i) / CGFloat(numberOfColors)
            let hue: CGFloat = 0.5 + (progress * 0.15) // Range from cyan to blue
            let saturation: CGFloat = 0.7 + (sin(progress * .pi) * 0.2)
            let brightness: CGFloat = 0.8 + (sin(progress * .pi * 2) * 0.1)
            
            let oceanColor = SKColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
            
            // Blend with player color
            let blendedColor = blendColors(oceanColor, with: baseColor, ratio: 0.4)
            
            let colorAction = SKAction.run { [weak shape] in
                shape?.fillColor = blendedColor
                shape?.strokeColor = blendedColor.withAlphaComponent(0.7)
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(numberOfColors))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }
        
        let oceanSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(oceanSequence)
        
        shape.run(repeatForever)
    }
    
    /// Blend two colors together
    private func blendColors(_ color1: SKColor, with color2: SKColor, ratio: CGFloat) -> SKColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return SKColor(
            red: r1 * (1 - ratio) + r2 * ratio,
            green: g1 * (1 - ratio) + g2 * ratio,
            blue: b1 * (1 - ratio) + b2 * ratio,
            alpha: 1.0
        )
    }
}
