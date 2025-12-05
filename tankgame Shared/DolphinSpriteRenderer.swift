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
    
    /// Create a dolphin sprite node with classic solid colors
    func createDolphinNode(color: SKColor, direction: Direction) -> SKNode {
        let dolphinNode = SKNode()
        
        // Darker shade for accents
        let darkColor = color.blended(withFraction: 0.3, of: .black) ?? color
        
        // Dolphin body (oval shape)
        let body = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.5, height: tileSize * 0.75))
        body.fillColor = color
        body.strokeColor = darkColor
        body.lineWidth = 2
        dolphinNode.addChild(body)
        
        // Dolphin snout/nose (pointing in direction of travel)
        let snout = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.25))
        snout.fillColor = color
        snout.strokeColor = .clear
        snout.position = CGPoint(x: 0, y: tileSize * 0.4)
        dolphinNode.addChild(snout)
        
        // Dorsal fin (top fin)
        let dorsalFin = createTriangleFin(
            size: CGSize(width: tileSize * 0.15, height: tileSize * 0.25),
            color: darkColor
        )
        dorsalFin.position = CGPoint(x: tileSize * 0.1, y: 0)
        dorsalFin.zRotation = -.pi / 4
        dolphinNode.addChild(dorsalFin)
        
        // Left flipper
        let leftFlipper = createFlipper(color: darkColor)
        leftFlipper.position = CGPoint(x: -tileSize * 0.25, y: -tileSize * 0.05)
        leftFlipper.zRotation = .pi / 6
        dolphinNode.addChild(leftFlipper)
        
        // Right flipper
        let rightFlipper = createFlipper(color: darkColor)
        rightFlipper.position = CGPoint(x: tileSize * 0.25, y: -tileSize * 0.05)
        rightFlipper.zRotation = -.pi / 6
        dolphinNode.addChild(rightFlipper)
        
        // Tail flukes (at the back)
        let tailFlukes = createTailFlukes(color: darkColor)
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
}
