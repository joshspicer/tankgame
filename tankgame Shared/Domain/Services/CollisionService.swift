//
//  CollisionService.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Service for detecting collisions between game entities
struct CollisionService {
    
    /// Check if projectile collides with a tank
    func projectileHitsTank(_ projectile: ProjectileEntity, _ tank: TankEntity) -> Bool {
        guard tank.isAlive && projectile.isActive else { return false }
        return projectile.position == tank.position
    }
    
    /// Check if projectile hits the map (wall)
    func projectileHitsMap(_ projectile: ProjectileEntity, _ map: GameMapEntity) -> Bool {
        guard projectile.isActive else { return false }
        
        // Check if out of bounds
        if !projectile.position.isValid(gridSize: map.size) {
            return true
        }
        
        // Check if hits wall
        return map.blocksProjectiles(at: projectile.position)
    }
    
    /// Check if tank can move to position
    func canTankMoveTo(_ position: Position, in map: GameMapEntity, avoiding tanks: [TankEntity]) -> Bool {
        // Check bounds
        guard position.isValid(gridSize: map.size) else {
            return false
        }
        
        // Check if map cell is passable
        guard map.isPassable(at: position) else {
            return false
        }
        
        // Check if another tank is in the way
        for tank in tanks where tank.isAlive {
            if tank.position == position {
                return false
            }
        }
        
        return true
    }
    
    /// Find all collisions between projectiles and tanks
    func findProjectileTankCollisions(
        projectiles: [ProjectileEntity],
        tanks: [TankEntity]
    ) -> [(projectileID: UUID, tankPlayerID: PlayerID)] {
        var collisions: [(UUID, PlayerID)] = []
        
        for projectile in projectiles where projectile.isActive {
            for tank in tanks where tank.isAlive {
                if projectileHitsTank(projectile, tank) {
                    collisions.append((projectile.id, tank.playerID))
                }
            }
        }
        
        return collisions
    }
    
    /// Find all projectiles that hit the map
    func findProjectileMapCollisions(
        projectiles: [ProjectileEntity],
        map: GameMapEntity
    ) -> [UUID] {
        return projectiles
            .filter { $0.isActive && projectileHitsMap($0, map) }
            .map { $0.id }
    }
}
