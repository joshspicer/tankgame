//
//  GameMode.swift
//  tankgame Shared
//
//  Game mode configuration for different tank styles
//

import Foundation

/// Game modes that affect tank appearance and behavior
enum GameMode: Int, Codable, CaseIterable {
    case normal = 0
    case spider = 1
    
    var displayName: String {
        switch self {
        case .normal: return "Tank"
        case .spider: return "Spider"
        }
    }
    
    var emoji: String {
        switch self {
        case .normal: return "🎯"
        case .spider: return "🕷️"
        }
    }
}
