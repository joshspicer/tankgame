//
//  GameMessageTests.swift
//  tankgame Tests
//
//  Unit tests for GameMessage enum
//

import XCTest
@testable import tankgame

class GameMessageTests: XCTestCase {
    
    func testGameMessageRoundStartCodable() throws {
        let message = GameMessage.roundStart(seed: 12345, isInitiator: true)
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(GameMessage.self, from: data)
        
        if case let .roundStart(seed, isInitiator) = decodedMessage {
            XCTAssertEqual(seed, 12345)
            XCTAssertTrue(isInitiator)
        } else {
            XCTFail("Expected roundStart message")
        }
    }
    
    func testGameMessagePlayerMoveCodable() throws {
        let message = GameMessage.playerMove(row: 3, col: 4, direction: .up)
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(GameMessage.self, from: data)
        
        if case let .playerMove(row, col, direction) = decodedMessage {
            XCTAssertEqual(row, 3)
            XCTAssertEqual(col, 4)
            XCTAssertEqual(direction, .up)
        } else {
            XCTFail("Expected playerMove message")
        }
    }
    
    func testGameMessagePlayerShootCodable() throws {
        let projectile = Projectile(row: 2, col: 3, direction: .right)
        let message = GameMessage.playerShoot(projectile: projectile)
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(GameMessage.self, from: data)
        
        if case let .playerShoot(decodedProjectile) = decodedMessage {
            XCTAssertEqual(decodedProjectile.row, 2)
            XCTAssertEqual(decodedProjectile.col, 3)
            XCTAssertEqual(decodedProjectile.direction, .right)
        } else {
            XCTFail("Expected playerShoot message")
        }
    }
    
    func testGameMessagePlayerHitCodable() throws {
        let message = GameMessage.playerHit(playerIndex: 1)
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(GameMessage.self, from: data)
        
        if case let .playerHit(playerIndex) = decodedMessage {
            XCTAssertEqual(playerIndex, 1)
        } else {
            XCTFail("Expected playerHit message")
        }
    }
    
    func testGameMessageReadyForNextRoundCodable() throws {
        let message = GameMessage.readyForNextRound
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(GameMessage.self, from: data)
        
        if case .readyForNextRound = decodedMessage {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected readyForNextRound message")
        }
    }
}
