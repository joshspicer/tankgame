//
//  InputController.swift
//  tankgame Shared
//
//  Handles user input
//

import SpriteKit

/// Protocol for input handling
protocol InputDelegate: AnyObject {
    func inputDidRequestMove(direction: Direction)
    func inputDidRequestFire()
}

/// Simple touch-based input controller
final class InputController {
    weak var delegate: InputDelegate?
    
    private var fireButton: SKSpriteNode?
    private var joystickBase: SKShapeNode?
    private var joystickKnob: SKShapeNode?
    private var joystickActive = false
    private var joystickTouchId: UITouch?
    
    func setup(in scene: SKScene) {
        // Create fire button in bottom-right
        let fireButton = SKSpriteNode(color: .red, size: CGSize(width: 80, height: 80))
        fireButton.position = CGPoint(x: scene.size.width - 60, y: 60)
        fireButton.name = "fireButton"
        fireButton.alpha = 0.7
        scene.addChild(fireButton)
        self.fireButton = fireButton
        
        // Add "FIRE" label
        let label = SKLabelNode(text: "FIRE")
        label.fontSize = 16
        label.fontName = "AvenirNext-Bold"
        label.verticalAlignmentMode = .center
        fireButton.addChild(label)
        
        // Create joystick in bottom-left
        let joystickBase = SKShapeNode(circleOfRadius: 60)
        joystickBase.fillColor = .darkGray
        joystickBase.strokeColor = .white
        joystickBase.lineWidth = 2
        joystickBase.alpha = 0.5
        joystickBase.position = CGPoint(x: 80, y: 80)
        joystickBase.name = "joystickBase"
        scene.addChild(joystickBase)
        self.joystickBase = joystickBase
        
        let joystickKnob = SKShapeNode(circleOfRadius: 25)
        joystickKnob.fillColor = .lightGray
        joystickKnob.strokeColor = .white
        joystickKnob.lineWidth = 2
        joystickKnob.alpha = 0.8
        joystickBase.addChild(joystickKnob)
        self.joystickKnob = joystickKnob
    }
    
    func handleTouchBegan(_ touch: UITouch, in scene: SKScene) {
        let location = touch.location(in: scene)
        let touchedNode = scene.atPoint(location)
        
        // Fire button
        if touchedNode.name == "fireButton" || touchedNode.parent?.name == "fireButton" {
            delegate?.inputDidRequestFire()
            fireButton?.run(SKAction.sequence([
                SKAction.scale(to: 0.9, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
            return
        }
        
        // Joystick
        if let joystickBase = joystickBase,
           joystickBase.contains(location) || location.distance(to: joystickBase.position) < 80 {
            joystickActive = true
            joystickTouchId = touch
            updateJoystick(touch: touch, in: scene)
        }
    }
    
    func handleTouchMoved(_ touch: UITouch, in scene: SKScene) {
        if joystickActive && touch == joystickTouchId {
            updateJoystick(touch: touch, in: scene)
        }
    }
    
    func handleTouchEnded(_ touch: UITouch, in scene: SKScene) {
        if touch == joystickTouchId {
            joystickActive = false
            joystickTouchId = nil
            joystickKnob?.position = .zero
        }
    }
    
    private func updateJoystick(touch: UITouch, in scene: SKScene) {
        guard let joystickBase = joystickBase, let joystickKnob = joystickKnob else { return }
        
        let location = touch.location(in: scene)
        let basePosition = joystickBase.position
        
        var offset = CGPoint(x: location.x - basePosition.x, y: location.y - basePosition.y)
        let distance = sqrt(offset.x * offset.x + offset.y * offset.y)
        
        // Limit knob movement
        let maxDistance: CGFloat = 40
        if distance > maxDistance {
            offset.x = offset.x / distance * maxDistance
            offset.y = offset.y / distance * maxDistance
        }
        
        joystickKnob.position = offset
        
        // Determine direction
        if distance > 15 {
            let angle = atan2(offset.y, offset.x)
            let direction = angleToDirection(angle)
            delegate?.inputDidRequestMove(direction: direction)
        }
    }
    
    private func angleToDirection(_ angle: CGFloat) -> Direction {
        let degrees = angle * 180 / .pi
        
        if degrees >= -45 && degrees < 45 {
            return .right
        } else if degrees >= 45 && degrees < 135 {
            return .up
        } else if degrees >= -135 && degrees < -45 {
            return .down
        } else {
            return .left
        }
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
