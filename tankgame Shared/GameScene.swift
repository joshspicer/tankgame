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
    var lizardNode: SKNode?
    
    // Components - Use modern versions
    var renderer: GameSceneRenderer!
    var modernGridRenderer: ModernGridRenderer!
    var soundManager: SoundManager!
    var explosionEffects: ExplosionEffects!
    var modernExplosionEffects: ModernExplosionEffects!
    var joystickController: JoystickController!
    var modernJoystickController: ModernJoystickController!
    var fireButton: FireButton!
    var modernFireButton: ModernFireButton!
    var ui: GameSceneUI!
    var modernUI: ModernGameSceneUI!
    
    #if os(iOS) || os(tvOS)
    var inputHandler: GameSceneInputHandler!
    #endif
    private var updateLoop: GameSceneUpdateLoop!
    
    // Explosion state
    var tankExploding: [Bool] = [false, false, false, false]
    
    // Modern UI flag
    var useModernUI: Bool = true
    
    class func newGameScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 600, height: 800))
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        // Modern dark background
        backgroundColor = SKColor(red: 0.08, green: 0.1, blue: 0.15, alpha: 1.0)
        setupComponents()
        setupScene()
        
        // If startGame was called before didMove (e.g., for clients receiving roundStart),
        // render the grid now that the scene has been set up
        if gameState != nil {
            renderGrid()
            renderTanks()
            renderProjectiles()
            renderLizards()
            updateScore()
        }
    }
    
    private func setupComponents() {
        renderer = GameSceneRenderer(tileSize: tileSize, gridSize: gridSize)
        modernGridRenderer = ModernGridRenderer(tileSize: tileSize, gridSize: gridSize)
        soundManager = SoundManager(scene: self)
        explosionEffects = ExplosionEffects(tileSize: tileSize)
        modernExplosionEffects = ModernExplosionEffects(tileSize: tileSize)
        modernExplosionEffects.setScene(self)
        
        // Initialize both old and modern joystick/fire button for compatibility
        joystickController = JoystickController()
        modernJoystickController = ModernJoystickController()
        fireButton = FireButton()
        modernFireButton = ModernFireButton()
        ui = GameSceneUI()
        modernUI = ModernGameSceneUI()
        
        #if os(iOS) || os(tvOS)
        inputHandler = GameSceneInputHandler(scene: self)
        #endif
        updateLoop = GameSceneUpdateLoop(scene: self)
    }
    
    func setupScene() {
        GameSceneSetup.setupScene(in: self)
    }
    
    func startGame(with state: GameState) {
        self.gameState = state
        tankExploding = Array(repeating: false, count: state.tanks.count)
        renderGrid()
        renderTanks()
        renderLizards()
        updateScore()
        if useModernUI {
            modernUI.updateStatus("Fight!")
        } else {
            ui.updateStatus("Fight!")
        }
    }
    
    func renderGrid() {
        guard let state = gameState, let grid = gridNode else { return }
        if useModernUI {
            modernGridRenderer.renderGrid(state.grid, in: grid)
        } else {
            renderer.renderGrid(state.grid, in: grid)
        }
    }
    
    func renderTanks() {
        guard let state = gameState else { return }
        renderer.renderTanks(state.tanks, tankExploding: tankExploding, in: tankNodes)
    }
    
    func renderTanksWithSmoothing() {
        guard let state = gameState else { return }
        renderer.renderTanksWithSmoothing(state.tanks, tankExploding: tankExploding, in: tankNodes, duration: 0.08)
    }
    
    func renderProjectiles() {
        guard let state = gameState, let projectiles = projectilesNode else { return }
        renderer.renderProjectiles(state.projectiles, in: projectiles)
    }
    
    func renderLizards() {
        guard let state = gameState, let lizards = lizardNode else { return }
        renderer.renderLizards(state.lizards, in: lizards)
    }
    
    func renderLizardsWithSmoothing() {
        guard let state = gameState, let lizards = lizardNode else { return }
        renderer.renderLizardsWithSmoothing(state.lizards, in: lizards, duration: 0.1)
    }
    
    func updateScore() {
        guard let state = gameState else { return }
        if useModernUI {
            modernUI.updateScore(wins: state.wins)
        } else {
            ui.updateScore(wins: state.wins)
        }
    }
    
    func showRoundEnd(winner: Int?) {
        guard let state = gameState else { return }
        if useModernUI {
            modernUI.showRoundEnd(winner: winner, localPlayerIndex: state.localPlayerIndex)
        } else {
            ui.showRoundEnd(winner: winner, localPlayerIndex: state.localPlayerIndex)
        }
    }
    
    /// Get the current joystick direction (from either old or modern joystick)
    func getCurrentJoystickDirection() -> Direction? {
        if useModernUI {
            return modernJoystickController.currentDirection
        } else {
            return joystickController.currentDirection
        }
    }
    
    /// Check if joystick is active
    func isJoystickActive() -> Bool {
        if useModernUI {
            return modernJoystickController.isActive
        } else {
            return joystickController.isActive
        }
    }
    
    /// Get joystick position
    func getJoystickPosition() -> CGPoint {
        if useModernUI {
            return modernJoystickController.position
        } else {
            return joystickController.position
        }
    }
    
    /// Get fire button position
    func getFireButtonPosition() -> CGPoint {
        if useModernUI {
            return modernFireButton.position
        } else {
            return fireButton.position
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateLoop.update(currentTime)
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputHandler.handleTouchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputHandler.handleTouchesMoved(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputHandler.handleTouchesEnded(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
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

