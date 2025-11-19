//
//  GameScene.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Main game scene that coordinates all game elements
/// Acts as the central coordinator between game state, rendering, input, and audio
class GameScene: SKScene {
    
    // MARK: - Game State
    
    /// Current game state managing tanks, projectiles, and grid
    var gameState: GameState?
    
    /// Callback for sending game messages over the network
    var onGameMessage: ((GameMessage) -> Void)?
    
    // MARK: - Constants
    
    /// Size of each grid tile in points
    let tileSize: CGFloat = 64
    
    /// Number of cells in the grid
    let gridSize = 8
    
    // MARK: - Scene Nodes
    
    /// Container node for grid tiles
    var gridNode: SKNode?
    
    /// Container nodes for each tank (up to 4 players)
    var tankNodes: [SKNode?] = [nil, nil, nil, nil]
    
    /// Container node for all projectiles
    var projectilesNode: SKNode?
    
    // MARK: - Component Dependencies
    
    /// Handles all rendering operations
    private var renderer: GameSceneRenderer!
    
    /// Manages sound playback
    private var soundManager: SoundManager!
    
    /// Creates explosion particle effects
    private var explosionEffects: ExplosionEffects!
    
    /// Handles joystick input
    private var joystickController: JoystickController!
    
    /// Handles fire button input
    private var fireButton: FireButton!
    
    /// Manages UI labels
    private var ui: GameSceneUI!
    
    // MARK: - Timing
    
    /// Time of last update call
    var lastUpdateTime: TimeInterval = 0
    
    /// Time of last tank movement
    var lastMoveTime: TimeInterval = 0
    
    // MARK: - Explosion State
    
    /// Tracks which tanks are currently exploding
    var tankExploding: [Bool] = [false, false, false, false]
    
    // MARK: - Scene Lifecycle
    
    // MARK: - Scene Lifecycle
    
    /// Factory method to create a new game scene
    /// - Returns: Configured GameScene instance
    class func newGameScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 600, height: 800))
        scene.scaleMode = .aspectFit
        return scene
    }
    
    /// Called when the scene is presented in a view
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
    
    // MARK: - Setup
    
    /// Initializes all component dependencies
    private func setupComponents() {
        renderer = GameSceneRenderer(tileSize: tileSize, gridSize: gridSize)
        soundManager = SoundManager(scene: self)
        explosionEffects = ExplosionEffects(tileSize: tileSize)
        joystickController = JoystickController()
        fireButton = FireButton()
        ui = GameSceneUI()
    }
    
    /// Sets up the scene hierarchy with all nodes and UI elements
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
    
    // MARK: - Game Management
    
    /// Starts a new game with the provided state
    /// - Parameter state: Initial game state
    func startGame(with state: GameState) {
        self.gameState = state
        tankExploding = Array(repeating: false, count: state.tanks.count)
        renderGrid()
        renderTanks()
        updateScore()
        ui.updateStatus("Fight!")
    }
    
    // MARK: - Rendering
    
    /// Renders the game grid
    func renderGrid() {
        guard let state = gameState, let grid = gridNode else { return }
        renderer.renderGrid(state.grid, in: grid)
    }
    
    /// Renders all player tanks
    func renderTanks() {
        guard let state = gameState else { return }
        renderer.renderTanks(state.tanks, tankExploding: tankExploding, in: tankNodes)
    }
    
    /// Renders all active projectiles
    func renderProjectiles() {
        guard let state = gameState, let projectiles = projectilesNode else { return }
        renderer.renderProjectiles(state.projectiles, in: projectiles)
    }
    
    /// Updates the score UI with current win counts
    func updateScore() {
        guard let state = gameState else { return }
        ui.updateScore(wins: state.wins)
    }
    
    /// Shows the round end UI with winner information
    /// - Parameter winner: Player index of the winner, or nil for a draw
    func showRoundEnd(winner: Int?) {
        guard let state = gameState else { return }
        ui.showRoundEnd(winner: winner, localPlayerIndex: state.localPlayerIndex)
    }
    
    // MARK: - Game Loop
    
    /// Main game loop that handles continuous movement, projectile updates, and collision detection
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
            // Save tank alive state before update
            let wasAlive = state.tanks.map { $0.isAlive }
            let tankPositions = state.tanks.map { renderer.gridPosition(row: $0.row, col: $0.col) }
            
            state.updateProjectiles()
            renderProjectiles()
            
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
// MARK: - Touch-Based Input (iOS/tvOS)

extension GameScene {
    /// Handles touch began events for joystick and fire button
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
    
    /// Handles touch moved events for continuous joystick control
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            joystickController.handleTouchMoved(touch, in: self)
        }
    }
    
    /// Handles touch ended events to reset joystick
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            joystickController.handleTouchEnded(touch)
        }
    }
    
    /// Handles touch cancelled events (treated same as touch ended)
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    /// Handles the fire button tap to shoot a projectile
    func handleShoot() {
        guard let state = gameState, state.localTank.isAlive else { return }
        
        let projectile = state.localTank.shoot()
        state.projectiles.append(projectile)
        renderProjectiles()
        soundManager.playSound("shoot.wav")
        
        // Send shoot message
        onGameMessage?(.playerShoot(playerIndex: state.localPlayerIndex, projectile: projectile))
    }
}
#endif

#if os(OSX)
// MARK: - Mouse-Based Input (macOS)

extension GameScene {
    /// Handles mouse down events (macOS support can be added later)
    override func mouseDown(with event: NSEvent) {
        // macOS support can be added later
    }
}
#endif

