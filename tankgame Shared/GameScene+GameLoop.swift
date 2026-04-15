//
//  GameScene+GameLoop.swift
//  Tank Game
//
//  Main game loop: movement input, rendering, respawn countdown.
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

        // Send movement input to server at the movement interval
        if let tank = game.players[game.localPeerId]?.tank, tank.isAlive {
            updateLocalTankInput(currentTime: currentTime)
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

    // MARK: - Tank Movement Input

    private func updateLocalTankInput(currentTime: TimeInterval) {
        if currentTime - lastMoveTime > moveInterval {
            if let dir = currentDirection {
                // Send input to server via delegate (server validates and moves)
                gameDelegate?.gameScene(self, playerMoved: dir)
                lastMoveTime = currentTime
            }
        }
    }
}
