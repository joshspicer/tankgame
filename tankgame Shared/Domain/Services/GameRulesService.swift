//
//  GameRulesService.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Service for game rules and win conditions
struct GameRulesService {
    
    /// Minimum number of players
    let minPlayers = 2
    
    /// Maximum number of players
    let maxPlayers = 6
    
    /// Number of rounds to win the game
    let roundsToWin = 5
    
    /// Check if player count is valid
    func isValidPlayerCount(_ count: Int) -> Bool {
        return count >= minPlayers && count <= maxPlayers
    }
    
    /// Check if round is over (only one tank alive or less)
    func isRoundOver(tanks: [TankEntity]) -> Bool {
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count <= 1
    }
    
    /// Get the winner of the current round
    func getRoundWinner(tanks: [TankEntity]) -> PlayerID? {
        let aliveTanks = tanks.filter { $0.isAlive }
        if aliveTanks.count == 1 {
            return aliveTanks.first?.playerID
        }
        return nil
    }
    
    /// Check if game is over (a player reached winning score)
    func isGameOver(players: [PlayerEntity]) -> Bool {
        return players.contains { $0.score >= roundsToWin }
    }
    
    /// Get the winner of the game
    func getGameWinner(players: [PlayerEntity]) -> PlayerEntity? {
        return players.first { $0.score >= roundsToWin }
    }
    
    /// Get spawn positions for players
    func getSpawnPositions(for playerCount: Int, mapSize: Int) -> [(Position, Direction)] {
        let positions: [(Position, Direction)] = [
            (Position(row: 1, col: 1), .down),              // Top-left
            (Position(row: mapSize - 2, col: mapSize - 2), .up),    // Bottom-right
            (Position(row: 1, col: mapSize - 2), .down),    // Top-right
            (Position(row: mapSize - 2, col: 1), .up),      // Bottom-left
            (Position(row: 1, col: mapSize / 2), .down),    // Top-center
            (Position(row: mapSize - 2, col: mapSize / 2), .up)     // Bottom-center
        ]
        
        return Array(positions.prefix(playerCount))
    }
}
