//
//  PlayerID.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Unique identifier for a player
struct PlayerID: Equatable, Hashable, Codable {
    let value: UUID
    
    init() {
        self.value = UUID()
    }
    
    init(value: UUID) {
        self.value = value
    }
    
    init(uuidString: String) {
        self.value = UUID(uuidString: uuidString) ?? UUID()
    }
}
