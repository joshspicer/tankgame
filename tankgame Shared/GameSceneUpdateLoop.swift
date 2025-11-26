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
        if currentTime - lastUpdateTime > 0.05 { // ~20 FPS for projectile updates
            updateProjectiles(state: state)
            lastUpdateTime = currentTime
        }
        
        // Update dinosaur AI movement (slower pace)
        if currentTime - lastDinosaurMoveTime > 0.5 { // Move dinosaur every 0.5 seconds
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
        let dinosaurWasAlive = state.dinosaurs.map { $0.isAlive }
        let dinosaurPositions = state.dinosaurs.map { scene.renderer.gridPosition(row: $0.row, col: $0.col) }
        
        state.updateProjectiles()
        scene.renderProjectiles()
        
        // Check which tanks were hit and trigger explosions
        for i in 0..<state.tanks.count {
            if wasAlive[i] && !state.tanks[i].isAlive {
                triggerTankExplosion(tankIndex: i, position: tankPositions[i])
            }
        }
        
        // Check which dinosaurs were hit and trigger explosions
        for i in 0..<state.dinosaurs.count {
            if dinosaurWasAlive[i] && !state.dinosaurs[i].isAlive {
                triggerDinosaurExplosion(dinosaurIndex: i, position: dinosaurPositions[i])
            }
        }
        
        // Check if round ended after update
        if state.isRoundOver() {
            handleRoundEnd()
        }
    }
    
    private func updateDinosaurs(state: GameState) {
        guard let scene = scene else { return }
        
        state.updateDinosaurs()
        scene.renderDinosaursWithSmoothing()
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
        guard let scene = scene else { return }
        guard dinosaurIndex < scene.dinosaurNodes.count, let dinosaurNode = scene.dinosaurNodes[dinosaurIndex] else { return }
        
        scene.soundManager.playSound("hit.wav")
        let color = SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0) // Dinosaur green color
        scene.explosionEffects.createExplosion(at: position, color: color, in: dinosaurNode) { [weak scene] in
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
