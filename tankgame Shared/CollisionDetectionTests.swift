//
//  CollisionDetectionTests.swift
//  tankgame Shared
//
//  Unit tests for CollisionDetection utilities
//

import XCTest
@testable import tankgame

class CollisionDetectionTests: XCTestCase {
    
    // MARK: - Wall Collision Tests
    
    func testHitsWallWithWall() {
        let grid = createGridWithWalls()
        
        XCTAssertTrue(CollisionDetection.hitsWall(row: 2, col: 2, grid: grid))
    }
    
    func testHitsWallWithEmpty() {
        let grid = createGridWithWalls()
        
        XCTAssertFalse(CollisionDetection.hitsWall(row: 0, col: 0, grid: grid))
    }
    
    func testHitsWallOutOfBounds() {
        let grid = createGridWithWalls()
        
        XCTAssertFalse(CollisionDetection.hitsWall(row: -1, col: 0, grid: grid))
        XCTAssertFalse(CollisionDetection.hitsWall(row: 0, col: -1, grid: grid))
        XCTAssertFalse(CollisionDetection.hitsWall(row: 8, col: 0, grid: grid))
        XCTAssertFalse(CollisionDetection.hitsWall(row: 0, col: 8, grid: grid))
    }
    
    // MARK: - Bounds Checking Tests
    
    func testIsOutOfBoundsNegativeRow() {
        XCTAssertTrue(CollisionDetection.isOutOfBounds(row: -1, col: 0, rowCount: 8))
    }
    
    func testIsOutOfBoundsNegativeCol() {
        XCTAssertTrue(CollisionDetection.isOutOfBounds(row: 0, col: -1, rowCount: 8))
    }
    
    func testIsOutOfBoundsTooLargeRow() {
        XCTAssertTrue(CollisionDetection.isOutOfBounds(row: 8, col: 0, rowCount: 8))
    }
    
    func testIsOutOfBoundsTooLargeCol() {
        XCTAssertTrue(CollisionDetection.isOutOfBounds(row: 0, col: 8, rowCount: 8))
    }
    
    func testIsOutOfBoundsValidPosition() {
        XCTAssertFalse(CollisionDetection.isOutOfBounds(row: 0, col: 0, rowCount: 8))
        XCTAssertFalse(CollisionDetection.isOutOfBounds(row: 7, col: 7, rowCount: 8))
        XCTAssertFalse(CollisionDetection.isOutOfBounds(row: 4, col: 4, rowCount: 8))
    }
    
    func testIsOutOfBoundsNonSquareGrid() {
        // Test rectangular grid
        XCTAssertFalse(CollisionDetection.isOutOfBounds(row: 5, col: 9, rowCount: 8, colCount: 10))
        XCTAssertTrue(CollisionDetection.isOutOfBounds(row: 5, col: 10, rowCount: 8, colCount: 10))
        XCTAssertTrue(CollisionDetection.isOutOfBounds(row: 8, col: 5, rowCount: 8, colCount: 10))
    }
    
    func testIsOutOfBoundsEdgeCases() {
        // Test at exact boundaries
        XCTAssertFalse(CollisionDetection.isOutOfBounds(row: 0, col: 0, rowCount: 8))
        XCTAssertFalse(CollisionDetection.isOutOfBounds(row: 7, col: 7, rowCount: 8))
        XCTAssertTrue(CollisionDetection.isOutOfBounds(row: 8, col: 7, rowCount: 8))
        XCTAssertTrue(CollisionDetection.isOutOfBounds(row: 7, col: 8, rowCount: 8))
    }
    
    // MARK: - Position Matching Tests
    
    func testPositionsMatchSamePosition() {
        XCTAssertTrue(CollisionDetection.positionsMatch(row1: 3, col1: 4, row2: 3, col2: 4))
    }
    
    func testPositionsMatchDifferentRow() {
        XCTAssertFalse(CollisionDetection.positionsMatch(row1: 3, col1: 4, row2: 4, col2: 4))
    }
    
    func testPositionsMatchDifferentCol() {
        XCTAssertFalse(CollisionDetection.positionsMatch(row1: 3, col1: 4, row2: 3, col2: 5))
    }
    
    func testPositionsMatchBothDifferent() {
        XCTAssertFalse(CollisionDetection.positionsMatch(row1: 3, col1: 4, row2: 5, col2: 6))
    }
    
    func testPositionsMatchAtOrigin() {
        XCTAssertTrue(CollisionDetection.positionsMatch(row1: 0, col1: 0, row2: 0, col2: 0))
    }
    
    // MARK: - Projectile-Tank Collision Tests
    
    func testProjectileHitsTankAtSamePosition() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = true
        
        XCTAssertTrue(CollisionDetection.projectileHitsTank(projectile, tank))
    }
    
    func testProjectileDoesNotHitTankAtDifferentPosition() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        let tank = Tank(row: 3, col: 5, direction: .down)
        
        XCTAssertFalse(CollisionDetection.projectileHitsTank(projectile, tank))
    }
    
    func testProjectileDoesNotHitDeadTank() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = false
        
        XCTAssertFalse(CollisionDetection.projectileHitsTank(projectile, tank),
                      "Dead tanks should not register hits")
    }
    
    // MARK: - Projectile-Lizard Collision Tests
    
    func testProjectileHitsLizardAtSamePosition() {
        let projectile = Projectile(row: 5, col: 6, direction: .left)
        var lizard = Lizard(row: 5, col: 6)
        lizard.isAlive = true
        
        XCTAssertTrue(CollisionDetection.projectileHitsLizard(projectile, lizard))
    }
    
    func testProjectileDoesNotHitLizardAtDifferentPosition() {
        let projectile = Projectile(row: 5, col: 6, direction: .left)
        let lizard = Lizard(row: 5, col: 7)
        
        XCTAssertFalse(CollisionDetection.projectileHitsLizard(projectile, lizard))
    }
    
    func testProjectileDoesNotHitDeadLizard() {
        let projectile = Projectile(row: 5, col: 6, direction: .left)
        var lizard = Lizard(row: 5, col: 6)
        lizard.isAlive = false
        
        XCTAssertFalse(CollisionDetection.projectileHitsLizard(projectile, lizard),
                      "Dead lizards should not register hits")
    }
    
    // MARK: - Integration Tests
    
    func testComplexCollisionScenario() {
        let grid = createGridWithWalls()
        
        // Create entities
        let projectile = Projectile(row: 2, col: 2, direction: .up)
        let tank1 = Tank(row: 2, col: 2, direction: .down)
        let tank2 = Tank(row: 3, col: 3, direction: .up)
        
        // Projectile at wall should hit wall
        XCTAssertTrue(CollisionDetection.hitsWall(row: projectile.row, col: projectile.col, grid: grid))
        
        // Projectile should hit tank1 (same position)
        XCTAssertTrue(CollisionDetection.projectileHitsTank(projectile, tank1))
        
        // Projectile should not hit tank2 (different position)
        XCTAssertFalse(CollisionDetection.projectileHitsTank(projectile, tank2))
    }
    
    // MARK: - Helper Methods
    
    private func createGridWithWalls() -> [[GridCell]] {
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        // Add some walls
        grid[2][2] = .wall
        grid[3][3] = .wall
        grid[4][4] = .wall
        return grid
    }
}
