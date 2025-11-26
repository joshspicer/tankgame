//
//  BatmanAnimationHelper.swift
//  tankgame Shared
//
//  Batman-themed animation helper for dark knight mode
//

import SpriteKit

/// Helper for adding Batman-themed dark animations to sprites
class BatmanAnimationHelper {
    
    // Batman color palette - dark grays, blacks, and occasional yellow highlights
    private let batmanColors: [SKColor] = [
        SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0),     // Dark black
        SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0),   // Dark gray-blue
        SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0),    // Medium dark gray
        SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0),    // Near black
        SKColor(red: 0.95, green: 0.85, blue: 0.1, alpha: 1.0),   // Batman yellow
        SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0),     // Dark black
    ]
    
    /// Add Batman-themed dark pulsing animation to a sprite
    func addBatmanAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 2.5
        let numberOfColors = batmanColors.count
        
        var colorActions: [SKAction] = []
        
        // Create smooth transitions through Batman colors
        for i in 0..<numberOfColors {
            let colorIndex = (i + Int(phaseOffset * CGFloat(numberOfColors))) % numberOfColors
            let color = batmanColors[colorIndex]
            let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: animationDuration / Double(numberOfColors))
            colorActions.append(colorAction)
        }
        
        let batmanSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(batmanSequence)
        
        sprite.run(repeatForever)
    }
    
    /// Add Batman-themed animation to a shape node
    func addBatmanAnimationToShape(_ shape: SKShapeNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 2.5
        let numberOfColors = batmanColors.count
        
        var colorActions: [SKAction] = []
        
        for i in 0..<numberOfColors {
            let colorIndex = (i + Int(phaseOffset * CGFloat(numberOfColors))) % numberOfColors
            let color = batmanColors[colorIndex]
            let colorAction = SKAction.run {
                shape.fillColor = color
                shape.strokeColor = color.withAlphaComponent(0.7)
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(numberOfColors))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }
        
        let batmanSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(batmanSequence)
        
        shape.run(repeatForever)
    }
    
    /// Get the primary Batman color (dark gray)
    static var primaryColor: SKColor {
        return SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
    }
    
    /// Get the accent Batman color (yellow)
    static var accentColor: SKColor {
        return SKColor(red: 0.95, green: 0.85, blue: 0.1, alpha: 1.0)
    }
    
    /// Get the dark Batman color (near black)
    static var darkColor: SKColor {
        return SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    }
    
    /// Get the Batman mode background color (very dark blue)
    static var backgroundColor: SKColor {
        return SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
    }
}
