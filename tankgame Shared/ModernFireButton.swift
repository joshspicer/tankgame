//
//  ModernFireButton.swift
//  tankgame Shared
//
//  A modernized fire button with glassy/neon visual styling
//

import SpriteKit

/// Manages the fire button UI with modern visual styling
class ModernFireButton {
    private var buttonNode: SKNode?
    private var buttonBase: SKShapeNode?
    private var buttonHighlight: SKShapeNode?
    private var innerGlow: SKShapeNode?
    private var buttonLabel: SKLabelNode?
    private var crosshairNode: SKNode?
    private var rippleContainer: SKNode?
    
    var onTap: (() -> Void)?
    
    // Visual constants
    private let buttonRadius: CGFloat = 45
    private let baseColor: SKColor = .systemRed
    private let highlightColor: SKColor = .systemOrange
    
    init() {}
    
    /// Setup the fire button with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        let container = SKNode()
        container.position = position
        container.zPosition = 100
        scene.addChild(container)
        buttonNode = container
        
        // Create ripple container for tap effects
        let ripples = SKNode()
        ripples.zPosition = -1
        container.addChild(ripples)
        rippleContainer = ripples
        
        // Create outer glow ring
        let outerGlow = SKShapeNode(circleOfRadius: buttonRadius + 10)
        outerGlow.fillColor = .clear
        outerGlow.strokeColor = baseColor.withAlphaComponent(0.3)
        outerGlow.lineWidth = 2
        outerGlow.glowWidth = 8
        container.addChild(outerGlow)
        addPulseAnimation(to: outerGlow)
        
