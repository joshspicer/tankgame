//
//  ModernFireButton.swift
//  tankgame Shared
//
//  Enhanced fire button with modern styling and effects
//

import SpriteKit

/// Modern styled fire button with visual effects
class ModernFireButton {
    private var buttonNode: SKNode?
    private var outerRing: SKShapeNode?
    private var innerCircle: SKShapeNode?
    private var labelNode: SKLabelNode?
    var onTap: (() -> Void)?
    
    init() {}
    
    /// Setup the fire button with modern styling
    func setup(in scene: SKScene, at position: CGPoint) {
        // Create container node
        let container = SKNode()
        container.position = position
        container.zPosition = 50
        scene.addChild(container)
        buttonNode = container
        
        // Create outer glow ring
        let glow = SKShapeNode(circleOfRadius: 52)
        glow.fillColor = .clear
        glow.strokeColor = SKColor.red.withAlphaComponent(0.3)
        glow.lineWidth = 6
        glow.glowWidth = 8
        container.addChild(glow)
        
        // Animate outer glow
        let pulseOut = SKAction.scale(to: 1.15, duration: 1.0)
        let pulseIn = SKAction.scale(to: 1.0, duration: 1.0)
        let fadeOut = SKAction.fadeAlpha(to: 0.15, duration: 1.0)
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: 1.0)
        let pulseSeq = SKAction.sequence([
            SKAction.group([pulseOut, fadeOut]),
            SKAction.group([pulseIn, fadeIn])
        ])
        glow.run(SKAction.repeatForever(pulseSeq))
        
        // Create outer ring
        let outer = SKShapeNode(circleOfRadius: 44)
        outer.fillColor = .clear
        outer.strokeColor = SKColor.white.withAlphaComponent(0.8)
        outer.lineWidth = 3
        container.addChild(outer)
        outerRing = outer
        
        // Create inner circle with gradient-like effect
        let inner = SKShapeNode(circleOfRadius: 38)
        inner.fillColor = SKColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 0.9)
        inner.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        inner.lineWidth = 2
        container.addChild(inner)
        innerCircle = inner
        
        // Create highlight (top shine)
        let highlight = SKShapeNode(circleOfRadius: 22)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.25)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: 8)
        container.addChild(highlight)
        
        // Add "FIRE" label
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = "FIRE"
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)
        labelNode = label
        
        // Add subtle idle animation
        let bobUp = SKAction.moveBy(x: 0, y: 2, duration: 1.5)
        let bobDown = SKAction.moveBy(x: 0, y: -2, duration: 1.5)
        bobUp.timingMode = .easeInEaseOut
        bobDown.timingMode = .easeInEaseOut
        container.run(SKAction.repeatForever(SKAction.sequence([bobUp, bobDown])))
    }
    
    /// Get the button's position
    var position: CGPoint {
        return buttonNode?.position ?? .zero
    }
    
    /// Trigger pressed visual feedback
    func showPressedState() {
        guard let button = buttonNode else { return }
        
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.08)
        scaleDown.timingMode = .easeOut
        button.run(scaleDown)
        
        // Flash effect
        innerCircle?.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
    }
    
    /// Reset to normal state
    func showNormalState() {
        guard let button = buttonNode else { return }
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.15)
        scaleUp.timingMode = .easeOut
        button.run(scaleUp)
        
        innerCircle?.fillColor = SKColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 0.9)
    }
    
    #if os(iOS) || os(tvOS)
    /// Check if a touch is within the fire button and handle it
    /// - Returns: true if touch was handled by button
    func handleTouch(at location: CGPoint) -> Bool {
        guard let button = buttonNode else { return false }
        
        let dx = location.x - button.position.x
        let dy = location.y - button.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < 55 {
            showPressedState()
            onTap?()
            
            // Reset after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.showNormalState()
            }
            
            return true
        }
        
        return false
    }
    #endif
}
