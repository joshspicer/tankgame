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
    func gameScene(_ scene: GameScene, didChangeGridSize delta: Int)
}

/// Main game scene
class GameScene: SKScene {

    weak var gameDelegate: GameSceneDelegate?

    var game: Game?

    /// Whether the local player is the elder (for debug display)
    var isLocalPlayerElder: Bool = false

    /// Current grid size from game (or default)
    private var currentGridSize: Int {
        game?.gridSize ?? 8
    }

    /// Tile size calculated to fit the screen
    private var tileSize: CGFloat {
        // Use the smaller dimension to ensure grid fits, with padding for UI
        let availableWidth = size.width - 40  // 20px padding each side
        let availableHeight = size.height - 280  // Leave room for controls at bottom
        let maxGridSize = min(availableWidth, availableHeight)
        return floor(maxGridSize / CGFloat(currentGridSize))
    }

    // Settings UI (elder only)
    private var settingsButton: SKNode?
    private var settingsModal: SKNode?
    private var gridSizeLabel: SKLabelNode?
    private var isSettingsModalVisible: Bool = false

    // Node containers
    private var gridNode: SKNode!
    private var tanksNode: SKNode!
    private var projectilesNode: SKNode!
    private var borderNode: SKShapeNode!

    // UI elements
    private var joystickBase: SKShapeNode!
    private var joystickStick: SKShapeNode!
    private var fireButton: SKShapeNode!
    private var scoreboardNode: SKNode!
    private var statusLabel: SKLabelNode!
    private var respawnOverlay: SKNode?
    private var respawnCountdownLabel: SKLabelNode?
    private var respawnEndTime: TimeInterval = 0

    // Touch tracking
    private var joystickTouch: UITouch?
    private var currentDirection: Direction?

    // Timing
    private var lastUpdateTime: TimeInterval = 0
    private var lastMoveTime: TimeInterval = 0
    private var lastProjectileUpdate: TimeInterval = 0
    private let moveInterval: TimeInterval = 0.15
    private let projectileInterval: TimeInterval = 0.05

    // Color cache to avoid recalculating (keyed by peerId)
    private var colorCache: [String: UIColor] = [:]

    // MARK: - Scene Setup

    static func newScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
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
        let gridWidth = CGFloat(currentGridSize) * tileSize
        let gridX = (size.width - gridWidth) / 2
        let gridY = size.height - gridWidth - 60

        // Border around grid (will be colored with player color)
        let borderPadding: CGFloat = 6
        let borderRect = CGRect(
            x: gridX - borderPadding,
            y: gridY - borderPadding,
            width: gridWidth + borderPadding * 2,
            height: gridWidth + borderPadding * 2
        )
        borderNode = SKShapeNode(rect: borderRect, cornerRadius: 8)
        borderNode.fillColor = .clear
        borderNode.strokeColor = .white
        borderNode.lineWidth = 4
        borderNode.zPosition = -1
        addChild(borderNode)

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

        // Scoreboard container (positioned below grid)
        let gridWidth = CGFloat(currentGridSize) * tileSize
        let gridBottomY = size.height - gridWidth - 60  // Same calculation as setupNodes
        scoreboardNode = SKNode()
        scoreboardNode.position = CGPoint(x: size.width / 2, y: gridBottomY - 25)
        scoreboardNode.zPosition = 100
        addChild(scoreboardNode)

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

