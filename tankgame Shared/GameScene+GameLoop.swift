//
//  GameScene+GameLoop.swift
//  Tank Game
//
//  Main game loop: movement, projectiles, respawn countdown.
//

import SpriteKit

extension GameScene {

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        sceneTime = currentTime
        updateRespawnCountdown()
        updateReload(currentTime: currentTime)

        guard let game = game else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        // Update AI players
        updateAIPlayers(currentTime: currentTime)

        // Update local tank movement
        if let tank = game.players[game.localPeerId]?.tank, tank.isAlive {
            var mutableTank = tank
            updateLocalTankMovement(currentTime: currentTime, tank: &mutableTank, game: game)
        }

        updateProjectiles(currentTime: currentTime, game: game)

        lastUpdateTime = currentTime
    }

    // MARK: - Respawn Countdown

    private func updateRespawnCountdown() {
        if respawnEndTime > 0 {
            let remaining = max(0, respawnEndTime - CACurrentMediaTime())
            respawnCountdownLabel?.text = String(format: "%.1f", remaining)
            if remaining <= 0 {
                hideRespawnCountdown()
            }
        }
    }

    // MARK: - Tank Movement

    private func updateLocalTankMovement(currentTime: TimeInterval, tank: inout Tank, game: Game) {
        if currentTime - lastMoveTime > moveInterval {
            if let dir = currentDirection {
                let oldDir = tank.direction
                let moved = tank.move(dir, on: game.map.grid)

                if moved || tank.direction != oldDir {
                    self.game?.players[game.localPeerId]?.tank = tank
                    gameDelegate?.gameScene(self, playerMoved: dir)
                    renderTanksSmooth()
                }
                lastMoveTime = currentTime
            }
        }
    }

    // MARK: - Projectile Updates

    private func updateProjectiles(currentTime: TimeInterval, game: Game) {
        if currentTime - lastProjectileUpdate > projectileInterval {
            let hits = game.projectiles.isEmpty ? [] : game.updateProjectiles()
            renderProjectiles()

            for hit in hits {
                gameDelegate?.gameScene(self, playerHit: hit.victimId, byShooter: hit.shooterId)
                renderTanksSmooth()
            }

            lastProjectileUpdate = currentTime
        }
    }
}
