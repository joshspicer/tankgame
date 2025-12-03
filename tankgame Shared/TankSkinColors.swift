//
//  TankSkinColors.swift
//  tankgame Shared
//
//  Provides color schemes for purchased tank skins
//

import SpriteKit

/// Provides color schemes for different tank skins
class TankSkinColors {
    
    /// Get the color for a tank based on player index and selected skin
    static func getColor(for playerIndex: Int, skin: TankSkinProduct?) -> SKColor {
        guard let skin = skin else {
            // Default rainbow colors for each player
            return defaultColors[playerIndex % defaultColors.count]
        }
        
        return skinColor(for: skin)
    }
    
    /// Default tank colors (one per player)
    static let defaultColors: [SKColor] = [.blue, .red, .green, .orange]
    
    /// Get the primary color for a skin
    static func skinColor(for skin: TankSkinProduct) -> SKColor {
        switch skin {
        case .goldSkin:
            return SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold
        case .neonSkin:
            return SKColor(red: 0.0, green: 1.0, blue: 0.8, alpha: 1.0) // Neon cyan
        case .camouflage:
            return SKColor(red: 0.33, green: 0.42, blue: 0.18, alpha: 1.0) // Olive green
        case .flameSkin:
            return SKColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0) // Flame orange-red
        }
    }
    
    /// Get a secondary color for visual accents
    static func secondaryColor(for skin: TankSkinProduct) -> SKColor {
        switch skin {
        case .goldSkin:
            return SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0) // Darker gold
        case .neonSkin:
            return SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0) // Neon pink
        case .camouflage:
            return SKColor(red: 0.55, green: 0.47, blue: 0.36, alpha: 1.0) // Tan
        case .flameSkin:
            return SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Orange
        }
    }
    
    /// Check if a skin should use rainbow animation
    static func usesRainbowAnimation(for skin: TankSkinProduct?) -> Bool {
        guard let skin = skin else {
            return true // Default uses rainbow
        }
        
        switch skin {
        case .neonSkin:
            return true // Neon also uses rainbow animation
        default:
            return false
        }
    }
}
