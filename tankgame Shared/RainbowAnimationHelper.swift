//
//  RainbowAnimationHelper.swift
//  tankgame Shared
//
//  Rainbow animation logic extracted from GameSceneRenderer
//

import SpriteKit

/// Helper for adding rainbow color animations to sprites
class RainbowAnimationHelper {
    
    /// Add rainbow color animation to a sprite (only if rainbow mode is enabled)
    func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        // Only apply rainbow animation if rainbow mode is enabled
        guard RainbowModeSettings.shared.isEnabled else { return }
        
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
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
}
