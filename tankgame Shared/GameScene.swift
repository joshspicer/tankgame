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
    var localTankNode: SKNode?
    var remoteTankNode: SKNode?
    var projectilesNode: SKNode?
    var joystickNode: SKNode?
    var joystickBase: SKShapeNode?
    var joystickHandle: SKShapeNode?
    var fireButton: SKShapeNode?
    var statusLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    
    // Joystick state
    var joystickActive = false
    var joystickTouchID: UITouch?
    var currentDirection: Direction?
    
    // Update timer
    var lastUpdateTime: TimeInterval = 0
    var lastMoveTime: TimeInterval = 0
    
    // Sound control
    var soundEnabled = true
    
    // Explosion state
    var localTankExploding = false
    var remoteTankExploding = false
    
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
        
        // Create tank nodes
        let newLocalTankNode = SKNode()
        newLocalTankNode.position = gridOffset
        addChild(newLocalTankNode)
        localTankNode = newLocalTankNode
        
        let newRemoteTankNode = SKNode()
        newRemoteTankNode.position = gridOffset
        addChild(newRemoteTankNode)
        remoteTankNode = newRemoteTankNode
        
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
        localTankExploding = false
        remoteTankExploding = false
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
        
        // Render local tank - keep visible during explosion
        localTankNode?.removeAllChildren()
        if state.localTank.isAlive || localTankExploding, let localNode = localTankNode {
            let tank = createTankNode(color: .blue, direction: state.localTank.direction)
            tank.position = gridPosition(row: state.localTank.row, col: state.localTank.col)
            localNode.addChild(tank)
        }
        
        // Render remote tank - keep visible during explosion
        remoteTankNode?.removeAllChildren()
        if state.remoteTank.isAlive || remoteTankExploding, let remoteNode = remoteTankNode {
            let tank = createTankNode(color: .red, direction: state.remoteTank.direction)
            tank.position = gridPosition(row: state.remoteTank.row, col: state.remoteTank.col)
            remoteNode.addChild(tank)
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
    
    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, isLocalTank: Bool) {
        // Mark which tank is exploding
        if isLocalTank {
            localTankExploding = true
        } else {
            remoteTankExploding = true
        }
        
        // Create explosion particles
        let particleCount = 12
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 8)
            particle.fillColor = color
            particle.strokeColor = .white
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 10
            
            // Calculate random direction
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let velocity: CGFloat = 150
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity
            
            // Create movement animation
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.6)
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let scaleUp = SKAction.scale(to: 2.0, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            
            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])
            
            parentNode.addChild(particle)
            particle.run(sequence)
        }
        
        // Create central flash effect
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.5)
        flash.fillColor = .white
        flash.strokeColor = .yellow
        flash.lineWidth = 4
        flash.position = position
        flash.zPosition = 11
        flash.alpha = 0.9
        
        let flashScale = SKAction.scale(to: 2.5, duration: 0.4)
        let flashFade = SKAction.fadeOut(withDuration: 0.4)
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])
        
        parentNode.addChild(flash)
        flash.run(flashSequence) {
            // Clear the explosion flag for this tank
            if isLocalTank {
                self.localTankExploding = false
            } else {
                self.remoteTankExploding = false
            }
        }
    }
    
    func renderProjectiles() {
        guard let state = gameState, let projectiles = projectilesNode else { return }
        
        projectiles.removeAllChildren()
        
        for projectile in state.projectiles {
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
        scoreLabel?.text = "Score: \(state.localWins) - \(state.remoteWins)"
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
                    
                    // Send position update
                    onGameMessage?(.playerMove(row: state.localTank.row, col: state.localTank.col, direction: state.localTank.direction))
                }
            }
        }
        
        // Don't update if round is over or explosion in progress
        if state.isRoundOver() || localTankExploding || remoteTankExploding {
            return
        }
        
        // Update projectiles
        if currentTime - lastUpdateTime > 0.05 { // ~20 FPS for projectile updates
            let wasLocalAlive = state.localTank.isAlive
            let wasRemoteAlive = state.remoteTank.isAlive
            let localTankPosition = gridPosition(row: state.localTank.row, col: state.localTank.col)
            let remoteTankPosition = gridPosition(row: state.remoteTank.row, col: state.remoteTank.col)
            
            state.updateProjectiles()
            renderProjectiles()
            
            // Check if local tank was hit and trigger explosion
            if wasLocalAlive && !state.localTank.isAlive {
                playSound("hit.wav")
                if let localNode = localTankNode {
                    createExplosion(at: localTankPosition, color: .blue, in: localNode, isLocalTank: true)
                }
            }
            
            // Check if remote tank was hit and trigger explosion
            if wasRemoteAlive && !state.remoteTank.isAlive {
                playSound("hit.wav")
                if let remoteNode = remoteTankNode {
                    createExplosion(at: remoteTankPosition, color: .red, in: remoteNode, isLocalTank: false)
                }
            }
            
            // Check if round ended after update
            if state.isRoundOver() {
                let localWon = state.localPlayerWon()
                
                // Wait for explosion to complete before showing round end
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    
                    // Update score and play win/lose sound
                    if localWon {
                        self.gameState?.localWins += 1
                        self.playSound("win.wav")
                    } else {
                        self.gameState?.remoteWins += 1
                        self.playSound("lose.wav")
                    }
                    
                    // Remove tank nodes now that explosion is done
                    self.renderTanks()
                    self.showRoundEnd(localWon: localWon)
                    self.updateScore()
                    
                    // Notify that round ended after a longer delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                        self?.onGameMessage?(.readyForNextRound)
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
        state.projectiles.append(projectile)
        renderProjectiles()
        playSound("shoot.wav")
        
        // Send shoot message
        onGameMessage?(.playerShoot(projectile: projectile))
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

