//
//  GameScene.swift
//  Tank Game
//
//  Main SpriteKit scene: rendering, input, and game loop.
//

import SpriteKit

/// Callback for game events
protocol GameSceneDelegate: AnyObject {
    func gameScene(_ scene: GameScene, playerMoved direction: Direction)
    func gameScene(_ scene: GameScene, playerShot projectile: Projectile)
    func gameScene(_ scene: GameScene, playerHit peerId: String)
}

/// Main game scene
class GameScene: SKScene {

    weak var gameDelegate: GameSceneDelegate?

    var game: Game?

    // Layout constants
    let tileSize: CGFloat = 64
    let gridSize = 8

    // Node containers
    private var gridNode: SKNode!
    private var tanksNode: SKNode!
    private var projectilesNode: SKNode!

    // UI elements
    private var joystickBase: SKShapeNode!
    private var joystickStick: SKShapeNode!
    private var fireButton: SKShapeNode!
    private var scoreLabels: [SKLabelNode] = []
    private var statusLabel: SKLabelNode!

    // Touch tracking
    private var joystickTouch: UITouch?
    private var currentDirection: Direction?

    // Timing
    private var lastUpdateTime: TimeInterval = 0
    private var lastMoveTime: TimeInterval = 0
    private var lastProjectileUpdate: TimeInterval = 0
    private let moveInterval: TimeInterval = 0.15
    private let projectileInterval: TimeInterval = 0.05

    // Colors for players (8 base colors, hash fallback for more)
    private let baseColors: [UIColor] = [
        .systemBlue, .systemRed, .systemGreen, .systemOrange,
        .systemPurple, .systemPink, .systemTeal, .systemYellow
    ]

    // MARK: - Scene Setup

