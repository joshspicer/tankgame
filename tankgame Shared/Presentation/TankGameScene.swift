//
//  TankGameScene.swift
//  tankgame Shared
//
//  Main SpriteKit scene for the game
//

import SpriteKit

/// Main game scene that coordinates rendering and input
final class TankGameScene: SKScene {
    
    // Dependencies
    var gameCoordinator: GameCoordinator?
    
    // Components
    private var renderer: GameRenderer?
    private var inputController: InputController?
    
    // UI
    private var statusLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    
    private var lastUpdateTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    private func setupScene() {
        backgroundColor = .black
        
        // Setup renderer
        let renderer = SpriteKitRenderer()
        renderer.setup(in: self)
        self.renderer = renderer
        
        // Setup input
        let inputController = InputController()
        inputController.delegate = self
        inputController.setup(in: self)
        self.inputController = inputController
        
        // Setup UI
        setupUI()
        
        // Setup coordinator callbacks
        gameCoordinator?.onStateChanged = { [weak self] state in
            self?.renderer?.render(state: state)
            self?.updateUI(with: state)
        }
        
        gameCoordinator?.onEventOccurred = { [weak self] event in
            self?.renderer?.handleEvent(event)
        }
    }
    
    private func setupUI() {
        // Status label at top
        let statusLabel = SKLabelNode(text: "Waiting for game...")
        statusLabel.fontSize = 24
        statusLabel.fontName = "AvenirNext-Bold"
        statusLabel.fontColor = .white
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(statusLabel)
        self.statusLabel = statusLabel
        
        // Score label below status
        let scoreLabel = SKLabelNode(text: "")
        scoreLabel.fontSize = 18
        scoreLabel.fontName = "AvenirNext-Regular"
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 70)
        addChild(scoreLabel)
        self.scoreLabel = scoreLabel
    }
    
    private func updateUI(with state: GameStateModel) {
        if state.isRoundActive {
            statusLabel?.text = "Round \(state.roundNumber) - \(state.aliveTankCount) tanks remaining"
        } else {
            statusLabel?.text = "Waiting for next round..."
        }
        
        // Display scores
        let scoreText = state.players.map { "P\($0.index): \($0.score)" }.joined(separator: "  ")
        scoreLabel?.text = scoreText
    }
    
    // MARK: - Update Loop
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        gameCoordinator?.update(deltaTime: deltaTime)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputController?.handleTouchBegan(touch, in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputController?.handleTouchMoved(touch, in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputController?.handleTouchEnded(touch, in: self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputController?.handleTouchEnded(touch, in: self)
        }
    }
}

// MARK: - InputDelegate

extension TankGameScene: InputDelegate {
    func inputDidRequestMove(direction: Direction) {
        gameCoordinator?.moveTank(direction: direction)
    }
    
    func inputDidRequestFire() {
        gameCoordinator?.fireTank()
    }
}
