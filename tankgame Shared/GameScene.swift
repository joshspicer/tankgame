//
//  GameScene.swift
//  tankgame Shared
//
//  SpriteKit scene with clean rendering

import SpriteKit

final class GameScene: SKScene {

    // MARK: - Properties
    weak var viewModel: GameViewModel?

    private let tileSize: CGFloat = 64
    private let gridSize = 8

    private var gridNode: SKNode!
    private var entitiesNode: SKNode!
    private var controlsNode: SKNode!
    private var joystick: SKShapeNode!
    private var fireButton: SKShapeNode!

    // MARK: - Setup
    static func create(viewModel: GameViewModel) -> GameScene {
        let scene = GameScene(size: CGSize(width: 600, height: 800))
        scene.viewModel = viewModel
        scene.scaleMode = .aspectFit
        return scene
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.2, alpha: 1.0)
        setupNodes()
        setupControls()
    }

    private func setupNodes() {
        gridNode = SKNode()
        gridNode.position = CGPoint(x: size.width / 2 - CGFloat(gridSize) * tileSize / 2,
                                    y: size.height / 2)
        addChild(gridNode)

        entitiesNode = SKNode()
        entitiesNode.position = gridNode.position
        addChild(entitiesNode)

        controlsNode = SKNode()
        addChild(controlsNode)
    }

    private func setupControls() {
        // Joystick
        joystick = SKShapeNode(circleOfRadius: 50)
        joystick.fillColor = SKColor(white: 0.3, alpha: 0.5)
        joystick.position = CGPoint(x: 80, y: 80)
        joystick.name = "joystick"
        controlsNode.addChild(joystick)

        let joystickInner = SKShapeNode(circleOfRadius: 20)
        joystickInner.fillColor = SKColor(white: 0.7, alpha: 0.7)
        joystickInner.name = "joystickInner"
        joystick.addChild(joystickInner)

        // Fire button
        fireButton = SKShapeNode(circleOfRadius: 40)
        fireButton.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.5)
        fireButton.position = CGPoint(x: size.width - 80, y: 80)
        fireButton.name = "fireButton"
        controlsNode.addChild(fireButton)

        let fireLabel = SKLabelNode(text: "FIRE")
        fireLabel.fontSize = 16
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireButton.addChild(fireLabel)
    }

    // MARK: - Rendering
    func render() {
        guard let engine = viewModel?.engine else { return }

        // Clear
        entitiesNode.removeAllChildren()

        // Render grid
        renderGrid(engine.grid)

        // Render tanks
        for tank in engine.tanks {
            renderTank(tank)
        }

        // Render projectiles
        for projectile in engine.projectiles {
            renderProjectile(projectile)
        }
    }

    private func renderGrid(_ grid: [[Cell]]) {
        gridNode.removeAllChildren()

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                cell.position = CGPoint(x: CGFloat(col) * tileSize + tileSize / 2,
                                       y: CGFloat(row) * tileSize + tileSize / 2)
                cell.fillColor = grid[row][col] == .wall ? .darkGray : .clear
                cell.strokeColor = SKColor(white: 0.3, alpha: 1.0)
                gridNode.addChild(cell)
            }
        }
    }

    private func renderTank(_ tank: Tank) {
        guard tank.isAlive else { return }

        let node = SKShapeNode(rectOf: CGSize(width: tileSize * 0.8, height: tileSize * 0.8))
        node.position = CGPoint(x: CGFloat(tank.position.col) * tileSize + tileSize / 2,
                               y: CGFloat(tank.position.row) * tileSize + tileSize / 2)

        // Color based on player index
        let colors: [SKColor] = [.blue, .red, .green, .yellow, .purple, .orange]
        node.fillColor = colors[tank.playerIndex % colors.count]
        node.strokeColor = .white
        node.zRotation = CGFloat(tank.direction.rawValue) * .pi / 2

        // Direction indicator
        let indicator = SKShapeNode(rectOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.6))
        indicator.fillColor = .white
        indicator.position = CGPoint(x: 0, y: tileSize * 0.2)
        node.addChild(indicator)

        entitiesNode.addChild(node)
    }

    private func renderProjectile(_ projectile: Projectile) {
        guard projectile.isAlive else { return }

        let node = SKShapeNode(circleOfRadius: tileSize * 0.15)
        node.position = CGPoint(x: CGFloat(projectile.position.col) * tileSize + tileSize / 2,
                               y: CGFloat(projectile.position.row) * tileSize + tileSize / 2)
        node.fillColor = .yellow
        node.strokeColor = .orange

        entitiesNode.addChild(node)
    }

    // MARK: - Input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if fireButton.contains(location) {
            viewModel?.shootLocalTank()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let joystick = joystick, joystick.contains(location) {
            handleJoystickMove(location: location)
        }
    }

    private func handleJoystickMove(location: CGPoint) {
        let joystickPos = joystick.position
        let dx = location.x - joystickPos.x
        let dy = location.y - joystickPos.y
        let angle = atan2(dy, dx)

        // Determine direction
        let directions: [(Direction, CGFloat)] = [
            (.right, 0),
            (.up, .pi / 2),
            (.left, .pi),
            (.down, -.pi / 2)
        ]

        if let closest = directions.min(by: { abs($0.1 - angle) < abs($1.1 - angle) }) {
            viewModel?.rotateLocalTank(clockwise: true) // Simplified rotation logic
        }

        // Move tank
        viewModel?.moveLocalTank()
    }

    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        viewModel?.update()
        render()
    }
}
