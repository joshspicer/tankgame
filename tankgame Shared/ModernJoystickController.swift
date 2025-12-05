//
//  ModernJoystickController.swift
//  tankgame Shared
//
//  A modernized joystick with glassy/neon visual styling
//

import SpriteKit

/// Manages the virtual joystick UI with modern visual styling
class ModernJoystickController {
    // Nodes
    private var joystickNode: SKNode?
    private var joystickBase: SKNode?
    private var joystickHandle: SKNode?
    private var outerGlow: SKShapeNode?
    private var innerGlow: SKShapeNode?
    private var directionIndicators: [SKShapeNode] = []
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    // Visual constants
    private let baseRadius: CGFloat = 55
    private let handleRadius: CGFloat = 28
    private let glowColor: SKColor = .cyan
    private let activeColor: SKColor = .systemBlue
    
    // Input constants
    private let deadZoneThreshold: CGFloat = 15  // Minimum distance to register direction
    private let maxHandleDistance: CGFloat = 35  // Maximum handle travel distance
    
    init() {}
    
    /// Setup the joystick UI with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        newJoystickNode.zPosition = 100
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        // Create outer glow ring
        let newOuterGlow = SKShapeNode(circleOfRadius: baseRadius + 8)
        newOuterGlow.fillColor = .clear
        newOuterGlow.strokeColor = glowColor.withAlphaComponent(0.3)
        newOuterGlow.lineWidth = 3
        newOuterGlow.glowWidth = 8
        newJoystickNode.addChild(newOuterGlow)
        outerGlow = newOuterGlow
        addPulseAnimation(to: newOuterGlow)
        
        // Create main base with gradient effect (simulated with multiple circles)
        let baseContainer = SKNode()
        
        // Outer ring of base
        let baseOuter = SKShapeNode(circleOfRadius: baseRadius)
        baseOuter.fillColor = SKColor(white: 0.15, alpha: 0.9)
        baseOuter.strokeColor = SKColor(white: 0.3, alpha: 0.8)
        baseOuter.lineWidth = 2
        baseContainer.addChild(baseOuter)
        
        // Inner gradient layer
        let baseInner = SKShapeNode(circleOfRadius: baseRadius - 5)
        baseInner.fillColor = SKColor(white: 0.1, alpha: 0.8)
        baseInner.strokeColor = .clear
        baseContainer.addChild(baseInner)
        
        // Center dimple effect
        let centerDimple = SKShapeNode(circleOfRadius: baseRadius * 0.3)
        centerDimple.fillColor = SKColor(white: 0.05, alpha: 0.6)
        centerDimple.strokeColor = SKColor(white: 0.2, alpha: 0.4)
        centerDimple.lineWidth = 1
        baseContainer.addChild(centerDimple)
        
        newJoystickNode.addChild(baseContainer)
        joystickBase = baseContainer
        
        // Create direction indicators
        createDirectionIndicators(in: newJoystickNode)
        
        // Create handle with glassy effect
        let handleContainer = SKNode()
        handleContainer.zPosition = 10
        
        // Handle shadow
        let handleShadow = SKShapeNode(circleOfRadius: handleRadius + 2)
        handleShadow.fillColor = SKColor.black.withAlphaComponent(0.3)
        handleShadow.strokeColor = .clear
        handleShadow.position = CGPoint(x: 2, y: -2)
        handleContainer.addChild(handleShadow)
        
        // Handle base (dark outer ring)
        let handleOuter = SKShapeNode(circleOfRadius: handleRadius)
        handleOuter.fillColor = SKColor(white: 0.25, alpha: 1.0)
        handleOuter.strokeColor = activeColor.withAlphaComponent(0.6)
        handleOuter.lineWidth = 2
        handleOuter.glowWidth = 3
        handleContainer.addChild(handleOuter)
        
        // Handle highlight (glassy reflection)
        let handleHighlight = SKShapeNode(circleOfRadius: handleRadius - 4)
        handleHighlight.fillColor = SKColor(white: 0.35, alpha: 0.9)
        handleHighlight.strokeColor = .clear
        handleContainer.addChild(handleHighlight)
        
