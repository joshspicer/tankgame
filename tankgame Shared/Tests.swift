//
//  Tests.swift
//  tankgame Shared
//
//  Basic test file for validating core game logic
//

import Foundation

/// Simple test runner for core game logic
struct GameTests {
    
    /// Run all tests and print results
    static func runAll() {
        print("=== Running Tank Game Tests ===\n")
        
        var passed = 0
        var failed = 0
        
        // Test Direction
        if testDirectionOffsets() {
            passed += 1
            print("✓ Direction offsets test passed")
        } else {
            failed += 1
            print("✗ Direction offsets test failed")
        }
        
        if testDirectionAngles() {
            passed += 1
            print("✓ Direction angles test passed")
        } else {
            failed += 1
            print("✗ Direction angles test failed")
        }
        
        // Test Tank
        if testTankMovement() {
            passed += 1
            print("✓ Tank movement test passed")
        } else {
            failed += 1
            print("✗ Tank movement test failed")
        }
        
        if testTankShoot() {
            passed += 1
            print("✓ Tank shoot test passed")
        } else {
            failed += 1
            print("✗ Tank shoot test failed")
        }
        
        // Test Projectile
        if testProjectileAdvance() {
            passed += 1
            print("✓ Projectile advance test passed")
        } else {
            failed += 1
            print("✗ Projectile advance test failed")
        }
        
        if testProjectileCollision() {
            passed += 1
            print("✓ Projectile collision test passed")
        } else {
            failed += 1
            print("✗ Projectile collision test failed")
        }
        
        // Test GridGenerator
        if testGridGeneratorSeeded() {
            passed += 1
            print("✓ Grid generator seeded test passed")
        } else {
            failed += 1
            print("✗ Grid generator seeded test failed")
        }
        
        // Test GameState
        if testGameStateInit() {
            passed += 1
            print("✓ Game state initialization test passed")
        } else {
            failed += 1
            print("✗ Game state initialization test failed")
        }
        
        print("\n=== Test Summary ===")
        print("Passed: \(passed)")
        print("Failed: \(failed)")
        print("Total: \(passed + failed)")
    }
    
    // MARK: - Direction Tests
    
    static func testDirectionOffsets() -> Bool {
        let up = Direction.up.offset
        let down = Direction.down.offset
        let left = Direction.left.offset
        let right = Direction.right.offset
        
        return up == (-1, 0) &&
               down == (1, 0) &&
               left == (0, -1) &&
               right == (0, 1)
    }
    
    static func testDirectionAngles() -> Bool {
        // Test that angles are defined correctly
        return Direction.up.angle == 0 &&
               Direction.right.angle == .pi / 2 &&
               Direction.down.angle == .pi &&
               Direction.left.angle == -.pi / 2
    }
    
    // MARK: - Tank Tests
    
    static func testTankMovement() -> Bool {
        // Create empty grid
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        var tank = Tank(row: 4, col: 4, direction: .up)
        
        // Test valid movement
        let moved = tank.move(in: .up, grid: grid)
        guard moved && tank.row == 3 && tank.col == 4 else {
            return false
        }
        
        // Test wall collision
        grid[2][4] = .wall
        let blockedMove = tank.move(in: .up, grid: grid)
        guard !blockedMove && tank.row == 3 else {
            return false
        }
        
        // Test boundary
        var edgeTank = Tank(row: 0, col: 0, direction: .up)
        let boundaryMove = edgeTank.move(in: .up, grid: grid)
        guard !boundaryMove else {
            return false
        }
        
        return true
    }
    
    static func testTankShoot() -> Bool {
        let tank = Tank(row: 4, col: 4, direction: .right)
        let projectile = tank.shoot()
        
        // Projectile should be one cell ahead in the tank's direction
        return projectile.row == 4 &&
               projectile.col == 5 &&
               projectile.direction == .right
    }
    
    // MARK: - Projectile Tests
    
    static func testProjectileAdvance() -> Bool {
        var projectile = Projectile(row: 4, col: 4, direction: .down)
        projectile.advance()
        
        return projectile.row == 5 && projectile.col == 4
    }
    
    static func testProjectileCollision() -> Bool {
        let projectile = Projectile(row: 3, col: 3, direction: .up)
        let tank = Tank(row: 3, col: 3, direction: .down)
        
        // Test tank collision
        guard projectile.hits(tank: tank) else {
            return false
        }
        
        // Test out of bounds
        let outOfBounds = Projectile(row: -1, col: 0, direction: .up)
        guard outOfBounds.isOutOfBounds(gridSize: 8) else {
            return false
        }
        
        // Test wall collision
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        grid[5][5] = .wall
        let wallProjectile = Projectile(row: 5, col: 5, direction: .up)
        guard wallProjectile.hits(grid: grid) else {
            return false
        }
        
        return true
    }
    
    // MARK: - Grid Generator Tests
    
    static func testGridGeneratorSeeded() -> Bool {
        // Same seed should produce same grid
        let seed: UInt32 = 12345
        let grid1 = GridGenerator.generate(seed: seed)
        let grid2 = GridGenerator.generate(seed: seed)
        
        // Compare grids
        for row in 0..<8 {
            for col in 0..<8 {
                if grid1[row][col] != grid2[row][col] {
                    return false
                }
            }
        }
        
        // Different seeds should (very likely) produce different grids
        let grid3 = GridGenerator.generate(seed: 54321)
        var different = false
        for row in 0..<8 {
            for col in 0..<8 {
                if grid1[row][col] != grid3[row][col] {
                    different = true
                    break
                }
            }
        }
        
        return different
    }
    
    // MARK: - GameState Tests
    
    static func testGameStateInit() -> Bool {
        let seed: UInt32 = 99999
        
        // Test player 1 initialization
        let state1 = GameState(seed: seed, isPlayer1: true)
        guard state1.localTank.row == 0 &&
              state1.localTank.col == 0 &&
              state1.remoteTank.row == 7 &&
              state1.remoteTank.col == 7 else {
            return false
        }
        
        // Test player 2 initialization
        let state2 = GameState(seed: seed, isPlayer1: false)
        guard state2.localTank.row == 7 &&
              state2.localTank.col == 7 &&
              state2.remoteTank.row == 0 &&
              state2.remoteTank.col == 0 else {
            return false
        }
        
        return true
    }
}