    static func newScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 600, height: 800))
        scene.scaleMode = .aspectFit
        return scene
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.15, alpha: 1)
        setupNodes()
        setupUI()

        if game != nil {
            renderGrid()
            renderTanks()
            updateScores()
        }
    }

    private func setupNodes() {
        // Calculate grid position (centered horizontally, toward top)
        let gridWidth = CGFloat(gridSize) * tileSize
        let gridX = (size.width - gridWidth) / 2
        let gridY = size.height - gridWidth - 60

        gridNode = SKNode()
        gridNode.position = CGPoint(x: gridX, y: gridY)
        addChild(gridNode)

        tanksNode = SKNode()
        tanksNode.position = gridNode.position
        tanksNode.zPosition = 10
        addChild(tanksNode)

        projectilesNode = SKNode()
        projectilesNode.position = gridNode.position
        projectilesNode.zPosition = 5
        addChild(projectilesNode)
    }

    private func setupUI() {
        // Joystick (bottom left)
        let joystickRadius: CGFloat = 60
        let baseRadius: CGFloat = 80
        let joystickX: CGFloat = 100
        let joystickY: CGFloat = 120

        joystickBase = SKShapeNode(circleOfRadius: baseRadius)
        joystickBase.fillColor = SKColor(white: 0.3, alpha: 0.5)
        joystickBase.strokeColor = SKColor(white: 0.5, alpha: 0.5)
        joystickBase.lineWidth = 2
        joystickBase.position = CGPoint(x: joystickX, y: joystickY)
        joystickBase.zPosition = 100
        addChild(joystickBase)

        joystickStick = SKShapeNode(circleOfRadius: joystickRadius / 2)
        joystickStick.fillColor = SKColor(white: 0.6, alpha: 0.8)
        joystickStick.strokeColor = .clear
        joystickStick.position = joystickBase.position
        joystickStick.zPosition = 101
        addChild(joystickStick)

        // Fire button (bottom right)
        fireButton = SKShapeNode(circleOfRadius: 50)
        fireButton.fillColor = .systemRed.withAlphaComponent(0.7)
        fireButton.strokeColor = .white
        fireButton.lineWidth = 3
        fireButton.position = CGPoint(x: size.width - 100, y: 120)
        fireButton.zPosition = 100
        addChild(fireButton)

        let fireLabel = SKLabelNode(text: "FIRE")
        fireLabel.fontName = "AvenirNext-Bold"
        fireLabel.fontSize = 18
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireButton.addChild(fireLabel)

        // Score labels (top) - create 8 slots, show dynamically
        for i in 0..<8 {
            let label = SKLabelNode()
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 16
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 40 + CGFloat(i % 4) * 140, y: size.height - 20 - CGFloat(i / 4) * 25)
            label.zPosition = 100
            label.isHidden = true
            addChild(label)
            scoreLabels.append(label)
        }

        // Status label
        statusLabel = SKLabelNode()
        statusLabel.fontName = "AvenirNext-Bold"
        statusLabel.fontSize = 28
        statusLabel.fontColor = .white
        statusLabel.horizontalAlignmentMode = .center
        statusLabel.verticalAlignmentMode = .center
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        statusLabel.zPosition = 200
        statusLabel.isHidden = true
        addChild(statusLabel)
    }

    // MARK: - Color Assignment

    private func color(for peerId: String) -> UIColor {
        guard let game = game else { return baseColors[0] }

        // Get sorted peer IDs for consistent ordering
        let sortedIds = game.sortedPeerIds
        if let index = sortedIds.firstIndex(of: peerId) {
            if index < baseColors.count {
                return baseColors[index]
            }
            // Hash fallback for >8 players
            let hash = abs(peerId.hashValue)
            return UIColor(
                hue: CGFloat(hash % 360) / 360.0,
                saturation: 0.7,
                brightness: 0.9,
                alpha: 1.0
            )
        }
        return baseColors[0]
    }

    // MARK: - Rendering

    func renderGrid() {
        gridNode.removeAllChildren()
        guard let game = game else { return }

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let isWall = game.map.grid[row][col]
                let tile = SKShapeNode(rectOf: CGSize(width: tileSize - 2, height: tileSize - 2), cornerRadius: 4)
                tile.fillColor = isWall ? SKColor(white: 0.4, alpha: 1) : SKColor(white: 0.2, alpha: 1)
                tile.strokeColor = SKColor(white: 0.3, alpha: 1)
                tile.lineWidth = 1
                tile.position = position(for: row, col: col)
                gridNode.addChild(tile)
            }
        }
    }

    func renderTanks() {
        tanksNode.removeAllChildren()
        guard let game = game else { return }

        for (peerId, data) in game.players {
            guard data.tank.isAlive else { continue }

            let tankNode = createTankNode(color: color(for: peerId))
            tankNode.position = position(for: data.tank.row, col: data.tank.col)
            tankNode.zRotation = CGFloat(data.tank.direction.rotation)
            tankNode.name = "tank_\(peerId)"
            tanksNode.addChild(tankNode)
        }
    }

    func renderTanksSmooth() {
        guard let game = game else { return }

        for (peerId, data) in game.players {
            if let node = tanksNode.childNode(withName: "tank_\(peerId)") {
                if data.tank.isAlive {
                    let targetPos = position(for: data.tank.row, col: data.tank.col)
                    let move = SKAction.move(to: targetPos, duration: 0.1)
                    let rotate = SKAction.rotate(toAngle: CGFloat(data.tank.direction.rotation), duration: 0.1, shortestUnitArc: true)
                    node.run(SKAction.group([move, rotate]))
                } else {
                    // Death animation
                    let explode = SKAction.sequence([
                        SKAction.group([
                            SKAction.scale(to: 1.5, duration: 0.15),
                            SKAction.fadeOut(withDuration: 0.15)
                        ]),
                        SKAction.removeFromParent()
                    ])
                    node.run(explode)
                }
            } else if data.tank.isAlive {
                // Tank needs to be created
                let tankNode = createTankNode(color: color(for: peerId))
                tankNode.position = position(for: data.tank.row, col: data.tank.col)
                tankNode.zRotation = CGFloat(data.tank.direction.rotation)
                tankNode.name = "tank_\(peerId)"
                tanksNode.addChild(tankNode)
            }
        }
    }

    func renderProjectiles() {
        projectilesNode.removeAllChildren()
        guard let game = game else { return }

        for projectile in game.projectiles {
            let node = SKShapeNode(circleOfRadius: 6)
            node.fillColor = .yellow
            node.strokeColor = .orange
            node.lineWidth = 2
            node.position = position(for: projectile.row, col: projectile.col)
            node.zPosition = 5
            projectilesNode.addChild(node)
        }
    }

    private func createTankNode(color: UIColor) -> SKNode {
        let tank = SKNode()

        // Body
        let body = SKShapeNode(rectOf: CGSize(width: tileSize * 0.7, height: tileSize * 0.6), cornerRadius: 4)
        body.fillColor = color
        body.strokeColor = color.withAlphaComponent(0.5)
        body.lineWidth = 2
        tank.addChild(body)

        // Turret
        let turret = SKShapeNode(rectOf: CGSize(width: 8, height: tileSize * 0.4))
        turret.fillColor = color.withAlphaComponent(0.8)
        turret.strokeColor = .clear
        turret.position = CGPoint(x: 0, y: tileSize * 0.3)
        tank.addChild(turret)

        return tank
    }

    private func position(for row: Int, col: Int) -> CGPoint {
        CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }

    // MARK: - Dynamic Player UI

    /// Spawn a tank with animation
    func spawnTank(for peerId: String, at row: Int, col: Int, direction: Direction) {
        // Remove existing node if any
        tanksNode.childNode(withName: "tank_\(peerId)")?.removeFromParent()

        let tankNode = createTankNode(color: color(for: peerId))
        tankNode.position = position(for: row, col: col)
        tankNode.zRotation = CGFloat(direction.rotation)
        tankNode.name = "tank_\(peerId)"

        // Spawn animation
        tankNode.setScale(0)
        tankNode.alpha = 0
        tanksNode.addChild(tankNode)

        let spawnAnim = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.3),
            SKAction.fadeIn(withDuration: 0.3)
        ])
        spawnAnim.timingMode = .easeOut
        tankNode.run(spawnAnim)

        updateScores()
    }

    /// Remove a tank (for disconnects)
    func removeTank(for peerId: String) {
        tanksNode.childNode(withName: "tank_\(peerId)")?.removeFromParent()
    }

    /// Show explosion effect at position
    func showExplosion(at row: Int, col: Int) {
        let pos = position(for: row, col: col)

        // Create explosion particles
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 6)
            particle.fillColor = .orange
            particle.strokeColor = .yellow
            particle.lineWidth = 2
            particle.position = pos
            particle.zPosition = 15
            tanksNode.addChild(particle)

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 30...60)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance

            let explodeAnim = SKAction.sequence([
                SKAction.group([
                    SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 0.3),
                    SKAction.scale(to: 0.1, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3)
                ]),
                SKAction.removeFromParent()
            ])
            particle.run(explodeAnim)
        }

        // Flash effect
        let flash = SKShapeNode(circleOfRadius: 40)
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.alpha = 0.8
        flash.position = pos
        flash.zPosition = 14
        tanksNode.addChild(flash)

        let flashAnim = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ])
        flash.run(flashAnim)
    }

    /// Full refresh for world state sync
    func fullRefresh() {
        renderGrid()
        renderTanks()
        renderProjectiles()
        updateScores()
    }

    // MARK: - UI Updates

    func updateScores() {
        guard let game = game else { return }

        // Hide all labels first
        for label in scoreLabels {
            label.isHidden = true
        }

        // Show scores for current players
        let sortedIds = game.sortedPeerIds
        for (i, peerId) in sortedIds.enumerated() {
            guard i < scoreLabels.count else { break }

            let label = scoreLabels[i]
            label.isHidden = false
            label.fontColor = color(for: peerId)

            let score = game.score(for: peerId)
            if peerId == game.localPeerId {
                label.text = "You: \(score)"
            } else {
                // Show abbreviated peer ID
                let shortId = String(peerId.prefix(4))
                label.text = "\(shortId): \(score)"
            }
        }
    }

    func showStatus(_ text: String, duration: TimeInterval = 2.0) {
        statusLabel.text = text
        statusLabel.isHidden = false
        statusLabel.alpha = 1

        statusLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.run { self.statusLabel.isHidden = true }
        ]))
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            // Fire button
            if fireButton.contains(location) {
                fire()
                return
            }

            // Joystick
            let joystickDist = hypot(location.x - joystickBase.position.x, location.y - joystickBase.position.y)
            if joystickDist < 100 {
                joystickTouch = touch
                updateJoystick(touch: touch)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                updateJoystick(touch: touch)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                joystickTouch = nil
                currentDirection = nil
                joystickStick.position = joystickBase.position
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func updateJoystick(touch: UITouch) {
        let location = touch.location(in: self)
        let basePos = joystickBase.position

        var dx = location.x - basePos.x
        var dy = location.y - basePos.y
        let dist = hypot(dx, dy)
        let maxDist: CGFloat = 40

        // Clamp to max distance
        if dist > maxDist {
            dx = dx / dist * maxDist
            dy = dy / dist * maxDist
        }

        joystickStick.position = CGPoint(x: basePos.x + dx, y: basePos.y + dy)

        // Determine direction (only if moved enough)
        if dist > 20 {
            let angle = atan2(dy, dx)
            if angle > .pi * 0.25 && angle < .pi * 0.75 {
                currentDirection = .up
            } else if angle < -.pi * 0.25 && angle > -.pi * 0.75 {
                currentDirection = .down
            } else if abs(angle) < .pi * 0.25 {
                currentDirection = .right
            } else {
                currentDirection = .left
            }
        } else {
            currentDirection = nil
        }
    }

    private func fire() {
        guard let game = game else { return }
        guard game.localTank.isAlive else { return }

        var projectile = game.localTank.shoot()
        projectile.ownerId = game.localPeerId
        gameDelegate?.gameScene(self, playerShot: projectile)
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard let game = game else { return }

        // Get a local copy of the tank to avoid exclusive access violations
        guard var tank = game.players[game.localPeerId]?.tank, tank.isAlive else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        // Move local tank
        if currentTime - lastMoveTime > moveInterval {
            if let dir = currentDirection {
                let oldDir = tank.direction
                let moved = tank.move(dir, on: game.map.grid)

                if moved || tank.direction != oldDir {
                    // Write the mutated tank back
                    self.game?.players[game.localPeerId]?.tank = tank
                    gameDelegate?.gameScene(self, playerMoved: dir)
                    renderTanksSmooth()
                }
                lastMoveTime = currentTime
            }
        }

        // Update projectiles
        if currentTime - lastProjectileUpdate > projectileInterval {
            let hitPeers = game.projectiles.isEmpty ? [] : game.updateProjectiles()
            renderProjectiles()

            for hitPeerId in hitPeers {
                gameDelegate?.gameScene(self, playerHit: hitPeerId)
                renderTanksSmooth()
            }

            lastProjectileUpdate = currentTime
        }

        lastUpdateTime = currentTime
    }
}