        // Top reflection arc (glassy effect)
        let reflectionPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 5),
                                          radius: handleRadius - 8,
                                          startAngle: CGFloat.pi * 0.15,
                                          endAngle: CGFloat.pi * 0.85,
                                          clockwise: true)
        let reflection = SKShapeNode(path: reflectionPath.cgPath)
        reflection.fillColor = SKColor.white.withAlphaComponent(0.3)
        reflection.strokeColor = .clear
        handleContainer.addChild(reflection)
        
        // Inner glow
        let newInnerGlow = SKShapeNode(circleOfRadius: handleRadius * 0.4)
        newInnerGlow.fillColor = activeColor.withAlphaComponent(0.4)
        newInnerGlow.strokeColor = activeColor
        newInnerGlow.lineWidth = 1
        newInnerGlow.glowWidth = 5
        handleContainer.addChild(newInnerGlow)
        innerGlow = newInnerGlow
        
        newJoystickNode.addChild(handleContainer)
        joystickHandle = handleContainer
        
        // Add idle animation to handle
        addIdleAnimation(to: handleContainer)
    }
    
    /// Create direction indicator arrows
    private func createDirectionIndicators(in parent: SKNode) {
        let directions: [(CGFloat, Direction)] = [
            (0, .right),
            (CGFloat.pi / 2, .up),
            (CGFloat.pi, .left),
            (-CGFloat.pi / 2, .down)
        ]
        
        for (angle, _) in directions {
            let distance = baseRadius + 18
            let x = cos(angle) * distance
            let y = sin(angle) * distance
            
            // Create arrow shape
            let arrowPath = UIBezierPath()
            arrowPath.move(to: CGPoint(x: 0, y: 6))
            arrowPath.addLine(to: CGPoint(x: 5, y: -4))
            arrowPath.addLine(to: CGPoint(x: -5, y: -4))
            arrowPath.close()
            
            let arrow = SKShapeNode(path: arrowPath.cgPath)
            arrow.fillColor = SKColor.white.withAlphaComponent(0.3)
            arrow.strokeColor = .clear
            arrow.position = CGPoint(x: x, y: y)
            arrow.zRotation = angle - CGFloat.pi / 2
            arrow.name = "directionArrow"
            parent.addChild(arrow)
            directionIndicators.append(arrow)
        }
    }
    
    /// Add pulse animation to outer glow
    private func addPulseAnimation(to node: SKShapeNode) {
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.2)
        let scaleDown = SKAction.scale(to: 0.95, duration: 1.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
        
        // Also pulse the alpha
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 1.2)
        let fadeIn = SKAction.fadeAlpha(to: 0.4, duration: 1.2)
        let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
        let repeatFade = SKAction.repeatForever(fadeSequence)
        node.run(repeatFade)
    }
    
    /// Add subtle idle animation to handle
    private func addIdleAnimation(to node: SKNode) {
        let floatUp = SKAction.moveBy(x: 0, y: 2, duration: 1.5)
        let floatDown = SKAction.moveBy(x: 0, y: -2, duration: 1.5)
        let sequence = SKAction.sequence([floatUp, floatDown])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction, withKey: "idle")
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
            
            // Activate visual feedback
            activateVisuals()
            
            // Stop idle animation
            joystickHandle?.removeAction(forKey: "idle")
            
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
        
        // Animate handle back to center with spring effect
        if let handle = joystickHandle {
            let returnAction = SKAction.move(to: .zero, duration: 0.15)
            returnAction.timingMode = .easeOut
            handle.run(returnAction)
        }
        
        // Deactivate visual feedback
        deactivateVisuals()
        
        // Restart idle animation
        if let handle = joystickHandle {
            addIdleAnimation(to: handle)
        }
    }
    
    /// Process touch location and update joystick state
    private func processTouchLocation(_ location: CGPoint) {
        guard let handle = joystickHandle else { return }
        
        let dx = location.x
        let dy = location.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Dead zone - requires minimum movement to register direction
        if distance > deadZoneThreshold {
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
            let clampedDistance = min(distance, maxHandleDistance)
            let targetPosition = CGPoint(
                x: cos(angle) * clampedDistance,
                y: sin(angle) * clampedDistance
            )
            
            // Quick smooth movement
            let moveAction = SKAction.move(to: targetPosition, duration: 0.05)
            moveAction.timingMode = .easeOut
            handle.run(moveAction)
            
            // Update direction indicators
            updateDirectionIndicators(for: direction)
        } else {
            currentDirection = nil
            
            // Return handle to center
            let returnAction = SKAction.move(to: .zero, duration: 0.08)
            returnAction.timingMode = .easeOut
            handle.run(returnAction)
            
            // Reset direction indicators
            resetDirectionIndicators()
        }
    }
    
    /// Update direction indicators based on current direction
    private func updateDirectionIndicators(for direction: Direction) {
        for (index, indicator) in directionIndicators.enumerated() {
            let isActive: Bool
            switch index {
            case 0: isActive = direction == .right || direction == .upRight || direction == .downRight
            case 1: isActive = direction == .up || direction == .upLeft || direction == .upRight
            case 2: isActive = direction == .left || direction == .upLeft || direction == .downLeft
            case 3: isActive = direction == .down || direction == .downLeft || direction == .downRight
            default: isActive = false
            }
            
            let targetColor = isActive ? activeColor : SKColor.white.withAlphaComponent(0.3)
            indicator.fillColor = targetColor
        }
    }
    
    /// Reset all direction indicators to inactive
    private func resetDirectionIndicators() {
        for indicator in directionIndicators {
            indicator.fillColor = SKColor.white.withAlphaComponent(0.3)
        }
    }
    
    /// Activate visual feedback when touched
    private func activateVisuals() {
        outerGlow?.strokeColor = activeColor.withAlphaComponent(0.6)
        outerGlow?.glowWidth = 12
        innerGlow?.fillColor = activeColor.withAlphaComponent(0.6)
    }
    
    /// Deactivate visual feedback
    private func deactivateVisuals() {
        outerGlow?.strokeColor = glowColor.withAlphaComponent(0.3)
        outerGlow?.glowWidth = 8
        innerGlow?.fillColor = activeColor.withAlphaComponent(0.4)
        resetDirectionIndicators()
    }
    #endif
}
