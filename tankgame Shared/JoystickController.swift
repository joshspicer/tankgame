//
//  JoystickController.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the virtual joystick UI and input processing
class JoystickController {
    // Nodes
    private var joystickNode: SKNode?
    private var joystickBase: SKShapeNode?
    private var joystickHandle: SKShapeNode?
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    init() {}
    
    /// Setup the joystick UI
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        let newJoystickBase = SKShapeNode(circleOfRadius: 60)
        newJoystickBase.fillColor = .gray
        newJoystickBase.strokeColor = .white
        newJoystickBase.lineWidth = 3
        newJoystickBase.alpha = 0.6
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        let newJoystickHandle = SKShapeNode(circleOfRadius: 30)
        newJoystickHandle.fillColor = .white
        newJoystickHandle.strokeColor = .white
        newJoystickHandle.alpha = 0.9
        newJoystickNode.addChild(newJoystickHandle)
        joystickHandle = newJoystickHandle
    }
    
    /// Get the joystick's center position
    var position: CGPoint {
        return joystickNode?.position ?? .zero
    }
    
    #if os(iOS) || os(tvOS)
    /// Handle touch began in joystick area
    /// - Returns: true if touch was handled by joystick
    func handleTouchBegan(_ touch: UITouch, in scene: SKScene) -> Bool {
        guard let joystick = joystickNode else { return false }
        
        let location = touch.location(in: scene)
        let joystickCenter = joystick.position
        let dx = location.x - joystickCenter.x
        let dy = location.y - joystickCenter.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Joystick area is 180 points radius (larger for easier activation)
        if distance < 180 {
            isActive = true
            touchID = touch
            // Process initial direction
            processTouchLocation(touch.location(in: joystick))
            return true
        }
        
        return false
    }
    
    /// Handle touch moved
    func handleTouchMoved(_ touch: UITouch, in scene: SKScene) {
        guard isActive, touch == touchID, let joystick = joystickNode else { return }
        
        let location = touch.location(in: joystick)
        processTouchLocation(location)
    }
    
    /// Handle touch ended
    func handleTouchEnded(_ touch: UITouch) {
        guard touch == touchID else { return }
        
        isActive = false
        touchID = nil
        currentDirection = nil
        joystickHandle?.position = .zero
        // Reset visual feedback
        joystickHandle?.alpha = 0.9
    }
    
    /// Process touch location and update joystick state
    private func processTouchLocation(_ location: CGPoint) {
        guard let handle = joystickHandle else { return }
        
        let dx = location.x
        let dy = location.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Increased dead zone from 20 to 30 for better stability
        if distance > 30 {
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
            
            // Update joystick handle position with better visual feedback
            let maxDistance: CGFloat = 40
            let clampedDistance = min(distance, maxDistance)
            handle.position = CGPoint(
                x: cos(angle) * clampedDistance,
                y: sin(angle) * clampedDistance
            )
            
            // Enhance visual feedback when active
            handle.alpha = 1.0
        } else {
            currentDirection = nil
            handle.position = .zero
            // Reset visual feedback when in dead zone
            handle.alpha = 0.9
        }
    }
    #endif
}
