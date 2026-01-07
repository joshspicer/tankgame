//
//  GameSessionEntity.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Represents a complete game session with all state
struct GameSessionEntity: Codable {
    let id: UUID
    var map: GameMapEntity
    var tanks: [TankEntity]
    var projectiles: [ProjectileEntity]
    var players: [PlayerEntity]
    var state: GameState
    var currentRound: Int
    let localPlayerID: PlayerID
    
    enum GameState: String, Codable {
        case lobby
        case starting
        case playing
        case roundEnd
        case gameOver
    }
    
    init(
        id: UUID = UUID(),
        map: GameMapEntity,
        players: [PlayerEntity],
        localPlayerID: PlayerID
    ) {
        self.id = id
        self.map = map
        self.players = players
        self.localPlayerID = localPlayerID
        self.state = .lobby
        self.currentRound = 0
        
        // Initialize tanks for each player
        self.tanks = []
        self.projectiles = []
    }
    
    /// Get local player
    var localPlayer: PlayerEntity? {
        players.first { $0.id == localPlayerID }
    }
    
    /// Get local tank
    var localTank: TankEntity? {
        tanks.first { $0.playerID == localPlayerID }
    }
    
    /// Get tank for player
    func tank(for playerID: PlayerID) -> TankEntity? {
        tanks.first { $0.playerID == playerID }
    }
    
    /// Get active projectiles
    var activeProjectiles: [ProjectileEntity] {
        projectiles.filter { $0.isActive }
    }
    
    /// Get alive tanks
    var aliveTanks: [TankEntity] {
        tanks.filter { $0.isAlive }
    }
    
    /// Check if round is over
    func isRoundOver() -> Bool {
        return aliveTanks.count <= 1
    }
    
    /// Get winner if round is over
    func getRoundWinner() -> PlayerEntity? {
        guard isRoundOver(), let winningTank = aliveTanks.first else { return nil }
        return players.first { $0.id == winningTank.playerID }
    }
    
    /// Start new round
    mutating func startRound(spawnPositions: [(Position, Direction)]) {
        currentRound += 1
        state = .playing
        projectiles.removeAll()
        
        // Reset tanks to spawn positions
        for (index, tank) in tanks.enumerated() {
            let spawn = spawnPositions[index % spawnPositions.count]
            tanks[index].reset(at: spawn.0, direction: spawn.1)
        }
    }
    
    /// End current round
    mutating func endRound() {
        state = .roundEnd
        if let winner = getRoundWinner() {
            if let index = players.firstIndex(where: { $0.id == winner.id }) {
                players[index].addScore()
            }
        }
    }
}
