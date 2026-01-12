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
    
    // Components
    var renderer: GameSceneRenderer!
    var soundManager: SoundManager!
    var explosionEffects: ExplosionEffects!
    var joystickController: JoystickController!
    var fireButton: FireButton!
    var ui: GameSceneUI!
    
    // Update state
    var lastUpdateTime: TimeInterval = 0
    var lastMoveTime: TimeInterval = 0
    var lastLizardUpdateTime: TimeInterval = 0
    var lastBotUpdateTime: TimeInterval = 0
    private var explosionHandler: ExplosionHandler?
    
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
        joystickController = JoystickController()
        fireButton = FireButton()
        ui = GameSceneUI()
        explosionHandler = ExplosionHandler(scene: self)
    }
    
    func setupScene() {
        let newGridNode = SKNode()
        let gridOffset = CGPoint(x: (size.width - CGFloat(gridSize) * tileSize) / 2, y: (size.height - CGFloat(gridSize) * tileSize) / 2 + 50)
        newGridNode.position = gridOffset
        addChild(newGridNode)
        gridNode = newGridNode
        
        let newProjectilesNode = SKNode()
        newProjectilesNode.position = gridOffset
        addChild(newProjectilesNode)
        projectilesNode = newProjectilesNode
        
        let newLizardNode = SKNode()
        newLizardNode.position = gridOffset
        newLizardNode.zPosition = 5
        addChild(newLizardNode)
        lizardNode = newLizardNode
        
        for i in 0..<4 {
            let tankNode = SKNode()
            tankNode.position = gridOffset
            tankNode.zPosition = 10
            addChild(tankNode)
            tankNodes[i] = tankNode
        }
        
        joystickController.setup(in: self, at: CGPoint(x: 80, y: 100))
        fireButton.setup(in: self, at: CGPoint(x: size.width - 80, y: 100))
        ui.setup(in: self, sceneSize: size)
        
        fireButton.onTap = { [weak self] in
            self?.handleShoot()
        }
    }
    
    func startGame(with state: GameState) {
        self.gameState = state
        tankExploding = Array(repeating: false, count: state.tanks.count)
        renderGrid()
        renderTanks()
        renderLizards()
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
            let moveInterval = direction.isDiagonal ? 0.15 : 0.10
            if currentTime - lastMoveTime > moveInterval {
                if state.localTank.move(in: direction, grid: state.grid) {
                    renderTanksWithSmoothing()
                    soundManager.playSound("move.wav")
                    lastMoveTime = currentTime
                    let localIndex = state.localPlayerIndex
                    onGameMessage?(.playerMove(playerIndex: localIndex, row: state.localTank.row, col: state.localTank.col, direction: state.localTank.direction))
                }
            }
        }
        
        // Don't update if round is over or any explosion in progress
        if state.isRoundOver() || tankExploding.contains(true) {
            return
        }
        
        // Update AI bots
        if currentTime - lastBotUpdateTime > 0.1 {
            updateBots(state: state)
            lastBotUpdateTime = currentTime
        }
        
        // Update projectiles
        if currentTime - lastUpdateTime > 0.05 {
            updateProjectiles(state: state)
            lastUpdateTime = currentTime
        }
        
        // Update lizards
        if currentTime - lastLizardUpdateTime > 0.1 {
            updateLizards(state: state)
            lastLizardUpdateTime = currentTime
        }
    }
    
    private func updateProjectiles(state: GameState) {
        let wasAlive = state.tanks.map { $0.isAlive }
        let tankPositions = state.tanks.map { renderer.gridPosition(row: $0.row, col: $0.col) }
        let lizardWasAlive = state.lizards.map { $0.isAlive }
        let lizardPositions = state.lizards.map { renderer.gridPosition(row: $0.row, col: $0.col) }
        
        state.updateProjectiles()
        renderProjectiles()
        
        explosionHandler?.checkAndTriggerTankExplosions(wasAlive: wasAlive, tanks: state.tanks, tankPositions: tankPositions)
        explosionHandler?.checkAndTriggerLizardExplosions(wasAlive: lizardWasAlive, lizards: state.lizards, lizardPositions: lizardPositions)
        
        if lizardWasAlive != state.lizards.map({ $0.isAlive }) {
            renderLizards()
        }
        
        if state.isRoundOver() {
            handleRoundEnd(state: state)
        }
    }
    
    private func updateLizards(state: GameState) {
        state.updateLizards()
        renderLizardsWithSmoothing()
    }
    
    private func updateBots(state: GameState) {
        guard state.botManager.hasBots else { return }
        
        state.botManager.onBotMove = { [weak self] tankIndex, row, col, direction in
            self?.renderTanksWithSmoothing()
            self?.soundManager.playSound("move.wav")
        }
        
        state.botManager.onBotShoot = { [weak self, weak state] tankIndex, projectile in
            state?.projectiles.append(projectile)
            self?.renderProjectiles()
            self?.soundManager.playSound("shoot.wav")
        }
        
        state.botManager.update(tanks: &state.tanks, grid: state.grid, projectiles: state.projectiles)
    }
    
    private func handleRoundEnd(state: GameState) {
        let winner = state.getWinner()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, let state = self.gameState else { return }
            
            if let winner = winner {
                state.wins[winner] += 1
                if winner == state.localPlayerIndex {
                    self.soundManager.playSound("win.wav")
                } else {
                    self.soundManager.playSound("lose.wav")
                }
            }
            
            self.renderTanks()
            self.showRoundEnd(winner: winner)
            self.updateScore()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let state = self?.gameState else { return }
                self?.onGameMessage?(.readyForNextRound(playerIndex: state.localPlayerIndex))
            }
        }
    }
    
    func handleShoot() {
        guard let state = gameState, state.localTank.isAlive else { return }
        let projectile = state.localTank.shoot()
        state.projectiles.append(projectile)
        renderProjectiles()
        soundManager.playSound("shoot.wav")
        onGameMessage?(.playerShoot(playerIndex: state.localPlayerIndex, projectile: projectile))
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState != nil else { return }
        for touch in touches {
            let location = touch.location(in: self)
            if fireButton.handleTouch(at: location) {
                continue
            }
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