        // Create button shadow
        let shadow = SKShapeNode(circleOfRadius: buttonRadius + 2)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.4)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -3)
        container.addChild(shadow)
        
        // Create main button base
        let base = SKShapeNode(circleOfRadius: buttonRadius)
        base.fillColor = baseColor
        base.strokeColor = highlightColor.withAlphaComponent(0.6)
        base.lineWidth = 3
        base.glowWidth = 5
        container.addChild(base)
        buttonBase = base
        
        // Create inner gradient effect
        let innerCircle = SKShapeNode(circleOfRadius: buttonRadius - 8)
        innerCircle.fillColor = baseColor.withAlphaComponent(0.8)
        innerCircle.strokeColor = .clear
        container.addChild(innerCircle)
        
        // Create highlight reflection (glassy effect)
        let highlightPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 8),
                                         radius: buttonRadius - 12,
                                         startAngle: CGFloat.pi * 0.2,
                                         endAngle: CGFloat.pi * 0.8,
                                         clockwise: true)
        highlightPath.addLine(to: CGPoint(x: 0, y: 12))
        highlightPath.close()
        
        let highlight = SKShapeNode(path: highlightPath.cgPath)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.3)
        highlight.strokeColor = .clear
        container.addChild(highlight)
        buttonHighlight = highlight
        
        // Create inner glow
        let glow = SKShapeNode(circleOfRadius: buttonRadius * 0.35)
        glow.fillColor = highlightColor.withAlphaComponent(0.5)
        glow.strokeColor = highlightColor
        glow.lineWidth = 2
        glow.glowWidth = 8
        container.addChild(glow)
        innerGlow = glow
        addGlowPulse(to: glow)
        
        // Create crosshair/target icon
        createCrosshair(in: container)
        
        // Create fire label
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = "FIRE"
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -buttonRadius - 20)
        label.zPosition = 1
        container.addChild(label)
        buttonLabel = label
        
        // Add idle animation
        addIdleAnimation(to: container)
    }
    
    /// Create a crosshair/target icon
    private func createCrosshair(in parent: SKNode) {
        let crosshair = SKNode()
        crosshair.zPosition = 5
        
        let lineLength: CGFloat = 12
        let lineWidth: CGFloat = 2
        let gap: CGFloat = 5
        
        // Create crosshair lines
        let positions: [(CGPoint, CGSize)] = [
            (CGPoint(x: 0, y: gap + lineLength/2), CGSize(width: lineWidth, height: lineLength)), // Top
            (CGPoint(x: 0, y: -gap - lineLength/2), CGSize(width: lineWidth, height: lineLength)), // Bottom
            (CGPoint(x: gap + lineLength/2, y: 0), CGSize(width: lineLength, height: lineWidth)), // Right
            (CGPoint(x: -gap - lineLength/2, y: 0), CGSize(width: lineLength, height: lineWidth))  // Left
        ]
        
        for (position, size) in positions {
            let line = SKSpriteNode(color: .white, size: size)
            line.position = position
            crosshair.addChild(line)
        }
        
        // Center dot
        let centerDot = SKShapeNode(circleOfRadius: 3)
        centerDot.fillColor = .white
        centerDot.strokeColor = .clear
        crosshair.addChild(centerDot)
        
        // Add subtle rotation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi / 8, duration: 2.0)
        let rotateBack = SKAction.rotate(byAngle: -CGFloat.pi / 8, duration: 2.0)
        let sequence = SKAction.sequence([rotate, rotateBack])
        let repeatAction = SKAction.repeatForever(sequence)
        crosshair.run(repeatAction)
        
        parent.addChild(crosshair)
        crosshairNode = crosshair
    }
    
    /// Add pulse animation to outer glow
    private func addPulseAnimation(to node: SKShapeNode) {
        let scaleUp = SKAction.scale(to: 1.08, duration: 0.8)
        let scaleDown = SKAction.scale(to: 0.92, duration: 0.8)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
    }
    
    /// Add glow pulse to inner element
    private func addGlowPulse(to node: SKShapeNode) {
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.6)
        let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.6)
        let sequence = SKAction.sequence([fadeOut, fadeIn])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
    }
    
    /// Add idle animation
    private func addIdleAnimation(to node: SKNode) {
        let floatUp = SKAction.moveBy(x: 0, y: 3, duration: 1.2)
        let floatDown = SKAction.moveBy(x: 0, y: -3, duration: 1.2)
        let sequence = SKAction.sequence([floatUp, floatDown])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction, withKey: "idle")
    }
    
    /// Get the button's position
    var position: CGPoint {
        return buttonNode?.position ?? .zero
    }
    
    #if os(iOS) || os(tvOS)
    /// Check if a touch is within the fire button and handle it
    /// - Returns: true if touch was handled by button
    func handleTouch(at location: CGPoint) -> Bool {
        guard let button = buttonNode else { return false }
        
        let dx = location.x - button.position.x
        let dy = location.y - button.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < buttonRadius + 15 {
            // Trigger tap animation
            animateTap()
            
            // Create ripple effect
            createRippleEffect()
            
            // Call callback
            onTap?()
            return true
        }
        
        return false
    }
    
    /// Animate button tap
    private func animateTap() {
        guard let button = buttonNode else { return }
        
        // Stop idle animation
        button.removeAction(forKey: "idle")
        
        // Scale down quickly
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.08)
        scaleDown.timingMode = .easeOut
        
        // Flash the base color
        let flashColor = SKAction.run { [weak self] in
            self?.buttonBase?.fillColor = .white
            self?.innerGlow?.fillColor = .white
        }
        
        let wait = SKAction.wait(forDuration: 0.05)
        
        // Scale back up with spring
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
        scaleUp.timingMode = .easeOut
        
        let scaleNormal = SKAction.scale(to: 1.0, duration: 0.1)
        
        // Reset colors
        let resetColor = SKAction.run { [weak self] in
            self?.buttonBase?.fillColor = self?.baseColor ?? .systemRed
            self?.innerGlow?.fillColor = self?.highlightColor.withAlphaComponent(0.5) ?? .systemOrange.withAlphaComponent(0.5)
        }
        
        // Resume idle animation
        let resumeIdle = SKAction.run { [weak self] in
            if let button = self?.buttonNode {
                self?.addIdleAnimation(to: button)
            }
        }
        
        let sequence = SKAction.sequence([
            scaleDown,
            flashColor,
            wait,
            scaleUp,
            resetColor,
            scaleNormal,
            resumeIdle
        ])
        
        button.run(sequence)
    }
    
    /// Create expanding ripple effect
    private func createRippleEffect() {
        guard let container = rippleContainer else { return }
        
        // Create multiple ripples
        for i in 0..<3 {
            let delay = Double(i) * 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                
                let ripple = SKShapeNode(circleOfRadius: self.buttonRadius * 0.5)
                ripple.fillColor = .clear
                ripple.strokeColor = self.highlightColor.withAlphaComponent(0.8)
                ripple.lineWidth = 3
                container.addChild(ripple)
                
                // Expand and fade
                let expand = SKAction.scale(to: 3.0, duration: 0.5)
                let fade = SKAction.fadeOut(withDuration: 0.5)
                let group = SKAction.group([expand, fade])
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([group, remove])
                
                ripple.run(sequence)
            }
        }
    }
    #endif
}
