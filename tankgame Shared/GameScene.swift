//
//  GameScene.swift
//  tankgame Shared
//
//  SpriteKit scene for rendering the game
//

import SpriteKit

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Main game scene that renders the game state
class GameScene: SKScene {
    
    // MARK: - Properties
    
    private let tileSize: CGFloat = 50
    private var gridSize: Int = GameEngine.defaultGridSize
    private var gridNode: SKNode?
    private var playerNodes: [String: SKShapeNode] = [:]
    private var projectileNodes: [String: SKShapeNode] = [:]
    
    // Input handling
    private var joystickNode: SKShapeNode?
    private var joystickKnob: SKShapeNode?
    private var fireButton: SKLabelNode?
    
    // Callbacks
    var onMove: ((Direction) -> Void)?
    var onShoot: (() -> Void)?
    
    // MARK: - Initialization
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        setupScene()
    }
    
    private func setupScene() {
        // Create grid container
        gridNode = SKNode()
        gridNode?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        addChild(gridNode!)
        
        // Create joystick
        setupJoystick()
        
        // Create fire button
        setupFireButton()
    }
    
    private func setupJoystick() {
        // Joystick base
        joystickNode = SKShapeNode(circleOfRadius: 60)
        joystickNode?.fillColor = .gray
        joystickNode?.alpha = 0.5
        joystickNode?.position = CGPoint(x: 100, y: 100)
        addChild(joystickNode!)
        
        // Joystick knob
        joystickKnob = SKShapeNode(circleOfRadius: 30)
        joystickKnob?.fillColor = .white
        joystickKnob?.position = .zero
        joystickNode?.addChild(joystickKnob!)
    }
    
    private func setupFireButton() {
        fireButton = SKLabelNode(text: "🔥")
        fireButton?.fontSize = 60
        fireButton?.position = CGPoint(x: size.width - 80, y: 100)
        fireButton?.name = "fireButton"
        addChild(fireButton!)
    }
    
    // MARK: - Rendering
    
    /// Render the game grid
    func renderGrid(_ grid: GameGrid) {
        gridNode?.removeAllChildren()
        
        let gridSize = grid.size
        let totalSize = CGFloat(gridSize) * tileSize
        let startX = -totalSize / 2
        let startY = -totalSize / 2
        
        // Draw grid lines
        for i in 0...gridSize {
            let offset = CGFloat(i) * tileSize
            
            // Vertical line
            let vPath = CGMutablePath()
            vPath.move(to: CGPoint(x: startX + offset, y: startY))
            vPath.addLine(to: CGPoint(x: startX + offset, y: startY + totalSize))
            let vLine = SKShapeNode(path: vPath)
            vLine.strokeColor = .darkGray
            gridNode?.addChild(vLine)
            
            // Horizontal line
            let hPath = CGMutablePath()
            hPath.move(to: CGPoint(x: startX, y: startY + offset))
            hPath.addLine(to: CGPoint(x: startX + totalSize, y: startY + offset))
            let hLine = SKShapeNode(path: hPath)
            hLine.strokeColor = .darkGray
            gridNode?.addChild(hLine)
        }
        
        // Draw walls
        for wall in grid.walls {
            let x = startX + CGFloat(wall.x) * tileSize + tileSize / 2
            let y = startY + CGFloat(wall.y) * tileSize + tileSize / 2
            
            let wallNode = SKShapeNode(rectOf: CGSize(width: tileSize - 2, height: tileSize - 2))
            wallNode.fillColor = .brown
            wallNode.strokeColor = .black
            wallNode.position = CGPoint(x: x, y: y)
            gridNode?.addChild(wallNode)
        }
    }
    
    /// Render players
    func renderPlayers(_ players: [Player], localPlayerId: String) {
        guard let gridNode = gridNode else { return }
        
        // Remove dead player nodes
        let playerIds = Set(players.map { $0.id })
        for (id, node) in playerNodes where !playerIds.contains(id) {
            node.removeFromParent()
            playerNodes.removeValue(forKey: id)
        }
        
        // Update or create player nodes
        for (index, player) in players.enumerated() where player.isAlive {
            let node: SKShapeNode
            
            if let existing = playerNodes[player.id] {
                node = existing
            } else {
                // Create new player node
                node = SKShapeNode(circleOfRadius: tileSize / 2.5)
                node.fillColor = getPlayerColor(index: index)
                node.strokeColor = .white
                node.lineWidth = 2
                
                // Add direction indicator
                let indicator = SKShapeNode(rectOf: CGSize(width: tileSize / 3, height: tileSize / 6))
                indicator.fillColor = .white
                indicator.position = CGPoint(x: 0, y: tileSize / 3)
                indicator.name = "direction"
                node.addChild(indicator)
                
                gridNode.addChild(node)
                playerNodes[player.id] = node
            }
            
            // Update position
            let totalSize = CGFloat(gridSize) * tileSize
            let startX = -totalSize / 2
            let startY = -totalSize / 2
            
            let x = startX + CGFloat(player.position.x) * tileSize + tileSize / 2
            let y = startY + CGFloat(player.position.y) * tileSize + tileSize / 2
            node.position = CGPoint(x: x, y: y)
            
            // Update direction indicator
            if let indicator = node.childNode(withName: "direction") {
                switch player.direction {
                case .up: indicator.zRotation = 0
                case .right: indicator.zRotation = -.pi / 2
                case .down: indicator.zRotation = .pi
                case .left: indicator.zRotation = .pi / 2
                }
            }
        }
    }
    
    /// Render projectiles
    func renderProjectiles(_ projectiles: [Projectile]) {
        guard let gridNode = gridNode else { return }
        
        // Remove old projectile nodes
        let projectileIds = Set(projectiles.map { $0.id })
        for (id, node) in projectileNodes where !projectileIds.contains(id) {
            node.removeFromParent()
            projectileNodes.removeValue(forKey: id)
        }
        
        // Update or create projectile nodes
        for projectile in projectiles {
            let node: SKShapeNode
            
            if let existing = projectileNodes[projectile.id] {
                node = existing
            } else {
                node = SKShapeNode(circleOfRadius: tileSize / 8)
                node.fillColor = .yellow
                node.strokeColor = .orange
                gridNode.addChild(node)
                projectileNodes[projectile.id] = node
            }
            
            // Update position
            let totalSize = CGFloat(gridSize) * tileSize
            let startX = -totalSize / 2
            let startY = -totalSize / 2
            
            let x = startX + CGFloat(projectile.position.x) * tileSize + tileSize / 2
            let y = startY + CGFloat(projectile.position.y) * tileSize + tileSize / 2
            node.position = CGPoint(x: x, y: y)
        }
    }
    
    /// Get color for player based on index
    private func getPlayerColor(index: Int) -> SKColor {
        let colors: [SKColor] = [.blue, .red, .green, .purple, .orange, .cyan]
        return colors[index % colors.count]
    }
    
    // MARK: - Input Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check fire button
        if fireButton?.contains(location) == true {
            onShoot?()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let joystickNode = joystickNode, let joystickKnob = joystickKnob else { return }
        
        let location = touch.location(in: self)
        
        // Check if touching joystick area
        let distance = hypot(location.x - joystickNode.position.x, location.y - joystickNode.position.y)
        if distance < 100 {
            // Calculate direction
            let dx = location.x - joystickNode.position.x
            let dy = location.y - joystickNode.position.y
            
            // Update knob position (clamped)
            let maxDistance: CGFloat = 40
            let clampedDistance = min(distance, maxDistance)
            let angle = atan2(dy, dx)
            joystickKnob.position = CGPoint(x: cos(angle) * clampedDistance, y: sin(angle) * clampedDistance)
            
            // Determine direction
            let absX = abs(dx)
            let absY = abs(dy)
            
            if absX > absY {
                onMove?(dx > 0 ? .right : .left)
            } else if absY > absX {
                onMove?(dy > 0 ? .up : .down)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset joystick
        joystickKnob?.position = .zero
    }
}
