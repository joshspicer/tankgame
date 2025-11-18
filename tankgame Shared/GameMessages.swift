//
//  GameMessages.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Network message types for multiplayer communication
///
/// These messages are exchanged between players to synchronize game state over MultipeerConnectivity.
/// All messages are Codable for easy serialization and transmission.
enum GameMessage: Codable {
    /// Broadcast by host to start a new round with synchronized grid and player assignments
    case roundStart(seed: UInt32, playerCount: Int, hostPlayerIndex: Int, playerAssignments: [String: Int])
    /// Notifies all players when a new player joins the game
    case playerJoined(playerIndex: Int, peerName: String)
    /// Broadcasts a player's movement to all other players
    case playerMove(playerIndex: Int, row: Int, col: Int, direction: Direction)
    /// Broadcasts when a player shoots a projectile
    case playerShoot(playerIndex: Int, projectile: Projectile)
    /// Notifies all players when a tank is hit and destroyed
    case playerHit(playerIndex: Int)
    /// Signals that a player is ready to begin the next round
    case readyForNextRound(playerIndex: Int)
    /// Host broadcasts this message to start the game
    case startGame
}
