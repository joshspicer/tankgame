//
//  SpriteMode.swift
//  tankgame Shared
//
//  Defines the different visual modes for game sprites
//

import Foundation

/// Different visual modes for player sprites
enum SpriteMode: String, Codable, CaseIterable {
    case tank = "tank"
    case dolphin = "dolphin"
    
    /// Display name for the mode
    var displayName: String {
        switch self {
        case .tank:
            return "Tank"
        case .dolphin:
            return "Dolphin"
        }
    }
    
    /// Emoji icon for the mode
    var icon: String {
        switch self {
        case .tank:
            return "🎯"
        case .dolphin:
            return "🐬"
        }
    }
}

/// Global settings for the game
class GameSettings {
    static let shared = GameSettings()
    
    /// Current sprite mode
    var spriteMode: SpriteMode = .tank
    
    /// Whether to use modern UI styling
    var useModernUI: Bool = true
    
    private init() {}
}
