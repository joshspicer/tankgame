//
//  BasicGameTests.swift
//  tankgame Shared
//
//  Created by Copilot on 01/09/26.
//

import Foundation

#if DEBUG
/// Basic test utilities for game functionality - only available in debug builds
class BasicGameTests {
    
    /// Test that Tank can be created with default values
    static func testTankCreation() {
        print("=== Testing Tank Creation ===")
        
        let tank = Tank(row: 5, col: 5)
        print("✓ Tank created at position (\(tank.row), \(tank.col))")
        print("✓ Tank direction: \(tank.direction)")
        print("✓ Tank is alive: \(tank.isAlive)")
        
        assert(tank.row == 5, "Tank row should be 5")
        assert(tank.col == 5, "Tank col should be 5")
        assert(tank.isAlive, "Tank should be alive")
        
        print("✓ All tank creation tests passed")
    }
    
    /// Test that Projectile can be created
    static func testProjectileCreation() {
        print("=== Testing Projectile Creation ===")
        
        let tank = Tank(row: 5, col: 5, direction: .up)
        let projectile = tank.shoot()
        
        print("✓ Projectile created at position (\(projectile.row), \(projectile.col))")
        print("✓ Projectile direction: \(projectile.direction)")
        
        assert(projectile.row == 4, "Projectile should be one row above tank")
        assert(projectile.col == 5, "Projectile should be in same column as tank")
        assert(projectile.direction == .up, "Projectile direction should match tank")
        
        print("✓ All projectile creation tests passed")
    }
    
    /// Test GridCell enum
    static func testGridCell() {
        print("=== Testing GridCell ===")
        
        let empty = GridCell.empty
        let wall = GridCell.wall
        
        print("✓ Empty cell value: \(empty.rawValue)")
        print("✓ Wall cell value: \(wall.rawValue)")
        
        assert(empty.rawValue == 0, "Empty cell should have value 0")
        assert(wall.rawValue == 1, "Wall cell should have value 1")
        
        print("✓ All GridCell tests passed")
    }
    
    /// Run all basic tests
    static func runAllTests() {
        print("\n========================================")
        print("Running Basic Game Tests")
        print("========================================\n")
        
        testTankCreation()
        print("")
        testProjectileCreation()
        print("")
        testGridCell()
        
        print("\n========================================")
        print("✓ All Basic Game Tests Passed")
        print("========================================\n")
    }
}
#endif
