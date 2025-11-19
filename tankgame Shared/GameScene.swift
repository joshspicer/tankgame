//
//  GameScene.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

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
    var powerUpNode: SKNode?
    var healthNode: SKNode?
    
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
        
        // Create power-up container
        let newPowerUpNode = SKNode()
        newPowerUpNode.position = gridOffset
        addChild(newPowerUpNode)
        powerUpNode = newPowerUpNode
        
        // Create health indicators container
        let newHealthNode = SKNode()
        newHealthNode.position = gridOffset
        addChild(newHealthNode)
        healthNode = newHealthNode
        
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
        renderHealthIndicators()
        updateScore()
        ui.updateStatus("Fight!")
    }
    
    func renderGrid() {
        guard let state = gameState, let grid = gridNode else { return }
        renderer.renderGrid(state.grid, in: grid)
    }
    
    func renderTanks() {
        guard let state = gameState else { return }
        renderer.renderTanks(state.tanks, tankExploding: tankExploding, in: tankNodes)
    }
    
    func renderProjectiles() {
        guard let state = gameState, let projectiles = projectilesNode else { return }
        renderer.renderProjectiles(state.projectiles, in: projectiles)
    }
    
    func renderPowerUps() {
        guard let state = gameState, let powerUps = powerUpNode else { return }
        renderer.renderPowerUps(state.powerUps, in: powerUps)
    }
    
    func renderHealthIndicators() {
        guard let state = gameState, let health = healthNode else { return }
        renderer.renderHealthIndicators(state.tanks, currentTime: state.currentTime, in: health)
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
        
        // Handle continuous movement from joystick
        if let direction = joystickController.currentDirection, !state.isRoundOver() {
            if currentTime - lastMoveTime > 0.12 { // Move ~8 times per second
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
            let deltaTime = currentTime - lastUpdateTime
            
            // Save tank alive state before update
            let wasAlive = state.tanks.map { $0.isAlive }
            let tankPositions = state.tanks.map { renderer.gridPosition(row: $0.row, col: $0.col) }
            
            state.updateProjectiles()
            state.updatePowerUps(deltaTime: deltaTime)
            renderProjectiles()
            renderPowerUps()
            renderHealthIndicators()
            
            // Check which tanks were hit and trigger explosions
            for i in 0..<state.tanks.count {
                if wasAlive[i] && !state.tanks[i].isAlive {
                    soundManager.playSound("hit.wav")
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
        guard let state = gameState else { return }
        guard state.localTank.isAlive else { return }
        guard state.localTank.canShoot(currentTime: state.currentTime) else { return }
        
        let localIndex = state.localPlayerIndex
        let projectile = state.localTank.shoot(ownerIndex: localIndex)
        state.localTank.recordShot(currentTime: state.currentTime)
        state.projectiles.append(projectile)
        state.statistics[localIndex].recordShot()
        
        renderProjectiles()
        soundManager.playSound("shoot.wav")
        
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

