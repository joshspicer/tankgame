//
//  GameSceneRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles all rendering operations for the game scene
class GameSceneRenderer {
    let tileSize: CGFloat
    let gridSize: Int
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    private let lizardRenderer: LizardRenderer
    private let tankSpriteRenderer: TankSpriteRenderer
    private let dolphinSpriteRenderer: DolphinSpriteRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.lizardRenderer = LizardRenderer(tileSize: tileSize, gridSize: gridSize)
        self.tankSpriteRenderer = TankSpriteRenderer(tileSize: tileSize)
        self.dolphinSpriteRenderer = DolphinSpriteRenderer(tileSize: tileSize)
    }
    
    // MARK: - Grid
    
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridNode.removeAllChildren()
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = grid[row][col]
                let tile = SKSpriteNode(color: cell == .wall ? .black : .white, size: CGSize(width: tileSize - 2, height: tileSize - 2))
                tile.position = gridPosition(row: row, col: col)
                gridNode.addChild(tile)
            }
        }
    }
    
    // MARK: - Tanks
    
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let color = tankColors[i]
                let tankSprite = createTankNode(color: color, direction: tank.direction)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }

    func renderTanksWithSmoothing(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?], duration: TimeInterval) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let targetPosition = gridPosition(row: tank.row, col: tank.col)
                if let tankSprite = tankNode.children.first {
                    let moveAction = SKAction.move(to: targetPosition, duration: duration)
                    moveAction.timingMode = .easeOut
                    tankSprite.run(moveAction)
                    let currentRotation = tankSprite.zRotation
                    let targetRotation = CGFloat(tank.direction.angle)
                    let rotationDiff = shortestRotationDifference(from: currentRotation, to: targetRotation)
                    if abs(rotationDiff) > 0.01 {
                        let rotateAction = SKAction.rotate(byAngle: rotationDiff, duration: duration)
                        rotateAction.timingMode = .easeOut
                        tankSprite.run(rotateAction)
                    }
                } else {
                    let color = tankColors[i]
                    let tankSprite = createTankNode(color: color, direction: tank.direction)
                    tankSprite.position = targetPosition
                    tankNode.addChild(tankSprite)
                }
            } else {
                tankNode.removeAllChildren()
            }
        }
    }
    
    private func shortestRotationDifference(from: CGFloat, to: CGFloat) -> CGFloat {
        var diff = to - from
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return diff
    }
    
    private func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        switch GameSettings.shared.spriteMode {
        case .dolphin:
            return dolphinSpriteRenderer.createDolphinNode(color: color, direction: direction)
        case .tank:
            return tankSpriteRenderer.createTankNode(color: color, direction: direction)
        }
    }
    
    // MARK: - Projectiles
    
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectilesNode.removeAllChildren()
        for projectile in projectiles {
            let bullet = SKSpriteNode(color: .yellow, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.5))
            bullet.zPosition = 5
            bullet.position = gridPosition(row: projectile.row, col: projectile.col)
            addRainbowAnimation(to: bullet, phaseOffset: 0.5)
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            bullet.run(SKAction.repeatForever(pulse))
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
            bullet.run(SKAction.repeatForever(rotate))
            projectilesNode.addChild(bullet)
        }
    }
    
    private func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        var colorActions: [SKAction] = []
        let animationDuration: TimeInterval = 3.0
        let numberOfColors = 12
        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
            let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: animationDuration / Double(numberOfColors))
            colorActions.append(colorAction)
        }
        let rainbowSequence = SKAction.sequence(colorActions)
        sprite.run(SKAction.repeatForever(rainbowSequence))
    }
    
    // MARK: - Lizards
    
    func renderLizards(_ lizards: [Lizard], in lizardNode: SKNode) {
        lizardRenderer.renderLizards(lizards, in: lizardNode)
    }
    
    func renderLizardsWithSmoothing(_ lizards: [Lizard], in lizardNode: SKNode, duration: TimeInterval) {
        lizardRenderer.renderLizardsWithSmoothing(lizards, in: lizardNode, duration: duration)
    }
    
    // MARK: - Helpers
    
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}
