//
//  PowerUpEffect.swift
//  Tank Game
//
//  Powerup effect system with hooks into game variables.
//

import Foundation

/// Protocol for powerup effects that modify game behavior
protocol PowerUpEffect: Codable {
    /// Type identifier for network serialization
    var effectType: String { get }

    /// Duration of the effect in seconds (0 = instant)
    var duration: TimeInterval { get }

    /// Apply effect to a tank
    func apply(to tank: inout Tank)

    /// Remove effect from a tank
    func remove(from tank: inout Tank)
}

/// Registry for powerup effect types to enable dynamic creation
struct PowerUpEffectRegistry {
    private static var effectCreators: [String: (Decoder) throws -> any PowerUpEffect] = [
        "speed": { try SpeedBoostEffect(from: $0) },
        "fireRate": { try FireRateBoostEffect(from: $0) },
        "shield": { try ShieldEffect(from: $0) },
        "health": { try HealthRestoreEffect(from: $0) }
    ]

    static func register(type: String, creator: @escaping (Decoder) throws -> any PowerUpEffect) {
        effectCreators[type] = creator
    }

    static func createEffect(type: String, from decoder: Decoder) throws -> any PowerUpEffect {
        guard let creator = effectCreators[type] else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown effect type: \(type)"
                )
            )
        }
        return try creator(decoder)
    }
}

/// Speed boost powerup effect
struct SpeedBoostEffect: PowerUpEffect, Codable {
    let effectType = "speed"
    let duration: TimeInterval
    let multiplier: Double

    func apply(to tank: inout Tank) {
        tank.speedMultiplier *= multiplier
    }

    func remove(from tank: inout Tank) {
        tank.speedMultiplier /= multiplier
    }
}

/// Fire rate boost powerup effect
struct FireRateBoostEffect: PowerUpEffect, Codable {
    let effectType = "fireRate"
    let duration: TimeInterval
    let multiplier: Double

    func apply(to tank: inout Tank) {
        tank.fireRateMultiplier *= multiplier
    }

    func remove(from tank: inout Tank) {
        tank.fireRateMultiplier /= multiplier
    }
}

/// Shield powerup effect (prevents one hit)
struct ShieldEffect: PowerUpEffect, Codable {
    let effectType = "shield"
    let duration: TimeInterval

    func apply(to tank: inout Tank) {
        tank.hasShield = true
    }

    func remove(from tank: inout Tank) {
        tank.hasShield = false
    }
}

/// Instant health restore
struct HealthRestoreEffect: PowerUpEffect, Codable {
    let effectType = "health"
    let duration: TimeInterval = 0 // Instant

    func apply(to tank: inout Tank) {
        // Instant effect - just sets tank to alive if dead
        if !tank.isAlive {
            tank.isAlive = true
        }
    }

    func remove(from tank: inout Tank) {
        // No removal for instant effects
    }
}

/// Active powerup effect with expiration tracking
struct ActivePowerUpEffect: Codable {
    let effectType: String
    let expiresAt: TimeInterval
    let multiplier: Double?

    /// Check if effect has expired
    func hasExpired(currentTime: TimeInterval) -> Bool {
        currentTime >= expiresAt
    }
}
