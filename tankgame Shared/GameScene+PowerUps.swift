//
//  GameScene+PowerUps.swift
//  Tank Game
//
//  Rendering and local effects for collectible power-ups.
//

import SpriteKit

extension GameScene {

    // MARK: - Colors

    /// Display color for a power-up kind.
    func color(for kind: PowerUpKind) -> UIColor {
        switch kind {
        case .shield:     return UIColor(red: 0.30, green: 0.85, blue: 1.00, alpha: 1.0)  // cyan
        case .speed:      return UIColor(red: 1.00, green: 0.85, blue: 0.20, alpha: 1.0)  // yellow
        case .tripleShot: return UIColor(red: 1.00, green: 0.45, blue: 0.30, alpha: 1.0)  // orange-red
        }
    }

    // MARK: - Rendering

    /// Render all power-ups currently on the map.
    func renderPowerUps() {
        guard powerUpsNode != nil else { return }
        powerUpsNode.removeAllChildren()
        guard let game = game else { return }

        for powerUp in game.powerUps {
            let node = makePowerUpNode(kind: powerUp.kind)
            node.position = position(for: powerUp.row, col: powerUp.col)
            powerUpsNode.addChild(node)
        }
    }

    private func makePowerUpNode(kind: PowerUpKind) -> SKNode {
        let container = SKNode()
        let tint = color(for: kind)

        let size = tileSize * 0.55
        let badge = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 6)
        badge.fillColor = tint.withAlphaComponent(0.85)
        badge.strokeColor = .white
        badge.lineWidth = 2
        container.addChild(badge)

        let label = SKLabelNode(text: kind.symbol)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = tileSize * 0.32
        label.fontColor = SKColor(white: 0.1, alpha: 1)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)

        // Gentle pulse so pickups are easy to spot.
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.6),
            SKAction.scale(to: 1.0, duration: 0.6)
        ])
        container.run(SKAction.repeatForever(pulse))

        return container
    }

    // MARK: - Shield Indicator

    /// Add/remove a glowing ring around tanks that currently have a shield.
    func updateShieldIndicators() {
        guard let game = game else { return }

        for (peerId, data) in game.players {
            guard let tankNode = tanksNode.childNode(withName: "tank_\(peerId)") else { continue }
            let hasShield = data.tank.isAlive && data.shieldCharges > 0
            let ring = tankNode.childNode(withName: "shield_ring")

            if hasShield && ring == nil {
                let shieldRing = SKShapeNode(circleOfRadius: tileSize * 0.5)
                shieldRing.strokeColor = color(for: .shield)
                shieldRing.lineWidth = 3
                shieldRing.fillColor = .clear
                shieldRing.name = "shield_ring"
                shieldRing.zPosition = 1
                let pulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.4, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ])
                shieldRing.run(SKAction.repeatForever(pulse))
                tankNode.addChild(shieldRing)
            } else if !hasShield {
                ring?.removeFromParent()
            }
        }
    }

    // MARK: - Local Effects

    /// Whether the local triple-shot effect is currently active.
    var isTripleShotActive: Bool {
        tripleShotUntil > CACurrentMediaTime()
    }

    /// Effective move interval for the local tank, accounting for the speed boost.
    var effectiveMoveInterval: TimeInterval {
        speedBoostUntil > CACurrentMediaTime() ? moveInterval * 0.5 : moveInterval
    }

    /// Apply the timed (local-only) effect of a collected power-up.
    func applyLocalPowerUpEffect(_ kind: PowerUpKind) {
        switch kind {
        case .shield:
            break  // Shield is synced via game state, not a local timer.
        case .speed:
            speedBoostUntil = CACurrentMediaTime() + kind.duration
        case .tripleShot:
            tripleShotUntil = CACurrentMediaTime() + kind.duration
        }
    }

    // MARK: - Collection

    /// Check whether the local tank is standing on a power-up and collect it.
    func collectPowerUpsForLocalTank() {
        guard let game = game else { return }
        let tank = game.localTank
        guard tank.isAlive else { return }
        guard let powerUp = game.powerUp(at: tank.row, col: tank.col) else { return }

        // Remove from the map and apply effects locally.
        game.removePowerUp(id: powerUp.id)
        game.applyCollectedEffect(powerUp.kind, to: game.localPeerId)
        applyLocalPowerUpEffect(powerUp.kind)

        renderPowerUps()
        updateShieldIndicators()
        showPowerUpPickup(kind: powerUp.kind, at: powerUp.row, col: powerUp.col)

        // Broadcast so all peers remove the pickup and apply the synced effect.
        gameDelegate?.gameScene(self, didCollectPowerUp: powerUp)
    }

    /// Expire local timed effects when their duration ends.
    func updatePowerUpEffects() {
        let now = CACurrentMediaTime()
        if speedBoostUntil != 0 && speedBoostUntil <= now {
            speedBoostUntil = 0
        }
        if tripleShotUntil != 0 && tripleShotUntil <= now {
            tripleShotUntil = 0
        }
    }

    // MARK: - Pickup Effect

    private func showPowerUpPickup(kind: PowerUpKind, at row: Int, col: Int) {
        let pos = position(for: row, col: col)

        let burst = SKShapeNode(circleOfRadius: tileSize * 0.4)
        burst.fillColor = color(for: kind).withAlphaComponent(0.6)
        burst.strokeColor = color(for: kind)
        burst.lineWidth = 2
        burst.position = pos
        burst.zPosition = 16
        powerUpsNode.addChild(burst)

        let anim = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.2, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.removeFromParent()
        ])
        burst.run(anim)
    }
}
