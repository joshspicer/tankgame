//
//  GameScene+GameLoop.swift
//  Tank Game
//
//  Main game loop: movement input with client-side prediction, rendering.
//  Collision detection and projectile updates are handled by the server.
//

import SpriteKit

extension GameScene {

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        updateRespawnCountdown()

        guard let game = game else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        // Apply local movement prediction + send to server
        if let tank = game.players[game.localPeerId]?.tank, tank.isAlive {
            updateLocalTankInput(currentTime: currentTime, tank: tank, game: game)
        }

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

    // MARK: - Tank Movement Input (with client-side prediction)

    private func updateLocalTankInput(currentTime: TimeInterval, tank: Tank, game: Game) {
        if currentTime - lastMoveTime > moveInterval {
            if let dir = currentDirection {
                // Client-side prediction: apply move locally for instant feedback
                var mutableTank = tank
                let moved = mutableTank.move(dir, on: game.map.grid)

                if moved || mutableTank.direction != tank.direction {
                    game.players[game.localPeerId]?.tank = mutableTank
                    renderTanksSmooth()
                }

                // Send input to server (server is authoritative, will correct if needed)
                gameDelegate?.gameScene(self, playerMoved: dir)
                lastMoveTime = currentTime
            }
        }
    }
}
