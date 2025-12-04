//
//  RainbowAnimationHelper.swift
//  tankgame Shared
//
//  Rainbow animation logic for game sprites
//

import SpriteKit

/// Helper for adding rainbow color animations to sprites and shapes
class RainbowAnimationHelper {
    
    /// Animation configuration
    private let animationDuration: TimeInterval = 3.0
    private let numberOfColors = 12
    
    /// Add rainbow color animation to a sprite
    func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        var colorActions: [SKAction] = []
        
        // Create a smooth rainbow by cycling through hue values
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
    func addRainbowAnimationToShape(_ shape: SKShapeNode, phaseOffset: CGFloat = 0) {
        var colorActions: [SKAction] = []
        
        // Create a smooth rainbow by cycling through hue values
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 0.9)
            // Capture color explicitly to avoid reference issues with loop variable
            let colorAction = SKAction.run { [weak shape, color] in
                shape?.fillColor = color
                shape?.strokeColor = color.withAlphaComponent(0.5)
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(numberOfColors))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }
        
        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)
        
        shape.run(repeatForever)
    }
}
