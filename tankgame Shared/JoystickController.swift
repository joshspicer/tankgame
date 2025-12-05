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
    private var joystickGlow: SKShapeNode?
    private var joystickRing: SKShapeNode?
    private var directionIndicators: [SKShapeNode] = []
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    init() {}
    
    /// Setup the joystick UI
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        newJoystickNode.zPosition = 100
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        // Outer glow effect
        let baseRadius = GameTheme.Dimensions.joystickBaseRadius
        let handleRadius = GameTheme.Dimensions.joystickHandleRadius
        let glowRadius = GameTheme.Dimensions.joystickGlowRadius
        
        let newJoystickGlow = SKShapeNode(circleOfRadius: glowRadius)
        newJoystickGlow.fillColor = GameTheme.Colors.joystickGlow
        newJoystickGlow.strokeColor = .clear
        newJoystickGlow.alpha = 0.3
        newJoystickGlow.zPosition = -2
        newJoystickNode.addChild(newJoystickGlow)
        joystickGlow = newJoystickGlow
        
        // Outer ring
        let newJoystickRing = SKShapeNode(circleOfRadius: baseRadius + 3)
        newJoystickRing.fillColor = .clear
        newJoystickRing.strokeColor = GameTheme.Colors.primary.withAlphaComponent(0.4)
        newJoystickRing.lineWidth = 2
        newJoystickRing.glowWidth = 3
        newJoystickRing.zPosition = -1
        newJoystickNode.addChild(newJoystickRing)
        joystickRing = newJoystickRing
        
        // Base with gradient-like effect using layered circles
        let newJoystickBase = SKShapeNode(circleOfRadius: baseRadius)
        newJoystickBase.fillColor = GameTheme.Colors.joystickBase
        newJoystickBase.strokeColor = GameTheme.Colors.gridBorder.withAlphaComponent(0.6)
        newJoystickBase.lineWidth = 2
        newJoystickBase.alpha = 0.95
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        // Inner decorative ring
        let innerRing = SKShapeNode(circleOfRadius: baseRadius - 8)
        innerRing.fillColor = .clear
        innerRing.strokeColor = GameTheme.Colors.gridBorder.withAlphaComponent(0.3)
        innerRing.lineWidth = 1
        newJoystickNode.addChild(innerRing)
        
        // Direction indicator dots
        createDirectionIndicators(in: newJoystickNode, radius: baseRadius - 15)
        
        // Handle with shadow effect
        let shadowHandle = SKShapeNode(circleOfRadius: handleRadius + 2)
        shadowHandle.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadowHandle.strokeColor = .clear
        shadowHandle.position = CGPoint(x: 2, y: -2)
        shadowHandle.zPosition = 1
        newJoystickNode.addChild(shadowHandle)
        
        let newJoystickHandle = SKShapeNode(circleOfRadius: handleRadius)
        newJoystickHandle.fillColor = GameTheme.Colors.joystickHandle
        newJoystickHandle.strokeColor = GameTheme.Colors.primary.withAlphaComponent(0.6)
        newJoystickHandle.lineWidth = 2
        newJoystickHandle.glowWidth = 2
        newJoystickHandle.alpha = 1.0
        newJoystickHandle.zPosition = 2
        newJoystickNode.addChild(newJoystickHandle)
        joystickHandle = newJoystickHandle
        
        // Handle inner highlight
        let handleHighlight = SKShapeNode(circleOfRadius: handleRadius * 0.6)
        handleHighlight.fillColor = GameTheme.Colors.textSecondary.withAlphaComponent(0.2)
        handleHighlight.strokeColor = .clear
        handleHighlight.position = CGPoint(x: -3, y: 3)
        newJoystickHandle.addChild(handleHighlight)
        
        // Add subtle pulse animation to the glow
        addGlowAnimation()
    }
    
    /// Create direction indicator dots around the joystick
    private func createDirectionIndicators(in parent: SKNode, radius: CGFloat) {
        let directions: [(angle: CGFloat, name: String)] = [
            (0, "right"),
            (.pi / 2, "up"),
            (.pi, "left"),
            (-.pi / 2, "down")
        ]
        
        for (angle, _) in directions {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.fillColor = GameTheme.Colors.textMuted.withAlphaComponent(0.5)
            dot.strokeColor = .clear
            dot.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            parent.addChild(dot)
            directionIndicators.append(dot)
        }
    }
    
    /// Add subtle glow animation to the joystick
    private func addGlowAnimation() {
        guard let glow = joystickGlow else { return }
        
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: GameTheme.Animations.glowSpeed)
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: GameTheme.Animations.glowSpeed)
        fadeIn.timingMode = .easeInEaseOut
        fadeOut.timingMode = .easeInEaseOut
        let pulseSequence = SKAction.sequence([fadeIn, fadeOut])
        let repeatPulse = SKAction.repeatForever(pulseSequence)
        glow.run(repeatPulse)
    }
    
    /// Highlight the active direction indicator
    private func highlightDirection(_ direction: Direction?) {
        // Reset all indicators
        for dot in directionIndicators {
            dot.fillColor = GameTheme.Colors.textMuted.withAlphaComponent(0.5)
            dot.setScale(1.0)
        }
        
        // Highlight active direction
        guard let direction = direction else { return }
        
        let index: Int?
        switch direction {
        case .right, .upRight, .downRight:
            index = 0
        case .up, .upLeft:
            index = 1
        case .left, .downLeft:
            index = 2
        case .down:
            index = 3
        }
        
        if let idx = index, idx < directionIndicators.count {
            directionIndicators[idx].fillColor = GameTheme.Colors.primary
            directionIndicators[idx].setScale(1.3)
        }
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
        highlightDirection(nil)
        
        // Reset ring glow
        joystickRing?.strokeColor = GameTheme.Colors.primary.withAlphaComponent(0.4)
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
            highlightDirection(direction)
            
            // Update joystick handle position with smooth movement
            let maxDistance: CGFloat = 35
            let clampedDistance = min(distance, maxDistance)
            handle.position = CGPoint(
                x: cos(angle) * clampedDistance,
                y: sin(angle) * clampedDistance
            )
            
            // Update ring glow when active
            joystickRing?.strokeColor = GameTheme.Colors.primary.withAlphaComponent(0.8)
        } else {
            currentDirection = nil
            highlightDirection(nil)
            handle.position = .zero
            joystickRing?.strokeColor = GameTheme.Colors.primary.withAlphaComponent(0.4)
        }
    }
    #endif
}
