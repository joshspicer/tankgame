//
//  ExplosionHandler.swift
//  tankgame Shared
//
//  Handles triggering and managing explosions in the game
//

import SpriteKit

/// Handles explosion triggering and animation for tanks and lizards
class ExplosionHandler {
    weak var scene: GameScene?
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    /// Trigger an explosion for a tank at the specified position
    /// - Parameters:
    ///   - tankIndex: Index of the tank being destroyed
    ///   - position: Position for the explosion
    func triggerTankExplosion(tankIndex: Int, position: CGPoint) {
        guard let scene = scene, let tankNode = scene.tankNodes[tankIndex] else { return }
        
        scene.soundManager.playSound("hit.wav")
        let color = scene.renderer.tankColors[tankIndex]
        scene.explosionEffects.createExplosion(at: position, color: color, in: tankNode) { [weak scene] in
            scene?.tankExploding[tankIndex] = false
        }
        scene.tankExploding[tankIndex] = true
    }
    
    /// Trigger an explosion for a lizard at the specified position
    /// - Parameter position: Position for the explosion
    func triggerLizardExplosion(position: CGPoint) {
        guard let scene = scene, let lizardNode = scene.lizardNode else { return }
        
        scene.soundManager.playSound("hit.wav")
        let color = SKColor.systemGreen
        scene.explosionEffects.createExplosion(at: position, color: color, in: lizardNode) { }
    }
    
    /// Check for destroyed tanks and trigger explosions
    /// - Parameters:
    ///   - wasAlive: Previous alive state for each tank
    ///   - tanks: Current tank states
    ///   - tankPositions: Positions where explosions should occur
    func checkAndTriggerTankExplosions(wasAlive: [Bool], tanks: [Tank], tankPositions: [CGPoint]) {
        for i in 0..<tanks.count {
            if wasAlive[i] && !tanks[i].isAlive {
                triggerTankExplosion(tankIndex: i, position: tankPositions[i])
            }
        }
    }
    
    /// Check for destroyed lizards and trigger explosions
    /// - Parameters:
    ///   - wasAlive: Previous alive state for each lizard
    ///   - lizards: Current lizard states
    ///   - lizardPositions: Positions where explosions should occur
    func checkAndTriggerLizardExplosions(wasAlive: [Bool], lizards: [Lizard], lizardPositions: [CGPoint]) {
        for i in 0..<lizards.count {
            if wasAlive[i] && !lizards[i].isAlive {
                triggerLizardExplosion(position: lizardPositions[i])
            }
        }
    }
}
