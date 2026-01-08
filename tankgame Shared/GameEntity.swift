//
//  GameEntity.swift
//  tankgame Shared
//
//  Core game entity protocol using Composite pattern

import Foundation

/// Base protocol for all game entities - Composite pattern
protocol GameEntity {
    var position: Position { get set }
    var isAlive: Bool { get set }
    mutating func update(in context: GameContext)
}

/// Position in grid
struct Position: Codable, Equatable {
    var row: Int
    var col: Int

    func isValid(gridSize: Int = 8) -> Bool {
        return row >= 0 && row < gridSize && col >= 0 && col < gridSize
    }
}

/// Direction enum
enum Direction: Int, Codable, CaseIterable {
    case up = 0, right, down, left

    var delta: (row: Int, col: Int) {
        switch self {
        case .up: return (-1, 0)
        case .down: return (1, 0)
        case .left: return (0, -1)
        case .right: return (0, 1)
        }
    }

    mutating func rotate(clockwise: Bool) {
        let allCases = Direction.allCases
        let currentIndex = allCases.firstIndex(of: self)!
        let offset = clockwise ? 1 : -1
        let newIndex = (currentIndex + offset + allCases.count) % allCases.count
        self = allCases[newIndex]
    }
}

/// Game context for entity updates
struct GameContext {
    let grid: [[Cell]]
    let entities: [GameEntity]
}

/// Grid cell type
enum Cell: Int, Codable {
    case empty = 0
    case wall = 1
}
