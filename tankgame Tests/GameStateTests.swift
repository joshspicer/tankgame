//
//  GameStateTests.swift
//  tankgame Tests
//
//  Unit tests for GameState
//

import XCTest
@testable import tankgame_iOS

final class GameStateTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitializeWithTwoPlayers() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(gameState.tanks.count, 2)
        XCTAssertEqual(gameState.wins.count, 2)
        XCTAssertEqual(gameState.localPlayerIndex, 0)
        XCTAssertTrue(gameState.projectiles.isEmpty)
    }
    
    func testInitializeWithFourPlayers() {
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 2)
        
        XCTAssertEqual(gameState.tanks.count, 4)
        XCTAssertEqual(gameState.wins.count, 4)
        XCTAssertEqual(gameState.localPlayerIndex, 2)
    }
    
    func testInitialWinsAreZero() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        for wins in gameState.wins {
            XCTAssertEqual(wins, 0)
        }
    }
    
    func testTanksInitializedAtSpawnPositions() {
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        
        let expectedSpawns = [
            (0, 0, Direction.down),
            (7, 7, Direction.up),
            (0, 7, Direction.down),
            (7, 0, Direction.up)
        ]
        
        for i in 0..<4 {
            let tank = gameState.tanks[i]
            let expected = expectedSpawns[i]
            
            XCTAssertEqual(tank.row, expected.0, "Tank \(i) row mismatch")
            XCTAssertEqual(tank.col, expected.1, "Tank \(i) col mismatch")
            XCTAssertEqual(tank.direction, expected.2, "Tank \(i) direction mismatch")
            XCTAssertTrue(tank.isAlive, "Tank \(i) should be alive")
        }
    }
    
    func testGridIsGenerated() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(gameState.grid.count, 8)
        XCTAssertEqual(gameState.grid[0].count, 8)
    }
    
    // MARK: - Reset Tests
    
    func testResetClearsProjectiles() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .down))
        
        gameState.reset(seed: 12345)
        
        XCTAssertTrue(gameState.projectiles.isEmpty)
    }
    
    func testResetRepositionsTanks() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Move tanks from spawn positions
        _ = gameState.tanks[0].move(in: .right, grid: gameState.grid)
        _ = gameState.tanks[1].move(in: .left, grid: gameState.grid)
        
        gameState.reset(seed: 12345)
        
        // Tanks should be back at spawn positions
        XCTAssertEqual(gameState.tanks[0].row, 0)
        XCTAssertEqual(gameState.tanks[0].col, 0)
        XCTAssertEqual(gameState.tanks[1].row, 7)
        XCTAssertEqual(gameState.tanks[1].col, 7)
    }
    
    func testResetRevivesTanks() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        
        gameState.reset(seed: 12345)
        
        XCTAssertTrue(gameState.tanks[0].isAlive)
        XCTAssertTrue(gameState.tanks[1].isAlive)
    }
    
    func testResetDoesNotClearWins() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        gameState.wins[0] = 3
        gameState.wins[1] = 2
        
        gameState.reset(seed: 12345)
        
        XCTAssertEqual(gameState.wins[0], 3)
        XCTAssertEqual(gameState.wins[1], 2)
    }
    
    func testResetWithDifferentSeedChangesGrid() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        let originalGrid = gameState.grid
        
        gameState.reset(seed: 67890)
        let newGrid = gameState.grid
        
        var hasDifference = false
        for i in 0..<originalGrid.count {
            for j in 0..<originalGrid[i].count {
                if originalGrid[i][j] != newGrid[i][j] {
                    hasDifference = true
                    break
                }
            }
            if hasDifference { break }
        }
        
        XCTAssertTrue(hasDifference, "Different seed should produce different grid")
    }
    
    // MARK: - Local Player Tests
    
    func testLocalPlayerIndex() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 2)
        
        XCTAssertEqual(gameState.localPlayerIndex, 2)
    }
    
    func testLocalPlayerTank() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 1)
        
        let localTank = gameState.tanks[gameState.localPlayerIndex]
        XCTAssertEqual(localTank.row, 7)
        XCTAssertEqual(localTank.col, 7)
    }
    
    // MARK: - Projectile Management Tests
    
    func testAddProjectile() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        let projectile = Projectile(row: 3, col: 3, direction: .up)
        gameState.projectiles.append(projectile)
        
        XCTAssertEqual(gameState.projectiles.count, 1)
        XCTAssertEqual(gameState.projectiles[0].row, 3)
        XCTAssertEqual(gameState.projectiles[0].col, 3)
    }
    
    func testRemoveProjectile() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .down))
        
        gameState.projectiles.remove(at: 0)
        
        XCTAssertEqual(gameState.projectiles.count, 1)
        XCTAssertEqual(gameState.projectiles[0].row, 4)
    }
    
    // MARK: - Spawn Position Tests
    
    func testSpawnPositionsAreCorrect() {
        let expectedPositions: [(Int, Int, Direction)] = [
            (0, 0, .down),
            (7, 7, .up),
            (0, 7, .down),
            (7, 0, .up)
        ]
        
        for (index, expected) in expectedPositions.enumerated() {
            let spawn = GameState.spawnPositions[index]
            XCTAssertEqual(spawn.row, expected.0, "Spawn \(index) row mismatch")
            XCTAssertEqual(spawn.col, expected.1, "Spawn \(index) col mismatch")
            XCTAssertEqual(spawn.direction, expected.2, "Spawn \(index) direction mismatch")
        }
    }
    
    func testSpawnPositionsAreFourCorners() {
        let positions = GameState.spawnPositions
        
        XCTAssertEqual(positions.count, 4)
        
        // Top-left
        XCTAssertEqual(positions[0].row, 0)
        XCTAssertEqual(positions[0].col, 0)
        
        // Bottom-right
        XCTAssertEqual(positions[1].row, 7)
        XCTAssertEqual(positions[1].col, 7)
        
        // Top-right
        XCTAssertEqual(positions[2].row, 0)
        XCTAssertEqual(positions[2].col, 7)
        
        // Bottom-left
        XCTAssertEqual(positions[3].row, 7)
        XCTAssertEqual(positions[3].col, 0)
    }
}
