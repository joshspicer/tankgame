//
//  GameScene.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit
#if os(iOS)
import UIKit
#endif

/// Main game scene that coordinates all game elements
class GameScene: SKScene {
    
    // Game state
    var gameState: GameState?
    var onGameMessage: ((GameMessage) -> Void)?
    
    // Constants
    let tileSize: CGFloat = 64
    let gridSize = 8
    
    // Nodes
    var gridNode: SKNode?
    var tankNodes: [SKNode?] = [nil, nil, nil, nil] // Support up to 4 tanks
    var projectilesNode: SKNode?
    var powerUpsNode: SKNode?
    
    // Components
    private var renderer: GameSceneRenderer!
    private var soundManager: SoundManager!
    private var explosionEffects: ExplosionEffects!
    private var joystickController: JoystickController!
    private var fireButton: FireButton!
    private var ui: GameSceneUI!
    
    // Update timer
    var lastUpdateTime: TimeInterval = 0
    var lastMoveTime: TimeInterval = 0
    var lastPowerUpCheck: TimeInterval = 0
    var lastFireTime: TimeInterval = 0
    
    // Explosion state
    var tankExploding: [Bool] = [false, false, false, false]
    
    class func newGameScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 600, height: 800))
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        setupComponents()
        setupScene()
        
        // If startGame was called before didMove (e.g., for clients receiving roundStart),
        // render the grid now that the scene has been set up
        if gameState != nil {
            renderGrid()
            renderTanks()
            renderProjectiles()
            renderPowerUps()
            updateScore()
        }
    }
    
    private func setupComponents() {
        renderer = GameSceneRenderer(tileSize: tileSize, gridSize: gridSize)
        soundManager = SoundManager(scene: self)
        explosionEffects = ExplosionEffects(tileSize: tileSize)
        joystickController = JoystickController()
        fireButton = FireButton()
        ui = GameSceneUI()
    }
    
    func setupScene() {
        // Create grid container (centered)
        let newGridNode = SKNode()
        let gridOffset = CGPoint(
            x: (size.width - CGFloat(gridSize) * tileSize) / 2,
            y: (size.height - CGFloat(gridSize) * tileSize) / 2 + 50
        )
        newGridNode.position = gridOffset
        addChild(newGridNode)
        gridNode = newGridNode
        
        // Create projectiles container
        let newProjectilesNode = SKNode()
        newProjectilesNode.position = gridOffset
        addChild(newProjectilesNode)
        projectilesNode = newProjectilesNode
        
        // Create power-ups container
        let newPowerUpsNode = SKNode()
        newPowerUpsNode.position = gridOffset
        addChild(newPowerUpsNode)
        powerUpsNode = newPowerUpsNode
        
        // Create tank nodes for all possible players
        for i in 0..<4 {
            let tankNode = SKNode()
            tankNode.position = gridOffset
            addChild(tankNode)
            tankNodes[i] = tankNode
        }
        
        // Setup components
        joystickController.setup(in: self, at: CGPoint(x: 80, y: 100))
        fireButton.setup(in: self, at: CGPoint(x: size.width - 80, y: 100))
        ui.setup(in: self, sceneSize: size)
        
        // Setup fire button callback
        fireButton.onTap = { [weak self] in
            self?.handleShoot()
        }
    }
    
    func startGame(with state: GameState) {
        self.gameState = state
        tankExploding = Array(repeating: false, count: state.tanks.count)
        renderGrid()
        renderTanks()
        renderPowerUps()
        updateScore()
        ui.updateStatus("Fight!")
    }
    
    func renderGrid() {
        guard let state = gameState, let grid = gridNode else { return }
        renderer.renderGrid(state.grid, in: grid)
    }
    
    func renderTanks() {
        guard let state = gameState else { return }
        renderer.renderTanks(state.tanks, tankExploding: tankExploding, in: tankNodes, activePowerUps: state.activePowerUps)
    }
    
    func renderProjectiles() {
        guard let state = gameState, let projectiles = projectilesNode else { return }
        renderer.renderProjectiles(state.projectiles, in: projectiles)
    }
    
    func renderPowerUps() {
        guard let state = gameState, let powerUps = powerUpsNode else { return }
        renderer.renderPowerUps(state.powerUps, in: powerUps)
    }
    
    func updateScore() {
        guard let state = gameState else { return }
        ui.updateScore(wins: state.wins)
    }
    
    func showRoundEnd(winner: Int?) {
        guard let state = gameState else { return }
        ui.showRoundEnd(winner: winner, localPlayerIndex: state.localPlayerIndex)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let state = gameState else { return }
        
        // Update power-up timers
        if lastUpdateTime > 0 {
            let delta = currentTime - lastUpdateTime
            state.updatePowerUpTimers(delta: delta)
        }
        
        // Check for power-up collection every 0.2 seconds
        if currentTime - lastPowerUpCheck > 0.2 {
            let collected = state.checkPowerUpCollisions()
            for (playerIndex, powerUpType) in collected {
                // Play sound for power-up collection
                soundManager.playSound("move.wav") // Using existing sound, can add specific power-up sound later
                
                // Trigger haptic feedback on local player collection
                #if os(iOS)
                if playerIndex == state.localPlayerIndex {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                #endif
                
                // Show visual feedback if local player collected
                if playerIndex == state.localPlayerIndex {
                    // Flash effect on collection
                    if let tankNode = tankNodes[playerIndex] {
                        let flash = SKAction.sequence([
                            SKAction.scale(to: 1.3, duration: 0.1),
                            SKAction.scale(to: 1.0, duration: 0.1)
                        ])
                        tankNode.run(flash)
                    }
                }
            }
            if !collected.isEmpty {
                renderPowerUps()
            }
            lastPowerUpCheck = currentTime
        }
        
        // Handle continuous movement from joystick
        if let direction = joystickController.currentDirection, !state.isRoundOver() {
            // Check if speed boost is active for local player
            let moveInterval: TimeInterval = state.hasPowerUp(.speedBoost, for: state.localPlayerIndex) ? 0.08 : 0.12
            
            if currentTime - lastMoveTime > moveInterval { // Move faster with speed boost
                if state.localTank.move(in: direction, grid: state.grid) {
                    renderTanks()
                    soundManager.playSound("move.wav")
                    lastMoveTime = currentTime
                    
                    // Send position update
                    let localIndex = state.localPlayerIndex
                    onGameMessage?(.playerMove(playerIndex: localIndex, row: state.localTank.row, col: state.localTank.col, direction: state.localTank.direction))
                }
            }
        }
        
        // Don't update if round is over or any explosion in progress
        if state.isRoundOver() || tankExploding.contains(true) {
            return
        }
        
        // Update projectiles
        if currentTime - lastUpdateTime > 0.05 { // ~20 FPS for projectile updates
            // Save tank alive state and health before update
            let wasAlive = state.tanks.map { $0.isAlive }
            let previousHealth = state.tanks.map { $0.health }
            let tankPositions = state.tanks.map { renderer.gridPosition(row: $0.row, col: $0.col) }
            
            state.updateProjectiles()
            renderProjectiles()
            
            // Check which tanks were hit and trigger effects
            for i in 0..<state.tanks.count {
                // Tank took damage but didn't die - show damage flash
                if wasAlive[i] && state.tanks[i].isAlive && previousHealth[i] > state.tanks[i].health {
                    soundManager.playSound("hit.wav")
                    
                    // Trigger haptic feedback on local player hit
                    #if os(iOS)
                    if i == state.localPlayerIndex {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                    #endif
                    
                    if let tankNode = tankNodes[i] {
                        // Flash the tank white briefly
                        let flash = SKAction.sequence([
                            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.1),
                            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
                        ])
                        tankNode.run(flash)
                    }
                    renderTanks() // Update health bar
                }
                
                // Tank was destroyed
                if wasAlive[i] && !state.tanks[i].isAlive {
                    soundManager.playSound("hit.wav")
                    
                    // Trigger strong haptic feedback on local player death
                    #if os(iOS)
                    if i == state.localPlayerIndex {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()
                    }
                    #endif
                    
                    if let tankNode = tankNodes[i] {
                        let color = renderer.tankColors[i]
                        explosionEffects.createExplosion(at: tankPositions[i], color: color, in: tankNode) { [weak self] in
                            self?.tankExploding[i] = false
                        }
                        tankExploding[i] = true
                    }
                }
            }
            
            // Check if round ended after update
            if state.isRoundOver() {
                let winner = state.getWinner()
                
                // Wait for explosion to complete before showing round end
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self, let state = self.gameState else { return }
                    
                    // Update score and play win/lose sound
                    if let winner = winner {
                        state.wins[winner] += 1
                        if winner == state.localPlayerIndex {
                            self.soundManager.playSound("win.wav")
                        } else {
                            self.soundManager.playSound("lose.wav")
                        }
                    }
                    
                    // Remove tank nodes now that explosion is done
                    self.renderTanks()
                    self.showRoundEnd(winner: winner)
                    self.updateScore()
                    
                    // Notify that round ended after a longer delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                        guard let state = self?.gameState else { return }
                        self?.onGameMessage?(.readyForNextRound(playerIndex: state.localPlayerIndex))
                    }
                }
            }
            
            lastUpdateTime = currentTime
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState != nil else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            // Check if touching fire button
            if fireButton.handleTouch(at: location) {
                continue
            }
            
            // Check if touching joystick area
            if joystickController.handleTouchBegan(touch, in: self) {
                continue
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            joystickController.handleTouchMoved(touch, in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            joystickController.handleTouchEnded(touch)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func handleShoot() {
        guard let state = gameState, state.localTank.isAlive else { return }
        
        // Check if enough time has passed since last shot (rapid fire reduces cooldown)
        let fireInterval: TimeInterval = state.hasPowerUp(.rapidFire, for: state.localPlayerIndex) ? 0.15 : 0.3
        let currentTime = Date().timeIntervalSinceReferenceDate
        
        guard currentTime - lastFireTime >= fireInterval else { return }
        
        let projectile = state.localTank.shoot()
        state.projectiles.append(projectile)
        renderProjectiles()
        soundManager.playSound("shoot.wav")
        lastFireTime = currentTime
        
        // Send shoot message
        onGameMessage?(.playerShoot(playerIndex: state.localPlayerIndex, projectile: projectile))
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        // macOS support can be added later
    }
}
#endif

