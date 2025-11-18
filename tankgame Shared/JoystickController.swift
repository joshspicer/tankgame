//
//  JoystickController.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the virtual joystick UI and input processing
/// Provides directional input for tank movement
final class JoystickController {
    // MARK: - Properties
    
    /// Container node for the joystick
    private var joystickNode: SKNode?
    
    /// Visual base circle of the joystick
    private var joystickBase: SKShapeNode?
    
    /// Movable handle of the joystick
    private var joystickHandle: SKShapeNode?
    
    /// Whether the joystick is currently being used
    private(set) var isActive = false
    
    /// Touch currently controlling the joystick
    private var touchID: UITouch?
    
    /// Current direction based on joystick position
    private(set) var currentDirection: Direction?
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Setup
    
    /// Sets up the joystick UI in the scene
    /// - Parameters:
    ///   - scene: Scene to add joystick to
    ///   - position: Position for the joystick center
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        scene.addChild(newJoystickNode)
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
    
    // MARK: - Position
    
    /// Gets the center position of the joystick
    var position: CGPoint {
        return joystickNode?.position ?? .zero
    }
    
    #if os(iOS) || os(tvOS)
    // MARK: - Touch Handling
    
    /// Handles touch began event in the joystick area
    /// - Parameters:
    ///   - touch: The touch event
    ///   - scene: Scene containing the joystick
    /// - Returns: true if touch was handled by joystick, false otherwise
    func handleTouchBegan(_ touch: UITouch, in scene: SKScene) -> Bool {
        guard let joystick = joystickNode else { return false }
        
        let location = touch.location(in: scene)
        let joystickCenter = joystick.position
        let dx = location.x - joystickCenter.x
        let dy = location.y - joystickCenter.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Joystick area is 150 points radius
        if distance < 150 {
            isActive = true
            touchID = touch
            // Process initial direction
            processTouchLocation(touch.location(in: joystick))
            return true
        }
        
        return false
    }
    
    /// Handles touch moved event for continuous joystick control
    /// - Parameters:
    ///   - touch: The touch event
    ///   - scene: Scene containing the joystick
    func handleTouchMoved(_ touch: UITouch, in scene: SKScene) {
        guard isActive, touch == touchID, let joystick = joystickNode else { return }
        
        let location = touch.location(in: joystick)
        processTouchLocation(location)
    }
    
    /// Handles touch ended event to reset joystick
    /// - Parameter touch: The touch event
    func handleTouchEnded(_ touch: UITouch) {
        guard touch == touchID else { return }
        
        isActive = false
        touchID = nil
        currentDirection = nil
        joystickHandle?.position = .zero
    }
    
    /// Processes touch location and updates joystick handle position and direction
    /// Snaps to cardinal directions based on angle
    /// - Parameter location: Touch location relative to joystick center
    private func processTouchLocation(_ location: CGPoint) {
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
    #endif
}
