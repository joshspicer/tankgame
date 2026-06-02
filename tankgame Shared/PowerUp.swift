//
//  PowerUp.swift
//  Tank Game
//
//  Collectible power-ups that spawn on the map and grant temporary abilities.
//

import Foundation

/// The different kinds of power-ups available in the game.
enum PowerUpKind: Int, Codable, CaseIterable {
    /// Absorbs the next incoming hit (synced across all peers).
    case shield = 0
    /// Temporarily increases the local tank's movement speed.
    case speed
    /// Temporarily makes the local tank fire in three directions at once.
    case tripleShot

    /// Short human-readable label.
    var displayName: String {
        switch self {
        case .shield:     return "Shield"
        case .speed:      return "Speed"
        case .tripleShot: return "Triple Shot"
        }
    }

    /// Single-character glyph used when rendering the pickup.
    var symbol: String {
        switch self {
        case .shield:     return "S"
        case .speed:      return "»"
        case .tripleShot: return "T"
        }
    }

    /// Duration in seconds for timed (local) effects. Unused for `.shield`.
    var duration: TimeInterval {
        switch self {
        case .shield:     return 0
        case .speed:      return 6.0
        case .tripleShot: return 6.0
        }
    }
}

/// A power-up lying on the map waiting to be collected.
struct PowerUp: Codable, Equatable {
    let id: String
    var row: Int
    var col: Int
    var kind: PowerUpKind

    init(id: String = UUID().uuidString, row: Int, col: Int, kind: PowerUpKind) {
        self.id = id
        self.row = row
        self.col = col
        self.kind = kind
    }
}

// MARK: - Game Power-Up Logic

extension Game {
    /// Maximum number of power-ups allowed on the map at once.
    var maxPowerUps: Int { 3 }

    /// Find a power-up at a given grid cell, if any.
    func powerUp(at row: Int, col: Int) -> PowerUp? {
        powerUps.first { $0.row == row && $0.col == col }
    }

    /// Spawn a new power-up at a random empty cell (no wall, tank, or existing pickup).
    /// Returns the created power-up, or nil if the map is full / no space.
    @discardableResult
    func spawnRandomPowerUp() -> PowerUp? {
        guard powerUps.count < maxPowerUps else { return nil }

        // Collect candidate cells.
        var occupied = Set<String>()
        for data in players.values where data.tank.isAlive {
            occupied.insert("\(data.tank.row),\(data.tank.col)")
        }
        for powerUp in powerUps {
            occupied.insert("\(powerUp.row),\(powerUp.col)")
        }

        var candidates: [(row: Int, col: Int)] = []
        for row in 0..<map.size {
            for col in 0..<map.size {
                guard !map.grid[row][col] else { continue }
                guard !occupied.contains("\(row),\(col)") else { continue }
                candidates.append((row, col))
            }
        }

        guard let cell = candidates.randomElement() else { return nil }
        let kind = PowerUpKind.allCases.randomElement() ?? .shield
        let powerUp = PowerUp(row: cell.row, col: cell.col, kind: kind)
        powerUps.append(powerUp)
        return powerUp
    }

    /// Remove and return a power-up by id (when collected).
    @discardableResult
    func removePowerUp(id: String) -> PowerUp? {
        guard let index = powerUps.firstIndex(where: { $0.id == id }) else { return nil }
        return powerUps.remove(at: index)
    }

    /// Apply the synced portion of a collected power-up (shield charges).
    /// Timed effects (speed / triple shot) are applied locally by the scene.
    func applyCollectedEffect(_ kind: PowerUpKind, to peerId: String) {
        if kind == .shield {
            players[peerId]?.shieldCharges += 1
        }
    }
}
