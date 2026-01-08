//
//  MazeGenerator.swift
//  tankgame Shared
//
//  Procedural maze generation using recursive backtracking algorithm
//

import Foundation

struct MazeGenerator {
    /// Generate a maze using recursive backtracking (DFS) algorithm
    /// This creates a perfect maze with no loops, ensuring connectivity
    static func generate(seed: UInt32) -> [[GridCell]] {
        var rng = SeededRandomNumberGenerator(seed: seed)
        var grid = Array(repeating: Array(repeating: GridCell.wall, count: 8), count: 8)

        // Keep spawn corners clear (top-left and bottom-right)
        let protectedCells: Set<String> = [
            "0,0", "0,1", "1,0", "1,1", // Top-left spawn area
            "6,6", "6,7", "7,6", "7,7"  // Bottom-right spawn area
        ]

        // Mark all protected cells as empty
        for cellKey in protectedCells {
            let parts = cellKey.split(separator: ",")
            let row = Int(parts[0])!
            let col = Int(parts[1])!
            grid[row][col] = .empty
        }

        // Track visited cells for maze generation
        var visited = Array(repeating: Array(repeating: false, count: 8), count: 8)

        // Mark protected cells as visited so they won't be carved through
        for cellKey in protectedCells {
            let parts = cellKey.split(separator: ",")
            let row = Int(parts[0])!
            let col = Int(parts[1])!
            visited[row][col] = true
        }

        // Start carving from a random non-protected cell
        let startRow = 2 + Int(rng.next() % 4)
        let startCol = 2 + Int(rng.next() % 4)
        carveMaze(grid: &grid, visited: &visited, row: startRow, col: startCol, rng: &rng)

        // Ensure paths to spawn areas are clear
        ensurePathToSpawn(grid: &grid, toRow: 0, toCol: 0, fromRow: 2, fromCol: 2)
        ensurePathToSpawn(grid: &grid, toRow: 7, toCol: 7, fromRow: 5, fromCol: 5)

        // Add some extra connections to make the maze less linear (10-15% of walls)
        let extraPathDensity = 0.10 + (rng.nextDouble() * 0.05)
        addExtraPaths(grid: &grid, density: extraPathDensity, protectedCells: protectedCells, rng: &rng)

        return grid
    }

    /// Recursive backtracking algorithm to carve out maze passages
    private static func carveMaze(grid: inout [[GridCell]], visited: inout [[Bool]], row: Int, col: Int, rng: inout SeededRandomNumberGenerator) {
        // Mark current cell as visited and carve it out
        visited[row][col] = true
        grid[row][col] = .empty

        // Define directions: up, down, left, right
        var directions = [(dr: -1, dc: 0), (dr: 1, dc: 0), (dr: 0, dc: -1), (dr: 0, dc: 1)]

        // Shuffle directions for randomness
        directions.shuffle(using: &rng)

        for direction in directions {
            let newRow = row + direction.dr * 2 // Move by 2 to leave walls between passages
            let newCol = col + direction.dc * 2

            // Check if the new cell is within bounds and not visited
            if newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 && !visited[newRow][newCol] {
                // Carve the wall between current and new cell
                let wallRow = row + direction.dr
                let wallCol = col + direction.dc
                grid[wallRow][wallCol] = .empty

                // Recursively carve from the new cell
                carveMaze(grid: &grid, visited: &visited, row: newRow, col: newCol, rng: &rng)
            }
        }
    }

    /// Ensure there's a path from interior to spawn area
    private static func ensurePathToSpawn(grid: inout [[GridCell]], toRow: Int, toCol: Int, fromRow: Int, fromCol: Int) {
        var currentRow = fromRow
        var currentCol = fromCol

        // Carve a simple path toward the spawn
        while currentRow != toRow || currentCol != toCol {
            grid[currentRow][currentCol] = .empty

            // Move toward target
            if currentRow < toRow {
                currentRow += 1
            } else if currentRow > toRow {
                currentRow -= 1
            } else if currentCol < toCol {
                currentCol += 1
            } else if currentCol > toCol {
                currentCol -= 1
            }
        }
    }

    /// Add extra paths to make the maze less linear
    private static func addExtraPaths(grid: inout [[GridCell]], density: Double, protectedCells: Set<String>, rng: inout SeededRandomNumberGenerator) {
        for row in 1..<7 {
            for col in 1..<7 {
                let key = "\(row),\(col)"
                if grid[row][col] == .wall && !protectedCells.contains(key) && rng.nextDouble() < density {
                    // Only carve if it creates a connection between two empty spaces
                    let hasEmptyNeighbor = (row > 0 && grid[row-1][col] == .empty) ||
                                          (row < 7 && grid[row+1][col] == .empty) ||
                                          (col > 0 && grid[row][col-1] == .empty) ||
                                          (col < 7 && grid[row][col+1] == .empty)

                    if hasEmptyNeighbor {
                        grid[row][col] = .empty
                    }
                }
            }
        }
    }
}

// Extension to shuffle arrays with custom RNG
extension Array {
    mutating func shuffle(using rng: inout SeededRandomNumberGenerator) {
        for i in (1..<count).reversed() {
            let j = Int(rng.next() % UInt64(i + 1))
            swapAt(i, j)
        }
    }
}
