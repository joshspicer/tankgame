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
    var lastLizardUpdateTime: TimeInterval = 0
    var lastAIBotUpdateTime: TimeInterval = 0
    
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
        
        // Update lizards (less frequently for smoother movement)
        if currentTime - lastLizardUpdateTime > 0.1 { // ~10 FPS for lizard updates
            updateLizards(state: state)
            lastLizardUpdateTime = currentTime
        }
        
        // Update AI bots
        if currentTime - lastAIBotUpdateTime > 0.05 { // ~20 FPS for AI bot updates
            updateAIBots(state: state)
            lastAIBotUpdateTime = currentTime
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
        
        // Save lizard alive state before update
        let lizardWasAlive = state.lizards.map { $0.isAlive }
        let lizardPositions = state.lizards.map { scene.renderer.gridPosition(row: $0.row, col: $0.col) }
        
        state.updateProjectiles()
        scene.renderProjectiles()
        
        // Check which tanks were hit and trigger explosions
        for i in 0..<state.tanks.count {
            if wasAlive[i] && !state.tanks[i].isAlive {
                triggerTankExplosion(tankIndex: i, position: tankPositions[i])
            }
        }
        
        // Check which lizards were hit and trigger explosions
        for i in 0..<state.lizards.count {
            if lizardWasAlive[i] && !state.lizards[i].isAlive {
                triggerLizardExplosion(position: lizardPositions[i])
            }
        }
        
        // Re-render lizards if any were destroyed
        if lizardWasAlive != state.lizards.map({ $0.isAlive }) {
            scene.renderLizards()
        }
        
        // Check if round ended after update
        if state.isRoundOver() {
            handleRoundEnd()
        }
    }
    
    private func updateLizards(state: GameState) {
        guard let scene = scene else { return }
        
        // Update lizard AI
        state.updateLizards()
        
        // Render lizards with smooth animation
        scene.renderLizardsWithSmoothing()
    }
    
    private func updateAIBots(state: GameState) {
        guard let scene = scene else { return }
        
        // Update AI bots
        state.updateAIBots()
        
        // Render tanks with smooth animation if any bots moved
        if state.aiBotManager.isEnabled {
            scene.renderTanksWithSmoothing()
            scene.renderProjectiles()
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
    
    private func triggerLizardExplosion(position: CGPoint) {
        guard let scene = scene, let lizardNode = scene.lizardNode else { return }
        
        scene.soundManager.playSound("hit.wav")
        let color = SKColor.systemGreen
        scene.explosionEffects.createExplosion(at: position, color: color, in: lizardNode) { }
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
