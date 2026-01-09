//
//  TankTests.swift
//  tankgame Shared
//
//  Created by Copilot on 1/9/26.
//

import Foundation

#if DEBUG
/// Test utilities for Tank functionality - only available in debug builds
class TankTests {
    
    /// Test tank initialization
    static func testTankInitialization() {
        print("=== Testing Tank Initialization ===")
        
        let tank = Tank(row: 0, col: 0, direction: .down)
        
        assert(tank.row == 0, "Tank row should be 0")
        assert(tank.col == 0, "Tank col should be 0")
        assert(tank.direction == .down, "Tank direction should be down")
        assert(tank.isAlive == true, "Tank should be alive")
        
        print("✓ Tank initialization test passed")
    }
    
    /// Test tank shooting
    static func testTankShooting() {
        print("=== Testing Tank Shooting ===")
        
        var tank = Tank(row: 3, col: 3, direction: .up)
        let projectile = tank.shoot()
        
        // Projectile should be one cell ahead in the direction tank is facing
        assert(projectile.row == 2, "Projectile row should be 2 (one cell up from tank)")
        assert(projectile.col == 3, "Projectile col should be 3 (same as tank)")
        assert(projectile.direction == .up, "Projectile direction should match tank direction")
        
        print("✓ Tank shooting test passed")
    }
    
    /// Test tank movement validation
    static func testTankMovement() {
        print("=== Testing Tank Movement ===")
        
        // Create a simple 5x5 grid with all empty cells
        var grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        var tank = Tank(row: 2, col: 2, direction: .down)
        
        // Test valid move
        let moved = tank.move(in: .up, grid: grid)
        assert(moved == true, "Tank should be able to move up")
        assert(tank.row == 1, "Tank row should be 1 after moving up")
        assert(tank.col == 2, "Tank col should remain 2")
        assert(tank.direction == .up, "Tank direction should be up")
        
        // Test boundary checking - move to top edge
        var edgeTank = Tank(row: 0, col: 2, direction: .up)
        let canMoveOutOfBounds = edgeTank.move(in: .up, grid: grid)
        assert(canMoveOutOfBounds == false, "Tank should not move out of bounds")
        assert(edgeTank.row == 0, "Tank position should not change when blocked")
        
        // Test wall collision
        grid[1][1] = .wall
        var blockedTank = Tank(row: 2, col: 1, direction: .down)
        let canMoveToWall = blockedTank.move(in: .up, grid: grid)
        assert(canMoveToWall == false, "Tank should not move into wall")
        assert(blockedTank.row == 2, "Tank position should not change when blocked by wall")
        
        print("✓ Tank movement test passed")
    }
    
    /// Run all tank tests
    static func runAllTests() {
        print("\n========================================")
        print("Running Tank Tests")
        print("========================================\n")
        
        testTankInitialization()
        testTankShooting()
        testTankMovement()
        
        print("\n========================================")
        print("✓ All Tank Tests Passed")
        print("========================================\n")
    }
}
#endif
