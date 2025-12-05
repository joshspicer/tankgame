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
    
    /// Setup the joystick UI with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        // Modern styled joystick base
        let newJoystickBase = SKShapeNode(circleOfRadius: 55)
        newJoystickBase.fillColor = SKColor(red: 0.12, green: 0.16, blue: 0.26, alpha: 0.85)
        newJoystickBase.strokeColor = SKColor(red: 0.35, green: 0.45, blue: 0.65, alpha: 0.9)
        newJoystickBase.lineWidth = 3
        newJoystickBase.glowWidth = 3
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        // Add inner ring decoration
        let innerRing = SKShapeNode(circleOfRadius: 45)
        innerRing.fillColor = .clear
        innerRing.strokeColor = SKColor(white: 1, alpha: 0.15)
        innerRing.lineWidth = 1
        newJoystickBase.addChild(innerRing)
        
        // Direction markers
        let markerRadius: CGFloat = 47
        let directions: [CGFloat] = [0, .pi/2, .pi, .pi * 1.5]
        for angle in directions {
            let marker = SKShapeNode(circleOfRadius: 5)
            marker.fillColor = SKColor(white: 1, alpha: 0.35)
            marker.strokeColor = .clear
            marker.position = CGPoint(x: cos(angle) * markerRadius, y: sin(angle) * markerRadius)
            newJoystickBase.addChild(marker)
        }
        
        // Modern styled joystick handle
        let newJoystickHandle = SKShapeNode(circleOfRadius: 28)
        newJoystickHandle.fillColor = SKColor(red: 0.5, green: 0.6, blue: 0.85, alpha: 0.95)
        newJoystickHandle.strokeColor = SKColor(white: 1, alpha: 0.85)
        newJoystickHandle.lineWidth = 2
        newJoystickHandle.glowWidth = 5
        newJoystickNode.addChild(newJoystickHandle)
        joystickHandle = newJoystickHandle
        
        // Inner highlight for handle
        let handleHighlight = SKShapeNode(circleOfRadius: 16)
        handleHighlight.fillColor = SKColor(white: 1, alpha: 0.3)
        handleHighlight.strokeColor = .clear
        handleHighlight.position = CGPoint(x: -4, y: 4)
        newJoystickHandle.addChild(handleHighlight)
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
    }
    
    /// Process touch location and update joystick state
    private func processTouchLocation(_ location: CGPoint) {
        guard let handle = joystickHandle else { return }
        
        let dx = location.x
        let dy = location.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Improved dead zone - requires 15 points minimum movement
        if distance > 15 {
            let angle = atan2(dy, dx)
            
            // Snap to 8 directions (cardinal + diagonal)
            let direction: Direction
            let angleDeg = angle * 180 / .pi
            
            if angleDeg > -22.5 && angleDeg <= 22.5 {
                direction = .right
            } else if angleDeg > 22.5 && angleDeg <= 67.5 {
                direction = .upRight
            } else if angleDeg > 67.5 && angleDeg <= 112.5 {
                direction = .up
            } else if angleDeg > 112.5 && angleDeg <= 157.5 {
                direction = .upLeft
            } else if angleDeg > 157.5 || angleDeg <= -157.5 {
                direction = .left
            } else if angleDeg > -157.5 && angleDeg <= -112.5 {
                direction = .downLeft
            } else if angleDeg > -112.5 && angleDeg <= -67.5 {
                direction = .down
            } else {
                direction = .downRight
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
