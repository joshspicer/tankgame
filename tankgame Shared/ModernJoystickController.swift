//
//  ModernJoystickController.swift
//  tankgame Shared
//
//  Enhanced joystick with modern styling, glow effects, and haptic feedback
//

import SpriteKit

/// Modern joystick controller with enhanced visuals and feedback
class ModernJoystickController {
    
    // MARK: - Nodes
    
    private var containerNode: SKNode?
    private var outerRing: SKShapeNode?
    private var innerRing: SKShapeNode?
    private var joystickBase: SKShapeNode?
    private var joystickHandle: SKShapeNode?
    private var glowNode: SKShapeNode?
    private var directionIndicators: [SKShapeNode] = []
    
    // MARK: - State
    
    private(set) var isActive = false
    private var touchID: Any?
    private(set) var currentDirection: Direction?
    
    // MARK: - Configuration
    
    let baseRadius: CGFloat = 60
    let handleRadius: CGFloat = 28
    let maxHandleDistance: CGFloat = 35
    let deadZone: CGFloat = 15
    
    // MARK: - Colors
    
    struct Colors {
        static let outerRing = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.3)
        static let innerRing = SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.2)
        static let baseColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.5)
        static let baseStroke = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 0.8)
        static let handleColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.9)
        static let handleStroke = SKColor.white
        static let glowColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.6)
        static let activeGlow = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.9)
        static let directionIndicator = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.4)
    }
    
    init() {}
    
    // MARK: - Setup
    
    /// Setup the modern joystick UI
    func setup(in scene: SKScene, at position: CGPoint) {
        let container = SKNode()
        container.position = position
        container.zPosition = 100
        scene.addChild(container)
        containerNode = container
        
        // Create outer glow ring
        let outer = SKShapeNode(circleOfRadius: baseRadius + 15)
        outer.fillColor = Colors.outerRing
        outer.strokeColor = .clear
        outer.alpha = 0.5
        container.addChild(outer)
        outerRing = outer
        
        // Create inner ring
        let inner = SKShapeNode(circleOfRadius: baseRadius + 5)
        inner.fillColor = Colors.innerRing
        inner.strokeColor = Colors.baseStroke.withAlphaComponent(0.3)
        inner.lineWidth = 1
        container.addChild(inner)
        innerRing = inner
        
        // Create main joystick base
        let base = SKShapeNode(circleOfRadius: baseRadius)
        base.fillColor = Colors.baseColor
        base.strokeColor = Colors.baseStroke
        base.lineWidth = 2
        base.glowWidth = 3
        container.addChild(base)
        joystickBase = base
        
        // Create direction indicators
        createDirectionIndicators(in: container)
        
        // Create glow effect for handle
        let glow = SKShapeNode(circleOfRadius: handleRadius + 8)
        glow.fillColor = Colors.glowColor
        glow.strokeColor = .clear
        glow.alpha = 0.5
        container.addChild(glow)
        glowNode = glow
        
        // Create joystick handle
        let handle = SKShapeNode(circleOfRadius: handleRadius)
        handle.fillColor = Colors.handleColor
        handle.strokeColor = Colors.handleStroke
        handle.lineWidth = 3
        handle.glowWidth = 2
        container.addChild(handle)
        joystickHandle = handle
        
        // Add idle animation to handle
        addIdleAnimation()
    }
    
    private func createDirectionIndicators(in container: SKNode) {
        let indicatorDistance = baseRadius - 10
        let angles: [CGFloat] = [0, .pi/2, .pi, -.pi/2] // Right, Up, Left, Down
        
        for angle in angles {
            let indicator = SKShapeNode(circleOfRadius: 5)
            indicator.fillColor = Colors.directionIndicator
            indicator.strokeColor = .clear
            indicator.position = CGPoint(
                x: cos(angle) * indicatorDistance,
                y: sin(angle) * indicatorDistance
            )
            indicator.alpha = 0.6
            container.addChild(indicator)
            directionIndicators.append(indicator)
        }
    }
    
    private func addIdleAnimation() {
        guard let handle = joystickHandle, let glow = glowNode else { return }
        
        // Subtle pulse animation for handle
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.95, duration: 1.0)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        handle.run(SKAction.repeatForever(pulse))
        
        // Glow pulse animation
        let glowUp = SKAction.fadeAlpha(to: 0.7, duration: 1.2)
        let glowDown = SKAction.fadeAlpha(to: 0.4, duration: 1.2)
        let glowPulse = SKAction.sequence([glowUp, glowDown])
        glow.run(SKAction.repeatForever(glowPulse))
    }
    
    // MARK: - Position
    
    var position: CGPoint {
        return containerNode?.position ?? .zero
    }
    
    // MARK: - Touch Handling
    
    #if os(iOS) || os(tvOS)
    /// Handle touch began in joystick area
    func handleTouchBegan(_ touch: UITouch, in scene: SKScene) -> Bool {
        guard let container = containerNode else { return false }
        
        let location = touch.location(in: scene)
        let joystickCenter = container.position
        let dx = location.x - joystickCenter.x
        let dy = location.y - joystickCenter.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Joystick area is 150 points radius
        if distance < 150 {
            isActive = true
            touchID = touch
            activateJoystick()
            processTouchLocation(touch.location(in: container))
            return true
        }
        
        return false
    }
    
    /// Handle touch moved
    func handleTouchMoved(_ touch: UITouch, in scene: SKScene) {
        guard isActive, touch === touchID as AnyObject, let container = containerNode else { return }
        
        let location = touch.location(in: container)
        processTouchLocation(location)
    }
    
    /// Handle touch ended
    func handleTouchEnded(_ touch: UITouch) {
        guard touch === touchID as AnyObject else { return }
        
        isActive = false
        touchID = nil
        currentDirection = nil
        deactivateJoystick()
    }
    #endif
    
    // MARK: - Joystick Processing
    
    private func processTouchLocation(_ location: CGPoint) {
        guard let handle = joystickHandle, let glow = glowNode else { return }
        
        let dx = location.x
        let dy = location.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance > deadZone {
            let angle = atan2(dy, dx)
            
            // Calculate direction (8-way)
            let direction = calculateDirection(from: angle)
            
            // Only update if direction changed
            if currentDirection != direction {
                currentDirection = direction
                highlightDirectionIndicator(for: direction)
            }
            
            // Update handle position with clamping
            let clampedDistance = min(distance, maxHandleDistance)
            let newPosition = CGPoint(
                x: cos(angle) * clampedDistance,
                y: sin(angle) * clampedDistance
            )
            
            // Smooth animation to new position
            let moveAction = SKAction.move(to: newPosition, duration: 0.05)
            moveAction.timingMode = .easeOut
            handle.run(moveAction)
            glow.run(moveAction)
            
        } else {
            currentDirection = nil
            resetHandlePosition()
            resetDirectionIndicators()
        }
    }
    
    private func calculateDirection(from angle: CGFloat) -> Direction {
        let angleDeg = angle * 180 / .pi
        
        if angleDeg > -22.5 && angleDeg <= 22.5 {
            return .right
        } else if angleDeg > 22.5 && angleDeg <= 67.5 {
            return .upRight
        } else if angleDeg > 67.5 && angleDeg <= 112.5 {
            return .up
        } else if angleDeg > 112.5 && angleDeg <= 157.5 {
            return .upLeft
        } else if angleDeg > 157.5 || angleDeg <= -157.5 {
            return .left
        } else if angleDeg > -157.5 && angleDeg <= -112.5 {
            return .downLeft
        } else if angleDeg > -112.5 && angleDeg <= -67.5 {
            return .down
        } else {
            return .downRight
        }
    }
    
    // MARK: - Visual Feedback
    
    private func activateJoystick() {
        guard let base = joystickBase, let glow = glowNode else { return }
        
        // Scale up and brighten
        let scaleAction = SKAction.scale(to: 1.1, duration: 0.1)
        let brightenGlow = SKAction.run { [weak glow] in
            glow?.fillColor = Colors.activeGlow
            glow?.alpha = 0.8
        }
        
        base.run(scaleAction)
        glow.run(brightenGlow)
    }
    
    private func deactivateJoystick() {
        guard let base = joystickBase, let glow = glowNode else { return }
        
        // Scale back and dim
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.15)
        let dimGlow = SKAction.run { [weak glow] in
            glow?.fillColor = Colors.glowColor
            glow?.alpha = 0.5
        }
        
        base.run(scaleAction)
        glow.run(dimGlow)
        resetHandlePosition()
        resetDirectionIndicators()
    }
    
    private func resetHandlePosition() {
        guard let handle = joystickHandle, let glow = glowNode else { return }
        
        let moveAction = SKAction.move(to: .zero, duration: 0.1)
        moveAction.timingMode = .easeOut
        handle.run(moveAction)
        glow.run(moveAction)
    }
    
    private func highlightDirectionIndicator(for direction: Direction) {
        resetDirectionIndicators()
        
        // Map direction to indicator index
        let indicatorMap: [Direction: Int] = [
            .right: 0, .upRight: 0,
            .up: 1, .upLeft: 1,
            .left: 2, .downLeft: 2,
            .down: 3, .downRight: 3
        ]
        
        if let index = indicatorMap[direction], index < directionIndicators.count {
            let indicator = directionIndicators[index]
            indicator.run(SKAction.fadeAlpha(to: 1.0, duration: 0.1))
            indicator.run(SKAction.scale(to: 1.5, duration: 0.1))
        }
    }
    
    private func resetDirectionIndicators() {
        for indicator in directionIndicators {
            indicator.run(SKAction.fadeAlpha(to: 0.6, duration: 0.1))
            indicator.run(SKAction.scale(to: 1.0, duration: 0.1))
        }
    }
}
