//
//  GameSceneUpdateLoop.swift
//  tankgame Shared
//
//  Game update loop logic extracted from GameScene
//

import SpriteKit

/// Handles the game update loop including movement and projectile updates
class GameSceneUpdateLoop {
    weak var scene: GameScene?
    
    // Update timing constants
    private static let projectileUpdateInterval: TimeInterval = 0.05 // ~20 FPS for projectile updates
    private static let dinosaurMoveInterval: TimeInterval = 0.4 // Dinosaurs move every 0.4 seconds
    
    var lastUpdateTime: TimeInterval = 0
    var lastMoveTime: TimeInterval = 0
    var lastDinosaurMoveTime: TimeInterval = 0
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func update(_ currentTime: TimeInterval) {
        guard let scene = scene, let state = scene.gameState else { return }
        
        // Handle continuous movement from joystick
        handleJoystickMovement(currentTime, state: state)
        
        // Don't update if round is over or any explosion in progress
        if state.isRoundOver() || scene.tankExploding.contains(true) {
            return
        }
        
        // Update projectiles
        if currentTime - lastUpdateTime > Self.projectileUpdateInterval {
            updateProjectiles(state: state)
            lastUpdateTime = currentTime
        }
        
        // Update dinosaur AI movement (slower than projectiles)
        if currentTime - lastDinosaurMoveTime > Self.dinosaurMoveInterval {
            updateDinosaurs(state: state)
            lastDinosaurMoveTime = currentTime
        }
    }
    
    private func handleJoystickMovement(_ currentTime: TimeInterval, state: GameState) {
        guard let scene = scene else { return }
        
        if let direction = scene.joystickController.currentDirection, !state.isRoundOver() {
            // Diagonal movement is slightly slower to maintain game balance
            let moveInterval = direction.isDiagonal ? 0.15 : 0.10
            
            if currentTime - lastMoveTime > moveInterval {
                if state.localTank.move(in: direction, grid: state.grid) {
                    scene.renderTanksWithSmoothing()
                    scene.soundManager.playSound("move.wav")
                    lastMoveTime = currentTime
                    
                    // Send position update
                    let localIndex = state.localPlayerIndex
                    scene.onGameMessage?(.playerMove(playerIndex: localIndex, row: state.localTank.row, col: state.localTank.col, direction: state.localTank.direction))
                }
            }
        }
    }
    
    private func updateProjectiles(state: GameState) {
        guard let scene = scene else { return }
        
        // Save tank alive state before update
        let wasAlive = state.tanks.map { $0.isAlive }
        let tankPositions = state.tanks.map { scene.renderer.gridPosition(row: $0.row, col: $0.col) }
        
        // Save dinosaur alive state before update
        let dinosaursWereAlive = state.dinosaurs.map { $0.isAlive }
        let dinosaurPositions = state.dinosaurs.map { scene.renderer.dinosaurPosition(row: $0.row, col: $0.col) }
        
        let hitDinosaurIndices = state.updateProjectiles()
        scene.renderProjectiles()
        
        // Check which tanks were hit and trigger explosions
        for i in 0..<state.tanks.count {
            if wasAlive[i] && !state.tanks[i].isAlive {
                triggerTankExplosion(tankIndex: i, position: tankPositions[i])
            }
        }
        
        // Check which dinosaurs were hit and trigger explosions
        for i in hitDinosaurIndices {
            if dinosaursWereAlive[i] && !state.dinosaurs[i].isAlive {
                triggerDinosaurExplosion(dinosaurIndex: i, position: dinosaurPositions[i])
            }
        }
        
        // Re-render dinosaurs if any were hit
        if !hitDinosaurIndices.isEmpty {
            scene.renderDinosaurs()
        }
        
        // Check if round ended after update
        if state.isRoundOver() {
            handleRoundEnd()
        }
    }
    
    private func updateDinosaurs(state: GameState) {
        guard let scene = scene else { return }
        
        // Save tank alive state before dinosaur collision check
        let wasAlive = state.tanks.map { $0.isAlive }
        let tankPositions = state.tanks.map { scene.renderer.gridPosition(row: $0.row, col: $0.col) }
        
        // Move dinosaurs
        state.updateDinosaurs()
        scene.renderDinosaursWithSmoothing()
        
        // Check for dinosaur-tank collisions
        let hitTankIndices = state.checkDinosaurTankCollisions()
        
        // Trigger explosions for tanks hit by dinosaurs
        for i in hitTankIndices {
            if wasAlive[i] && !state.tanks[i].isAlive {
                triggerTankExplosion(tankIndex: i, position: tankPositions[i])
            }
        }
        
        // Check if round ended after dinosaur collision
        if state.isRoundOver() {
            handleRoundEnd()
        }
    }
    
    private func triggerTankExplosion(tankIndex: Int, position: CGPoint) {
        guard let scene = scene, let tankNode = scene.tankNodes[tankIndex] else { return }
        
        scene.soundManager.playSound("hit.wav")
        let color = scene.renderer.tankColors[tankIndex]
        scene.explosionEffects.createExplosion(at: position, color: color, in: tankNode) { [weak scene] in
            scene?.tankExploding[tankIndex] = false
        }
        scene.tankExploding[tankIndex] = true
    }
    
    private func triggerDinosaurExplosion(dinosaurIndex: Int, position: CGPoint) {
        guard let scene = scene, let dinoNode = scene.dinosaurNode else { return }
        
        scene.soundManager.playSound("hit.wav")
        // Use green color for dinosaur explosions
        scene.explosionEffects.createExplosion(at: position, color: .systemGreen, in: dinoNode) { [weak scene] in
            if dinosaurIndex < scene?.dinosaurExploding.count ?? 0 {
                scene?.dinosaurExploding[dinosaurIndex] = false
            }
        }
        if dinosaurIndex < scene.dinosaurExploding.count {
            scene.dinosaurExploding[dinosaurIndex] = true
        }
    }
    
    private func handleRoundEnd() {
        guard let scene = scene, let state = scene.gameState else { return }
        let winner = state.getWinner()
        
        // Wait for explosion to complete before showing round end
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak scene] in
            guard let scene = scene, let state = scene.gameState else { return }
            
            // Update score and play win/lose sound
            if let winner = winner {
                state.wins[winner] += 1
                if winner == state.localPlayerIndex {
                    scene.soundManager.playSound("win.wav")
                } else {
                    scene.soundManager.playSound("lose.wav")
                }
            }
            
            // Remove tank nodes now that explosion is done
            scene.renderTanks()
            scene.renderDinosaurs()
            scene.showRoundEnd(winner: winner)
            scene.updateScore()
            
            // Notify that round ended after a longer delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak scene] in
                guard let state = scene?.gameState else { return }
                scene?.onGameMessage?(.readyForNextRound(playerIndex: state.localPlayerIndex))
            }
        }
    }
}
