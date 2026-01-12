//
//  Explosions.swift
//  tankgame Shared
//
//  Consolidated explosion effects and handling
//

import SpriteKit

// MARK: - Explosion Effects

class ExplosionEffects {
    let tileSize: CGFloat

    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }

    func createExplosion(at position: CGPoint, color: SKColor, in parentNode: SKNode, completion: @escaping () -> Void) {
        // Create explosion particles
        let particleCount = 12
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 8)
            particle.fillColor = color
            particle.strokeColor = .white
            particle.lineWidth = 2
            particle.position = position
            particle.zPosition = 10

            // Calculate random direction
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let velocity: CGFloat = 150
            let dx = cos(angle) * velocity
            let dy = sin(angle) * velocity

            // Create movement animation
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.6)
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let scaleUp = SKAction.scale(to: 2.0, duration: 0.3)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])

            let group = SKAction.group([moveAction, fadeOut, scaleSequence])
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, remove])

            parentNode.addChild(particle)
            particle.run(sequence)
        }

        // Create central flash effect
        let flash = SKShapeNode(circleOfRadius: tileSize * 0.5)
        flash.fillColor = .white
        flash.strokeColor = .yellow
        flash.lineWidth = 4
        flash.position = position
        flash.zPosition = 11
        flash.alpha = 0.9

        let flashScale = SKAction.scale(to: 2.5, duration: 0.4)
        let flashFade = SKAction.fadeOut(withDuration: 0.4)
        let flashGroup = SKAction.group([flashScale, flashFade])
        let flashRemove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashGroup, flashRemove])

        parentNode.addChild(flash)
        flash.run(flashSequence, completion: completion)
    }
}

// MARK: - Explosion Handler

class ExplosionHandler {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
    }

    func triggerTankExplosion(tankIndex: Int, position: CGPoint) {
        guard let scene = scene, let tankNode = scene.tankNodes[tankIndex] else { return }

        scene.soundManager.playSound("hit.wav")
        let color = scene.renderer.tankColors[tankIndex]
        scene.explosionEffects.createExplosion(at: position, color: color, in: tankNode) { [weak scene] in
            scene?.tankExploding[tankIndex] = false
        }
        scene.tankExploding[tankIndex] = true
    }

    func triggerLizardExplosion(position: CGPoint) {
        guard let scene = scene, let lizardNode = scene.lizardNode else { return }

        scene.soundManager.playSound("hit.wav")
        let color = SKColor.systemGreen
        scene.explosionEffects.createExplosion(at: position, color: color, in: lizardNode) { }
    }

    func checkAndTriggerTankExplosions(wasAlive: [Bool], tanks: [Tank], tankPositions: [CGPoint]) {
        for i in 0..<tanks.count {
            if wasAlive[i] && !tanks[i].isAlive {
                triggerTankExplosion(tankIndex: i, position: tankPositions[i])
            }
        }
    }

    func checkAndTriggerLizardExplosions(wasAlive: [Bool], lizards: [Lizard], lizardPositions: [CGPoint]) {
        for i in 0..<lizards.count {
            if wasAlive[i] && !lizards[i].isAlive {
                triggerLizardExplosion(position: lizardPositions[i])
            }
        }
    }
}
