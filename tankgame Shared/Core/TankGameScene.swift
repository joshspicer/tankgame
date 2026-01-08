//
//  TankGameScene.swift
//  tankgame Shared
//
//  Simplified game scene

import SpriteKit
import Combine

/// Main game scene
final class TankGameScene: SKScene {

    private let renderer = GameRenderer()
    private let input = InputController()
    private var cancellables = Set<AnyCancellable>()

    var gameEngine: GameEngine?
    var networkService: NetworkService?
    var localPlayerIndex: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black
        renderer.setup(in: self)
        setupInput()
    }

    private func setupInput() {
        input.setup(in: self)

        // Handle movement
        input.moveCommand
            .sink { [weak self] direction in
                guard let self = self, let engine = self.gameEngine else { return }
                let command = MoveCommand(playerIndex: self.localPlayerIndex, direction: direction)
                engine.execute(command)
                self.networkService?.send(.move(playerIndex: self.localPlayerIndex,
                                               position: engine.state?.tanks[self.localPlayerIndex].position ?? Position(row: 0, col: 0),
                                               direction: direction))
            }
            .store(in: &cancellables)

        // Handle shooting
        input.shootCommand
            .sink { [weak self] in
                guard let self = self, let engine = self.gameEngine else { return }
                let command = ShootCommand(playerIndex: self.localPlayerIndex)
                engine.execute(command)
                if let tank = engine.state?.tanks[self.localPlayerIndex],
                   let projectile = engine.state?.projectiles.last {
                    self.networkService?.send(.shoot(playerIndex: self.localPlayerIndex, projectile: projectile))
                }
            }
            .store(in: &cancellables)
    }

    func render(state: GameState) {
        renderer.render(state: state)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        input.handleTouches(touches, in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        input.handleTouches(touches, in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        input.reset()
    }
}

// MARK: - Input Controller
final class InputController {

    let moveCommand = PassthroughSubject<Direction, Never>()
    let shootCommand = PassthroughSubject<Void, Never>()

    private var joystickNode: SKShapeNode?
    private var fireButton: SKShapeNode?
    private var lastMoveTime: TimeInterval = 0

    func setup(in scene: SKScene) {
        // Virtual joystick (left side)
        let joystick = SKShapeNode(circleOfRadius: 60)
        joystick.position = CGPoint(x: 100, y: 100)
        joystick.fillColor = .clear
        joystick.strokeColor = .white
        joystick.alpha = 0.5
        scene.addChild(joystick)
        joystickNode = joystick

        // Fire button (right side)
        let button = SKShapeNode(circleOfRadius: 40)
        button.position = CGPoint(x: scene.size.width - 100, y: 100)
        button.fillColor = .red
        button.alpha = 0.5
        scene.addChild(button)
        fireButton = button
    }

    func handleTouches(_ touches: Set<UITouch>, in scene: SKScene) {
        let now = Date().timeIntervalSince1970

        for touch in touches {
            let location = touch.location(in: scene)

            // Check fire button
            if let button = fireButton, button.contains(location) {
                shootCommand.send()
                continue
            }

            // Check joystick for movement
            if let joystick = joystickNode, joystick.frame.insetBy(dx: -50, dy: -50).contains(location) {
                let dx = location.x - joystick.position.x
                let dy = location.y - joystick.position.y

                // Throttle movement
                guard now - lastMoveTime > 0.15 else { continue }
                lastMoveTime = now

                let direction: Direction
                if abs(dx) > abs(dy) {
                    direction = dx > 0 ? .right : .left
                } else {
                    direction = dy > 0 ? .up : .down
                }
                moveCommand.send(direction)
            }
        }
    }

    func reset() {
        // Could add visual feedback here
    }
}

// MARK: - Tank Position Helper
extension Tank {
    var position: Position {
        Position(row: row, col: col)
    }
}
