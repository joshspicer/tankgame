//
//  GameSettings.swift
//  tankgame Shared
//
//  Global game settings including mode toggles
//

import Foundation

/// Available visual modes for the game
enum GameMode: String, Codable {
    case rainbow
    case batman
}

/// Singleton to manage global game settings
class GameSettings {
    static let shared = GameSettings()
    
    /// Current visual mode for the game
    var mode: GameMode = .rainbow
    
    private init() {}
    
    /// Check if Batman mode is enabled
    var isBatmanMode: Bool {
        return mode == .batman
    }
    
    /// Toggle between rainbow and batman mode
    func toggleMode() {
        mode = (mode == .rainbow) ? .batman : .rainbow
    }
}
