//
//  GameConfiguration.swift
//  tankgame Shared
//
//  Configuration constants for game behavior and tuning
//

import Foundation
import CoreGraphics

/// Central configuration for all game constants
struct GameConfiguration {
    // MARK: - Grid Configuration
    static let gridSize: Int = 8
    static let tileSize: CGFloat = 64
    
    // MARK: - Game Timing
    static let movementInterval: TimeInterval = 0.12 // ~8 moves per second
    static let projectileUpdateInterval: TimeInterval = 0.05 // ~20 FPS for projectiles
    static let explosionDelay: TimeInterval = 1.0 // Delay before showing round end
    
    // MARK: - Grid Generation
    static let minWallDensity: Double = 0.15 // 15% minimum wall coverage
    static let maxWallDensity: Double = 0.30 // 30% maximum wall coverage
    
    // MARK: - Multiplayer
    static let minPlayers: Int = 2
    static let maxPlayers: Int = 4
    static let connectionTimeout: TimeInterval = 30.0
    
    // MARK: - Scene Layout
    static let sceneWidth: CGFloat = 600
    static let sceneHeight: CGFloat = 800
    static let gridVerticalOffset: CGFloat = 50 // Offset grid down to make room for UI
    
    // MARK: - Input
    static let joystickPosition = CGPoint(x: 80, y: 100)
    static let fireButtonPosition = CGPoint(x: 520, y: 100) // Will be adjusted based on scene width
    
    // MARK: - Spawn Positions (for up to 4 players)
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),      // Player 0: top-left
        (7, 7, .up),        // Player 1: bottom-right
        (0, 7, .down),      // Player 2: top-right
        (7, 0, .up)         // Player 3: bottom-left
    ]
    
    // MARK: - Protected Grid Areas
    /// Grid cells that should remain empty for player spawns
    static let protectedSpawnCells: Set<String> = [
        "0,0", "0,1", "1,0", "1,1",     // Top-left (Player 0)
        "6,6", "6,7", "7,6", "7,7",     // Bottom-right (Player 1)
        "0,6", "0,7", "1,6", "1,7",     // Top-right (Player 2)
        "6,0", "6,1", "7,0", "7,1"      // Bottom-left (Player 3)
    ]
    
    /// Border cells that should remain clear for movement
    static func borderCells() -> Set<String> {
        var cells = Set<String>()
        for col in 0..<gridSize {
            cells.insert("0,\(col)")
            cells.insert("\(gridSize - 1),\(col)")
        }
        for row in 0..<gridSize {
            cells.insert("\(row),0")
            cells.insert("\(row),\(gridSize - 1)")
        }
        return cells
    }
    
    // MARK: - Helper Methods
    
    /// Calculate fire button position based on scene width
    static func fireButtonPosition(for sceneWidth: CGFloat) -> CGPoint {
        return CGPoint(x: sceneWidth - 80, y: 100)
    }
    
    /// Calculate grid offset for centering
    static func gridOffset(for sceneSize: CGSize) -> CGPoint {
        return CGPoint(
            x: (sceneSize.width - CGFloat(gridSize) * tileSize) / 2,
            y: (sceneSize.height - CGFloat(gridSize) * tileSize) / 2 + gridVerticalOffset
        )
    }
}
