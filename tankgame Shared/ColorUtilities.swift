//
//  ColorUtilities.swift
//  tankgame Shared
//
//  Shared color manipulation utilities for game sprites
//

import SpriteKit

/// Shared color manipulation utilities
class ColorUtilities {
    
    /// Darken a color by a percentage (0.0 to 1.0)
    static func darken(_ color: SKColor, by percentage: CGFloat) -> SKColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SKColor(
            red: max(0, r - percentage),
            green: max(0, g - percentage),
            blue: max(0, b - percentage),
            alpha: a
        )
    }
    
    /// Lighten a color by a percentage (0.0 to 1.0)
    static func lighten(_ color: SKColor, by percentage: CGFloat) -> SKColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SKColor(
            red: min(1, r + percentage),
            green: min(1, g + percentage),
            blue: min(1, b + percentage),
            alpha: a
        )
    }
    
    /// Blend two colors together with a ratio (0.0 = color1, 1.0 = color2)
    static func blend(_ color1: SKColor, with color2: SKColor, ratio: CGFloat) -> SKColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return SKColor(
            red: r1 * (1 - ratio) + r2 * ratio,
            green: g1 * (1 - ratio) + g2 * ratio,
            blue: b1 * (1 - ratio) + b2 * ratio,
            alpha: a1 * (1 - ratio) + a2 * ratio
        )
    }
    
    /// Create a color with adjusted saturation
    static func adjustSaturation(_ color: SKColor, by factor: CGFloat) -> SKColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return SKColor(hue: h, saturation: min(1, max(0, s * factor)), brightness: b, alpha: a)
    }
    
    /// Create a color with adjusted brightness
    static func adjustBrightness(_ color: SKColor, by factor: CGFloat) -> SKColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return SKColor(hue: h, saturation: s, brightness: min(1, max(0, b * factor)), alpha: a)
    }
}

/// Projectile animation color palette
struct ProjectileColorPalette {
    static let warmColors: [(fill: SKColor, stroke: SKColor)] = [
        (SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0), SKColor(red: 1.0, green: 0.7, blue: 0.1, alpha: 1.0)),
        (SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0), SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)),
        (SKColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 1.0), SKColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 1.0)),
        (SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0), SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
    ]
}
