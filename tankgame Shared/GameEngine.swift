//
//  GameEngine.swift
//  tankgame Shared
//
//  Complete rewrite - Pure game logic
//

import Foundation

final class GameEngine {
    private(set) var state: GameState

    init(state: GameState) {
        self.state = state
    }

    // MARK: - Tank Actions

    func moveTank(playerId: String, direction: Direction) -> Bool {
        guard let index = state.tanks.firstIndex(where: { $0.id == playerIndex(for: playerId) }),
              state.tanks[index].isAlive else {
            return false
        }

        let offset = direction.offset
        let current = state.tanks[index].position
        let newPos = Position(row: current.row + offset.row, col: current.col + offset.col)

        // Validate move
        guard isValidPosition(newPos),
              state.grid[newPos.row][newPos.col] == .empty,
              !isTankAt(newPos) else {
            return false
        }

        state.tanks[index].position = newPos
        state.tanks[index].direction = direction
        return true
    }

    func shootBullet(playerId: String) -> Bullet? {
        guard let index = state.tanks.firstIndex(where: { $0.id == playerIndex(for: playerId) }),
              state.tanks[index].isAlive else {
            return nil
        }

        let tank = state.tanks[index]
        let offset = tank.direction.offset
        var bullet = Bullet(
            position: Position(row: tank.position.row + offset.row, col: tank.position.col + offset.col),
            direction: tank.direction
        )

        // Only shoot if starting position is valid
        guard isValidPosition(bullet.position) else {
            return nil
        }

        state.bullets.append(bullet)
        return bullet
    }

    // MARK: - Game Loop

    func update() {
        updateBullets()
    }

    private func updateBullets() {
        var activeBullets: [Bullet] = []

        for var bullet in state.bullets {
            bullet.advance()

            // Check bounds
            guard isValidPosition(bullet.position) else { continue }

            // Check walls
            if state.grid[bullet.position.row][bullet.position.col] == .wall {
                continue
            }

            // Check tank hits
            var hitTank = false
            for i in 0..<state.tanks.count {
                if state.tanks[i].isAlive && state.tanks[i].position == bullet.position {
                    state.tanks[i].isAlive = false
                    hitTank = true
                    break
                }
            }

            if !hitTank {
                activeBullets.append(bullet)
            }
        }

        state.bullets = activeBullets
    }

    // MARK: - Game State Queries

    func isRoundOver() -> Bool {
        let aliveTanks = state.tanks.filter { $0.isAlive }
        return aliveTanks.count <= 1
    }

    func winnerId() -> String? {
        let aliveTanks = state.tanks.filter { $0.isAlive }
        if aliveTanks.count == 1, let winner = aliveTanks.first {
            return playerIdForIndex(winner.id)
        }
        return nil
    }

    // MARK: - Helpers

    private func isValidPosition(_ pos: Position) -> Bool {
        return pos.row >= 0 && pos.row < GameState.gridSize &&
               pos.col >= 0 && pos.col < GameState.gridSize
    }

    private func isTankAt(_ pos: Position) -> Bool {
        return state.tanks.contains { $0.isAlive && $0.position == pos }
    }

    private func playerIndex(for playerId: String) -> Int {
        // This should be maintained by the game coordinator
        // For now, we'll use a simple mapping
        return state.tanks.firstIndex(where: { String($0.id) == playerId }) ?? 0
    }

    private func playerIdForIndex(_ index: Int) -> String {
        return String(index)
    }
}
