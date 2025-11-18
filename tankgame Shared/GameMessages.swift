//
//  GameMessages.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Network message types for multiplayer communication
enum GameMessage: Codable {
    /// Sent by host to start a new round with game state parameters
    case roundStart(seed: UInt32, playerCount: Int, hostPlayerIndex: Int, playerAssignments: [String: Int])
    
    /// Sent when a new player joins the lobby
    case playerJoined(playerIndex: Int, peerName: String)
    
    /// Sent when a player moves their tank
    case playerMove(playerIndex: Int, row: Int, col: Int, direction: Direction)
    
    /// Sent when a player shoots a projectile
    case playerShoot(playerIndex: Int, projectile: Projectile)
    
    /// Sent when a player's tank is hit and destroyed
    case playerHit(playerIndex: Int)
    
    /// Sent when a player is ready to proceed to the next round
    case readyForNextRound(playerIndex: Int)
    
    /// Sent by host to signal all players to start the game
    case startGame
}
