//
//  PlayerInfo.swift
//  tankgame Shared
//
//  Core domain model for player information
//

import Foundation

/// Information about a player in the game
struct PlayerInfo: Codable, Equatable {
    let id: String
    let name: String
    let index: Int // 0-5 for up to 6 players
    var score: Int
    var isConnected: Bool
    
    init(id: String, name: String, index: Int) {
        self.id = id
        self.name = name
        self.index = index
        self.score = 0
        self.isConnected = true
    }
}
