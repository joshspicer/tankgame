//
//  NetworkMessage.swift
//  tankgame Shared
//
//  Clean Architecture - Infrastructure Layer
//

import Foundation

/// Messages sent over the network for multiplayer
enum NetworkMessage: Codable {
    // Player actions
    case playerMove(playerID: PlayerID, direction: Direction, timestamp: TimeInterval)
    case playerFire(playerID: PlayerID, timestamp: TimeInterval)
    
    // Game state sync
    case fullStateSync(GameSessionEntity)
    case deltaStateSync(tanks: [TankEntity], projectiles: [ProjectileEntity])
    
    // Game control
    case startRound(seed: UInt32, spawnPositions: [(Position, Direction)])
    case roundEnd(winnerID: PlayerID?)
    case gameOver(winnerID: PlayerID)
    
    // Connection management
    case playerJoined(PlayerEntity)
    case playerLeft(playerID: PlayerID)
    case ping
    case pong
    
    var messageType: String {
        switch self {
        case .playerMove: return "playerMove"
        case .playerFire: return "playerFire"
        case .fullStateSync: return "fullStateSync"
        case .deltaStateSync: return "deltaStateSync"
        case .startRound: return "startRound"
        case .roundEnd: return "roundEnd"
        case .gameOver: return "gameOver"
        case .playerJoined: return "playerJoined"
        case .playerLeft: return "playerLeft"
        case .ping: return "ping"
        case .pong: return "pong"
        }
    }
}

/// Protocol for serializing and deserializing network messages
protocol MessageSerializer {
    func serialize(_ message: NetworkMessage) throws -> Data
    func deserialize(_ data: Data) throws -> NetworkMessage
}

/// JSON-based message serializer
final class JSONMessageSerializer: MessageSerializer {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func serialize(_ message: NetworkMessage) throws -> Data {
        return try encoder.encode(message)
    }
    
    func deserialize(_ data: Data) throws -> NetworkMessage {
        return try decoder.decode(NetworkMessage.self, from: data)
    }
}
