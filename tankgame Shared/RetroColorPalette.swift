//
//  RetroColorPalette.swift
//  tankgame Shared
//
//  Classic retro color palette for simple, clean game aesthetics
//

import SpriteKit

#if os(iOS) || os(tvOS)
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
#endif

/// Centralized retro color palette for a classic, clean game look
enum RetroColors {
    // MARK: - Background Colors
    static let gameBackground = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
    static let lobbyBackground = PlatformColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1.0)
    
    // MARK: - Grid Colors
    static let gridFloor = SKColor(red: 0.2, green: 0.25, blue: 0.2, alpha: 1.0)
    static let gridWall = SKColor(red: 0.35, green: 0.35, blue: 0.4, alpha: 1.0)
    static let gridBorder = SKColor(red: 0.4, green: 0.45, blue: 0.4, alpha: 1.0)
    
    // MARK: - Player Tank Colors (classic, solid)
    static let player1 = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)  // Blue
    static let player2 = SKColor(red: 0.9, green: 0.35, blue: 0.3, alpha: 1.0) // Red
    static let player3 = SKColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0)  // Green
    static let player4 = SKColor(red: 0.95, green: 0.6, blue: 0.2, alpha: 1.0) // Orange
    
    static let playerColors: [SKColor] = [player1, player2, player3, player4]
    
    // MARK: - UI Tank Colors (for UIKit views)
    static let uiPlayer1 = PlatformColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
    static let uiPlayer2 = PlatformColor(red: 0.9, green: 0.35, blue: 0.3, alpha: 1.0)
    static let uiPlayer3 = PlatformColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0)
    static let uiPlayer4 = PlatformColor(red: 0.95, green: 0.6, blue: 0.2, alpha: 1.0)
    
    // MARK: - Projectile Colors
    static let projectile = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
    
    // MARK: - Lizard Colors
    static let lizard = SKColor(red: 0.4, green: 0.75, blue: 0.35, alpha: 1.0)
    
    // MARK: - UI Element Colors
    static let buttonPrimary = PlatformColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
    static let buttonSecondary = PlatformColor(red: 0.4, green: 0.45, blue: 0.5, alpha: 1.0)
    static let buttonDanger = PlatformColor(red: 0.85, green: 0.3, blue: 0.25, alpha: 1.0)
    static let buttonSuccess = PlatformColor(red: 0.3, green: 0.7, blue: 0.35, alpha: 1.0)
    static let buttonWarning = PlatformColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)
    
    // MARK: - Text Colors
    static let textPrimary = PlatformColor.white
    static let textSecondary = PlatformColor(white: 0.7, alpha: 1.0)
    static let textMuted = PlatformColor(white: 0.5, alpha: 1.0)
    
    // MARK: - Fire Button
    static let fireButton = SKColor(red: 0.85, green: 0.3, blue: 0.2, alpha: 1.0)
    static let fireButtonBorder = SKColor.white
    
    // MARK: - Joystick
    static let joystickBase = SKColor(white: 0.3, alpha: 0.8)
    static let joystickHandle = SKColor(white: 0.7, alpha: 0.9)
    static let joystickBorder = SKColor(white: 0.5, alpha: 1.0)
    
    // MARK: - Explosion
    static let explosionCore = SKColor.white
    static let explosionOuter = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
    
    // MARK: - Tank Components
    static let muzzle = SKColor(white: 0.25, alpha: 1.0)
}

/// Retro font configuration
enum RetroFonts {
    static let title = "Courier-Bold"
    static let label = "Courier"
    static let button = "Courier-Bold"
}
