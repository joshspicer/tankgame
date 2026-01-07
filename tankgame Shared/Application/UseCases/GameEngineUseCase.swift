//
//  GameEngineUseCase.swift
//  tankgame Shared
//
//  Clean Architecture - Application Layer
//

import Foundation

/// Core game engine that processes game ticks and updates state
final class GameEngineUseCase {
    
    private let collisionService: CollisionService
    private let gameRules: GameRulesService
    
    init(
        collisionService: CollisionService = CollisionService(),
        gameRules: GameRulesService = GameRulesService()
    ) {
        self.collisionService = collisionService
        self.gameRules = gameRules
    }
    
    /// Update game state for one tick
    func updateGameState(_ session: inout GameSessionEntity, deltaTime: TimeInterval) {
        guard session.state == .playing else { return }
        
        // Update projectiles
        updateProjectiles(&session)
        
        // Check collisions
        processCollisions(&session)
        
        // Check win condition
        if gameRules.isRoundOver(tanks: session.tanks) {
            session.endRound()
        }
    }
    
    /// Update all projectiles
    private func updateProjectiles(_ session: inout GameSessionEntity) {
        for i in 0..<session.projectiles.count {
            if session.projectiles[i].isActive {
                session.projectiles[i].advance()
            }
        }
    }
    
    /// Process all collisions
    private func processCollisions(_ session: inout GameSessionEntity) {
        // Check projectile-map collisions
        let mapCollisions = collisionService.findProjectileMapCollisions(
            projectiles: session.projectiles,
            map: session.map
        )
        
        for projectileID in mapCollisions {
            if let index = session.projectiles.firstIndex(where: { $0.id == projectileID }) {
                session.projectiles[index].deactivate()
            }
        }
        
        // Check projectile-tank collisions
        let tankCollisions = collisionService.findProjectileTankCollisions(
            projectiles: session.projectiles,
            tanks: session.tanks
        )
        
        for (projectileID, tankPlayerID) in tankCollisions {
            // Deactivate projectile
            if let pIndex = session.projectiles.firstIndex(where: { $0.id == projectileID }) {
                session.projectiles[pIndex].deactivate()
            }
            
            // Damage tank
            if let tIndex = session.tanks.firstIndex(where: { $0.playerID == tankPlayerID }) {
                session.tanks[tIndex].takeDamage()
            }
        }
        
        // Remove inactive projectiles
        session.projectiles.removeAll { !$0.isActive }
    }
}
