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
            return PowerUpEffectWrapper(SpeedBoostEffect(duration: 5.0, multiplier: 1.5))
        case .fireRate:
            return PowerUpEffectWrapper(FireRateBoostEffect(duration: 5.0, multiplier: 1.5))
        case .shield:
            return PowerUpEffectWrapper(ShieldEffect(duration: 10.0))
        case .health:
            return PowerUpEffectWrapper(HealthRestoreEffect())
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

/// Wrapper for type-erased powerup effects with type-safe encoding/decoding
struct PowerUpEffectWrapper: Codable {
    private let effect: any PowerUpEffect

    init(_ effect: any PowerUpEffect) {
        self.effect = effect
    }

    var effectType: String {
        effect.effectType
    }

    var duration: TimeInterval {
        effect.duration
    }

    func apply(to tank: inout Tank) {
        effect.apply(to: &tank)
    }

    func remove(from tank: inout Tank) {
        effect.remove(from: &tank)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case effectType
        case effectData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .effectType)

        // Use registry to create the appropriate effect type
        let effectDecoder = try container.superDecoder(forKey: .effectData)
        self.effect = try PowerUpEffectRegistry.createEffect(type: type, from: effectDecoder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(effect.effectType, forKey: .effectType)

        let effectEncoder = container.superEncoder(forKey: .effectData)
        try effect.encode(to: effectEncoder)
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
