//
//  AIBotDifficulty.swift
//  tankgame Shared
//
//  Defines difficulty levels and configurations for AI bots
//

import Foundation

/// Difficulty levels for AI bots
enum AIBotDifficulty: Int, Codable, CaseIterable {
    case easy = 0
    case medium = 1
    case hard = 2
    
    /// Display name for the difficulty level
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    /// Configuration parameters for this difficulty level
    var config: AIBotConfig {
        switch self {
        case .easy:
            return AIBotConfig(
                moveInterval: 16,           // Slower movement
                shootInterval: 35,          // Slower shooting
                aimAccuracy: 0.5,           // 50% chance to shoot when aligned
                dodgeReactionTime: 2,       // Only reacts to very close projectiles
                pursuitRandomness: 0.5,     // 50% random movement
                flankingEnabled: false,     // No flanking
                coverSeekingEnabled: false, // No cover seeking
                predictiveAiming: false,    // No predictive aiming
                retreatEnabled: false,      // No retreat behavior
                lookAheadDistance: 3        // Short look-ahead
            )
        case .medium:
            return AIBotConfig(
                moveInterval: 12,           // Normal movement
                shootInterval: 25,          // Normal shooting
                aimAccuracy: 0.7,           // 70% chance to shoot when aligned
                dodgeReactionTime: 4,       // Reacts to moderately close projectiles
                pursuitRandomness: 0.3,     // 30% random movement
                flankingEnabled: true,      // Enable flanking
                coverSeekingEnabled: false, // No cover seeking
                predictiveAiming: false,    // No predictive aiming
                retreatEnabled: true,       // Enable retreat behavior
                lookAheadDistance: 5        // Medium look-ahead
            )
        case .hard:
            return AIBotConfig(
                moveInterval: 10,           // Fast movement
                shootInterval: 18,          // Fast shooting
                aimAccuracy: 0.9,           // 90% chance to shoot when aligned
                dodgeReactionTime: 6,       // Reacts to distant projectiles
                pursuitRandomness: 0.15,    // Only 15% random movement
                flankingEnabled: true,      // Enable flanking
                coverSeekingEnabled: true,  // Enable cover seeking
                predictiveAiming: true,     // Enable predictive aiming
                retreatEnabled: true,       // Enable retreat behavior
                lookAheadDistance: 8        // Long look-ahead (full grid)
            )
        }
    }
}

/// Configuration parameters for AI bot behavior
struct AIBotConfig {
    /// Movement decision interval in update ticks
    let moveInterval: Int
    
    /// Shooting decision interval in update ticks
    let shootInterval: Int
    
    /// Probability (0.0 - 1.0) of shooting when target is aligned
    let aimAccuracy: Double
    
    /// How many cells ahead to check for incoming projectiles
    let dodgeReactionTime: Int
    
    /// Probability (0.0 - 1.0) of making a random move instead of pursuing
    let pursuitRandomness: Double
    
    /// Whether the bot tries to flank enemies instead of direct pursuit
    let flankingEnabled: Bool
    
    /// Whether the bot seeks cover (near walls) when under attack
    let coverSeekingEnabled: Bool
    
    /// Whether the bot predicts enemy movement for shooting
    let predictiveAiming: Bool
    
    /// Whether the bot retreats when outnumbered
    let retreatEnabled: Bool
    
    /// How far ahead to scan for targets and threats
    let lookAheadDistance: Int
}
