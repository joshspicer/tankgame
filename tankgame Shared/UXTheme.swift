//
//  UXTheme.swift
//  tankgame Shared
//
//  Centralized theme and color definitions for consistent UX
//

import SpriteKit

#if os(iOS) || os(tvOS)
import UIKit
#endif

/// Centralized UX theme providing color palettes, styling constants, 
/// and animation durations for consistent visual design across all game components
struct UXTheme {
    
    // MARK: - Colors
    
    /// Primary accent color
    static let primaryColor = SKColor(red: 0.27, green: 0.53, blue: 0.96, alpha: 1.0) // Vibrant blue
    
    /// Secondary accent color
    static let secondaryColor = SKColor(red: 0.40, green: 0.85, blue: 0.60, alpha: 1.0) // Fresh green
    
    /// Warning/action color
    static let accentColor = SKColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1.0) // Warm red
    
    /// Success color
    static let successColor = SKColor(red: 0.30, green: 0.80, blue: 0.40, alpha: 1.0) // Success green
    
    /// Orange accent
    static let orangeAccent = SKColor(red: 0.98, green: 0.60, blue: 0.20, alpha: 1.0) // Warm orange
    
    /// Purple accent
    static let purpleAccent = SKColor(red: 0.60, green: 0.40, blue: 0.90, alpha: 1.0) // Rich purple
    
    // MARK: - Game Scene Colors
    
    /// Background color for the game scene
    static let gameBackground = SKColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1.0) // Deep dark blue-gray
    
    /// Grid floor color
    static let gridFloor = SKColor(red: 0.20, green: 0.24, blue: 0.32, alpha: 1.0) // Subtle blue-gray
    
    /// Grid wall color
    static let gridWall = SKColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 1.0) // Dark charcoal
    
    /// Grid wall accent (for 3D effect)
    static let gridWallHighlight = SKColor(red: 0.22, green: 0.25, blue: 0.35, alpha: 1.0)
    
    /// Grid floor pattern overlay
    static let gridPattern = SKColor(red: 0.18, green: 0.22, blue: 0.30, alpha: 0.3)
    
    // MARK: - Player Colors (Enhanced)
    
    /// Enhanced player colors with better contrast
    static let playerColors: [SKColor] = [
        SKColor(red: 0.20, green: 0.60, blue: 0.98, alpha: 1.0), // Bright blue
        SKColor(red: 0.95, green: 0.30, blue: 0.30, alpha: 1.0), // Bright red
        SKColor(red: 0.30, green: 0.85, blue: 0.45, alpha: 1.0), // Bright green
        SKColor(red: 0.95, green: 0.60, blue: 0.15, alpha: 1.0)  // Bright orange
    ]
    
    // MARK: - UI Element Colors
    
    /// Joystick base color
    static let joystickBase = SKColor(red: 0.15, green: 0.18, blue: 0.25, alpha: 0.85)
    
    /// Joystick handle color
    static let joystickHandle = SKColor(red: 0.35, green: 0.40, blue: 0.52, alpha: 0.95)
    
    /// Fire button color
    static let fireButton = SKColor(red: 0.92, green: 0.25, blue: 0.25, alpha: 1.0)
    
    /// Fire button glow
    static let fireButtonGlow = SKColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 0.6)
    
    // MARK: - Text Colors
    
    /// Primary text color
    static let textPrimary = SKColor.white
    
    /// Secondary text color
    static let textSecondary = SKColor(white: 0.8, alpha: 1.0)
    
    /// Muted text color
    static let textMuted = SKColor(white: 0.6, alpha: 1.0)
    
    // MARK: - Shadows
    
    /// Standard shadow color
    static let shadowColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
    
    /// Glow shadow color
    static let glowShadow = SKColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 0.4)
    
    // MARK: - Animation Durations
    
    /// Standard button animation duration
    static let buttonAnimationDuration: TimeInterval = 0.15
    
    /// Smooth movement duration
    static let smoothMoveDuration: TimeInterval = 0.08
    
    /// UI transition duration
    static let transitionDuration: TimeInterval = 0.3
    
    // MARK: - Corner Radii
    
    /// Standard corner radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 14
    static let cornerRadiusLarge: CGFloat = 20
    
    // MARK: - Spacing
    
    /// Standard spacing values
    static let spacingSmall: CGFloat = 8
    static let spacingMedium: CGFloat = 16
    static let spacingLarge: CGFloat = 24
    static let spacingXLarge: CGFloat = 32
    
    // MARK: - Explosion Effect Configuration
    
    /// Number of primary explosion particles
    static let explosionPrimaryParticleCount: Int = 16
    
    /// Number of spark particles
    static let explosionSparkCount: Int = 24
    
    /// Number of smoke puffs
    static let explosionSmokeCount: Int = 6
}

#if os(iOS) || os(tvOS)
/// UIKit color extensions for the UX theme
extension UXTheme {
    
    /// Primary accent UIColor
    static var primaryUIColor: UIColor {
        return UIColor(red: 0.27, green: 0.53, blue: 0.96, alpha: 1.0)
    }
    
    /// Secondary accent UIColor
    static var secondaryUIColor: UIColor {
        return UIColor(red: 0.40, green: 0.85, blue: 0.60, alpha: 1.0)
    }
    
    /// Accent UIColor
    static var accentUIColor: UIColor {
        return UIColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1.0)
    }
    
    /// Success UIColor
    static var successUIColor: UIColor {
        return UIColor(red: 0.30, green: 0.80, blue: 0.40, alpha: 1.0)
    }
    
    /// Orange accent UIColor
    static var orangeAccentUIColor: UIColor {
        return UIColor(red: 0.98, green: 0.60, blue: 0.20, alpha: 1.0)
    }
    
    /// Purple accent UIColor
    static var purpleAccentUIColor: UIColor {
        return UIColor(red: 0.60, green: 0.40, blue: 0.90, alpha: 1.0)
    }
    
    /// Lobby background gradient colors
    static var lobbyGradientColors: [CGColor] {
        return [
            UIColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1.0).cgColor,
            UIColor(red: 0.12, green: 0.15, blue: 0.22, alpha: 1.0).cgColor,
            UIColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1.0).cgColor
        ]
    }
    
    /// Button background color
    static var buttonBackground: UIColor {
        return UIColor(red: 0.18, green: 0.22, blue: 0.32, alpha: 1.0)
    }
    
    /// Card background color
    static var cardBackground: UIColor {
        return UIColor(red: 0.14, green: 0.17, blue: 0.24, alpha: 1.0)
    }
    
    /// Separator color
    static var separatorColor: UIColor {
        return UIColor(white: 0.3, alpha: 0.5)
    }
}
#endif
