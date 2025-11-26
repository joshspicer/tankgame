//
//  GameMode.swift
//  tankgame Shared
//
//  Game mode settings for Tank Game
//

import Foundation

/// Represents the available game modes
enum GameMode: String, Codable {
    case tank = "tank"
    case bunny = "bunny"
}

/// Stores global game mode settings
class GameModeSettings {
    static let shared = GameModeSettings()
    
    var currentMode: GameMode = .tank
    
    private init() {}
}
