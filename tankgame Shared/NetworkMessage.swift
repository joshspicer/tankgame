//
//  NetworkMessage.swift
//  tankgame Shared
//
//  Network message protocol
//

import Foundation

/// Messages exchanged between players
enum NetworkMessage: Codable {
    case playerMove(playerId: String, direction: Direction)
    case playerShoot(playerId: String)
    case gameState(players: [Player], projectiles: [Projectile])
    case gameStart(playerIds: [String], hostId: String)
    case gameOver(winnerId: String?)
    
    /// Encode message to data
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    /// Decode message from data
    static func decode(from data: Data) -> NetworkMessage? {
        return try? JSONDecoder().decode(NetworkMessage.self, from: data)
    }
}
