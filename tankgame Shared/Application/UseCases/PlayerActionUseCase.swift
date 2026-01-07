//
//  PlayerActionUseCase.swift
//  tankgame Shared
//
//  Clean Architecture - Application Layer
//

import Foundation

/// Use case for handling player actions
final class PlayerActionUseCase {
    
    private let collisionService: CollisionService
    
    init(collisionService: CollisionService = CollisionService()) {
        self.collisionService = collisionService
    }
    
    /// Move player tank in a direction
    func moveTank(
        playerID: PlayerID,
        direction: Direction,
        in session: inout GameSessionEntity
    ) -> Bool {
        guard session.state == .playing else { return false }
        guard let tankIndex = session.tanks.firstIndex(where: { $0.playerID == playerID }) else {
            return false
        }
        
        var tank = session.tanks[tankIndex]
        guard tank.isAlive else { return false }
        
        // Update direction
        tank.turn(to: direction)
        
        // Calculate new position
        let newPosition = tank.position.moved(in: direction)
        
        // Check if move is valid
        guard collisionService.canTankMoveTo(newPosition, in: session.map, avoiding: session.tanks) else {
            // Update direction only
            session.tanks[tankIndex] = tank
            return false
        }
        
        // Apply movement
        tank.moveForward()
        session.tanks[tankIndex] = tank
        
        return true
    }
    
    /// Fire projectile from player tank
    func fireTank(
        playerID: PlayerID,
        currentTime: TimeInterval,
        in session: inout GameSessionEntity
    ) -> Bool {
        guard session.state == .playing else { return false }
        guard let tankIndex = session.tanks.firstIndex(where: { $0.playerID == playerID }) else {
            return false
        }
        
        var tank = session.tanks[tankIndex]
        guard tank.isAlive else { return false }
        guard tank.canFire(currentTime: currentTime) else { return false }
        
        // Create projectile
        let projectilePosition = tank.position.moved(in: tank.direction)
        let projectile = ProjectileEntity(
            ownerID: playerID,
            position: projectilePosition,
            direction: tank.direction
        )
        
        session.projectiles.append(projectile)
        
        // Update fire time
        tank.didFire(at: currentTime)
        session.tanks[tankIndex] = tank
        
        return true
    }
    
    /// Rotate tank (change direction without moving)
    func rotateTank(
        playerID: PlayerID,
        direction: Direction,
        in session: inout GameSessionEntity
    ) -> Bool {
        guard session.state == .playing else { return false }
        guard let tankIndex = session.tanks.firstIndex(where: { $0.playerID == playerID }) else {
            return false
        }
        
        var tank = session.tanks[tankIndex]
        guard tank.isAlive else { return false }
        
        tank.turn(to: direction)
        session.tanks[tankIndex] = tank
        
        return true
    }
}
