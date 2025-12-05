//
//  GameTheme.swift
//  tankgame Shared
//
//  Modern color theme and styling constants for the game
//

import SpriteKit

/// Centralized theme for consistent styling across the game
class GameTheme {
    static let shared = GameTheme()
    
    private init() {}
    
    // MARK: - Color Palette
    
    /// Primary colors for the game
    struct Colors {
        // Background colors
        static let backgroundDark = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
        static let backgroundMedium = SKColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1.0)
        static let backgroundLight = SKColor(red: 0.18, green: 0.18, blue: 0.24, alpha: 1.0)
        
        // Grid colors
        static let gridFloor = SKColor(red: 0.15, green: 0.18, blue: 0.22, alpha: 1.0)
        static let gridWall = SKColor(red: 0.25, green: 0.28, blue: 0.35, alpha: 1.0)
        static let gridBorder = SKColor(red: 0.3, green: 0.35, blue: 0.45, alpha: 1.0)
        
        // UI element colors
        static let primary = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        static let secondary = SKColor(red: 0.5, green: 0.8, blue: 0.6, alpha: 1.0)
        static let accent = SKColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0)
        static let danger = SKColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1.0)
        
        // Joystick colors
        static let joystickBase = SKColor(red: 0.2, green: 0.22, blue: 0.28, alpha: 0.9)
        static let joystickHandle = SKColor(red: 0.4, green: 0.45, blue: 0.55, alpha: 1.0)
        static let joystickGlow = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.3)
        
        // Fire button colors
        static let fireButtonBase = SKColor(red: 0.9, green: 0.25, blue: 0.2, alpha: 1.0)
        static let fireButtonHighlight = SKColor(red: 1.0, green: 0.5, blue: 0.4, alpha: 1.0)
        static let fireButtonGlow = SKColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 0.4)
        
        // Text colors
        static let textPrimary = SKColor.white
        static let textSecondary = SKColor(red: 0.7, green: 0.75, blue: 0.85, alpha: 1.0)
        static let textMuted = SKColor(red: 0.5, green: 0.55, blue: 0.65, alpha: 1.0)
        
        // Tank colors (more vibrant, distinct colors)
        static let tankColors: [SKColor] = [
            SKColor(red: 0.2, green: 0.5, blue: 0.95, alpha: 1.0),   // Vibrant Blue
            SKColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0),   // Vibrant Red
            SKColor(red: 0.2, green: 0.85, blue: 0.5, alpha: 1.0),   // Vibrant Green
            SKColor(red: 1.0, green: 0.65, blue: 0.2, alpha: 1.0)    // Vibrant Orange
        ]
        
        // Projectile colors
        static let projectileCore = SKColor(red: 1.0, green: 0.95, blue: 0.6, alpha: 1.0)
        static let projectileGlow = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.6)
        
        // Explosion colors
        static let explosionCore = SKColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
        static let explosionOuter = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 0.8)
    }
    
    // MARK: - Dimensions
    
    struct Dimensions {
        // Joystick
        static let joystickBaseRadius: CGFloat = 55
        static let joystickHandleRadius: CGFloat = 28
        static let joystickGlowRadius: CGFloat = 65
        static let joystickMaxHandleDistance: CGFloat = 35
        
        // Fire button
        static let fireButtonRadius: CGFloat = 45
        static let fireButtonGlowRadius: CGFloat = 55
        
        // Grid decorations
        static let gridBorderGlowPadding: CGFloat = 6
        static let gridBorderPadding: CGFloat = 2
        
        // UI element spacing
        static let standardMargin: CGFloat = 16
        static let labelHeight: CGFloat = 24
    }
    
    // MARK: - Fonts
    
    struct Fonts {
        static let titleFont = "AvenirNext-Bold"
        static let bodyFont = "AvenirNext-Medium"
        static let smallFont = "AvenirNext-Regular"
        
        static let titleSize: CGFloat = 24
        static let bodySize: CGFloat = 18
        static let smallSize: CGFloat = 14
    }
    
    // MARK: - Animation Durations
    
    struct Animations {
        static let quickFade: TimeInterval = 0.15
        static let standardFade: TimeInterval = 0.3
        static let slowFade: TimeInterval = 0.5
        static let pulseSpeed: TimeInterval = 1.2
        static let glowSpeed: TimeInterval = 2.0
    }
}
