//
//  PlayerEntity.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Player in the game
struct PlayerEntity: Equatable, Codable {
    let id: PlayerID
    let name: String
    var score: Int
    let index: Int // Player index (0-5 for 2-6 players)
    var isConnected: Bool
    
    init(id: PlayerID = PlayerID(), name: String, index: Int) {
        self.id = id
        self.name = name
        self.score = 0
        self.index = index
        self.isConnected = true
    }
    
    /// Add wins to player score
    mutating func addScore(_ points: Int = 1) {
        score += points
    }
    
    /// Reset player score
    mutating func resetScore() {
        score = 0
    }
    
    /// Mark player as disconnected
    mutating func disconnect() {
        isConnected = false
    }
    
    /// Mark player as reconnected
    mutating func reconnect() {
        isConnected = true
    }
}
