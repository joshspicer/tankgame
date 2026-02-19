//
//  GameScene.swift
//  Tank Game
//
//  Main SpriteKit scene: core class definition and setup.
//  Extensions: +Rendering, +UI, +Settings, +Input, +GameLoop
//

import SpriteKit

/// Callback for game events
protocol GameSceneDelegate: AnyObject {
    func gameScene(_ scene: GameScene, playerMoved direction: Direction)
    func gameScene(_ scene: GameScene, playerShot projectile: Projectile)
    func gameScene(_ scene: GameScene, playerHit victimId: String, byShooter shooterId: String)
    func gameScene(_ scene: GameScene, didChangeGridSize delta: Int)
}

/// Main game scene
class GameScene: SKScene {

    weak var gameDelegate: GameSceneDelegate?

    var game: Game?

    /// Whether the local player is the elder (for settings access)
    var isLocalPlayerElder: Bool = false

    // MARK: - Computed Properties

    /// Current grid size from game (or default)
    var currentGridSize: Int {
        game?.gridSize ?? 8
    }

    /// Tile size calculated to fit the screen
    var tileSize: CGFloat {
        let availableWidth = size.width - 40
        let availableHeight = size.height - 280
        let maxGridSize = min(availableWidth, availableHeight)
        return floor(maxGridSize / CGFloat(currentGridSize))
    }

    // MARK: - Node Containers

    var gridNode: SKNode!
    var tanksNode: SKNode!
    var projectilesNode: SKNode!
    var borderNode: SKShapeNode!

    // MARK: - UI Elements

    var joystickBase: SKShapeNode!
    var joystickStick: SKShapeNode!
    var fireButton: SKShapeNode!
    var scoreboardNode: SKNode!
    var statusLabel: SKLabelNode!
    var respawnOverlay: SKNode?
    var respawnCountdownLabel: SKLabelNode?
    var respawnEndTime: TimeInterval = 0

    // MARK: - Settings UI

    var settingsButton: SKNode?
    var settingsModal: SKNode?
    var gridSizeLabel: SKLabelNode?
    var isSettingsModalVisible: Bool = false

    // MARK: - Input State

    var joystickTouch: UITouch?
    var currentDirection: Direction?

    // MARK: - Timing

    var lastUpdateTime: TimeInterval = 0
    var lastMoveTime: TimeInterval = 0
    var lastProjectileUpdate: TimeInterval = 0
    let moveInterval: TimeInterval = 0.15
    let projectileInterval: TimeInterval = 0.05

    // MARK: - Color Cache

    var colorCache: [String: UIColor] = [:]

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

#if os(tvOS)
        setupControllerInput()
#endif

        if game != nil {
            renderGrid()
            renderTanks()
            updateScores()
        }
    }

    func setupNodes() {
        let gridWidth = CGFloat(currentGridSize) * tileSize
        let gridX = (size.width - gridWidth) / 2
        let gridY = size.height - gridWidth - 60

        // Border around grid
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

    /// Full refresh for world state sync
    func fullRefresh() {
        renderGrid()
        renderTanks()
        renderProjectiles()
        updateScores()
    }

    /// Convert grid position to screen coordinates
    func position(for row: Int, col: Int) -> CGPoint {
        CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(currentGridSize - 1 - row) * tileSize + tileSize / 2
        )
    }

    /// Generate a deterministic color from peerId
    func color(for peerId: String) -> UIColor {
        if let cached = colorCache[peerId] {
            return cached
        }

        var hash: UInt64 = 5381
        for char in peerId.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }

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
}
