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
    var backgroundNode: SKNode?
    
    // Components
    var renderer: GameSceneRenderer!
    var soundManager: SoundManager!
    var explosionEffects: ExplosionEffects!
    var joystickController: JoystickController!
    var modernJoystick: ModernJoystickController!
    var fireButton: FireButton!
    var modernFireButton: ModernFireButton!
    var ui: GameSceneUI!
    var modernUI: ModernGameSceneUI!
    
    // Feature flag for modern UI (set to true to use modern styling)
    private let useModernUI: Bool = true
    
    #if os(iOS) || os(tvOS)
    var inputHandler: GameSceneInputHandler!
    #endif
    private var updateLoop: GameSceneUpdateLoop!
    
    // Explosion state
    var tankExploding: [Bool] = [false, false, false, false]
    
    class func newGameScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 600, height: 800))
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        // Modern dark background
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
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
        soundManager = SoundManager(scene: self)
        explosionEffects = ExplosionEffects(tileSize: tileSize)
        
        // Setup controls based on UI style preference
        if useModernUI {
            modernJoystick = ModernJoystickController()
            modernFireButton = ModernFireButton()
            modernUI = ModernGameSceneUI()
        } else {
            joystickController = JoystickController()
            fireButton = FireButton()
            ui = GameSceneUI()
        }
        
        #if os(iOS) || os(tvOS)
        inputHandler = GameSceneInputHandler(scene: self)
        #endif
        updateLoop = GameSceneUpdateLoop(scene: self)
    }
    
    func setupScene() {
        if useModernUI {
            setupModernScene()
        } else {
            GameSceneSetup.setupScene(in: self)
        }
    }
    
    /// Setup scene with modern styling
    private func setupModernScene() {
        // Create animated background
        createAnimatedBackground()
        
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
        
        // Create lizard container
        let newLizardNode = SKNode()
        newLizardNode.position = gridOffset
        newLizardNode.zPosition = 5
        addChild(newLizardNode)
        lizardNode = newLizardNode
        
        // Create tank nodes for all possible players
        for i in 0..<4 {
            let tankNode = SKNode()
            tankNode.position = gridOffset
            tankNode.zPosition = 10
            addChild(tankNode)
            tankNodes[i] = tankNode
        }
        
        // Setup modern UI components
        modernJoystick.setup(in: self, at: CGPoint(x: 85, y: 105))
        modernFireButton.setup(in: self, at: CGPoint(x: size.width - 85, y: 105))
        modernUI.setup(in: self, sceneSize: size)
        
        // Setup fire button callback
        modernFireButton.onTap = { [weak self] in
            self?.inputHandler.handleShoot()
        }
    }
    
    /// Create animated background particles
    private func createAnimatedBackground() {
        let bgNode = SKNode()
        bgNode.zPosition = -100
        addChild(bgNode)
        backgroundNode = bgNode
        
        // Create subtle star-like particles
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            star.fillColor = SKColor.white.withAlphaComponent(CGFloat.random(in: 0.1...0.3))
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            bgNode.addChild(star)
            
            // Add twinkling animation
            let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: Double.random(in: 1...3))
            let fadeIn = SKAction.fadeAlpha(to: 0.4, duration: Double.random(in: 1...3))
            let sequence = SKAction.sequence([fadeOut, fadeIn])
            star.run(SKAction.repeatForever(sequence))
        }
    }
    
    func startGame(with state: GameState) {
        self.gameState = state
        tankExploding = Array(repeating: false, count: state.tanks.count)
        renderGrid()
        renderTanks()
        renderLizards()
        updateScore()
        
        // Update status with animation
        if useModernUI {
            modernUI.updateStatus("⚔️ FIGHT! ⚔️")
        } else {
            ui.updateStatus("Fight!")
        }
    }
    
    func renderGrid() {
        guard let state = gameState, let grid = gridNode else { return }
        renderer.renderGrid(state.grid, in: grid)
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

