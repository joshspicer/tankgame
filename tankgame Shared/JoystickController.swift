//
//  JoystickController.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the virtual joystick UI and input processing with premium styling
class JoystickController {
    // Nodes
    private var joystickNode: SKNode?
    private var joystickBase: SKShapeNode?
    private var joystickHandle: SKShapeNode?
    private var joystickRing: SKShapeNode?
    private var directionIndicators: [SKShapeNode] = []
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    init() {}
    
    /// Setup the joystick UI with premium styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        // Outer glow ring
        let outerGlow = SKShapeNode(circleOfRadius: 58)
        outerGlow.fillColor = .clear
        outerGlow.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.2)
        outerGlow.lineWidth = 2
        outerGlow.glowWidth = 4
        newJoystickNode.addChild(outerGlow)
        
        // Base with gradient-like effect
        let newJoystickBase = SKShapeNode(circleOfRadius: 52)
        newJoystickBase.fillColor = SKColor(white: 0.15, alpha: 0.9)
        newJoystickBase.strokeColor = SKColor(white: 0.4, alpha: 0.5)
        newJoystickBase.lineWidth = 2
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        // Direction indicators (subtle dots around the edge)
        let indicatorRadius: CGFloat = 38
        for i in 0..<8 {
            let angle = CGFloat(i) * (.pi / 4)
            let indicator = SKShapeNode(circleOfRadius: 4)
            indicator.fillColor = SKColor(white: 0.4, alpha: 0.5)
            indicator.strokeColor = .clear
            indicator.position = CGPoint(
                x: cos(angle) * indicatorRadius,
                y: sin(angle) * indicatorRadius
            )
            newJoystickNode.addChild(indicator)
            directionIndicators.append(indicator)
        }
        
        // Inner ring
        let innerRing = SKShapeNode(circleOfRadius: 28)
        innerRing.fillColor = .clear
        innerRing.strokeColor = SKColor(white: 0.3, alpha: 0.5)
        innerRing.lineWidth = 1
        newJoystickNode.addChild(innerRing)
        joystickRing = innerRing
        
        // Handle with modern design
        let newJoystickHandle = SKShapeNode(circleOfRadius: 22)
        newJoystickHandle.fillColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        newJoystickHandle.strokeColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.8)
        newJoystickHandle.lineWidth = 3
        newJoystickHandle.glowWidth = 4
        newJoystickNode.addChild(newJoystickHandle)
        joystickHandle = newJoystickHandle
        
        // Handle highlight
        let handleHighlight = SKShapeNode(circleOfRadius: 12)
        handleHighlight.fillColor = SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.5)
        handleHighlight.strokeColor = .clear
        handleHighlight.position = CGPoint(x: -4, y: 4)
        newJoystickHandle.addChild(handleHighlight)
        
        // Arrow icon in center
        let arrow = SKLabelNode(text: "↑")
        arrow.fontSize = 16
        arrow.fontColor = .white
        arrow.fontName = "AvenirNext-Bold"
        arrow.verticalAlignmentMode = .center
        arrow.horizontalAlignmentMode = .center
        arrow.alpha = 0.7
        newJoystickHandle.addChild(arrow)
    }
    
    /// Get the joystick's center position
    var position: CGPoint {
        return joystickNode?.position ?? .zero
    }
    
    /// Update direction indicator highlights
    private func updateDirectionIndicators(activeIndex: Int?) {
        for (index, indicator) in directionIndicators.enumerated() {
            if let active = activeIndex, index == active {
                indicator.fillColor = SKColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
                let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
                indicator.run(scaleUp)
            } else {
                indicator.fillColor = SKColor(white: 0.4, alpha: 0.5)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
                indicator.run(scaleDown)
            }
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
            // Process initial direction
            processTouchLocation(touch.location(in: joystick))
            
            // Highlight effect
            joystickHandle?.run(SKAction.scale(to: 1.1, duration: 0.1))
            
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
        let moveToCenter = SKAction.move(to: .zero, duration: 0.15)
        moveToCenter.timingMode = .easeOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        joystickHandle?.run(SKAction.group([moveToCenter, scaleDown]))
        
        // Reset direction indicators
        updateDirectionIndicators(activeIndex: nil)
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
            var indicatorIndex: Int = 0
            
            if angleDeg > -22.5 && angleDeg <= 22.5 {
                direction = .right
                indicatorIndex = 0
            } else if angleDeg > 22.5 && angleDeg <= 67.5 {
                direction = .upRight
                indicatorIndex = 1
            } else if angleDeg > 67.5 && angleDeg <= 112.5 {
                direction = .up
                indicatorIndex = 2
            } else if angleDeg > 112.5 && angleDeg <= 157.5 {
                direction = .upLeft
                indicatorIndex = 3
            } else if angleDeg > 157.5 || angleDeg <= -157.5 {
                direction = .left
                indicatorIndex = 4
            } else if angleDeg > -157.5 && angleDeg <= -112.5 {
                direction = .downLeft
                indicatorIndex = 5
            } else if angleDeg > -112.5 && angleDeg <= -67.5 {
                direction = .down
                indicatorIndex = 6
            } else {
                direction = .downRight
                indicatorIndex = 7
            }
            
            currentDirection = direction
            updateDirectionIndicators(activeIndex: indicatorIndex)
            
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
        } else {
            currentDirection = nil
            handle.position = .zero
            updateDirectionIndicators(activeIndex: nil)
        }
    }
    #endif
}
