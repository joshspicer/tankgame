//
//  NetworkMessage.swift
//  tankgame Shared
//
//  Network message protocol
//

import Foundation

/// Messages sent over the network
enum NetworkMessage: Codable {
    case playerJoined(playerId: String, playerName: String)
    case playerLeft(playerId: String)
    case gameStarting(players: [PlayerInfo], seed: UInt32)
    case tankAction(playerIndex: Int, action: TankAction)
    case gameEvent(event: GameEventData)
    case roundEnded(winnerIndex: Int?, scores: [Int])
    
    /// Tank actions that can be sent over network
    enum TankAction: Codable {
        case move(direction: Direction)
        case rotate(direction: Direction)
        case fire
    }
    
    /// Serializable game event data
    enum GameEventData: Codable {
        case tankMoved(playerIndex: Int, position: Position, direction: Direction)
        case tankRotated(playerIndex: Int, direction: Direction)
        case projectileFired(playerIndex: Int, projectileId: String, position: Position, direction: Direction)
        case projectileHit(projectileId: String, position: Position)
        case tankDestroyed(playerIndex: Int)
        case wallDestroyed(position: Position)
    }
}
