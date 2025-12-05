//
//  JoystickController.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages the virtual joystick UI and input processing with modern glass-morphism styling
class JoystickController {
    // Nodes
    private var joystickNode: SKNode?
    private var joystickBase: SKShapeNode?
    private var joystickHandle: SKShapeNode?
    private var joystickGlow: SKShapeNode?
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    init() {}
    
    /// Setup the joystick UI with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        newJoystickNode.zPosition = 100
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        // Outer glow effect
        let glow = SKShapeNode(circleOfRadius: 58)
        glow.fillColor = UXTheme.primaryColor.withAlphaComponent(0.08)
        glow.strokeColor = .clear
        glow.zPosition = -1
        newJoystickNode.addChild(glow)
        joystickGlow = glow
        
        // Base with glass-morphism effect
        let newJoystickBase = SKShapeNode(circleOfRadius: 52)
        newJoystickBase.fillColor = UXTheme.joystickBase
        newJoystickBase.strokeColor = SKColor.white.withAlphaComponent(0.15)
        newJoystickBase.lineWidth = 2
        newJoystickBase.glowWidth = 0
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        // Inner ring decoration
        let innerRing = SKShapeNode(circleOfRadius: 35)
        innerRing.fillColor = .clear
        innerRing.strokeColor = SKColor.white.withAlphaComponent(0.08)
        innerRing.lineWidth = 1
        newJoystickNode.addChild(innerRing)
        
        // Directional indicators
        addDirectionIndicators(to: newJoystickNode)
        
        // Handle with gradient-like appearance
        let newJoystickHandle = SKShapeNode(circleOfRadius: 22)
        newJoystickHandle.fillColor = UXTheme.joystickHandle
        newJoystickHandle.strokeColor = SKColor.white.withAlphaComponent(0.3)
        newJoystickHandle.lineWidth = 2
        newJoystickHandle.glowWidth = 2
        newJoystickNode.addChild(newJoystickHandle)
        joystickHandle = newJoystickHandle
        
        // Handle highlight (gives 3D appearance)
        let handleHighlight = SKShapeNode(circleOfRadius: 14)
        handleHighlight.fillColor = SKColor.white.withAlphaComponent(0.1)
        handleHighlight.strokeColor = .clear
        handleHighlight.position = CGPoint(x: -3, y: 3)
        newJoystickHandle.addChild(handleHighlight)
    }
    
    /// Add subtle directional indicators
    private func addDirectionIndicators(to node: SKNode) {
        let indicatorColor = SKColor.white.withAlphaComponent(0.15)
        let distance: CGFloat = 42
        
        // Create small triangles pointing outward
        let directions: [(CGFloat, CGFloat)] = [
            (0, 1),    // Up
            (0, -1),   // Down
            (-1, 0),   // Left
            (1, 0)     // Right
        ]
        
        for (dx, dy) in directions {
            let indicator = SKShapeNode(path: createTrianglePath(size: 6))
            indicator.fillColor = indicatorColor
            indicator.strokeColor = .clear
            indicator.position = CGPoint(x: dx * distance, y: dy * distance)
            indicator.zRotation = atan2(dy, dx) - .pi / 2
            node.addChild(indicator)
        }
    }
    
    /// Create a small triangle path for indicators
    private func createTrianglePath(size: CGFloat) -> CGPath {
        let triangleBaseRatio: CGFloat = 0.7
        let triangleHeightRatio: CGFloat = 0.5
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: -size * triangleBaseRatio, y: -size * triangleHeightRatio))
        path.addLine(to: CGPoint(x: size * triangleBaseRatio, y: -size * triangleHeightRatio))
        path.closeSubpath()
        return path
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
            
            // Visual feedback - scale up slightly
            let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
            joystickNode?.run(scaleUp)
            
            // Glow effect
            joystickGlow?.run(SKAction.fadeAlpha(to: 0.2, duration: 0.1))
            
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
        let returnAction = SKAction.move(to: .zero, duration: 0.15)
        returnAction.timingMode = .easeOut
        joystickHandle?.run(returnAction)
        
        // Visual feedback - scale back
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        joystickNode?.run(scaleDown)
        
        // Reduce glow
        joystickGlow?.run(SKAction.fadeAlpha(to: 0.08, duration: 0.15))
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
