//
//  TankGameEngine.swift
//  tankgame Shared
//
//  Main implementation of the game engine
//

import Foundation

/// Main game engine implementation
final class TankGameEngine: GameEngine {
    private(set) var state: GameStateModel
    var eventHandler: ((GameEvent) -> Void)?
    
    private var projectileSpeed: TimeInterval = 0.15 // Seconds between projectile moves
    private var lastProjectileUpdate: TimeInterval = 0
    
    init(players: [PlayerInfo]) {
        // Start with an empty board
        let board = GameBoard(rows: 8, cols: 8)
        self.state = GameStateModel(board: board, players: players)
    }
    
    // MARK: - Round Management
    
    func startRound(seed: UInt32) {
        state.roundNumber += 1
        state.isRoundActive = true
        
        // Generate new board
        state.board = BoardGenerator.generateStandardBoard(seed: seed)
        
        // Create tanks for all players
        state.tanks = []
        for player in state.players {
            guard player.index < BoardGenerator.spawnPositions.count else { continue }
            
            let position = BoardGenerator.spawnPositions[player.index]
            let direction = BoardGenerator.spawnDirections[player.index]
            let tank = TankEntity(
                id: "tank_\(player.index)",
                playerIndex: player.index,
                position: position,
                direction: direction
            )
            state.tanks.append(tank)
        }
        
        // Clear projectiles
        state.projectiles = []
        
        eventHandler?(.roundStarted(roundNumber: state.roundNumber))
    }
    
    func endRound() {
        state.isRoundActive = false
        
        // Find winner (last tank standing)
        let aliveTanks = state.tanks.filter { $0.isAlive }
        let winnerIndex = aliveTanks.first?.playerIndex
        
        // Update scores
        if let winner = winnerIndex {
            if let playerIndex = state.players.firstIndex(where: { $0.index == winner }) {
                state.players[playerIndex].score += 1
            }
        }
        
        eventHandler?(.roundEnded(winnerIndex: winnerIndex))
    }
    
    // MARK: - Tank Actions
    
    func moveTank(playerIndex: Int, direction: Direction) -> Bool {
        guard state.isRoundActive else { return false }
        guard let tankIndex = state.tanks.firstIndex(where: { $0.playerIndex == playerIndex && $0.isAlive }) else {
            return false
        }
        
        let tank = state.tanks[tankIndex]
        let newPosition = tank.position.moved(in: direction)
        
        // Check if move is valid
        guard state.board.isValid(position: newPosition),
              state.board.isPassable(at: newPosition) else {
            return false
        }
        
        // Check for collision with other tanks
        if state.tanks.contains(where: { $0.position == newPosition && $0.isAlive && $0.playerIndex != playerIndex }) {
            return false
        }
        
        // Perform move
        let oldPosition = tank.position
        state.tanks[tankIndex].position = newPosition
        state.tanks[tankIndex].direction = direction
        
        eventHandler?(.tankMoved(playerIndex: playerIndex, from: oldPosition, to: newPosition))
        eventHandler?(.tankRotated(playerIndex: playerIndex, direction: direction))
        
        return true
    }
    
    func rotateTank(playerIndex: Int, direction: Direction) {
        guard state.isRoundActive else { return }
        guard let tankIndex = state.tanks.firstIndex(where: { $0.playerIndex == playerIndex && $0.isAlive }) else {
            return
        }
        
        state.tanks[tankIndex].direction = direction
        eventHandler?(.tankRotated(playerIndex: playerIndex, direction: direction))
    }
    
    func fireTank(playerIndex: Int) -> Bool {
        guard state.isRoundActive else { return false }
        guard let tankIndex = state.tanks.firstIndex(where: { $0.playerIndex == playerIndex && $0.isAlive }) else {
            return false
        }
        
        let tank = state.tanks[tankIndex]
        guard tank.canShoot else { return false }
        
        // Create projectile
        let projectile = tank.createProjectile()
        
        // Check if initial position is valid
        guard state.board.isValid(position: projectile.position) else {
            return false
        }
        
        state.projectiles.append(projectile)
        eventHandler?(.projectileFired(playerIndex: playerIndex, projectile: projectile))
        
        // Apply cooldown
        state.tanks[tankIndex].canShoot = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            if let idx = self.state.tanks.firstIndex(where: { $0.playerIndex == playerIndex }) {
                self.state.tanks[idx].canShoot = true
            }
        }
        
        return true
    }
    
    // MARK: - Update Loop
    
    func update(deltaTime: TimeInterval) {
        guard state.isRoundActive else { return }
        
        lastProjectileUpdate += deltaTime
        
        // Update projectiles at fixed intervals
        if lastProjectileUpdate >= projectileSpeed {
            lastProjectileUpdate = 0
            updateProjectiles()
        }
        
        // Check win condition
        checkWinCondition()
    }
    
    private func updateProjectiles() {
        var projectilesToRemove: Set<String> = []
        
        for i in 0..<state.projectiles.count {
            guard state.projectiles[i].isActive else { continue }
            
            let projectileId = state.projectiles[i].id
            
            // Move projectile
            state.projectiles[i].advance()
            let newPosition = state.projectiles[i].position
            
            // Check bounds
            if !state.board.isValid(position: newPosition) {
                state.projectiles[i].isActive = false
                projectilesToRemove.insert(projectileId)
                continue
            }
            
            // Check wall collision
            if let cellType = state.board.cellType(at: newPosition), cellType.blocksProjectiles {
                state.projectiles[i].isActive = false
                projectilesToRemove.insert(projectileId)
                eventHandler?(.projectileHitWall(projectileId: projectileId, position: newPosition))
                
                // Destroy destructible walls
                if state.board.destroyWallIfPossible(at: newPosition) {
                    eventHandler?(.wallDestroyed(position: newPosition))
                }
                continue
            }
            
            // Check tank collision
            if let hitTankIndex = state.tanks.firstIndex(where: { $0.position == newPosition && $0.isAlive }) {
                let hitPlayerIndex = state.tanks[hitTankIndex].playerIndex
                let shooterIndex = state.projectiles[i].ownerIndex
                
                // Don't allow self-hits
                if hitPlayerIndex != shooterIndex {
                    state.projectiles[i].isActive = false
                    projectilesToRemove.insert(projectileId)
                    state.tanks[hitTankIndex].isAlive = false
                    
                    eventHandler?(.projectileHitTank(projectileId: projectileId, tankPlayerIndex: hitPlayerIndex))
                    eventHandler?(.tankDestroyed(playerIndex: hitPlayerIndex))
                }
                continue
            }
            
            eventHandler?(.projectileMoved(projectileId: projectileId, to: newPosition))
        }
        
        // Remove inactive projectiles
        state.projectiles.removeAll { projectilesToRemove.contains($0.id) }
    }
    
    private func checkWinCondition() {
        let aliveTankCount = state.tanks.filter { $0.isAlive }.count
        
        // Round ends when 0 or 1 tank remains
        if aliveTankCount <= 1 {
            endRound()
        }
    }
}
