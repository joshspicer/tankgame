//
//  GameRenderer.swift
//  tankgame Shared
//
//  Simplified rendering using Composite pattern

import SpriteKit

/// Renders game state to SpriteKit scene
final class GameRenderer {

    private let tileSize: CGFloat = 64
    private let gridNode = SKNode()
    private var tankNodes: [SKShapeNode] = []
    private var projectileNodes: [SKShapeNode] = []

    func setup(in scene: SKScene) {
        scene.addChild(gridNode)
        gridNode.position = CGPoint(x: scene.size.width / 2 - tileSize * 4,
                                   y: scene.size.height / 2 - tileSize * 4)
    }

    func render(state: GameState) {
        renderGrid(state.grid)
        renderTanks(state.tanks)
        renderProjectiles(state.projectiles)
    }

    private func renderGrid(_ grid: [[Cell]]) {
        gridNode.removeAllChildren()

        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                let cell = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                cell.position = CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(7 - row) * tileSize)
                cell.strokeColor = .gray
                cell.fillColor = grid[row][col] == .wall ? .darkGray : .black
                gridNode.addChild(cell)
            }
        }
    }

    private func renderTanks(_ tanks: [Tank]) {
        // Remove old tank nodes
        tankNodes.forEach { $0.removeFromParent() }
        tankNodes.removeAll()

        for (index, tank) in tanks.enumerated() where tank.isAlive {
            let node = SKShapeNode(rectOf: CGSize(width: tileSize * 0.8, height: tileSize * 0.8))
            node.position = position(for: tank)
            node.fillColor = color(for: index)
            node.zRotation = rotation(for: tank.direction)

            // Add barrel indicator
            let barrel = SKShapeNode(rectOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.4))
            barrel.fillColor = .white
            barrel.position = CGPoint(x: 0, y: tileSize * 0.3)
            node.addChild(barrel)

            gridNode.addChild(node)
            tankNodes.append(node)
        }
    }

    private func renderProjectiles(_ projectiles: [Projectile]) {
        // Remove old projectile nodes
        projectileNodes.forEach { $0.removeFromParent() }
        projectileNodes.removeAll()

        for projectile in projectiles {
            let node = SKShapeNode(circleOfRadius: tileSize * 0.15)
            node.position = position(for: projectile)
            node.fillColor = .red
            gridNode.addChild(node)
            projectileNodes.append(node)
        }
    }

    private func position(for tank: Tank) -> CGPoint {
        CGPoint(x: CGFloat(tank.col) * tileSize, y: CGFloat(7 - tank.row) * tileSize)
    }

    private func position(for projectile: Projectile) -> CGPoint {
        CGPoint(x: CGFloat(projectile.col) * tileSize, y: CGFloat(7 - projectile.row) * tileSize)
    }

    private func rotation(for direction: Direction) -> CGFloat {
        switch direction {
        case .up: return 0
        case .right: return -.pi / 2
        case .down: return .pi
        case .left: return .pi / 2
        }
    }

    private func color(for index: Int) -> SKColor {
        let colors: [SKColor] = [.cyan, .magenta, .yellow, .green, .orange, .purple]
        return colors[index % colors.count]
    }
}
