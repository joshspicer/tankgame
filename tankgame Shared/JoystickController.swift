//
//  JoystickController.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the virtual joystick UI with modern styling and input processing
class JoystickController {
    // Nodes
    private var joystickNode: SKNode?
    private var joystickBase: SKShapeNode?
    private var joystickHandle: SKShapeNode?
    private var handleInnerGlow: SKShapeNode?
    private var directionIndicators: [SKShapeNode] = []
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    init() {}
    
    /// Setup the joystick UI with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        newJoystickNode.zPosition = 200
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        // Create outer ring with gradient effect
        let outerRing = SKShapeNode(circleOfRadius: 56)
        outerRing.fillColor = .clear
        outerRing.strokeColor = SKColor.white.withAlphaComponent(0.3)
        outerRing.lineWidth = 2
        newJoystickNode.addChild(outerRing)
        
        // Create joystick base with modern styling
        let newJoystickBase = SKShapeNode(circleOfRadius: 50)
        newJoystickBase.fillColor = SKColor(white: 0.2, alpha: 0.7)
        newJoystickBase.strokeColor = SKColor.white.withAlphaComponent(0.4)
        newJoystickBase.lineWidth = 3
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        // Add direction indicator dots
        createDirectionIndicators(in: newJoystickNode)
        
        // Create joystick handle with modern styling
        let newJoystickHandle = SKShapeNode(circleOfRadius: 28)
        newJoystickHandle.fillColor = SKColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 0.9)
        newJoystickHandle.strokeColor = SKColor.white.withAlphaComponent(0.8)
        newJoystickHandle.lineWidth = 3
        newJoystickHandle.zPosition = 1
        newJoystickNode.addChild(newJoystickHandle)
        joystickHandle = newJoystickHandle
        
        // Add inner glow to handle
        let innerGlow = SKShapeNode(circleOfRadius: 20)
        innerGlow.fillColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 0.6)
        innerGlow.strokeColor = .clear
        newJoystickHandle.addChild(innerGlow)
        handleInnerGlow = innerGlow
        
        // Add subtle pulse animation to handle
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.8)
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.8)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        innerGlow.run(SKAction.repeatForever(pulse))
        
        // Add arrow icon to handle
        let arrowIcon = createArrowIcon()
        arrowIcon.zPosition = 2
        newJoystickHandle.addChild(arrowIcon)
    }
    
    /// Create direction indicator dots around the joystick
    private func createDirectionIndicators(in parent: SKNode) {
        let radius: CGFloat = 42
        let dotRadius: CGFloat = 4
        
        // 8 directions
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let dot = SKShapeNode(circleOfRadius: dotRadius)
            dot.fillColor = SKColor.white.withAlphaComponent(0.3)
            dot.strokeColor = .clear
            dot.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            parent.addChild(dot)
            directionIndicators.append(dot)
        }
    }
    
    /// Create arrow icon for handle
    private func createArrowIcon() -> SKNode {
        let arrowNode = SKNode()
        
        // Create four small arrows pointing outward
        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 2
            let arrow = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.7), size: CGSize(width: 2, height: 10))
            arrow.position = CGPoint(x: cos(angle) * 8, y: sin(angle) * 8)
            arrow.zRotation = angle - .pi / 2
            arrowNode.addChild(arrow)
        }
        
        return arrowNode
    }
    
    /// Get the joystick's center position
    var position: CGPoint {
        return joystickNode?.position ?? .zero
    }
    
    /// Update visual feedback when direction changes
    private func updateDirectionVisuals() {
        // Reset all indicators
        for (index, dot) in directionIndicators.enumerated() {
            dot.fillColor = SKColor.white.withAlphaComponent(0.3)
            dot.run(SKAction.scale(to: 1.0, duration: 0.1))
        }
        
        // Highlight active direction
        if let direction = currentDirection {
            let directionIndex: Int
            switch direction {
            case .right: directionIndex = 0
            case .upRight: directionIndex = 1
            case .up: directionIndex = 2
            case .upLeft: directionIndex = 3
            case .left: directionIndex = 4
            case .downLeft: directionIndex = 5
            case .down: directionIndex = 6
            case .downRight: directionIndex = 7
            }
            
            if directionIndex < directionIndicators.count {
                let dot = directionIndicators[directionIndex]
                dot.fillColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
                dot.run(SKAction.scale(to: 1.5, duration: 0.1))
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
            
            // Activate visual feedback
            joystickBase?.fillColor = SKColor(white: 0.25, alpha: 0.8)
            joystickHandle?.strokeColor = SKColor.white
            
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
        
        // Reset handle position with animation
        let resetAction = SKAction.move(to: .zero, duration: 0.15)
        resetAction.timingMode = .easeOut
        joystickHandle?.run(resetAction)
        
        // Reset visual feedback
        joystickBase?.fillColor = SKColor(white: 0.2, alpha: 0.7)
        joystickHandle?.strokeColor = SKColor.white.withAlphaComponent(0.8)
        
        updateDirectionVisuals()
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
            
            // Only update visuals when direction changes
            if currentDirection != direction {
                currentDirection = direction
                updateDirectionVisuals()
            }
            
            // Update joystick handle position with smooth movement
            let maxDistance: CGFloat = 32
            let clampedDistance = min(distance, maxDistance)
            let targetPosition = CGPoint(
                x: cos(angle) * clampedDistance,
                y: sin(angle) * clampedDistance
            )
            
            let moveAction = SKAction.move(to: targetPosition, duration: 0.05)
            moveAction.timingMode = .easeOut
            handle.run(moveAction)
        } else {
            currentDirection = nil
            let resetAction = SKAction.move(to: .zero, duration: 0.1)
            handle.run(resetAction)
            updateDirectionVisuals()
        }
    }
    #endif
}
