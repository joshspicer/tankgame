//
//  GameMode.swift
//  tankgame Shared
//
//  Defines the available game modes for rendering entities
//

import Foundation

/// Represents the visual mode for the game entities
enum GameMode: String, Codable {
    case tank = "tank"
    case racoon = "racoon"
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .tank:
            return "Tank"
        case .racoon:
            return "Racoon"
        }
    }
    
    /// Emoji representation for UI
    var emoji: String {
        switch self {
        case .tank:
            return "🎯"
        case .racoon:
            return "🦝"
        }
    }
}
