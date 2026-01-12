//
//  GameEnums.swift
//  tankgame Shared
//
//  Consolidated enums for game logic and networking
//

import Foundation

// MARK: - Direction

enum Direction: Int, Codable, CaseIterable {
    case up = 0
    case right = 1
    case down = 2
    case left = 3
    case upRight = 4
    case downRight = 5
    case downLeft = 6
    case upLeft = 7

    var angle: Double {
        switch self {
        case .up: return 0
        case .right: return .pi / 2
        case .down: return .pi
        case .left: return -.pi / 2
        case .upRight: return .pi / 4
        case .downRight: return 3 * .pi / 4
        case .downLeft: return -.pi * 3 / 4
        case .upLeft: return -.pi / 4
        }
    }

    var offset: (row: Int, col: Int) {
        switch self {
        case .up: return (-1, 0)
        case .down: return (1, 0)
        case .left: return (0, -1)
        case .right: return (0, 1)
        case .upRight: return (-1, 1)
        case .downRight: return (1, 1)
        case .downLeft: return (1, -1)
        case .upLeft: return (-1, -1)
        }
    }

    var isDiagonal: Bool {
        switch self {
        case .upRight, .downRight, .downLeft, .upLeft:
            return true
        case .up, .down, .left, .right:
            return false
        }
    }

    static let cardinalDirections: [Direction] = [.up, .down, .left, .right]
}

// MARK: - GridCell

enum GridCell: Int, Codable {
    case empty = 0
    case wall = 1
}

// MARK: - ConnectionState

enum ConnectionState: Equatable {
    case disconnected
    case browsing
    case advertising
    case connecting(peerName: String)
    case connected(peerCount: Int)
    case reconnecting(attempt: Int, maxAttempts: Int)

    var description: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .browsing:
            return "Searching for games..."
        case .advertising:
            return "Hosting game..."
        case .connecting(let peerName):
            return "Connecting to \(peerName)..."
        case .connected(let peerCount):
            return "Connected (\(peerCount) player\(peerCount == 1 ? "" : "s"))"
        case .reconnecting(let attempt, let maxAttempts):
            return "Reconnecting (attempt \(attempt)/\(maxAttempts))..."
        }
    }

    var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }

    var isConnecting: Bool {
        if case .connecting = self {
            return true
        }
        return false
    }

    var isReconnecting: Bool {
        if case .reconnecting = self {
            return true
        }
        return false
    }
}

// MARK: - GameMessage

enum GameMessage: Codable {
    case roundStart(seed: UInt32, playerCount: Int, hostPlayerIndex: Int, playerAssignments: [String: Int])
    case playerJoined(playerIndex: Int, peerName: String)
    case playerMove(playerIndex: Int, row: Int, col: Int, direction: Direction)
    case playerShoot(playerIndex: Int, projectile: Projectile)
    case playerHit(playerIndex: Int)
    case readyForNextRound(playerIndex: Int)
    case startGame
}
