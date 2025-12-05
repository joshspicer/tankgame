//
//  ModernFireButton.swift
//  tankgame Shared
//
//  Enhanced fire button with modern styling, animations, and visual feedback
//

import SpriteKit

/// Modern fire button with enhanced visuals and animations
class ModernFireButton {
    
    // MARK: - Nodes
    
    private var containerNode: SKNode?
    private var outerGlow: SKShapeNode?
    private var buttonBase: SKShapeNode?
    private var buttonTop: SKShapeNode?
    private var labelNode: SKLabelNode?
    private var ringEffect: SKShapeNode?
    
    // MARK: - State
    
    private var isPressed = false
    var onTap: (() -> Void)?
    
    // MARK: - Configuration
    
    let buttonRadius: CGFloat = 45
    
    // MARK: - Colors
    
    struct Colors {
        static let outerGlow = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.4)
        static let buttonBase = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.9)
        static let buttonTop = SKColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0)
        static let buttonStroke = SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.8)
        static let pressedBase = SKColor(red: 0.6, green: 0.15, blue: 0.15, alpha: 0.9)
        static let pressedTop = SKColor(red: 0.8, green: 0.25, blue: 0.25, alpha: 1.0)
        static let textColor = SKColor.white
        static let ringEffect = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.6)
    }
    
    init() {}
    
    // MARK: - Setup
    
    /// Setup the modern fire button
    func setup(in scene: SKScene, at position: CGPoint) {
        let container = SKNode()
        container.position = position
        container.zPosition = 100
        scene.addChild(container)
        containerNode = container
        
        // Create outer glow
        let glow = SKShapeNode(circleOfRadius: buttonRadius + 15)
        glow.fillColor = Colors.outerGlow
        glow.strokeColor = .clear
        glow.alpha = 0.6
        container.addChild(glow)
        outerGlow = glow
        
        // Create ring effect (for tap animation)
        let ring = SKShapeNode(circleOfRadius: buttonRadius)
        ring.fillColor = .clear
        ring.strokeColor = Colors.ringEffect
        ring.lineWidth = 3
        ring.alpha = 0
        container.addChild(ring)
        ringEffect = ring
        
        // Create button base (shadow layer)
        let base = SKShapeNode(circleOfRadius: buttonRadius)
        base.fillColor = Colors.buttonBase
        base.strokeColor = Colors.buttonStroke.withAlphaComponent(0.3)
        base.lineWidth = 2
        base.position = CGPoint(x: 0, y: -3) // Slight offset for 3D effect
        container.addChild(base)
        buttonBase = base
        
        // Create button top
        let top = SKShapeNode(circleOfRadius: buttonRadius - 3)
        top.fillColor = Colors.buttonTop
        top.strokeColor = Colors.buttonStroke
        top.lineWidth = 3
        top.glowWidth = 2
        container.addChild(top)
        buttonTop = top
        
        // Create FIRE label
        let label = SKLabelNode(fontNamed: "Arial-BoldMT")
        label.text = "FIRE"
        label.fontSize = 16
        label.fontColor = Colors.textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)
        labelNode = label
        
        // Add crosshair icon above text
        addCrosshairIcon(to: container)
        
        // Add idle animations
        addIdleAnimations()
    }
    
    private func addCrosshairIcon(to container: SKNode) {
        let crosshairSize: CGFloat = 12
        let lineWidth: CGFloat = 2
        
        // Horizontal line
        let horizontal = SKShapeNode(rectOf: CGSize(width: crosshairSize, height: lineWidth))
        horizontal.fillColor = Colors.textColor.withAlphaComponent(0.8)
        horizontal.strokeColor = .clear
        horizontal.position = CGPoint(x: 0, y: 12)
        container.addChild(horizontal)
        
        // Vertical line
        let vertical = SKShapeNode(rectOf: CGSize(width: lineWidth, height: crosshairSize))
        vertical.fillColor = Colors.textColor.withAlphaComponent(0.8)
        vertical.strokeColor = .clear
        vertical.position = CGPoint(x: 0, y: 12)
        container.addChild(vertical)
        
        // Small center dot
        let dot = SKShapeNode(circleOfRadius: 2)
        dot.fillColor = Colors.textColor
        dot.strokeColor = .clear
        dot.position = CGPoint(x: 0, y: 12)
        container.addChild(dot)
        
        // Update label position to be below crosshair
        labelNode?.position = CGPoint(x: 0, y: -8)
    }
    
    private func addIdleAnimations() {
        guard let glow = outerGlow, let top = buttonTop else { return }
        
        // Glow pulse animation
        let glowUp = SKAction.fadeAlpha(to: 0.8, duration: 0.8)
        let glowDown = SKAction.fadeAlpha(to: 0.4, duration: 0.8)
        let glowPulse = SKAction.sequence([glowUp, glowDown])
        glow.run(SKAction.repeatForever(glowPulse))
        
        // Subtle scale pulse
        let scaleUp = SKAction.scale(to: 1.03, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.97, duration: 1.0)
        let scalePulse = SKAction.sequence([scaleUp, scaleDown])
        top.run(SKAction.repeatForever(scalePulse))
    }
    
    // MARK: - Position
    
    var position: CGPoint {
        return containerNode?.position ?? .zero
    }
    
    // MARK: - Touch Handling
    
    #if os(iOS) || os(tvOS)
    /// Check if a touch is within the fire button and handle it
    func handleTouch(at location: CGPoint) -> Bool {
        guard let container = containerNode else { return false }
        
        let dx = location.x - container.position.x
        let dy = location.y - container.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < buttonRadius + 15 {
            triggerFire()
            return true
        }
        
        return false
    }
    #endif
    
    // MARK: - Fire Action
    
    private func triggerFire() {
        guard !isPressed else { return }
        
        isPressed = true
        playPressAnimation()
        onTap?()
        
        // Reset after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.isPressed = false
            self?.playReleaseAnimation()
        }
    }
    
    private func playPressAnimation() {
        guard let top = buttonTop, let base = buttonBase, let ring = ringEffect else { return }
        
        // Press down effect
        let pressAction = SKAction.group([
            SKAction.scale(to: 0.9, duration: 0.05),
            SKAction.move(to: CGPoint(x: 0, y: -2), duration: 0.05)
        ])
        top.run(pressAction)
        
        // Darken colors
        top.fillColor = Colors.pressedTop
        base.fillColor = Colors.pressedBase
        
        // Ring expansion effect
        ring.alpha = 0.8
        ring.setScale(1.0)
        let ringExpand = SKAction.group([
            SKAction.scale(to: 2.0, duration: 0.3),
            SKAction.fadeAlpha(to: 0, duration: 0.3)
        ])
        ring.run(ringExpand)
    }
    
    private func playReleaseAnimation() {
        guard let top = buttonTop, let base = buttonBase else { return }
        
        // Release effect
        let releaseAction = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.move(to: .zero, duration: 0.1)
        ])
        releaseAction.timingMode = .easeOut
        top.run(releaseAction)
        
        // Restore colors
        top.fillColor = Colors.buttonTop
        base.fillColor = Colors.buttonBase
    }
    
    /// Flash the button to indicate successful fire
    func playSuccessFlash() {
        guard let top = buttonTop else { return }
        
        let flashWhite = SKAction.run { [weak top] in
            top?.fillColor = .white
        }
        let wait = SKAction.wait(forDuration: 0.05)
        let restore = SKAction.run { [weak top] in
            top?.fillColor = Colors.buttonTop
        }
        
        top.run(SKAction.sequence([flashWhite, wait, restore]))
    }
}
