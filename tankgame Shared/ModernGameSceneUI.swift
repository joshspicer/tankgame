//
//  ModernGameSceneUI.swift
//  tankgame Shared
//
//  Modern, enhanced UI elements for the game scene
//

import SpriteKit

/// Provides modern styling for in-game UI elements
class ModernGameSceneUI {
    
    // MARK: - Status Label Enhancement
    
    /// Create a modern styled status label
    static func createStyledStatusLabel(in scene: SKScene, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = 22
        label.fontColor = .white
        label.position = position
        label.text = "Waiting for game..."
        label.zPosition = 100
        
        // Add shadow effect
        let shadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadow.fontSize = 22
        shadow.fontColor = SKColor(white: 0, alpha: 0.4)
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.text = label.text
        shadow.zPosition = -1
        label.addChild(shadow)
        
        // Add background pill
        let bgWidth: CGFloat = 240
        let bgHeight: CGFloat = 40
        let background = SKShapeNode(rectOf: CGSize(width: bgWidth, height: bgHeight), cornerRadius: 20)
        background.fillColor = SKColor(white: 0, alpha: 0.5)
        background.strokeColor = SKColor(white: 1, alpha: 0.2)
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -2
        label.addChild(background)
        
        return label
    }
    
    /// Create a modern styled score display
    static func createStyledScoreLabel(in scene: SKScene, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.fontSize = 18
        label.fontColor = SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
        label.position = position
        label.text = "Score: 0 - 0"
        label.zPosition = 100
        
        // Add subtle glow effect
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.position = label.position
        glow.zPosition = 99
        
        return label
    }
    
    // MARK: - Joystick Enhancement
    
    /// Create a modern styled joystick base
    static func createStyledJoystickBase(radius: CGFloat) -> SKShapeNode {
        let base = SKShapeNode(circleOfRadius: radius)
        
        // Outer ring gradient effect (simulated with layers)
        base.fillColor = SKColor(red: 0.15, green: 0.2, blue: 0.3, alpha: 0.8)
        base.strokeColor = SKColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 0.8)
        base.lineWidth = 3
        base.glowWidth = 2
        
        // Inner circle
        let innerRing = SKShapeNode(circleOfRadius: radius * 0.85)
        innerRing.fillColor = .clear
        innerRing.strokeColor = SKColor(white: 1, alpha: 0.2)
        innerRing.lineWidth = 1
        base.addChild(innerRing)
        
        // Direction markers
        let markerRadius = radius - 8
        let markerSize: CGFloat = 6
        let directions: [CGFloat] = [0, .pi/2, .pi, .pi * 1.5]
        
        for angle in directions {
            let marker = SKShapeNode(circleOfRadius: markerSize)
            marker.fillColor = SKColor(white: 1, alpha: 0.4)
            marker.strokeColor = .clear
            marker.position = CGPoint(
                x: cos(angle) * markerRadius,
                y: sin(angle) * markerRadius
            )
            base.addChild(marker)
        }
        
        return base
    }
    
    /// Create a modern styled joystick handle
    static func createStyledJoystickHandle(radius: CGFloat) -> SKShapeNode {
        let handle = SKShapeNode(circleOfRadius: radius)
        
        // Gradient simulation with layers
        handle.fillColor = SKColor(red: 0.6, green: 0.7, blue: 0.9, alpha: 0.9)
        handle.strokeColor = SKColor(white: 1, alpha: 0.8)
        handle.lineWidth = 2
        handle.glowWidth = 4
        
        // Inner highlight
        let highlight = SKShapeNode(circleOfRadius: radius * 0.6)
        highlight.fillColor = SKColor(white: 1, alpha: 0.3)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -radius * 0.15, y: radius * 0.15)
        handle.addChild(highlight)
        
        return handle
    }
    
    // MARK: - Fire Button Enhancement
    
    /// Create a modern styled fire button
    static func createStyledFireButton(radius: CGFloat) -> SKShapeNode {
        let button = SKShapeNode(circleOfRadius: radius)
        
        // Aggressive red gradient effect
        button.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.9)
        button.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.9)
        button.lineWidth = 3
        button.glowWidth = 6
        
        // Inner glow ring
        let innerRing = SKShapeNode(circleOfRadius: radius * 0.7)
        innerRing.fillColor = .clear
        innerRing.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 0.5)
        innerRing.lineWidth = 2
        button.addChild(innerRing)
        
        // Crosshair decoration
        let crosshairSize: CGFloat = radius * 0.4
        let verticalLine = SKSpriteNode(color: SKColor(white: 1, alpha: 0.6), size: CGSize(width: 2, height: crosshairSize * 2))
        let horizontalLine = SKSpriteNode(color: SKColor(white: 1, alpha: 0.6), size: CGSize(width: crosshairSize * 2, height: 2))
        button.addChild(verticalLine)
        button.addChild(horizontalLine)
        
        // Fire label
        let fireLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        fireLabel.text = "FIRE"
        fireLabel.fontSize = 14
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireLabel.position = CGPoint(x: 0, y: -radius * 0.5)
        button.addChild(fireLabel)
        
        // Add pulsing animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        button.run(SKAction.repeatForever(pulse))
        
        return button
    }
    
    // MARK: - Grid Enhancement
    
    /// Get enhanced colors for grid cells
    static func getGridCellColor(for cell: GridCell) -> SKColor {
        switch cell {
        case .empty:
            return SKColor(red: 0.2, green: 0.25, blue: 0.35, alpha: 1.0)
        case .wall:
            return SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        }
    }
    
    /// Get grid cell border color
    static func getGridCellBorderColor() -> SKColor {
        return SKColor(red: 0.3, green: 0.35, blue: 0.45, alpha: 0.5)
    }
    
    // MARK: - Victory/Defeat Overlay
    
    /// Create a victory overlay
    static func createVictoryOverlay(in scene: SKScene, message: String) -> SKNode {
        let overlay = SKNode()
        overlay.zPosition = 1000
        
        // Dark background
        let background = SKShapeNode(rectOf: scene.size)
        background.fillColor = SKColor(white: 0, alpha: 0.7)
        background.strokeColor = .clear
        background.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        overlay.addChild(background)
        
        // Message label
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = message
        label.fontSize = 48
        label.fontColor = .white
        label.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        
        // Add glow effect
        label.run(SKAction.sequence([
            SKAction.scale(to: 0.5, duration: 0),
            SKAction.scale(to: 1.1, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        overlay.addChild(label)
        
        return overlay
    }
}
