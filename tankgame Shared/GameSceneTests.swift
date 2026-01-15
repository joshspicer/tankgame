//
//  GameSceneTests.swift
//  tankgame Shared
//
//  Created by Copilot on 01/15/26.
//

import Foundation
import SpriteKit

#if DEBUG
/// Test utilities for the game scene - only available in debug builds
class GameSceneTests {
    
    /// Test that a game scene can be created successfully
    static func testGameSceneCreation() {
        print("=== Testing Game Scene Creation ===")
        
        let scene = GameScene.newGameScene()
        
        if scene.size.width > 0 && scene.size.height > 0 {
            print("✓ Game scene created successfully with size: \(scene.size)")
        } else {
            print("✗ Failed to create game scene with valid size")
        }
    }
    
    /// Test basic game state initialization
    static func testGameStateInitialization() {
        print("=== Testing Game State Initialization ===")
        
        // Create a game state with 2 players for testing multiplayer
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        print("✓ Game state initialized")
        print("  Tanks count: \(gameState.tanks.count)")
        print("  Projectiles count: \(gameState.projectiles.count)")
        print("  Local player index: \(gameState.localPlayerIndex)")
    }
    
    /// Run all tests
    static func runAllTests() {
        print("\n" + String(repeating: "=", count: 50))
        print("Running Game Scene Tests")
        print(String(repeating: "=", count: 50) + "\n")
        
        testGameSceneCreation()
        print("")
        testGameStateInitialization()
        
        print("\n" + String(repeating: "=", count: 50))
        print("All tests completed")
        print(String(repeating: "=", count: 50) + "\n")
    }
}
#endif