        // Settings UI (top right corner)
        setupSettingsUI()
    }

    private func setupSettingsUI() {
        settingsButton?.removeFromParent()

        // Only show settings button for elder
        guard isLocalPlayerElder else {
            settingsButton = nil
            return
        }

        // Small subtle gear button container
        let button = SKNode()
        button.position = CGPoint(x: size.width - 30, y: size.height - 45)
        button.zPosition = 100
        button.name = "settings_button"

        // Small subtle background
        let bg = SKShapeNode(circleOfRadius: 16)
        bg.fillColor = SKColor(white: 0.2, alpha: 0.4)
        bg.strokeColor = SKColor(white: 0.4, alpha: 0.3)
        bg.lineWidth = 1
        bg.name = "settings_button"
        button.addChild(bg)

        // Subtle gear icon
        let gearLabel = SKLabelNode(text: "⚙")
        gearLabel.fontName = "AvenirNext-Medium"
        gearLabel.fontSize = 16
        gearLabel.fontColor = SKColor(white: 0.7, alpha: 0.7)
        gearLabel.horizontalAlignmentMode = .center
        gearLabel.verticalAlignmentMode = .center
        gearLabel.position = CGPoint(x: 0, y: -1)
        gearLabel.name = "settings_button"
        button.addChild(gearLabel)

        addChild(button)
        settingsButton = button
    }

    /// Show settings modal overlay
    private func showSettingsModal() {
        guard settingsModal == nil else { return }

        isSettingsModalVisible = true

        // Modal container
        let modal = SKNode()
        modal.zPosition = 200

        // Dimmed background (tap to close)
        let dimBg = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimBg.fillColor = SKColor(white: 0, alpha: 0.5)
        dimBg.strokeColor = .clear
        dimBg.name = "settings_modal_bg"
        modal.addChild(dimBg)

        // Modal panel
        let panelWidth: CGFloat = 240
        let panelHeight: CGFloat = 160
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 16)
        panel.fillColor = SKColor(white: 0.15, alpha: 0.95)
        panel.strokeColor = SKColor(white: 0.4, alpha: 1)
        panel.lineWidth = 2
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.name = "settings_modal_panel"
        modal.addChild(panel)

        // Title
        let title = SKLabelNode(text: "SETTINGS")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 20
        title.fontColor = .white
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 50)
        panel.addChild(title)

        // Grid size label
        let gridLabel = SKLabelNode(text: "Grid Size")
        gridLabel.fontName = "AvenirNext-Medium"
        gridLabel.fontSize = 14
        gridLabel.fontColor = SKColor(white: 0.7, alpha: 1)
        gridLabel.horizontalAlignmentMode = .center
        gridLabel.verticalAlignmentMode = .center
        gridLabel.position = CGPoint(x: 0, y: 10)
        panel.addChild(gridLabel)

        // Grid size controls row
        let controlsY: CGFloat = -25

        // Minus button
        let minusBtn = SKShapeNode(circleOfRadius: 20)
        minusBtn.fillColor = SKColor(white: 0.3, alpha: 1)
        minusBtn.strokeColor = SKColor(white: 0.5, alpha: 1)
        minusBtn.lineWidth = 2
        minusBtn.position = CGPoint(x: -60, y: controlsY)
        minusBtn.name = "settings_minus"
        panel.addChild(minusBtn)

        let minusLabel = SKLabelNode(text: "−")
        minusLabel.fontName = "AvenirNext-Bold"
        minusLabel.fontSize = 28
        minusLabel.fontColor = .white
        minusLabel.horizontalAlignmentMode = .center
        minusLabel.verticalAlignmentMode = .center
        minusLabel.position = CGPoint(x: 0, y: -2)
        minusBtn.addChild(minusLabel)

        // Grid size value
        let sizeLabel = SKLabelNode(text: "\(currentGridSize)×\(currentGridSize)")
        sizeLabel.fontName = "AvenirNext-Bold"
        sizeLabel.fontSize = 22
        sizeLabel.fontColor = .white
        sizeLabel.horizontalAlignmentMode = .center
        sizeLabel.verticalAlignmentMode = .center
        sizeLabel.position = CGPoint(x: 0, y: controlsY)
        panel.addChild(sizeLabel)
        gridSizeLabel = sizeLabel

        // Plus button
        let plusBtn = SKShapeNode(circleOfRadius: 20)
        plusBtn.fillColor = SKColor(white: 0.3, alpha: 1)
        plusBtn.strokeColor = SKColor(white: 0.5, alpha: 1)
        plusBtn.lineWidth = 2
        plusBtn.position = CGPoint(x: 60, y: controlsY)
        plusBtn.name = "settings_plus"
        panel.addChild(plusBtn)

        let plusLabel = SKLabelNode(text: "+")
        plusLabel.fontName = "AvenirNext-Bold"
        plusLabel.fontSize = 28
        plusLabel.fontColor = .white
        plusLabel.horizontalAlignmentMode = .center
        plusLabel.verticalAlignmentMode = .center
        plusLabel.position = CGPoint(x: 0, y: -2)
        plusBtn.addChild(plusLabel)

        // Close button
        let closeBtn = SKShapeNode(circleOfRadius: 16)
        closeBtn.fillColor = SKColor(white: 0.25, alpha: 1)
        closeBtn.strokeColor = SKColor(white: 0.5, alpha: 1)
        closeBtn.lineWidth = 1
        closeBtn.position = CGPoint(x: panelWidth / 2 - 20, y: panelHeight / 2 - 20)
        closeBtn.name = "settings_close"
        panel.addChild(closeBtn)

        let closeLabel = SKLabelNode(text: "✕")
        closeLabel.fontName = "AvenirNext-Bold"
        closeLabel.fontSize = 16
        closeLabel.fontColor = .white
        closeLabel.horizontalAlignmentMode = .center
        closeLabel.verticalAlignmentMode = .center
        closeLabel.position = CGPoint(x: 0, y: -1)
        closeBtn.addChild(closeLabel)

        // Fade in animation
        modal.alpha = 0
        addChild(modal)
        modal.run(SKAction.fadeIn(withDuration: 0.15))

        settingsModal = modal
    }

    /// Hide settings modal
    private func hideSettingsModal() {
        guard let modal = settingsModal else { return }

        isSettingsModalVisible = false

        modal.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.removeFromParent()
        ]))

        settingsModal = nil
        gridSizeLabel = nil
    }

    /// Update settings UI visibility and state
    func updateSettingsUI() {
        // Recreate settings button based on elder status
        setupSettingsUI()

        // Update grid size label in modal if visible
        gridSizeLabel?.text = "\(currentGridSize)×\(currentGridSize)"
    }

    // MARK: - Color Assignment

    /// Generate a deterministic color from peerId - always the same for a given device
    private func color(for peerId: String) -> UIColor {
        // Check cache first
        if let cached = colorCache[peerId] {
            return cached
        }

        // Generate deterministic color from peerId using a stable hash
        // Use a simple string hash that's stable across runs
        var hash: UInt64 = 5381
        for char in peerId.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }

        // Use golden ratio to spread hues evenly
        let goldenRatio: Double = 0.618033988749895
        let hue = (Double(hash % 1000) / 1000.0 + goldenRatio).truncatingRemainder(dividingBy: 1.0)

        let color = UIColor(
            hue: CGFloat(hue),
            saturation: 0.7,
            brightness: 0.85,
            alpha: 1.0
        )

        colorCache[peerId] = color
        return color
    }

    // MARK: - Rendering

    func renderGrid() {
        gridNode.removeAllChildren()
        guard let game = game else { return }

        for row in 0..<currentGridSize {
            for col in 0..<currentGridSize {
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
                    // Ensure node is visible (might have been faded from death animation)
                    node.alpha = 1.0
                    node.setScale(1.0)
                    node.removeAllActions()

                    let targetPos = position(for: data.tank.row, col: data.tank.col)
                    let move = SKAction.move(to: targetPos, duration: 0.1)
                    let rotate = SKAction.rotate(toAngle: CGFloat(data.tank.direction.rotation), duration: 0.1, shortestUnitArc: true)
                    node.run(SKAction.group([move, rotate]))
                } else {
                    // Death animation - just hide, don't remove (spawnTank handles removal)
                    let explode = SKAction.group([
                        SKAction.scale(to: 1.5, duration: 0.15),
                        SKAction.fadeOut(withDuration: 0.15)
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
            y: CGFloat(currentGridSize - 1 - row) * tileSize + tileSize / 2
        )
    }

    // MARK: - Dynamic Player UI

    /// Spawn a tank with animation
    func spawnTank(for peerId: String, at row: Int, col: Int, direction: Direction) {
        // Remove ALL existing nodes for this player (stop any running death animations)
        while let existingNode = tanksNode.childNode(withName: "tank_\(peerId)") {
            existingNode.removeAllActions()
            existingNode.removeFromParent()
        }

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

        // Update border to local player's color
        let myColor = color(for: game.localPeerId)
        borderNode.strokeColor = myColor

        // Rebuild scoreboard
        scoreboardNode.removeAllChildren()

        // Sort players by score (descending), then by peerId
        let sortedPlayers = game.players.sorted { a, b in
            if a.value.score != b.value.score {
                return a.value.score > b.value.score
            }
            return a.key < b.key
        }

        // Create compact score display
        let maxDisplay = min(sortedPlayers.count, 6)
        let spacing: CGFloat = 90
        let startX = -CGFloat(maxDisplay - 1) * spacing / 2

        // Determine who is the elder (lowest peerId alphabetically)
        let elderPeerId = sortedPlayers.map(\.key).sorted().first

        for (i, (peerId, _)) in sortedPlayers.prefix(maxDisplay).enumerated() {
            let playerColor = color(for: peerId)
            let score = game.score(for: peerId)
            let isLocal = peerId == game.localPeerId
            let isElder = peerId == elderPeerId

            // Color indicator - star for elder, dot for others
            if isElder {
                // Star shape for elder
                let star = SKLabelNode(text: "★")
                star.fontName = "AvenirNext-Bold"
                star.fontSize = 16
                star.fontColor = playerColor
                star.horizontalAlignmentMode = .center
                star.verticalAlignmentMode = .center
                star.position = CGPoint(x: startX + CGFloat(i) * spacing - 25, y: 0)
                if isLocal {
                    // Add glow effect for local elder
                    let glow = SKLabelNode(text: "★")
                    glow.fontName = "AvenirNext-Bold"
                    glow.fontSize = 20
                    glow.fontColor = .white
                    glow.alpha = 0.5
                    glow.horizontalAlignmentMode = .center
                    glow.verticalAlignmentMode = .center
                    glow.position = star.position
                    glow.zPosition = -1
                    scoreboardNode.addChild(glow)
                }
                scoreboardNode.addChild(star)
            } else {
                // Regular dot
                let dot = SKShapeNode(circleOfRadius: 6)
                dot.fillColor = playerColor
                dot.strokeColor = isLocal ? .white : .clear
                dot.lineWidth = isLocal ? 2 : 0
                dot.position = CGPoint(x: startX + CGFloat(i) * spacing - 25, y: 0)
                scoreboardNode.addChild(dot)
            }

            // Score text
            let label = SKLabelNode(text: "\(score)")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = isLocal ? 18 : 14
            label.fontColor = playerColor
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: startX + CGFloat(i) * spacing - 12, y: 0)
            scoreboardNode.addChild(label)

            // "YOU" label for local player
            if isLocal {
                let youLabel = SKLabelNode(text: "YOU")
                youLabel.fontName = "AvenirNext-Bold"
                youLabel.fontSize = 10
                youLabel.fontColor = playerColor.withAlphaComponent(0.7)
                youLabel.horizontalAlignmentMode = .center
                youLabel.verticalAlignmentMode = .center
                youLabel.position = CGPoint(x: startX + CGFloat(i) * spacing - 5, y: -15)
                scoreboardNode.addChild(youLabel)
            }
        }

        // If more players than displayed, show count
        if sortedPlayers.count > maxDisplay {
            let moreLabel = SKLabelNode(text: "+\(sortedPlayers.count - maxDisplay)")
            moreLabel.fontName = "AvenirNext-Bold"
            moreLabel.fontSize = 12
            moreLabel.fontColor = SKColor(white: 0.6, alpha: 1)
            moreLabel.horizontalAlignmentMode = .left
            moreLabel.verticalAlignmentMode = .center
            moreLabel.position = CGPoint(x: startX + CGFloat(maxDisplay) * spacing - 25, y: 0)
            scoreboardNode.addChild(moreLabel)
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

    /// Show respawn countdown with spinner animation
    func showRespawnCountdown(duration: TimeInterval) {
        // Remove any existing overlay
        hideRespawnCountdown()

        // Create overlay container
        let overlay = SKNode()
        overlay.zPosition = 150

        // Dimmed background
        let dimBackground = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimBackground.fillColor = SKColor(white: 0, alpha: 0.4)
        dimBackground.strokeColor = .clear
        dimBackground.position = .zero
        overlay.addChild(dimBackground)

        // Center container for spinner and text
        let centerY = size.height / 2

        // Spinner ring
        let spinnerRadius: CGFloat = 40
        let spinner = SKShapeNode()
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: spinnerRadius, startAngle: 0, endAngle: .pi * 1.5, clockwise: false)
        spinner.path = path
        spinner.strokeColor = .white
        spinner.lineWidth = 4
        spinner.lineCap = .round
        spinner.position = CGPoint(x: size.width / 2, y: centerY + 20)
        spinner.zPosition = 151

        // Rotate spinner continuously
        let rotate = SKAction.rotate(byAngle: -.pi * 2, duration: 1.0)
        spinner.run(SKAction.repeatForever(rotate))
        overlay.addChild(spinner)

        // Countdown label inside spinner
        let countdownLabel = SKLabelNode()
        countdownLabel.fontName = "AvenirNext-Bold"
        countdownLabel.fontSize = 24
        countdownLabel.fontColor = .white
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: size.width / 2, y: centerY + 20)
        countdownLabel.zPosition = 152
        overlay.addChild(countdownLabel)

        // "RESPAWNING" label below
        let respawnLabel = SKLabelNode(text: "RESPAWNING")
        respawnLabel.fontName = "AvenirNext-Bold"
        respawnLabel.fontSize = 18
        respawnLabel.fontColor = SKColor(white: 0.8, alpha: 1)
        respawnLabel.horizontalAlignmentMode = .center
        respawnLabel.verticalAlignmentMode = .center
        respawnLabel.position = CGPoint(x: size.width / 2, y: centerY - 40)
        respawnLabel.zPosition = 151
        overlay.addChild(respawnLabel)

        addChild(overlay)
        respawnOverlay = overlay
        respawnCountdownLabel = countdownLabel
        respawnEndTime = CACurrentMediaTime() + duration
    }

    /// Hide respawn countdown
    func hideRespawnCountdown() {
        respawnOverlay?.removeFromParent()
        respawnOverlay = nil
        respawnCountdownLabel = nil
        respawnEndTime = 0
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            // Handle settings modal if visible
            if isSettingsModalVisible, let modal = settingsModal {
                let modalLocation = touch.location(in: modal)
                let node = modal.atPoint(modalLocation)
                let name = node.name ?? node.parent?.name ?? node.parent?.parent?.name

                if name == "settings_minus" && currentGridSize > 4 {
                    gameDelegate?.gameScene(self, didChangeGridSize: -1)
                    return
                } else if name == "settings_plus" && currentGridSize < 12 {
                    gameDelegate?.gameScene(self, didChangeGridSize: 1)
                    return
                } else if name == "settings_close" || name == "settings_modal_bg" {
                    hideSettingsModal()
                    return
                } else if name == "settings_modal_panel" {
                    // Tap inside panel but not on a button - do nothing
                    return
                }
                // If touched elsewhere in modal, close it
                hideSettingsModal()
                return
            }

            // Check settings button (elder only) - use distance check for proper hit detection
            if isLocalPlayerElder, let button = settingsButton {
                let buttonDist = hypot(location.x - button.position.x, location.y - button.position.y)
                if buttonDist < 25 {  // Slightly larger than button radius (16) for easier tap
                    showSettingsModal()
                    return
                }
            }

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
        // Update respawn countdown label
        if respawnEndTime > 0 {
            let remaining = max(0, respawnEndTime - CACurrentMediaTime())
            respawnCountdownLabel?.text = String(format: "%.1f", remaining)
            if remaining <= 0 {
                hideRespawnCountdown()
            }
        }

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
