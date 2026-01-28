//
//  GameScene+PowerUps.swift
//  Tank Game
//
//  Powerup rendering and visual effects.
//

import SpriteKit

extension GameScene {

    // MARK: - PowerUp Rendering

    /// Render all powerups on the map
    func renderPowerUps() {
        guard let game = game else { return }

        // Remove old powerup nodes
        powerUpsNode.removeAllChildren()

        // Render each powerup
        for powerUp in game.powerUps {
            renderPowerUp(powerUp)
        }
    }

    /// Render a single powerup
    private func renderPowerUp(_ powerUp: PowerUp) {
        let pos = position(for: powerUp.row, col: powerUp.col)

        // Background circle
        let background = SKShapeNode(circleOfRadius: tileSize * 0.35)
        background.fillColor = powerUpColor(for: powerUp.type)
        background.strokeColor = .white
        background.lineWidth = 2
        background.position = pos
        background.name = "powerup_\(powerUp.id)"
        background.zPosition = 1

        // Symbol label
        let label = SKLabelNode(text: powerUp.type.symbol)
        label.fontSize = tileSize * 0.5
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        background.addChild(label)

        // Pulse animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        background.run(repeatPulse)

        powerUpsNode.addChild(background)
    }

    /// Get color for powerup type
    private func powerUpColor(for type: PowerUpType) -> UIColor {
        switch type {
        case .speed:
            return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold
        case .fireRate:
            return UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0) // Orange-red
        case .shield:
            return UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Blue
        case .health:
            return UIColor(red: 1.0, green: 0.0, blue: 0.4, alpha: 1.0) // Pink-red
        }
    }

    /// Show powerup collection effect
    func showPowerUpCollectionEffect(at row: Int, col: Int, type: PowerUpType) {
        let pos = position(for: row, col: col)

        // Create particles
        let particleCount = 12
        for i in 0..<particleCount {
            let angle = Double(i) * (2.0 * .pi / Double(particleCount))
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = powerUpColor(for: type)
            particle.strokeColor = .clear
            particle.position = pos
            particle.zPosition = 20

            let dx = cos(angle) * tileSize * 0.8
            let dy = sin(angle) * tileSize * 0.8
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let group = SKAction.group([move, fadeOut])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])

            particle.run(sequence)
            addChild(particle)
        }
    }
}
