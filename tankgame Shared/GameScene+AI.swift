//
//  GameScene+AI.swift
//  Tank Game
//
//  AI player updates and behavior processing.
//

import SpriteKit

extension GameScene {

    /// Update all AI players (called from game loop)
    func updateAIPlayers(currentTime: TimeInterval) {
        guard let game = game else { return }

        // Process each AI player
        for (peerId, data) in game.players {
            guard let aiPlayer = data.aiPlayer else { continue }
            guard data.tank.isAlive else { continue }

            // Decide action for this AI
            if let action = aiPlayer.decideAction(tank: data.tank, game: game, currentTime: currentTime) {
                processAIAction(peerId: peerId, action: action)
            }
        }
    }

    /// Process an AI action
    private func processAIAction(peerId: String, action: AIAction) {
        guard let game = game else { return }
        guard var data = game.players[peerId] else { return }

        switch action {
        case .move(let direction):
            let oldDir = data.tank.direction
            let moved = data.tank.move(direction, on: game.map.grid)

            if moved || data.tank.direction != oldDir {
                game.players[peerId]?.tank = data.tank
                gameDelegate?.gameScene(self, playerMoved: direction)
                renderTanksSmooth()
            }

        case .shoot:
            guard data.tank.isAlive else { return }

            var projectile = data.tank.shoot()
            projectile.ownerId = peerId
            game.projectiles.append(projectile)

            gameDelegate?.gameScene(self, playerShot: projectile)
            renderProjectiles()
        }
    }
}
