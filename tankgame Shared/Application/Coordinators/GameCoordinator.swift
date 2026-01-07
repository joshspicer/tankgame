//
//  GameCoordinator.swift
//  tankgame Shared
//
//  Clean Architecture - Application Layer
//

import Foundation

/// Coordinates the overall game flow
final class GameCoordinator {
    
    // Use cases
    private let createSessionUseCase: CreateGameSessionUseCase
    private let gameEngineUseCase: GameEngineUseCase
    private let playerActionUseCase: PlayerActionUseCase
    
    // Services
    private let gameRules: GameRulesService
    
    // Network
    private var networkAdapter: NetworkAdapter?
    
    // State
    private(set) var session: GameSessionEntity?
    var onSessionUpdated: ((GameSessionEntity) -> Void)?
    var onRoundEnd: ((PlayerEntity?) -> Void)?
    var onGameOver: ((PlayerEntity) -> Void)?
    
    private var lastUpdateTime: TimeInterval = 0
    private let updateInterval: TimeInterval = 1.0 / 60.0 // 60 FPS
    
    init(
        createSessionUseCase: CreateGameSessionUseCase = CreateGameSessionUseCase(),
        gameEngineUseCase: GameEngineUseCase = GameEngineUseCase(),
        playerActionUseCase: PlayerActionUseCase = PlayerActionUseCase(),
        gameRules: GameRulesService = GameRulesService()
    ) {
        self.createSessionUseCase = createSessionUseCase
        self.gameEngineUseCase = gameEngineUseCase
        self.playerActionUseCase = playerActionUseCase
        self.gameRules = gameRules
    }
    
    // MARK: - Session Management
    
    func createSession(players: [PlayerEntity], localPlayerID: PlayerID) -> Result<Void, GameSessionError> {
        let result = createSessionUseCase.execute(
            players: players,
            localPlayerID: localPlayerID
        )
        
        switch result {
        case .success(let session):
            self.session = session
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func startRound() -> Result<Void, GameSessionError> {
        guard var session = session else {
            return .failure(.sessionNotReady)
        }
        
        let result = createSessionUseCase.startNewRound(in: &session)
        self.session = session
        return result
    }
    
    // MARK: - Game Loop
    
    func update(currentTime: TimeInterval) {
        guard var session = session else { return }
        guard session.state == .playing else { return }
        
        // Throttle updates
        if currentTime - lastUpdateTime < updateInterval {
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update game state
        gameEngineUseCase.updateGameState(&session, deltaTime: deltaTime)
        
        // Check if round ended
        if session.state == .roundEnd {
            let winner = session.getRoundWinner()
            onRoundEnd?(winner)
            
            // Check if game is over
            if gameRules.isGameOver(players: session.players) {
                if let gameWinner = gameRules.getGameWinner(players: session.players) {
                    onGameOver?(gameWinner)
                }
            }
        }
        
        self.session = session
        onSessionUpdated?(session)
    }
    
    // MARK: - Player Actions
    
    func movePlayer(direction: Direction) -> Bool {
        guard var session = session else { return false }
        
        let success = playerActionUseCase.moveTank(
            playerID: session.localPlayerID,
            direction: direction,
            in: &session
        )
        
        if success {
            self.session = session
            onSessionUpdated?(session)
            
            // Send to network if multiplayer
            if let adapter = networkAdapter {
                let message = NetworkMessage.playerMove(
                    playerID: session.localPlayerID,
                    direction: direction,
                    timestamp: Date().timeIntervalSince1970
                )
                try? adapter.broadcast(message)
            }
        }
        
        return success
    }
    
    func fireWeapon(currentTime: TimeInterval) -> Bool {
        guard var session = session else { return false }
        
        let success = playerActionUseCase.fireTank(
            playerID: session.localPlayerID,
            currentTime: currentTime,
            in: &session
        )
        
        if success {
            self.session = session
            onSessionUpdated?(session)
            
            // Send to network if multiplayer
            if let adapter = networkAdapter {
                let message = NetworkMessage.playerFire(
                    playerID: session.localPlayerID,
                    timestamp: currentTime
                )
                try? adapter.broadcast(message)
            }
        }
        
        return success
    }
    
    // MARK: - Networking
    
    func setNetworkAdapter(_ adapter: NetworkAdapter) {
        self.networkAdapter = adapter
    }
}
