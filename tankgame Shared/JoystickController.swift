//
//  JoystickController.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the virtual joystick UI and input processing with modern styling
class JoystickController {
    // Nodes
    private var joystickNode: SKNode?
    private var joystickBase: SKShapeNode?
    private var joystickRing: SKShapeNode?
    private var joystickHandle: SKShapeNode?
    private var joystickGlow: SKShapeNode?
    private var directionIndicators: [SKShapeNode] = []
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    init() {}
    
    /// Setup the joystick UI with modern design
    func setup(in scene: SKScene, at position: CGPoint) {
        let container = SKNode()
        container.position = position
        scene.addChild(container)
        joystickNode = container
        
        // Outer glow effect
        let glow = SKShapeNode(circleOfRadius: 58)
        glow.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.15)
        glow.strokeColor = .clear
        glow.zPosition = -2
        container.addChild(glow)
        joystickGlow = glow
        
        // Base circle with gradient effect
        let base = SKShapeNode(circleOfRadius: 52)
        base.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.9)
        base.strokeColor = SKColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 0.6)
        base.lineWidth = 2
        base.zPosition = -1
        container.addChild(base)
        joystickBase = base
        
        // Inner ring for visual depth
        let ring = SKShapeNode(circleOfRadius: 42)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 0.4)
        ring.lineWidth = 1
        container.addChild(ring)
        joystickRing = ring
        
        // Direction indicators (subtle dots around the edge)
        let indicatorRadius: CGFloat = 45
        let directions = 8
        for i in 0..<directions {
            let angle = (CGFloat(i) / CGFloat(directions)) * 2 * .pi - .pi / 2
            let indicator = SKShapeNode(circleOfRadius: 3)
            indicator.fillColor = SKColor(red: 0.5, green: 0.6, blue: 0.8, alpha: 0.4)
            indicator.strokeColor = .clear
            indicator.position = CGPoint(
                x: cos(angle) * indicatorRadius,
                y: sin(angle) * indicatorRadius
            )
            container.addChild(indicator)
            directionIndicators.append(indicator)
        }
        
        // Joystick handle with modern look
        let handle = SKShapeNode(circleOfRadius: 24)
        handle.fillColor = SKColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1.0)
        handle.strokeColor = SKColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 0.8)
        handle.lineWidth = 2
        handle.zPosition = 1
        container.addChild(handle)
        joystickHandle = handle
        
        // Handle highlight (3D effect)
        let handleHighlight = SKShapeNode(circleOfRadius: 16)
        handleHighlight.fillColor = SKColor(red: 0.5, green: 0.6, blue: 1.0, alpha: 0.5)
        handleHighlight.strokeColor = .clear
        handleHighlight.position = CGPoint(x: -4, y: 4)
        handle.addChild(handleHighlight)
        
        // Center dot on handle
        let centerDot = SKShapeNode(circleOfRadius: 4)
        centerDot.fillColor = .white
        centerDot.strokeColor = .clear
        centerDot.alpha = 0.6
        handle.addChild(centerDot)
    }
    
    /// Get the joystick's center position
    var position: CGPoint {
        return joystickNode?.position ?? .zero
    }
    
    /// Highlight the active direction indicator
    private func updateDirectionIndicators() {
        // Reset all indicators
        for indicator in directionIndicators {
            indicator.fillColor = SKColor(red: 0.5, green: 0.6, blue: 0.8, alpha: 0.4)
            indicator.setScale(1.0)
        }
        
        // Highlight active direction
        guard let direction = currentDirection else { return }
        
        let directionAngles: [Direction: Int] = [
            .up: 0, .upRight: 1, .right: 2, .downRight: 3,
            .down: 4, .downLeft: 5, .left: 6, .upLeft: 7
        ]
        
        if let index = directionAngles[direction] {
            directionIndicators[index].fillColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
            directionIndicators[index].setScale(1.3)
        }
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
            
            // Activate visual feedback
            activateJoystick()
            
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
        
        // Animate handle back to center
        if let handle = joystickHandle {
            let moveBack = SKAction.move(to: .zero, duration: 0.15)
            moveBack.timingMode = .easeOut
            handle.run(moveBack)
        }
        
        // Deactivate visual feedback
        deactivateJoystick()
        updateDirectionIndicators()
    }
    
    /// Activate joystick visual feedback
    private func activateJoystick() {
        // Scale up glow
        if let glow = joystickGlow {
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
            glow.run(scaleUp)
            glow.fillColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.25)
        }
        
        // Brighten handle
        if let handle = joystickHandle {
            handle.fillColor = SKColor(red: 0.5, green: 0.6, blue: 1.0, alpha: 1.0)
        }
    }
    
    /// Deactivate joystick visual feedback
    private func deactivateJoystick() {
        // Scale down glow
        if let glow = joystickGlow {
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
            glow.run(scaleDown)
            glow.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.15)
        }
        
        // Dim handle
        if let handle = joystickHandle {
            handle.fillColor = SKColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1.0)
        }
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
            
            // Update joystick handle position with smooth animation
            let maxDistance: CGFloat = 32
            let clampedDistance = min(distance, maxDistance)
            let targetPosition = CGPoint(
                x: cos(angle) * clampedDistance,
                y: sin(angle) * clampedDistance
            )
            
            // Smooth movement
            let moveAction = SKAction.move(to: targetPosition, duration: 0.05)
            handle.run(moveAction)
            
            updateDirectionIndicators()
        } else {
            currentDirection = nil
            
            // Return handle to center
            let moveBack = SKAction.move(to: .zero, duration: 0.1)
            handle.run(moveBack)
            
            updateDirectionIndicators()
        }
    }
    #endif
}
