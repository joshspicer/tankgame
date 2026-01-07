//
//  GameCoordinator.swift
//  tankgame Shared
//
//  Coordinates game logic and network communication
//

import Foundation

/// Coordinates the game engine with network communication
final class GameCoordinator {
    
    // Dependencies
    private let engine: GameEngine
    private let networkManager: NetworkManager
    
    // State
    private var localPlayerIndex: Int?
    private var isHost: Bool = false
    
    // Callbacks
    var onStateChanged: ((GameStateModel) -> Void)?
    var onEventOccurred: ((GameEvent) -> Void)?
    
    init(engine: GameEngine, networkManager: NetworkManager) {
        self.engine = engine
        self.networkManager = networkManager
        
        // Setup engine event handler
        engine.eventHandler = { [weak self] event in
            self?.handleGameEvent(event)
        }
    }
    
    // MARK: - Game Control
    
    func startGame(asHost: Bool, playerInfo: PlayerInfo, maxPlayers: Int = 4) {
        self.isHost = asHost
        self.localPlayerIndex = playerInfo.index
        
        if asHost {
            networkManager.startHosting(playerName: playerInfo.name, maxPlayers: maxPlayers)
        } else {
            networkManager.startBrowsing(playerName: playerInfo.name)
        }
    }
    
    func startRound(seed: UInt32) {
        guard isHost else { return }
        
        engine.startRound(seed: seed)
        
        // Notify all players
        let players = engine.state.players
        networkManager.sendMessageToAll(.gameStarting(players: players, seed: seed), reliably: true)
    }
    
    func endGame() {
        networkManager.disconnect()
    }
    
    // MARK: - Player Actions
    
    func moveTank(direction: Direction) {
        guard let playerIndex = localPlayerIndex else { return }
        
        if engine.moveTank(playerIndex: playerIndex, direction: direction) {
            // Broadcast move
            networkManager.sendMessageToAll(
                .tankAction(playerIndex: playerIndex, action: .move(direction: direction)),
                reliably: false
            )
        }
    }
    
    func rotateTank(direction: Direction) {
        guard let playerIndex = localPlayerIndex else { return }
        
        engine.rotateTank(playerIndex: playerIndex, direction: direction)
        
        // Broadcast rotation
        networkManager.sendMessageToAll(
            .tankAction(playerIndex: playerIndex, action: .rotate(direction: direction)),
            reliably: false
        )
    }
    
    func fireTank() {
        guard let playerIndex = localPlayerIndex else { return }
        
        if engine.fireTank(playerIndex: playerIndex) {
            // Broadcast fire action
            networkManager.sendMessageToAll(
                .tankAction(playerIndex: playerIndex, action: .fire),
                reliably: true
            )
        }
    }
    
    func update(deltaTime: TimeInterval) {
        engine.update(deltaTime: deltaTime)
        onStateChanged?(engine.state)
    }
    
    // MARK: - Event Handling
    
    private func handleGameEvent(_ event: GameEvent) {
        onEventOccurred?(event)
        
        // Broadcast events to other players (host only)
        guard isHost else { return }
        
        let message: NetworkMessage?
        switch event {
        case .tankMoved(let playerIndex, _, let to):
            if let tank = engine.state.tank(forPlayerIndex: playerIndex) {
                message = .gameEvent(event: .tankMoved(playerIndex: playerIndex, position: to, direction: tank.direction))
            } else {
                message = nil
            }
            
        case .tankRotated(let playerIndex, let direction):
            message = .gameEvent(event: .tankRotated(playerIndex: playerIndex, direction: direction))
            
        case .projectileFired(let playerIndex, let projectile):
            message = .gameEvent(event: .projectileFired(
                playerIndex: playerIndex,
                projectileId: projectile.id,
                position: projectile.position,
                direction: projectile.direction
            ))
            
        case .projectileHitWall(let projectileId, let position),
             .projectileHitTank(let projectileId, _):
            message = .gameEvent(event: .projectileHit(projectileId: projectileId, position: position))
            
        case .tankDestroyed(let playerIndex):
            message = .gameEvent(event: .tankDestroyed(playerIndex: playerIndex))
            
        case .wallDestroyed(let position):
            message = .gameEvent(event: .wallDestroyed(position: position))
            
        case .roundEnded(let winnerIndex):
            let scores = engine.state.players.map { $0.score }
            message = .roundEnded(winnerIndex: winnerIndex, scores: scores)
            
        default:
            message = nil
        }
        
        if let message = message {
            networkManager.sendMessageToAll(message, reliably: true)
        }
    }
    
    // MARK: - Network Message Handling
    
    func handleNetworkMessage(_ message: NetworkMessage, from playerId: String) {
        switch message {
        case .playerJoined(let playerId, let playerName):
            print("Player joined: \(playerName)")
            
        case .playerLeft(let playerId):
            print("Player left: \(playerId)")
            
        case .gameStarting(let players, let seed):
            // Non-host players receive game start
            if !isHost {
                // Update local player index
                if let localId = networkManager.localPlayerId,
                   let player = players.first(where: { $0.id == localId }) {
                    localPlayerIndex = player.index
                }
                engine.startRound(seed: seed)
            }
            
        case .tankAction(let playerIndex, let action):
            // Apply actions from other players
            guard playerIndex != localPlayerIndex else { return }
            
            switch action {
            case .move(let direction):
                _ = engine.moveTank(playerIndex: playerIndex, direction: direction)
            case .rotate(let direction):
                engine.rotateTank(playerIndex: playerIndex, direction: direction)
            case .fire:
                _ = engine.fireTank(playerIndex: playerIndex)
            }
            
        case .gameEvent(let eventData):
            // Non-host players receive authoritative events
            guard !isHost else { return }
            handleGameEventData(eventData)
            
        case .roundEnded(let winnerIndex, let scores):
            print("Round ended. Winner: \(winnerIndex?.description ?? "None")")
        }
    }
    
    private func handleGameEventData(_ eventData: NetworkMessage.GameEventData) {
        // Apply authoritative updates from host
        // This ensures clients stay in sync with host
        
        switch eventData {
        case .tankMoved(let playerIndex, let position, let direction):
            if let tankIndex = engine.state.tanks.firstIndex(where: { $0.playerIndex == playerIndex }) {
                var tank = engine.state.tanks[tankIndex]
                tank.position = position
                tank.direction = direction
                // Direct state update for client sync
            }
            
        default:
            break
        }
    }
}
