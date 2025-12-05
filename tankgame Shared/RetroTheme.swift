//
//  RetroTheme.swift
//  tankgame Shared
//
//  Centralized retro theme colors, fonts, and styling
//

import SpriteKit

/// Centralized retro theme configuration for classic game aesthetics
struct RetroTheme {
    
    // MARK: - Colors
    
    /// Classic game colors
    struct Colors {
        /// Background color for the game scene
        static let background = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        /// Grid floor color
        static let gridFloor = SKColor(red: 0.2, green: 0.25, blue: 0.2, alpha: 1.0)
        
        /// Grid wall color
        static let gridWall = SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        
        /// Tank colors for players (classic palette)
        static let tankColors: [SKColor] = [
            SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0),  // Blue
            SKColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0),  // Red
            SKColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0),  // Green
            SKColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)   // Orange
        ]
        
        /// Projectile color
        static let projectile = SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
        
        /// UI text color
        static let text = SKColor.white
        
        /// Secondary text color
        static let textSecondary = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        
        /// Fire button color
        static let fireButton = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        
        /// Joystick base color
        static let joystickBase = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
        
        /// Joystick handle color
        static let joystickHandle = SKColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
    }
    
    // MARK: - Fonts
    
    /// Font names for retro style
    struct Fonts {
        /// Primary font name - clean monospace look
        static let primary = "Courier-Bold"
        
        /// Secondary font name
        static let secondary = "Courier"
        
        /// Title font size
        static let titleSize: CGFloat = 18
        
        /// Body font size
        static let bodySize: CGFloat = 14
        
        /// Small font size
        static let smallSize: CGFloat = 12
    }
    
    // MARK: - Dimensions
    
    struct Dimensions {
        /// Fire button radius
        static let fireButtonRadius: CGFloat = 35
        
        /// Joystick base radius
        static let joystickBaseRadius: CGFloat = 45
        
        /// Joystick handle radius
        static let joystickHandleRadius: CGFloat = 20
        
        /// Control opacity
        static let controlOpacity: CGFloat = 0.8
        
        /// Border width for controls
        static let borderWidth: CGFloat = 2
    }
}

#if os(iOS) || os(tvOS)
import UIKit

/// UIKit-specific retro theme colors for lobby UI
extension RetroTheme {
    struct UIColors {
        /// Background color
        static let background = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        /// Card background
        static let cardBackground = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        
        /// Primary text
        static let text = UIColor.white
        
        /// Secondary text
        static let textSecondary = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        
        /// Primary button
        static let buttonPrimary = UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0)
        
        /// Host button
        static let buttonHost = UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0)
        
        /// Join button
        static let buttonJoin = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        
        /// Single player button
        static let buttonSinglePlayer = UIColor(red: 0.5, green: 0.3, blue: 0.5, alpha: 1.0)
        
        /// Cancel/danger button
        static let buttonDanger = UIColor(red: 0.6, green: 0.2, blue: 0.2, alpha: 1.0)
        
        /// Border color
        static let border = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
    }
    
    struct UIFonts {
        /// Primary font name
        static let primary = "Courier-Bold"
        
        /// Secondary font name  
        static let secondary = "Courier"
        
        /// Get primary font with size
        static func primaryFont(size: CGFloat) -> UIFont {
            return UIFont(name: primary, size: size) ?? UIFont.monospacedSystemFont(ofSize: size, weight: .bold)
        }
        
        /// Get secondary font with size
        static func secondaryFont(size: CGFloat) -> UIFont {
            return UIFont(name: secondary, size: size) ?? UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
        }
    }
}
#endif
