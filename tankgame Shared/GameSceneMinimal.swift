//
//  GameSceneMinimal.swift
//  tankgame Shared
//
//  Complete rewrite - Minimal SpriteKit rendering
//

import SpriteKit

final class GameSceneMinimal: SKScene {
    var gameState: GameState?
    var onMove: ((Direction) -> Void)?
    var onShoot: (() -> Void)?

    private let tileSize: CGFloat = 64
    private var gridNode: SKNode!
    private var tanksNode: SKNode!
    private var bulletsNode: SKNode!
    private var joystickNode: SKShapeNode!
    private var fireButton: SKShapeNode!

    private var joystickActive = false
    private var joystickTouch: UITouch?

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        setupScene()
    }

    private func setupScene() {
        // Grid container
        gridNode = SKNode()
        gridNode.position = CGPoint(x: size.width / 2 - CGFloat(GameState.gridSize) * tileSize / 2,
                                    y: size.height / 2 - CGFloat(GameState.gridSize) * tileSize / 2 + 100)
        addChild(gridNode)

        // Tanks container
        tanksNode = SKNode()
        addChild(tanksNode)

        // Bullets container
        bulletsNode = SKNode()
        addChild(bulletsNode)

        // Joystick
        joystickNode = SKShapeNode(circleOfRadius: 80)
        joystickNode.fillColor = .white.withAlphaComponent(0.2)
        joystickNode.strokeColor = .white
        joystickNode.lineWidth = 2
        joystickNode.position = CGPoint(x: 100, y: 120)
        addChild(joystickNode)

        let joystickCenter = SKShapeNode(circleOfRadius: 30)
        joystickCenter.fillColor = .white.withAlphaComponent(0.5)
        joystickCenter.name = "joystickCenter"
        joystickNode.addChild(joystickCenter)

        // Fire button
        fireButton = SKShapeNode(circleOfRadius: 40)
        fireButton.fillColor = .red.withAlphaComponent(0.5)
        fireButton.strokeColor = .white
        fireButton.lineWidth = 2
        fireButton.position = CGPoint(x: size.width - 100, y: 120)
        addChild(fireButton)

        let fireLabel = SKLabelNode(text: "FIRE")
        fireLabel.fontSize = 16
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireButton.addChild(fireLabel)
    }

    func render(_ state: GameState) {
        self.gameState = state
        renderGrid(state.grid)
        renderTanks(state.tanks)
        renderBullets(state.bullets)
    }

    private func renderGrid(_ grid: Grid) {
        gridNode.removeAllChildren()

        for row in 0..<GameState.gridSize {
            for col in 0..<GameState.gridSize {
                let cell = grid[row][col]
                let rect = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                rect.position = CGPoint(x: CGFloat(col) * tileSize + tileSize / 2,
                                       y: CGFloat(GameState.gridSize - 1 - row) * tileSize + tileSize / 2)
                rect.fillColor = cell == .wall ? .gray : .black
                rect.strokeColor = .darkGray
                rect.lineWidth = 1
                gridNode.addChild(rect)
            }
        }
    }

    private func renderTanks(_ tanks: [Tank]) {
        tanksNode.removeAllChildren()

        for tank in tanks where tank.isAlive {
            let sprite = SKShapeNode(rectOf: CGSize(width: tileSize * 0.8, height: tileSize * 0.8))
            let gridPos = gridNode.position
            sprite.position = CGPoint(
                x: gridPos.x + CGFloat(tank.position.col) * tileSize + tileSize / 2,
                y: gridPos.y + CGFloat(GameState.gridSize - 1 - tank.position.row) * tileSize + tileSize / 2
            )

            // Color based on player
            let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemYellow, .systemPurple, .systemOrange]
            sprite.fillColor = colors[tank.id % colors.count]
            sprite.strokeColor = .white
            sprite.lineWidth = 2

            // Direction indicator
            let arrow = createArrow(for: tank.direction)
            sprite.addChild(arrow)

            tanksNode.addChild(sprite)
        }
    }

    private func createArrow(for direction: Direction) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: -8, y: -12))
        path.addLine(to: CGPoint(x: 8, y: -12))
        path.closeSubpath()

        let arrow = SKShapeNode(path: path)
        arrow.fillColor = .white
        arrow.strokeColor = .white

        // Rotate based on direction
        let rotation: CGFloat = {
            switch direction {
            case .up: return 0
            case .down: return .pi
            case .left: return .pi / 2
            case .right: return -.pi / 2
            }
        }()
        arrow.zRotation = rotation

        return arrow
    }

    private func renderBullets(_ bullets: [Bullet]) {
        bulletsNode.removeAllChildren()

        for bullet in bullets {
            let sprite = SKShapeNode(circleOfRadius: tileSize * 0.2)
            let gridPos = gridNode.position
            sprite.position = CGPoint(
                x: gridPos.x + CGFloat(bullet.position.col) * tileSize + tileSize / 2,
                y: gridPos.y + CGFloat(GameState.gridSize - 1 - bullet.position.row) * tileSize + tileSize / 2
            )
            sprite.fillColor = .yellow
            sprite.strokeColor = .white
            sprite.lineWidth = 1
            bulletsNode.addChild(sprite)
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            // Check joystick
            if joystickNode.contains(location) {
                joystickActive = true
                joystickTouch = touch
            }

            // Check fire button
            if fireButton.contains(location) {
                onShoot?()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard joystickActive, let touch = joystickTouch, touches.contains(touch) else { return }

        let location = touch.location(in: joystickNode)
        let center = joystickNode.childNode(withName: "joystickCenter") as? SKShapeNode

        // Calculate direction
        let distance = sqrt(location.x * location.x + location.y * location.y)
        if distance > 40 {
            // Determine direction
            let angle = atan2(location.y, location.x)
            let direction: Direction

            if angle > .pi / 4 && angle <= 3 * .pi / 4 {
                direction = .up
            } else if angle > -3 * .pi / 4 && angle <= -.pi / 4 {
                direction = .down
            } else if angle > -.pi / 4 && angle <= .pi / 4 {
                direction = .right
            } else {
                direction = .left
            }

            onMove?(direction)
        }

        // Visual feedback
        let clampedDistance = min(distance, 50)
        let normalizedX = location.x / distance * clampedDistance
        let normalizedY = location.y / distance * clampedDistance
        center?.position = CGPoint(x: normalizedX, y: normalizedY)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = joystickTouch, touches.contains(touch) {
            joystickActive = false
            joystickTouch = nil

            // Reset joystick center
            if let center = joystickNode.childNode(withName: "joystickCenter") {
                center.position = .zero
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
