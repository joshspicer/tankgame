//
//  GameScene+Rendering.swift
//  Tank Game
//
//  Grid, tank, and projectile rendering.
//

import SpriteKit

extension GameScene {

    // MARK: - Grid Rendering

    func renderGrid() {
        gridNode.removeAllChildren()
        guard let game = game else { return }

        for row in 0..<currentGridSize {
            for col in 0..<currentGridSize {
                let isWall = game.map.grid[row][col]
                let tile = SKShapeNode(rectOf: CGSize(width: tileSize - 2, height: tileSize - 2), cornerRadius: 4)
                tile.fillColor = isWall ? SKColor(white: 0.4, alpha: 1) : SKColor(white: 0.2, alpha: 1)
                tile.strokeColor = SKColor(white: 0.3, alpha: 1)
                tile.lineWidth = 1
                tile.position = position(for: row, col: col)
                gridNode.addChild(tile)
            }
        }
    }

    // MARK: - Tank Rendering

    func renderTanks() {
        tanksNode.removeAllChildren()
        guard let game = game else { return }

        for (peerId, data) in game.players {
            guard data.tank.isAlive else { continue }

            let tankNode = createTankNode(color: color(for: peerId))
            tankNode.position = position(for: data.tank.row, col: data.tank.col)
            tankNode.zRotation = CGFloat(data.tank.direction.rotation)
            tankNode.name = "tank_\(peerId)"
            tanksNode.addChild(tankNode)
        }
    }

    func renderTanksSmooth() {
        guard let game = game else { return }

        for (peerId, data) in game.players {
            if let node = tanksNode.childNode(withName: "tank_\(peerId)") {
                if data.tank.isAlive {
                    node.alpha = 1.0
                    node.setScale(1.0)

                    let targetPos = position(for: data.tank.row, col: data.tank.col)
                    let targetAngle = CGFloat(data.tank.direction.rotation)

                    // Only animate if position or rotation actually changed
                    let dx = abs(node.position.x - targetPos.x)
                    let dy = abs(node.position.y - targetPos.y)
                    let posChanged = dx > 1 || dy > 1
                    let rotChanged = abs(node.zRotation - targetAngle) > 0.01

                    if posChanged || rotChanged {
                        node.removeAllActions()
                        let animDuration: TimeInterval = 0.12
                        let move = SKAction.move(to: targetPos, duration: animDuration)
                        move.timingMode = .easeOut
                        let rotate = SKAction.rotate(toAngle: targetAngle, duration: animDuration, shortestUnitArc: true)
                        rotate.timingMode = .easeOut
                        node.run(SKAction.group([move, rotate]))
                    }
                } else {
                    if node.alpha > 0.1 {
                        let explode = SKAction.group([
                            SKAction.scale(to: 1.5, duration: 0.15),
                            SKAction.fadeOut(withDuration: 0.15)
                        ])
                        node.run(explode)
                    }
                }
            } else if data.tank.isAlive {
                let tankNode = createTankNode(color: color(for: peerId))
                tankNode.position = position(for: data.tank.row, col: data.tank.col)
                tankNode.zRotation = CGFloat(data.tank.direction.rotation)
                tankNode.name = "tank_\(peerId)"
                tanksNode.addChild(tankNode)
            }
        }
    }

    func createTankNode(color: UIColor) -> SKNode {
        let tank = SKNode()

        let body = SKShapeNode(rectOf: CGSize(width: tileSize * 0.7, height: tileSize * 0.6), cornerRadius: 4)
        body.fillColor = color
        body.strokeColor = color.withAlphaComponent(0.5)
        body.lineWidth = 2
        tank.addChild(body)

        let turret = SKShapeNode(rectOf: CGSize(width: 8, height: tileSize * 0.4))
        turret.fillColor = color.withAlphaComponent(0.8)
        turret.strokeColor = .clear
        turret.position = CGPoint(x: 0, y: tileSize * 0.3)
        tank.addChild(turret)

        return tank
    }

    // MARK: - Projectile Rendering

    func renderProjectiles() {
        projectilesNode.removeAllChildren()
        guard let game = game else { return }

        for projectile in game.projectiles {
            let node = SKShapeNode(circleOfRadius: 6)
            node.fillColor = .yellow
            node.strokeColor = .orange
            node.lineWidth = 2
            node.position = position(for: projectile.row, col: projectile.col)
            node.zPosition = 5
            projectilesNode.addChild(node)
        }
    }

    // MARK: - Tank Management

    func spawnTank(for peerId: String, at row: Int, col: Int, direction: Direction) {
        while let existingNode = tanksNode.childNode(withName: "tank_\(peerId)") {
            existingNode.removeAllActions()
            existingNode.removeFromParent()
        }

        let tankNode = createTankNode(color: color(for: peerId))
        tankNode.position = position(for: row, col: col)
        tankNode.zRotation = CGFloat(direction.rotation)
        tankNode.name = "tank_\(peerId)"

        tankNode.setScale(0)
        tankNode.alpha = 0
        tanksNode.addChild(tankNode)

        let spawnAnim = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.3),
            SKAction.fadeIn(withDuration: 0.3)
        ])
        spawnAnim.timingMode = .easeOut
        tankNode.run(spawnAnim)

        updateScores()
    }

    func removeTank(for peerId: String) {
        tanksNode.childNode(withName: "tank_\(peerId)")?.removeFromParent()
    }

    // MARK: - Effects

    func showExplosion(at row: Int, col: Int) {
        let pos = position(for: row, col: col)

        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 6)
            particle.fillColor = .orange
            particle.strokeColor = .yellow
            particle.lineWidth = 2
            particle.position = pos
            particle.zPosition = 15
            tanksNode.addChild(particle)

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 30...60)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance

            let explodeAnim = SKAction.sequence([
                SKAction.group([
                    SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 0.3),
                    SKAction.scale(to: 0.1, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3)
                ]),
                SKAction.removeFromParent()
            ])
            particle.run(explodeAnim)
        }

        let flash = SKShapeNode(circleOfRadius: 40)
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.alpha = 0.8
        flash.position = pos
        flash.zPosition = 14
        tanksNode.addChild(flash)

        let flashAnim = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ])
        flash.run(flashAnim)
    }
}
