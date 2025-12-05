//
//  ModernJoystickController.swift
//  tankgame Shared
//
//  Enhanced virtual joystick with modern styling
//

import SpriteKit

/// Modern styled virtual joystick controller
class ModernJoystickController {
    // Nodes
    private var joystickNode: SKNode?
    private var joystickBase: SKShapeNode?
    private var joystickHandle: SKNode?
    private var handleInner: SKShapeNode?
    private var directionIndicator: SKShapeNode?
    
    // State
    private(set) var isActive = false
    private var touchID: UITouch?
    private(set) var currentDirection: Direction?
    
    init() {}
    
    /// Setup the joystick UI with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let newJoystickNode = SKNode()
        newJoystickNode.position = position
        newJoystickNode.zPosition = 50
        scene.addChild(newJoystickNode)
        joystickNode = newJoystickNode
        
        // Create outer glow
        let outerGlow = SKShapeNode(circleOfRadius: 58)
        outerGlow.fillColor = .clear
        outerGlow.strokeColor = SKColor.white.withAlphaComponent(0.15)
        outerGlow.lineWidth = 4
        outerGlow.glowWidth = 8
        newJoystickNode.addChild(outerGlow)
        
        // Create base ring
        let newJoystickBase = SKShapeNode(circleOfRadius: 50)
        newJoystickBase.fillColor = SKColor.black.withAlphaComponent(0.3)
        newJoystickBase.strokeColor = SKColor.white.withAlphaComponent(0.6)
        newJoystickBase.lineWidth = 2.5
        newJoystickNode.addChild(newJoystickBase)
        joystickBase = newJoystickBase
        
        // Create direction indicator ring (shows active direction)
        let indicator = SKShapeNode(circleOfRadius: 50)
        indicator.fillColor = .clear
        indicator.strokeColor = SKColor.cyan.withAlphaComponent(0.0)
        indicator.lineWidth = 3
        newJoystickNode.addChild(indicator)
        directionIndicator = indicator
        
        // Create handle container
        let handleContainer = SKNode()
        newJoystickNode.addChild(handleContainer)
        joystickHandle = handleContainer
        
        // Create handle outer ring
        let handleOuter = SKShapeNode(circleOfRadius: 28)
        handleOuter.fillColor = .clear
        handleOuter.strokeColor = SKColor.white.withAlphaComponent(0.9)
        handleOuter.lineWidth = 2
        handleContainer.addChild(handleOuter)
        
        // Create handle inner circle
        let handleInnerCircle = SKShapeNode(circleOfRadius: 24)
        handleInnerCircle.fillColor = SKColor.white.withAlphaComponent(0.8)
        handleInnerCircle.strokeColor = .clear
        handleContainer.addChild(handleInnerCircle)
        handleInner = handleInnerCircle
        
        // Create highlight (top shine)
        let highlight = SKShapeNode(circleOfRadius: 12)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.4)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: 6)
        handleContainer.addChild(highlight)
        
        // Add directional arrows
        addDirectionalArrows(to: newJoystickNode)
    }
    
    /// Add subtle directional arrows around the joystick
    private func addDirectionalArrows(to node: SKNode) {
        let arrowDistance: CGFloat = 40
        let arrowSize: CGFloat = 8
        
        let directions: [(CGFloat, CGFloat)] = [
            (0, arrowDistance),      // Up
            (0, -arrowDistance),     // Down
            (-arrowDistance, 0),     // Left
            (arrowDistance, 0)       // Right
        ]
        
        for (x, y) in directions {
            let arrow = SKShapeNode()
            let path = CGMutablePath()
            
            if x == 0 {
                // Vertical arrow
                let dir: CGFloat = y > 0 ? 1 : -1
                path.move(to: CGPoint(x: -arrowSize, y: -arrowSize * dir * 0.5))
                path.addLine(to: CGPoint(x: 0, y: arrowSize * dir * 0.5))
                path.addLine(to: CGPoint(x: arrowSize, y: -arrowSize * dir * 0.5))
            } else {
                // Horizontal arrow
                let dir: CGFloat = x > 0 ? 1 : -1
                path.move(to: CGPoint(x: -arrowSize * dir * 0.5, y: -arrowSize))
                path.addLine(to: CGPoint(x: arrowSize * dir * 0.5, y: 0))
                path.addLine(to: CGPoint(x: -arrowSize * dir * 0.5, y: arrowSize))
            }
            
            arrow.path = path
            arrow.strokeColor = SKColor.white.withAlphaComponent(0.25)
            arrow.fillColor = .clear
            arrow.lineWidth = 1.5
            arrow.position = CGPoint(x: x, y: y)
            node.addChild(arrow)
        }
    }
    
    /// Get the joystick's center position
    var position: CGPoint {
        return joystickNode?.position ?? .zero
    }
    
    /// Show active state
    private func showActiveState() {
        handleInner?.fillColor = SKColor.cyan.withAlphaComponent(0.9)
        directionIndicator?.strokeColor = SKColor.cyan.withAlphaComponent(0.6)
    }
    
    /// Show inactive state
    private func showInactiveState() {
        handleInner?.fillColor = SKColor.white.withAlphaComponent(0.8)
        directionIndicator?.strokeColor = SKColor.cyan.withAlphaComponent(0.0)
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
            showActiveState()
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
        showInactiveState()
        
        // Animate handle back to center
        let returnAction = SKAction.move(to: .zero, duration: 0.15)
        returnAction.timingMode = .easeOut
        joystickHandle?.run(returnAction)
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
