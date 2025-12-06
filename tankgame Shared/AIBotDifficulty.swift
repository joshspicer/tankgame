//
//  AIBotDifficulty.swift
//  tankgame Shared
//
//  Defines difficulty levels for AI bots with tunable parameters
//

import Foundation

/// Difficulty level for AI bots
enum AIBotDifficulty: Int, CaseIterable {
    case easy = 0
    case medium = 1
    case hard = 2
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    /// Icon for UI
    var icon: String {
        switch self {
        case .easy: return "🟢"
        case .medium: return "🟡"
        case .hard: return "🔴"
        }
    }
    
    /// Movement interval in update ticks (lower = faster)
    var moveInterval: Int {
        switch self {
        case .easy: return 18
        case .medium: return 12
        case .hard: return 8
        }
    }
    
    /// Shooting interval in update ticks (lower = faster)
    var shootInterval: Int {
        switch self {
        case .easy: return 35
        case .medium: return 25
        case .hard: return 15
        }
    }
    
    /// Probability of making random moves instead of optimal ones (higher = more random)
    var randomMoveProbability: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 0.3
        case .hard: return 0.1
        }
    }
    
    /// Probability of random shooting when no target is in line (higher = wastes more ammo)
    var randomShootProbability: Double {
        switch self {
        case .easy: return 0.3
        case .medium: return 0.2
        case .hard: return 0.05
        }
    }
    
    /// Number of steps to look ahead for projectile danger detection
    var dangerLookAhead: Int {
        switch self {
        case .easy: return 2
        case .medium: return 4
        case .hard: return 6
        }
    }
    
    /// Whether the bot uses advanced targeting (aims toward target before shooting)
    var usesAdvancedTargeting: Bool {
        switch self {
        case .easy: return false
        case .medium: return true
        case .hard: return true
        }
    }
    
    /// Whether the bot uses flanking maneuvers
    var usesFlankingManeuvers: Bool {
        switch self {
        case .easy: return false
        case .medium: return false
        case .hard: return true
        }
    }
    
    /// Maximum line of sight for targeting (how far to check for enemies)
    var targetingRange: Int {
        switch self {
        case .easy: return 4
        case .medium: return 6
        case .hard: return 8
        }
    }
}

/// Global AI settings storage
class AISettings {
    static let shared = AISettings()
    
    /// Current difficulty level for AI bots
    var difficulty: AIBotDifficulty = .medium
    
    private init() {}
}
