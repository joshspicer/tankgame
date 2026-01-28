//
//  PowerUp.swift
//  Tank Game
//
//  Generic powerup system for spawning collectible items.
//

import Foundation

/// Powerup types available in the game
enum PowerUpType: String, Codable, CaseIterable {
    case speed
    case fireRate
    case shield
    case health

    /// Create the effect for this powerup type
    func createEffect() -> PowerUpEffectWrapper {
        switch self {
        case .speed:
            return .speed(SpeedBoostEffect(duration: 5.0, multiplier: 1.5))
        case .fireRate:
            return .fireRate(FireRateBoostEffect(duration: 5.0, multiplier: 1.5))
        case .shield:
            return .shield(ShieldEffect(duration: 10.0))
        case .health:
            return .health(HealthRestoreEffect())
        }
    }

    /// Visual identifier for rendering
    var symbol: String {
        switch self {
        case .speed: return "⚡︎"
        case .fireRate: return "🔥"
        case .shield: return "🛡"
        case .health: return "❤️"
        }
    }
}

/// Wrapper for type-erased powerup effects
enum PowerUpEffectWrapper: Codable {
    case speed(SpeedBoostEffect)
    case fireRate(FireRateBoostEffect)
    case shield(ShieldEffect)
    case health(HealthRestoreEffect)

    var effectType: String {
        switch self {
        case .speed(let effect): return effect.effectType
        case .fireRate(let effect): return effect.effectType
        case .shield(let effect): return effect.effectType
        case .health(let effect): return effect.effectType
        }
    }

    var duration: TimeInterval {
        switch self {
        case .speed(let effect): return effect.duration
        case .fireRate(let effect): return effect.duration
        case .shield(let effect): return effect.duration
        case .health(let effect): return effect.duration
        }
    }

    func apply(to tank: inout Tank) {
        switch self {
        case .speed(let effect): effect.apply(to: &tank)
        case .fireRate(let effect): effect.apply(to: &tank)
        case .shield(let effect): effect.apply(to: &tank)
        case .health(let effect): effect.apply(to: &tank)
        }
    }

    func remove(from tank: inout Tank) {
        switch self {
        case .speed(let effect): effect.remove(from: &tank)
        case .fireRate(let effect): effect.remove(from: &tank)
        case .shield(let effect): effect.remove(from: &tank)
        case .health(let effect): effect.remove(from: &tank)
        }
    }
}

/// Powerup entity on the map
struct PowerUp: Codable, Equatable {
    let id: String
    var row: Int
    var col: Int
    let type: PowerUpType
    let spawnedAt: TimeInterval

    /// Create a new powerup at a position
    init(row: Int, col: Int, type: PowerUpType, spawnedAt: TimeInterval = CACurrentMediaTime()) {
        self.id = UUID().uuidString
        self.row = row
        self.col = col
        self.type = type
        self.spawnedAt = spawnedAt
    }

    /// Check if powerup should despawn (after 30 seconds)
    func shouldDespawn(currentTime: TimeInterval) -> Bool {
        currentTime - spawnedAt > 30.0
    }
}

/// Powerup state for network sync
struct PowerUpState: Codable, Equatable {
    let id: String
    var row: Int
    var col: Int
    let type: PowerUpType
    let spawnedAt: TimeInterval
}

extension PowerUp {
    /// Convert to network state
    func toState() -> PowerUpState {
        PowerUpState(id: id, row: row, col: col, type: type, spawnedAt: spawnedAt)
    }

    /// Create from network state
    static func from(_ state: PowerUpState) -> PowerUp {
        var powerUp = PowerUp(row: state.row, col: state.col, type: state.type, spawnedAt: state.spawnedAt)
        // Override the generated id with the synced id
        powerUp = PowerUp(
            id: state.id,
            row: state.row,
            col: state.col,
            type: state.type,
            spawnedAt: state.spawnedAt
        )
        return powerUp
    }

    /// Internal init with custom id for network sync
    private init(id: String, row: Int, col: Int, type: PowerUpType, spawnedAt: TimeInterval) {
        self.id = id
        self.row = row
        self.col = col
        self.type = type
        self.spawnedAt = spawnedAt
    }
}
