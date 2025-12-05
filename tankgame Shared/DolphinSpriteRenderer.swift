//
//  DolphinSpriteRenderer.swift
//  tankgame Shared
//
//  Handles dolphin sprite creation and rendering
//

import SpriteKit

/// Handles dolphin sprite creation and rendering - Classic retro style
class DolphinSpriteRenderer {
    let tileSize: CGFloat
    
    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }
    
    /// Create a simple dolphin sprite node
    func createDolphinNode(color: SKColor, direction: Direction) -> SKNode {
        let dolphinNode = SKNode()
        
        // Darker shade for details
        let darkColor = darkenColor(color, by: 0.3)
        
        // Dolphin body (simple oval shape)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.4, height: tileSize * 0.65))
        dolphinNode.addChild(body)
        
        // Dolphin snout/nose
        let snout = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.15, height: tileSize * 0.2))
        snout.position = CGPoint(x: 0, y: tileSize * 0.35)
        dolphinNode.addChild(snout)
        
        // Dorsal fin (simple triangle shape represented as small rect)
        let dorsalFin = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.1, height: tileSize * 0.15))
        dorsalFin.position = CGPoint(x: tileSize * 0.1, y: tileSize * 0.05)
        dolphinNode.addChild(dorsalFin)
        
        // Tail
        let tail = SKSpriteNode(color: darkColor, size: CGSize(width: tileSize * 0.25, height: tileSize * 0.08))
        tail.position = CGPoint(x: 0, y: -tileSize * 0.35)
        dolphinNode.addChild(tail)
        
        // Eye (simple square)
        let eye = SKSpriteNode(color: .white, size: CGSize(width: tileSize * 0.08, height: tileSize * 0.08))
        eye.position = CGPoint(x: -tileSize * 0.08, y: tileSize * 0.15)
        dolphinNode.addChild(eye)
        
        // Rotate based on direction
        dolphinNode.zRotation = CGFloat(direction.angle)
        
        return dolphinNode
    }
    
    /// Darken a color by a percentage
    private func darkenColor(_ color: SKColor, by amount: CGFloat) -> SKColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SKColor(red: max(0, r - amount), green: max(0, g - amount), blue: max(0, b - amount), alpha: a)
    }
}
