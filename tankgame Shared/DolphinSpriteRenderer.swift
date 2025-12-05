//
//  DolphinSpriteRenderer.swift
//  tankgame Shared
//
//  Handles dolphin sprite creation - clean retro style
//

import SpriteKit

/// Handles dolphin sprite creation - clean retro style
class DolphinSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a simple dolphin sprite node
    func createDolphinNode(color: SKColor, direction: Direction) -> SKNode {
        let dolphinNode = SKNode()
        
        // Simple dolphin body (oval shape)
        let body = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.45, height: tileSize * 0.65))
        body.fillColor = color
        body.strokeColor = darkenColor(color, by: 0.2)
        body.lineWidth = 2
        dolphinNode.addChild(body)
        
        // Simple snout/nose
        let snout = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.15, height: tileSize * 0.2))
        snout.fillColor = color
        snout.strokeColor = .clear
        snout.position = CGPoint(x: 0, y: tileSize * 0.35)
        dolphinNode.addChild(snout)
        
        // Simple dorsal fin (triangle)
        let dorsalFin = createTriangleFin(
            size: CGSize(width: tileSize * 0.12, height: tileSize * 0.2),
            color: darkenColor(color, by: 0.1)
        )
        dorsalFin.position = CGPoint(x: tileSize * 0.08, y: 0)
        dorsalFin.zRotation = -.pi / 4
        dolphinNode.addChild(dorsalFin)
        
        // Simple tail flukes
        let tailFlukes = createSimpleTail(color: darkenColor(color, by: 0.1))
        tailFlukes.position = CGPoint(x: 0, y: -tileSize * 0.35)
        dolphinNode.addChild(tailFlukes)
        
        // Simple eye
        let eye = SKShapeNode(circleOfRadius: tileSize * 0.04)
        eye.fillColor = .white
        eye.strokeColor = .black
        eye.lineWidth = 1
        eye.position = CGPoint(x: -tileSize * 0.08, y: tileSize * 0.18)
        dolphinNode.addChild(eye)
        
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
    
    /// Create simple tail flukes
    private func createSimpleTail(color: SKColor) -> SKNode {
        let tailNode = SKNode()
        
        // Left fluke
        let leftFluke = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.15, height: tileSize * 0.08))
        leftFluke.fillColor = color
        leftFluke.strokeColor = .clear
        leftFluke.position = CGPoint(x: -tileSize * 0.08, y: 0)
        leftFluke.zRotation = .pi / 4
        tailNode.addChild(leftFluke)
        
        // Right fluke
        let rightFluke = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.15, height: tileSize * 0.08))
        rightFluke.fillColor = color
        rightFluke.strokeColor = .clear
        rightFluke.position = CGPoint(x: tileSize * 0.08, y: 0)
        rightFluke.zRotation = -.pi / 4
        tailNode.addChild(rightFluke)
        
        return tailNode
    }
    
    /// Darken a color by a percentage
    private func darkenColor(_ color: SKColor, by amount: CGFloat) -> SKColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(red: max(red - amount, 0), green: max(green - amount, 0), blue: max(blue - amount, 0), alpha: alpha)
    }
}
