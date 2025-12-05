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
    private var joystickHandle: SKShapeNode?
    private var outerGlow: SKShapeNode?
    private var innerGlow: SKShapeNode?
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    // Modern styling colors
    private let baseColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.9)
    private let handleColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
    private let glowColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.3)
    
    init() {}
    
    /// Setup the joystick UI with modern glassmorphism style
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        // Outer glow effect
        let newOuterGlow = SKShapeNode(circleOfRadius: 60)
        newOuterGlow.fillColor = glowColor
        newOuterGlow.strokeColor = .clear
        newOuterGlow.alpha = 0.4
        newOuterGlow.zPosition = -1
        newJoystickNode.addChild(newOuterGlow)
        outerGlow = newOuterGlow
        
        // Add pulse animation to outer glow
        let pulseOut = SKAction.scale(to: 1.1, duration: 1.0)
        let pulseIn = SKAction.scale(to: 1.0, duration: 1.0)
        pulseOut.timingMode = .easeInEaseOut
        pulseIn.timingMode = .easeInEaseOut
        let pulseSequence = SKAction.sequence([pulseOut, pulseIn])
        newOuterGlow.run(SKAction.repeatForever(pulseSequence))
        
        // Joystick base with gradient-like effect
        let newJoystickBase = SKShapeNode(circleOfRadius: 50)
        newJoystickBase.fillColor = baseColor
        newJoystickBase.strokeColor = SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.5)
        newJoystickBase.lineWidth = 2
        newJoystickBase.glowWidth = 3
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        // Inner highlight ring for depth
        let innerRing = SKShapeNode(circleOfRadius: 42)
        innerRing.fillColor = .clear
        innerRing.strokeColor = SKColor.white.withAlphaComponent(0.1)
        innerRing.lineWidth = 1
        newJoystickNode.addChild(innerRing)
        
        // Joystick handle with modern styling
        let newJoystickHandle = SKShapeNode(circleOfRadius: 22)
        newJoystickHandle.fillColor = handleColor
        newJoystickHandle.strokeColor = SKColor.white.withAlphaComponent(0.8)
        newJoystickHandle.lineWidth = 2
        newJoystickHandle.glowWidth = 4
        newJoystickNode.addChild(newJoystickHandle)
        joystickHandle = newJoystickHandle
        
        // Handle inner highlight for 3D effect
        let handleHighlight = SKShapeNode(circleOfRadius: 14)
        handleHighlight.fillColor = SKColor.white.withAlphaComponent(0.3)
        handleHighlight.strokeColor = .clear
        handleHighlight.position = CGPoint(x: -3, y: 3)
        newJoystickHandle.addChild(handleHighlight)
        
        // Add subtle idle animation to handle
        let breatheIn = SKAction.scale(to: 1.05, duration: 1.5)
        let breatheOut = SKAction.scale(to: 1.0, duration: 1.5)
        breatheIn.timingMode = .easeInEaseOut
        breatheOut.timingMode = .easeInEaseOut
        let breatheSequence = SKAction.sequence([breatheIn, breatheOut])
        newJoystickHandle.run(SKAction.repeatForever(breatheSequence))
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
            
            // Visual feedback when activated
            activateVisualFeedback()
            
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
            let returnAction = SKAction.move(to: .zero, duration: 0.15)
            returnAction.timingMode = .easeOut
            handle.run(returnAction)
        }
        
        // Deactivate visual feedback
        deactivateVisualFeedback()
    }
    
    /// Visual feedback when joystick is activated
    private func activateVisualFeedback() {
        joystickBase?.run(SKAction.scale(to: 1.05, duration: 0.1))
        joystickHandle?.fillColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        outerGlow?.run(SKAction.fadeAlpha(to: 0.7, duration: 0.1))
    }
    
    /// Deactivate visual feedback
    private func deactivateVisualFeedback() {
        joystickBase?.run(SKAction.scale(to: 1.0, duration: 0.15))
        joystickHandle?.fillColor = handleColor
        outerGlow?.run(SKAction.fadeAlpha(to: 0.4, duration: 0.15))
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
            
            // Update joystick handle position with smooth movement
            let maxDistance: CGFloat = 30
            let clampedDistance = min(distance, maxDistance)
            let targetPosition = CGPoint(
                x: cos(angle) * clampedDistance,
                y: sin(angle) * clampedDistance
            )
            
            // Smooth movement
            let moveAction = SKAction.move(to: targetPosition, duration: 0.05)
            moveAction.timingMode = .easeOut
            handle.run(moveAction)
        } else {
            currentDirection = nil
            let returnAction = SKAction.move(to: .zero, duration: 0.1)
            returnAction.timingMode = .easeOut
            handle.run(returnAction)
        }
    }
    #endif
}
