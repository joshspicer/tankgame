//
//  RainbowAnimationHelper.swift
//  tankgame Shared
//
//  Rainbow animation logic for game sprites
//

import SpriteKit

/// Helper for adding rainbow color animations to sprites and shapes
class RainbowAnimationHelper {
    private let animationDuration: TimeInterval = 3.0
    private let numberOfColors = 12

    private func generateRainbowColors(phaseOffset: CGFloat) -> [SKColor] {
        return (0...numberOfColors).map { i in
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            return SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
        }
    }

    func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        let colors = generateRainbowColors(phaseOffset: phaseOffset)
        let colorActions = colors.map { SKAction.colorize(with: $0, colorBlendFactor: 1.0, duration: animationDuration / Double(numberOfColors)) }
        sprite.run(SKAction.repeatForever(SKAction.sequence(colorActions)))
    }

    func addRainbowAnimationToShape(_ shape: SKShapeNode, phaseOffset: CGFloat = 0) {
        let colors = generateRainbowColors(phaseOffset: phaseOffset)
        let colorActions = colors.flatMap { color in
            [SKAction.run { [weak shape, color] in
                shape?.fillColor = color
                shape?.strokeColor = color.withAlphaComponent(0.5)
            }, SKAction.wait(forDuration: animationDuration / Double(numberOfColors))]
        }
        shape.run(SKAction.repeatForever(SKAction.sequence(colorActions)))
    }
}
