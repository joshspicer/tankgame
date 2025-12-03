//
//  GameLogicTests.swift
//  tankgame Shared
//
//  Created by Copilot on 12/3/25.
//

import Foundation

#if DEBUG
/// Unit tests for core game logic - only available in debug builds
class GameLogicTests {
    
    private static var passedTests = 0
    private static var failedTests = 0
    
    /// Run all tests
    static func runAll() {
        print("=== Running Game Logic Tests ===\n")
        passedTests = 0
        failedTests = 0
        
        testDirectionOffsets()
        testDirectionAngles()
        testDirectionDiagonals()
        testTankInitialization()
        testTankMovement()
        testTankMovementBlocked()
        testTankShoot()
        testProjectileAdvance()
        testProjectileOutOfBounds()
        testProjectileHitsWall()
        testProjectileHitsTank()
        testGridCellValues()
        
        print("\n=== Test Results ===")
        print("Passed: \(passedTests), Failed: \(failedTests)")
        if failedTests == 0 {
            print("✓ All tests passed!")
        } else {
            print("✗ Some tests failed")
        }
    }
    
    // MARK: - Direction Tests
    
    static func testDirectionOffsets() {
        let testName = "Direction offsets"
        
        let expectedOffsets: [(Direction, Int, Int)] = [
            (.up, -1, 0),
            (.down, 1, 0),
            (.left, 0, -1),
            (.right, 0, 1),
            (.upRight, -1, 1),
            (.downRight, 1, 1),
            (.downLeft, 1, -1),
            (.upLeft, -1, -1)
        ]
        
        var allPassed = true
        for (direction, expectedRow, expectedCol) in expectedOffsets {
            let offset = direction.offset
            if offset.row != expectedRow || offset.col != expectedCol {
                print("✗ \(testName): \(direction) expected (\(expectedRow), \(expectedCol)) but got (\(offset.row), \(offset.col))")
                allPassed = false
            }
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    static func testDirectionAngles() {
        let testName = "Direction angles"
        
        // Test cardinal directions have correct angles
        let up = Direction.up.angle
        let right = Direction.right.angle
        let down = Direction.down.angle
        let left = Direction.left.angle
        
        let tolerance = 0.001
        var allPassed = true
        
        if abs(up - 0) > tolerance {
            print("✗ \(testName): up angle expected 0 but got \(up)")
            allPassed = false
        }
        if abs(right - .pi / 2) > tolerance {
            print("✗ \(testName): right angle expected π/2 but got \(right)")
            allPassed = false
        }
        if abs(down - .pi) > tolerance {
            print("✗ \(testName): down angle expected π but got \(down)")
            allPassed = false
        }
        if abs(left - -.pi / 2) > tolerance {
            print("✗ \(testName): left angle expected -π/2 but got \(left)")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    static func testDirectionDiagonals() {
        let testName = "Direction isDiagonal"
        
        var allPassed = true
        
        // Cardinal directions should not be diagonal
        for dir in [Direction.up, .down, .left, .right] {
            if dir.isDiagonal {
                print("✗ \(testName): \(dir) should not be diagonal")
                allPassed = false
            }
        }
        
        // Diagonal directions should be diagonal
        for dir in [Direction.upRight, .downRight, .downLeft, .upLeft] {
            if !dir.isDiagonal {
                print("✗ \(testName): \(dir) should be diagonal")
                allPassed = false
            }
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    // MARK: - Tank Tests
    
    static func testTankInitialization() {
        let testName = "Tank initialization"
        
        let tank = Tank(row: 5, col: 3)
        var allPassed = true
        
        if tank.row != 5 {
            print("✗ \(testName): expected row 5 but got \(tank.row)")
            allPassed = false
        }
        if tank.col != 3 {
            print("✗ \(testName): expected col 3 but got \(tank.col)")
            allPassed = false
        }
        if tank.direction != .down {
            print("✗ \(testName): expected default direction .down but got \(tank.direction)")
            allPassed = false
        }
        if !tank.isAlive {
            print("✗ \(testName): expected isAlive to be true")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    static func testTankMovement() {
        let testName = "Tank movement on empty grid"
        
        // Create a 10x10 empty grid
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 10), count: 10)
        var tank = Tank(row: 5, col: 5)
        
        var allPassed = true
        
        // Move right
        let movedRight = tank.move(in: .right, grid: grid)
        if !movedRight {
            print("✗ \(testName): failed to move right")
            allPassed = false
        }
        if tank.col != 6 {
            print("✗ \(testName): expected col 6 after moving right but got \(tank.col)")
            allPassed = false
        }
        if tank.direction != .right {
            print("✗ \(testName): expected direction .right but got \(tank.direction)")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    static func testTankMovementBlocked() {
        let testName = "Tank movement blocked by wall/boundary"
        
        // Create a 10x10 grid with a wall
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 10), count: 10)
        grid[4][5] = .wall
        
        var tank = Tank(row: 5, col: 5)
        var allPassed = true
        
        // Try to move up (blocked by wall)
        let movedUp = tank.move(in: .up, grid: grid)
        if movedUp {
            print("✗ \(testName): should not be able to move through wall")
            allPassed = false
        }
        if tank.row != 5 {
            print("✗ \(testName): tank position should not change when blocked")
            allPassed = false
        }
        
        // Try to move out of bounds
        var edgeTank = Tank(row: 0, col: 0)
        let movedOutOfBounds = edgeTank.move(in: .up, grid: grid)
        if movedOutOfBounds {
            print("✗ \(testName): should not be able to move out of bounds")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    static func testTankShoot() {
        let testName = "Tank shooting"
        
        let tank = Tank(row: 5, col: 5, direction: .right)
        let projectile = tank.shoot()
        
        var allPassed = true
        
        // Projectile should spawn one cell in front of tank
        if projectile.row != 5 {
            print("✗ \(testName): expected projectile row 5 but got \(projectile.row)")
            allPassed = false
        }
        if projectile.col != 6 {
            print("✗ \(testName): expected projectile col 6 but got \(projectile.col)")
            allPassed = false
        }
        if projectile.direction != .right {
            print("✗ \(testName): expected projectile direction .right but got \(projectile.direction)")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    // MARK: - Projectile Tests
    
    static func testProjectileAdvance() {
        let testName = "Projectile advance"
        
        var projectile = Projectile(row: 5, col: 5, direction: .down)
        projectile.advance()
        
        var allPassed = true
        
        if projectile.row != 6 {
            print("✗ \(testName): expected row 6 after advancing down but got \(projectile.row)")
            allPassed = false
        }
        if projectile.col != 5 {
            print("✗ \(testName): col should remain 5 but got \(projectile.col)")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    static func testProjectileOutOfBounds() {
        let testName = "Projectile out of bounds"
        
        var allPassed = true
        
        let inBounds = Projectile(row: 5, col: 5, direction: .up)
        if inBounds.isOutOfBounds(gridSize: 10) {
            print("✗ \(testName): projectile at (5,5) should not be out of bounds in 10x10 grid")
            allPassed = false
        }
        
        let outOfBoundsNegative = Projectile(row: -1, col: 5, direction: .up)
        if !outOfBoundsNegative.isOutOfBounds(gridSize: 10) {
            print("✗ \(testName): projectile at (-1,5) should be out of bounds")
            allPassed = false
        }
        
        let outOfBoundsPositive = Projectile(row: 10, col: 5, direction: .down)
        if !outOfBoundsPositive.isOutOfBounds(gridSize: 10) {
            print("✗ \(testName): projectile at (10,5) should be out of bounds in 10x10 grid")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    static func testProjectileHitsWall() {
        let testName = "Projectile hits wall"
        
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 10), count: 10)
        grid[5][5] = .wall
        
        var allPassed = true
        
        let hitsWall = Projectile(row: 5, col: 5, direction: .up)
        if !hitsWall.hits(grid: grid) {
            print("✗ \(testName): projectile at wall position should hit wall")
            allPassed = false
        }
        
        let missesWall = Projectile(row: 5, col: 6, direction: .up)
        if missesWall.hits(grid: grid) {
            print("✗ \(testName): projectile at empty position should not hit wall")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    static func testProjectileHitsTank() {
        let testName = "Projectile hits tank"
        
        var allPassed = true
        
        let aliveTank = Tank(row: 5, col: 5)
        let projectileHits = Projectile(row: 5, col: 5, direction: .up)
        
        if !projectileHits.hits(tank: aliveTank) {
            print("✗ \(testName): projectile should hit alive tank at same position")
            allPassed = false
        }
        
        let projectileMisses = Projectile(row: 5, col: 6, direction: .up)
        if projectileMisses.hits(tank: aliveTank) {
            print("✗ \(testName): projectile should not hit tank at different position")
            allPassed = false
        }
        
        var deadTank = Tank(row: 5, col: 5)
        deadTank.isAlive = false
        if projectileHits.hits(tank: deadTank) {
            print("✗ \(testName): projectile should not hit dead tank")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    // MARK: - GridCell Tests
    
    static func testGridCellValues() {
        let testName = "GridCell raw values"
        
        var allPassed = true
        
        if GridCell.empty.rawValue != 0 {
            print("✗ \(testName): empty should have rawValue 0")
            allPassed = false
        }
        if GridCell.wall.rawValue != 1 {
            print("✗ \(testName): wall should have rawValue 1")
            allPassed = false
        }
        
        recordResult(testName, passed: allPassed)
    }
    
    // MARK: - Helpers
    
    private static func recordResult(_ testName: String, passed: Bool) {
        if passed {
            print("✓ \(testName)")
            passedTests += 1
        } else {
            failedTests += 1
        }
    }
}
#endif
