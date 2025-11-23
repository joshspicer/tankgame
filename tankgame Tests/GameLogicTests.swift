//
//  GameLogicTests.swift
//  tankgame Tests
//
//  Simple test file to verify core game logic
//

import Foundation

// Test helper to load source files
func testDirection() {
    print("Testing Direction enum...")
    
    // Test all directions
    let directions: [(Direction, (Int, Int))] = [
        (.up, (-1, 0)),
        (.down, (1, 0)),
        (.left, (0, -1)),
        (.right, (0, 1))
    ]
    
    for (direction, expectedOffset) in directions {
        let offset = direction.offset
        assert(offset.row == expectedOffset.0, "Direction \(direction) row offset should be \(expectedOffset.0)")
        assert(offset.col == expectedOffset.1, "Direction \(direction) col offset should be \(expectedOffset.1)")
    }
    
    print("✓ Direction offset tests passed")
}

func testTank() {
    print("Testing Tank struct...")
    
    // Test tank initialization
    var tank = Tank(row: 5, col: 5, direction: .up)
    assert(tank.row == 5, "Tank row should be 5")
    assert(tank.col == 5, "Tank col should be 5")
    assert(tank.direction == .up, "Tank direction should be up")
    assert(tank.isAlive == true, "Tank should be alive")
    
    // Test tank movement with empty grid
    let gridSize = 10
    var grid = Array(repeating: Array(repeating: GridCell.empty, count: gridSize), count: gridSize)
    
    // Test valid movement
    let moved = tank.move(in: .up, grid: grid)
    assert(moved == true, "Tank should be able to move up")
    assert(tank.row == 4, "Tank should have moved to row 4")
    assert(tank.col == 5, "Tank col should remain 5")
    
    // Test movement into wall
    grid[3][5] = .wall
    let blockedMove = tank.move(in: .up, grid: grid)
    assert(blockedMove == false, "Tank should not be able to move into wall")
    assert(tank.row == 4, "Tank position should not change")
    
    // Test boundary check
    tank.row = 0
    tank.col = 0
    let outOfBounds = tank.move(in: .up, grid: grid)
    assert(outOfBounds == false, "Tank should not move out of bounds")
    
    print("✓ Tank movement tests passed")
}

func testProjectile() {
    print("Testing Projectile struct...")
    
    // Test projectile initialization
    var projectile = Projectile(row: 5, col: 5, direction: .right)
    assert(projectile.row == 5, "Projectile row should be 5")
    assert(projectile.col == 5, "Projectile col should be 5")
    assert(projectile.direction == .right, "Projectile direction should be right")
    
    // Test projectile advancement
    projectile.advance()
    assert(projectile.row == 5, "Projectile row should remain 5")
    assert(projectile.col == 6, "Projectile should advance to col 6")
    
    // Test out of bounds detection
    let gridSize = 10
    assert(projectile.isOutOfBounds(gridSize: gridSize) == false, "Projectile should be in bounds")
    
    projectile.col = 10
    assert(projectile.isOutOfBounds(gridSize: gridSize) == true, "Projectile should be out of bounds")
    
    projectile.col = -1
    assert(projectile.isOutOfBounds(gridSize: gridSize) == true, "Projectile should be out of bounds")
    
    // Test wall collision
    var grid = Array(repeating: Array(repeating: GridCell.empty, count: gridSize), count: gridSize)
    projectile.row = 5
    projectile.col = 5
    grid[5][5] = .wall
    
    assert(projectile.hits(grid: grid) == true, "Projectile should hit wall")
    
    grid[5][5] = .empty
    assert(projectile.hits(grid: grid) == false, "Projectile should not hit empty cell")
    
    // Test tank collision
    let tank = Tank(row: 7, col: 7, direction: .up)
    projectile.row = 7
    projectile.col = 7
    assert(projectile.hits(tank: tank) == true, "Projectile should hit tank")
    
    projectile.row = 8
    assert(projectile.hits(tank: tank) == false, "Projectile should not hit tank at different position")
    
    print("✓ Projectile tests passed")
}

func testTankShooting() {
    print("Testing Tank shooting...")
    
    let tank = Tank(row: 5, col: 5, direction: .right)
    let projectile = tank.shoot()
    
    // Projectile should spawn one cell in front of tank
    assert(projectile.row == 5, "Projectile row should be 5")
    assert(projectile.col == 6, "Projectile should spawn at col 6")
    assert(projectile.direction == .right, "Projectile should have same direction as tank")
    
    print("✓ Tank shooting tests passed")
}

// Main entry point
@main
struct GameLogicTestRunner {
    static func main() {
        print("🚀 Running Tank Game Logic Tests\n")
        testDirection()
        testTank()
        testProjectile()
        testTankShooting()
        print("\n✅ All tests passed!")
    }
}
