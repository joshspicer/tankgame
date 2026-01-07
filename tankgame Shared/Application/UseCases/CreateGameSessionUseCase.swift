//
//  CreateGameSessionUseCase.swift
//  tankgame Shared
//
//  Clean Architecture - Application Layer
//

import Foundation

/// Use case for creating a new game session
final class CreateGameSessionUseCase {
    
    private let mapGenerator: MapGeneratorService
    private let gameRules: GameRulesService
    
    init(
        mapGenerator: MapGeneratorService = MapGeneratorService(),
        gameRules: GameRulesService = GameRulesService()
    ) {
        self.mapGenerator = mapGenerator
        self.gameRules = gameRules
    }
    
    /// Create a new game session
    func execute(
        players: [PlayerEntity],
        localPlayerID: PlayerID,
        mapSize: Int = 10,
        seed: UInt32? = nil
    ) -> Result<GameSessionEntity, GameSessionError> {
        // Validate player count
        guard gameRules.isValidPlayerCount(players.count) else {
            return .failure(.invalidPlayerCount(players.count))
        }
        
        // Generate map
        let mapSeed = seed ?? UInt32.random(in: 0...UInt32.max)
        let map = mapGenerator.generateMap(size: mapSize, seed: mapSeed)
        
        // Create session
        var session = GameSessionEntity(
            map: map,
            players: players,
            localPlayerID: localPlayerID
        )
        
        // Create tanks for each player
        let spawnPositions = gameRules.getSpawnPositions(for: players.count, mapSize: mapSize)
        for (index, player) in players.enumerated() {
            let spawn = spawnPositions[index]
            let tank = TankEntity(
                playerID: player.id,
                position: spawn.0,
                direction: spawn.1
            )
            session.tanks.append(tank)
        }
        
        return .success(session)
    }
    
    /// Start a new round in existing session
    func startNewRound(
        in session: inout GameSessionEntity,
        seed: UInt32? = nil
    ) -> Result<Void, GameSessionError> {
        let mapSeed = seed ?? UInt32.random(in: 0...UInt32.max)
        let newMap = mapGenerator.generateMap(size: session.map.size, seed: mapSeed)
        session.map = newMap
        
        let spawnPositions = gameRules.getSpawnPositions(for: session.players.count, mapSize: session.map.size)
        session.startRound(spawnPositions: spawnPositions)
        
        return .success(())
    }
}

/// Errors that can occur during game session creation
enum GameSessionError: Error, LocalizedError {
    case invalidPlayerCount(Int)
    case playerNotFound
    case sessionNotReady
    
    var errorDescription: String? {
        switch self {
        case .invalidPlayerCount(let count):
            return "Invalid player count: \(count). Must be between 2 and 6 players."
        case .playerNotFound:
            return "Player not found in session."
        case .sessionNotReady:
            return "Session is not ready to start."
        }
    }
}
