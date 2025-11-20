//
//  GameMessages.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Network message types for multiplayer communication
enum GameMessage: Codable {
    case roundStart(seed: UInt32, playerCount: Int, hostPlayerIndex: Int, playerAssignments: [String: Int]) // peerName -> playerIndex
    case playerJoined(playerIndex: Int, peerName: String)
    case playerMove(playerIndex: Int, row: Int, col: Int, direction: Direction)
    case playerShoot(playerIndex: Int, projectile: Projectile)
    case playerHit(playerIndex: Int)
    case readyForNextRound(playerIndex: Int)
    case startGame // Host signals game start
    case restartMatch // Request to restart match (reset scores)
    case quitToLobby // Request to return to lobby
}
