//
//  Messages.swift
//  Tank Game
//
//  Network message types for multiplayer communication.
//

import Foundation

/// All network message types for the game
enum GameMessage: Codable {
    /// Host starts a new round with a map seed
    case roundStart(seed: UInt32, playerCount: Int, playerAssignments: [String: Int])
    
    /// Player moved to a new position
    case move(playerIndex: Int, row: Int, col: Int, direction: Direction)
    
    /// Player fired a projectile
    case shoot(playerIndex: Int, projectile: Projectile)
    
    /// Player was hit and eliminated
    case hit(playerIndex: Int)
    
    /// Player ready for next round
    case ready(playerIndex: Int)
}
