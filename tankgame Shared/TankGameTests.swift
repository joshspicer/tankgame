//
//  TankGameTests.swift
//  tankgame Shared
//
//  Simple test example for VS Code
//

import XCTest
@testable import tankgame_iOS

class TankGameTests: XCTestCase {
    
    func testTankInitialization() {
        // Test that a tank can be created with basic properties
        let tank = Tank(row: 5, col: 5, direction: .down)
        
        XCTAssertEqual(tank.row, 5, "Tank row should be 5")
        XCTAssertEqual(tank.col, 5, "Tank col should be 5")
        XCTAssertEqual(tank.direction, .down, "Tank should face down initially")
        XCTAssertTrue(tank.isAlive, "Tank should be alive initially")
    }
    
    func testTankShooting() {
        // Test that a tank can shoot a projectile in the direction it's facing
        let tank = Tank(row: 5, col: 5, direction: .up)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 4, "Projectile should spawn one row up")
        XCTAssertEqual(projectile.col, 5, "Projectile should be in the same column")
        XCTAssertEqual(projectile.direction, .up, "Projectile should move up")
    }
}
