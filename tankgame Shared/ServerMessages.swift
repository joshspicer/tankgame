//
//  ServerMessages.swift
//  Tank Game
//
//  Codable message types for Modal server communication.
//

import Foundation

// MARK: - Client → Server Messages

/// Messages sent from the iOS client to the server
enum ClientMessage: Codable {
    case join(displayName: String)
    case move(direction: Int)
    case shoot
    case leave

    private enum CodingKeys: String, CodingKey {
        case type, direction, displayName
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .join(let name):
            try container.encode("join", forKey: .type)
            try container.encode(name, forKey: .displayName)
        case .move(let dir):
            try container.encode("move", forKey: .type)
            try container.encode(dir, forKey: .direction)
        case .shoot:
            try container.encode("shoot", forKey: .type)
        case .leave:
            try container.encode("leave", forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "join":
            let name = try container.decode(String.self, forKey: .displayName)
            self = .join(displayName: name)
        case "move":
            let dir = try container.decode(Int.self, forKey: .direction)
            self = .move(direction: dir)
        case "shoot":
            self = .shoot
        case "leave":
            self = .leave
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }
}

// MARK: - Server → Client Messages

/// Player state received from the server
struct ServerPlayerState: Codable {
    let row: Int
    let col: Int
    let direction: Int
    let isAlive: Bool
    let score: Int
    let displayName: String?
}

/// Projectile state received from the server
struct ServerProjectileState: Codable {
    let row: Int
    let col: Int
    let direction: Int
    let ownerId: String
}

/// Full world state from the server
struct ServerWorldState: Codable {
    let mapSeed: UInt32
    let gridSize: Int
    let players: [String: ServerPlayerState]
    let projectiles: [ServerProjectileState]
    let scores: [String: Int]
}

/// Messages received from the server
enum ServerMessage {
    case welcome(playerId: String, worldState: ServerWorldState)
    case stateUpdate(ServerWorldState)
    case playerJoined(playerId: String, displayName: String)
    case playerLeft(playerId: String)
    case hit(victimId: String, shooterId: String)
    case respawn(playerId: String, row: Int, col: Int, direction: Int)
    case mapUpdate(ServerWorldState)
    case error(message: String)
    case unknown

    /// Parse a raw JSON string from the server
    static func parse(_ raw: String) -> ServerMessage {
        guard let data = raw.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            return .unknown
        }

        let decoder = JSONDecoder()

        switch type {
        case "welcome":
            guard let playerId = json["playerId"] as? String,
                  let wsData = try? JSONSerialization.data(withJSONObject: json["worldState"] as Any),
                  let worldState = try? decoder.decode(ServerWorldState.self, from: wsData) else {
                return .unknown
            }
            return .welcome(playerId: playerId, worldState: worldState)

        case "stateUpdate":
            // The state_update message has world state fields at top level
            if let wsData = try? JSONSerialization.data(withJSONObject: json),
               let worldState = try? decoder.decode(ServerWorldState.self, from: wsData) {
                return .stateUpdate(worldState)
            }
            return .unknown

        case "playerJoined":
            guard let playerId = json["playerId"] as? String else { return .unknown }
            let displayName = json["displayName"] as? String ?? ""
            return .playerJoined(playerId: playerId, displayName: displayName)

        case "playerLeft":
            guard let playerId = json["playerId"] as? String else { return .unknown }
            return .playerLeft(playerId: playerId)

        case "hit":
            guard let victimId = json["victimId"] as? String,
                  let shooterId = json["shooterId"] as? String else { return .unknown }
            return .hit(victimId: victimId, shooterId: shooterId)

        case "respawn":
            guard let playerId = json["playerId"] as? String,
                  let row = json["row"] as? Int,
                  let col = json["col"] as? Int,
                  let direction = json["direction"] as? Int else { return .unknown }
            return .respawn(playerId: playerId, row: row, col: col, direction: direction)

        case "mapUpdate":
            if let wsData = try? JSONSerialization.data(withJSONObject: json),
               let worldState = try? decoder.decode(ServerWorldState.self, from: wsData) {
                return .mapUpdate(worldState)
            }
            return .unknown

        case "error":
            let message = json["message"] as? String ?? "Unknown error"
            return .error(message: message)

        default:
            return .unknown
        }
    }
}
