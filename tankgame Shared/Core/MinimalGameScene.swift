//
//  MinimalGameScene.swift
//  tankgame Shared
//
//  Minimal SpriteKit scene for game rendering

import SpriteKit

class MinimalGameScene: SKScene {
    private let tileSize: CGFloat = 64
    private var gridNode = SKNode()
    private var tankNodes: [SKShapeNode?] = []
    private var projectileNodes: [SKShapeNode] = []
    private var joystick: (base: SKShapeNode, handle: SKShapeNode)?
    private var fireButton: SKShapeNode?
    
    var onMove: ((Direction) -> Void)?
    var onShoot: (() -> Void)?
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        addChild(gridNode)
        setupControls()
    }
    
    private func setupControls() {
        // Joystick
        let baseRadius: CGFloat = 60
        let base = SKShapeNode(circleOfRadius: baseRadius)
        base.fillColor = .gray.withAlphaComponent(0.3)
        base.position = CGPoint(x: 80, y: 80)
        base.name = "joystickBase"
        
        let handle = SKShapeNode(circleOfRadius: 25)
        handle.fillColor = .white.withAlphaComponent(0.5)
        handle.position = base.position
        handle.name = "joystickHandle"
        
        addChild(base)
        addChild(handle)
        joystick = (base, handle)
        
        // Fire button
        let button = SKShapeNode(circleOfRadius: 35)
        button.fillColor = .red.withAlphaComponent(0.3)
        button.position = CGPoint(x: size.width - 80, y: 80)
        button.name = "fireButton"
        addChild(button)
        fireButton = button
    }
    
    func render(state: GameState) {
        renderGrid(state.grid)
        renderTanks(state.tanks)
        renderProjectiles(state.projectiles)
    }
    
    private func renderGrid(_ grid: [[Bool]]) {
        gridNode.removeAllChildren()
        
        for (row, rowData) in grid.enumerated() {
            for (col, isWall) in rowData.enumerated() {
                if isWall {
                    let wall = SKSpriteNode(color: .gray, size: CGSize(width: tileSize, height: tileSize))
                    wall.position = gridPosition(row: row, col: col)
                    gridNode.addChild(wall)
                }
            }
        }
    }
    
    private func renderTanks(_ tanks: [Tank]) {
        // Remove old nodes
        tankNodes.forEach { $0?.removeFromParent() }
        tankNodes = []
        
        for (i, tank) in tanks.enumerated() where tank.isAlive {
            let node = SKShapeNode(rectOf: CGSize(width: tileSize * 0.8, height: tileSize * 0.8))
            node.fillColor = tankColor(for: i)
            node.position = gridPosition(row: tank.position.row, col: tank.position.col)
            node.zRotation = rotation(for: tank.direction)
            addChild(node)
            tankNodes.append(node)
        }
    }
    
    private func renderProjectiles(_ projectiles: [Projectile]) {
        projectileNodes.forEach { $0.removeFromParent() }
        projectileNodes = projectiles.map { proj in
            let node = SKShapeNode(circleOfRadius: 8)
            node.fillColor = .yellow
            node.position = gridPosition(row: proj.position.row, col: proj.position.col)
            addChild(node)
            return node
        }
    }
    
    private func gridPosition(row: Int, col: Int) -> CGPoint {
        let offsetX = (size.width - tileSize * 8) / 2
        let offsetY = (size.height - tileSize * 8) / 2 + 50
        return CGPoint(
            x: offsetX + CGFloat(col) * tileSize + tileSize / 2,
            y: size.height - (offsetY + CGFloat(row) * tileSize + tileSize / 2)
        )
    }
    
    private func tankColor(for index: Int) -> SKColor {
        [.blue, .green, .purple, .orange, .cyan, .magenta][index % 6]
    }
    
    private func rotation(for direction: Direction) -> CGFloat {
        switch direction {
        case .up: return .pi / 2
        case .down: return -.pi / 2
        case .left: return .pi
        case .right: return 0
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let fireButton = fireButton, fireButton.contains(location) {
            onShoot?()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let joystick = joystick else { return }
        let location = touch.location(in: self)
        
        if joystick.base.contains(touch.previousLocation(in: self)) {
            let dx = location.x - joystick.base.position.x
            let dy = location.y - joystick.base.position.y
            let distance = sqrt(dx * dx + dy * dy)
            let maxDistance: CGFloat = 60
            
            if distance > 0 {
                let ratio = min(distance, maxDistance) / distance
                joystick.handle.position = CGPoint(
                    x: joystick.base.position.x + dx * ratio,
                    y: joystick.base.position.y + dy * ratio
                )
                
                // Determine direction
                let angle = atan2(dy, dx)
                let direction: Direction
                if abs(angle) < .pi / 4 {
                    direction = .right
                } else if abs(angle) > 3 * .pi / 4 {
                    direction = .left
                } else if angle > 0 {
                    direction = .up
                } else {
                    direction = .down
                }
                onMove?(direction)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick?.handle.position = joystick?.base.position ?? .zero
    }
}
