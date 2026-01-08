//
//  NetworkMessage.swift
//  tankgame Shared
//
//  Network message protocol

import Foundation

/// Network messages - clean enum
enum NetworkMessage: Codable {
    case startRound(seed: UInt32, playerAssignments: [String: Int])
    case move(playerIndex: Int, position: Position, direction: Direction)
    case shoot(playerIndex: Int, position: Position, direction: Direction)
    case hit(playerIndex: Int)
    case roundEnd(winner: Int?)
}
