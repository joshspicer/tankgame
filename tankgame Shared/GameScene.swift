//
//  GameScene.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

class GameScene: SKScene {
    
    // Game state
    var gameState: GameState?
    var onGameMessage: ((GameMessage) -> Void)?
    
    // Constants
    let tileSize: CGFloat = 64
    let gridSize = 8
    
    // Nodes
    var gridNode: SKNode?
    var tankNodes: [SKNode] = [] // Array of tank nodes for each player
    var projectilesNode: SKNode?
    var joystickNode: SKNode?
    var joystickBase: SKShapeNode?
    var joystickHandle: SKShapeNode?
    var fireButton: SKShapeNode?
    var statusLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    
    // Colors for different players
    static let playerColors: [SKColor] = [.blue, .red, .green, .orange]
    
    // Joystick state
    var joystickActive = false
    var joystickTouchID: UITouch?
    var currentDirection: Direction?
    
    // Update timer
    var lastUpdateTime: TimeInterval = 0
    var lastMoveTime: TimeInterval = 0
    
    // Sound control
    var soundEnabled = true
    
    class func newGameScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 600, height: 800))
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        setupScene()
    }
    
    func playSound(_ soundFile: String) {
        guard soundEnabled else { return }
        run(SKAction.playSoundFileNamed(soundFile, waitForCompletion: false))
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
        
        // Create tank nodes for each player (we'll create them dynamically based on number of players)
        tankNodes = []
        
        // Create joystick
        setupJoystick()
        
        // Create status label
        let newStatusLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        newStatusLabel.fontSize = 20
        newStatusLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        newStatusLabel.text = "Waiting for game..."
        addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score label
        let newScoreLabel = SKLabelNode(fontNamed: "Arial")
        newScoreLabel.fontSize = 16
        newScoreLabel.position = CGPoint(x: size.width / 2, y: 30)
        newScoreLabel.text = "Score: 0 - 0"
        addChild(newScoreLabel)
        scoreLabel = newScoreLabel
        
        // Create fire button (bottom right)
        let newFireButton = SKShapeNode(circleOfRadius: 40)
        newFireButton.position = CGPoint(x: size.width - 80, y: 100)
        newFireButton.fillColor = .red
        newFireButton.strokeColor = .white
        newFireButton.lineWidth = 3
        newFireButton.alpha = 0.7
        addChild(newFireButton)
        fireButton = newFireButton
        
        // Add fire label
        let fireLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 14
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        newFireButton.addChild(fireLabel)
    }
    
    func setupJoystick() {
        let newJoystickNode = SKNode()
        newJoystickNode.position = CGPoint(x: 80, y: 100)
        addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        let newJoystickBase = SKShapeNode(circleOfRadius: 50)
        newJoystickBase.fillColor = .gray
        newJoystickBase.strokeColor = .white
        newJoystickBase.lineWidth = 2
        newJoystickBase.alpha = 0.5
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        let newJoystickHandle = SKShapeNode(circleOfRadius: 25)
        newJoystickHandle.fillColor = .white
        newJoystickHandle.strokeColor = .white
        newJoystickHandle.alpha = 0.8
        newJoystickNode.addChild(newJoystickHandle)
        joystickHandle = newJoystickHandle
    }
    
    func startGame(with state: GameState) {
        self.gameState = state
        
        // Create tank nodes for all players
        let gridOffset = CGPoint(
            x: (size.width - CGFloat(gridSize) * tileSize) / 2,
            y: (size.height - CGFloat(gridSize) * tileSize) / 2 + 50
        )
        
        // Remove old tank nodes
        tankNodes.forEach { $0.removeFromParent() }
        tankNodes = []
        
        // Create a node for each player
        for _ in 0..<state.tanks.count {
            let tankNode = SKNode()
            tankNode.position = gridOffset
            addChild(tankNode)
            tankNodes.append(tankNode)
        }
        
        renderGrid()
        renderTanks()
        updateScore()
        statusLabel?.text = "Fight!"
    }
    
    func renderGrid() {
        guard let state = gameState, let grid = gridNode else { return }
        
        grid.removeAllChildren()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = state.grid[row][col]
                let tile = SKSpriteNode(color: cell == .wall ? .black : .white, size: CGSize(width: tileSize - 2, height: tileSize - 2))
                tile.position = CGPoint(
                    x: CGFloat(col) * tileSize + tileSize / 2,
                    y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
                )
                grid.addChild(tile)
            }
        }
    }
    
    func renderTanks() {
        guard let state = gameState else { return }
        
        // Render all tanks
        for (index, tank) in state.tanks.enumerated() {
            guard index < tankNodes.count else { continue }
            
            tankNodes[index].removeAllChildren()
            if tank.isAlive {
                let color = GameScene.playerColors[index % GameScene.playerColors.count]
                let tankNode = createTankNode(color: color, direction: tank.direction)
                tankNode.position = gridPosition(row: tank.row, col: tank.col)
                tankNodes[index].addChild(tankNode)
            }
        }
    }
    
    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()
        
        // Tank body (square)
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.7, height: tileSize * 0.7))
        tankNode.addChild(body)
        
        // Tank barrel (rectangle)
        let barrel = SKSpriteNode(color: color.withAlphaComponent(0.8), size: CGSize(width: tileSize * 0.2, height: tileSize * 0.5))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
        tankNode.addChild(barrel)
        
        // Add rainbow animation to body and barrel
        addRainbowAnimation(to: body, phaseOffset: 0)
        addRainbowAnimation(to: barrel, phaseOffset: 0.15)
        
        // Rotate based on direction
        tankNode.zRotation = CGFloat(direction.angle)
        
        return tankNode
    }
    
    func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        
        var colorActions: [SKAction] = []
        
        // Create a smooth rainbow by cycling through hue values
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
            let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: animationDuration / Double(numberOfColors))
            colorActions.append(colorAction)
        }
        
        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)
        
        sprite.run(repeatForever)
    }
    
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
    
    func renderProjectiles() {
        guard let state = gameState, let projectiles = projectilesNode else { return }
        
        projectiles.removeAllChildren()
        
        for (projectile, ownerIndex) in state.projectiles {
            // Make projectile larger and more visible
            let bullet = SKSpriteNode(color: .yellow, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.5))
            bullet.zPosition = 5
            bullet.position = gridPosition(row: projectile.row, col: projectile.col)
            
            // Add rainbow color animation
            addRainbowAnimation(to: bullet, phaseOffset: 0.5)
            
            // Add pulsing scale animation
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            let repeatPulse = SKAction.repeatForever(pulse)
            bullet.run(repeatPulse)
            
            // Add rotation animation based on direction
            let rotationDuration: TimeInterval = 0.5
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: rotationDuration)
            let repeatRotation = SKAction.repeatForever(rotate)
            bullet.run(repeatRotation)
            
            projectiles.addChild(bullet)
        }
    }
    
    func updateScore() {
        guard let state = gameState else { return }
        // Show scores for all players
        let scoreText = state.wins.enumerated()
            .map { "P\($0.offset + 1): \($0.element)" }
            .joined(separator: " | ")
        scoreLabel?.text = "Score: \(scoreText)"
    }
    
    func showRoundEnd(localWon: Bool) {
        let message = localWon ? "You Win!" : "You Lose!"
        statusLabel?.text = message
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "Next round starting..."
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let state = gameState else { return }
        
        // Handle continuous movement from joystick
        if let direction = currentDirection, !state.isRoundOver() {
            if currentTime - lastMoveTime > 0.12 { // Move ~8 times per second
                if state.localTank.move(in: direction, grid: state.grid) {
                    renderTanks()
                    playSound("move.wav")
                    lastMoveTime = currentTime
                    
                    // Send position update with player index
                    onGameMessage?(.playerMove(playerIndex: state.localPlayerIndex, row: state.localTank.row, col: state.localTank.col, direction: state.localTank.direction))
                }
            }
        }
        
        // Don't update if round is over
        if state.isRoundOver() {
            return
        }
        
        // Update projectiles
        if currentTime - lastUpdateTime > 0.05 { // ~20 FPS for projectile updates
            // Track which tanks were alive before update
            let tanksAliveStatus = state.tanks.map { $0.isAlive }
            
            state.updateProjectiles()
            renderProjectiles()
            
            // Play hit sound if any tank was hit
            for (index, wasAlive) in tanksAliveStatus.enumerated() {
                if wasAlive && !state.tanks[index].isAlive {
                    playSound("hit.wav")
                }
            }
            
            // Check if round ended after update
            if state.isRoundOver() {
                let localWon = state.localPlayerWon()
                
                // Award win to the surviving player(s)
                if localWon {
                    gameState?.wins[state.localPlayerIndex] += 1
                    playSound("win.wav")
                } else {
                    // Find the winner (if any)
                    if let winnerIndex = state.tanks.enumerated().first(where: { $0.element.isAlive })?.offset {
                        gameState?.wins[winnerIndex] += 1
                    }
                    playSound("lose.wav")
                }
                showRoundEnd(localWon: localWon)
                updateScore()
                
                // Notify that round ended
                onGameMessage?(.readyForNextRound)
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
            if let button = fireButton {
                let dx = location.x - button.position.x
                let dy = location.y - button.position.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance < 50 {
                    handleShoot()
                    continue
                }
            }
            
            // Check if touching joystick area (expanded hit area)
            if let joystick = joystickNode {
                let joystickCenter = joystick.position
                let dx = location.x - joystickCenter.x
                let dy = location.y - joystickCenter.y
                let distance = sqrt(dx * dx + dy * dy)
                
                // Joystick area is 150 points radius
                if distance < 150 {
                    joystickActive = true
                    joystickTouchID = touch
                    // Process initial direction
                    processTouchLocation(touch.location(in: joystick))
                    continue
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard joystickActive else { return }
        guard let touch = joystickTouchID, touches.contains(touch) else { return }
        guard let joystick = joystickNode else { return }
        
        let location = touch.location(in: joystick)
        processTouchLocation(location)
    }
    
    func processTouchLocation(_ location: CGPoint) {
        guard let handle = joystickHandle else { return }
        
        let dx = location.x
        let dy = location.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance > 20 {
            let angle = atan2(dy, dx)
            
            // Snap to cardinal directions
            let direction: Direction
            if angle > -.pi/4 && angle <= .pi/4 {
                direction = .right
            } else if angle > .pi/4 && angle <= 3 * .pi/4 {
                direction = .up
            } else if angle > 3 * .pi/4 || angle <= -3 * .pi/4 {
                direction = .left
            } else {
                direction = .down
            }
            
            currentDirection = direction
            
            // Update joystick handle position
            let maxDistance: CGFloat = 30
            let clampedDistance = min(distance, maxDistance)
            handle.position = CGPoint(
                x: cos(angle) * clampedDistance,
                y: sin(angle) * clampedDistance
            )
        } else {
            currentDirection = nil
            handle.position = .zero
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = joystickTouchID, touches.contains(touch) {
            joystickActive = false
            joystickTouchID = nil
            currentDirection = nil
            joystickHandle?.position = .zero
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func handleShoot() {
        guard let state = gameState, state.localTank.isAlive else { return }
        
        let projectile = state.localTank.shoot()
        state.projectiles.append((projectile, state.localPlayerIndex))
        renderProjectiles()
        playSound("shoot.wav")
        
        // Send shoot message with player index
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

