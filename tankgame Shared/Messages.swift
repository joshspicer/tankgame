//
//  Messages.swift
//  Tank Game
//
//  Network message types for multiplayer communication.
//

import Foundation

/// Player state for network sync
struct PlayerState: Codable, Equatable {
    let peerId: String
    var row: Int
    var col: Int
    var direction: Direction
    var isAlive: Bool
}

/// Projectile state for network sync
struct ProjectileState: Codable, Equatable {
    var row: Int
    var col: Int
    var direction: Direction
    var ownerId: String
}

/// Full world state for syncing new joiners
struct WorldState: Codable {
    let mapSeed: UInt32
    let players: [PlayerState]
    let projectiles: [ProjectileState]
    let scores: [String: Int]
}

/// All network message types for the game
enum GameMessage: Codable {
    /// Full world state sent to new joiners
    case worldState(WorldState)

    /// Periodic sync of all player states (sent by elder)
    case sync(players: [PlayerState], scores: [String: Int])

    /// Player joined the game
    case playerJoined(peerId: String)

    /// Player left the game
    case playerLeft(peerId: String)

    /// Player moved to a new position
    case move(peerId: String, row: Int, col: Int, direction: Direction)

    /// Player fired a projectile
    case shoot(peerId: String, projectile: ProjectileState)

    /// Player was hit and eliminated
    case hit(peerId: String)

    /// Player respawned
    case respawn(peerId: String, row: Int, col: Int, direction: Direction)
}
