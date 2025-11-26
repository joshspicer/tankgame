//
//  GameSceneRenderer.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Handles all rendering operations for the game scene
class GameSceneRenderer {
    // Constants
    let tileSize: CGFloat
    let gridSize: Int
    
    // Tank colors for up to 4 players
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    // Specialized renderers
    private let gridRenderer: GridRenderer
    private let tankRenderer: TankRenderer
    private let projectileRenderer: ProjectileRenderer
    
    /// Current game mode affecting tank appearance
    var gameMode: GameMode {
        get { tankRenderer.gameMode }
        set { tankRenderer.gameMode = newValue }
    }
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.gridRenderer = GridRenderer(tileSize: tileSize, gridSize: gridSize)
        self.tankRenderer = TankRenderer(tileSize: tileSize, gridSize: gridSize)
        self.projectileRenderer = ProjectileRenderer(tileSize: tileSize, gridSize: gridSize)
    }
    
    // MARK: - Grid Rendering
    
    /// Render the game grid
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        gridRenderer.renderGrid(grid, in: gridNode)
    }
    
    // MARK: - Tank Rendering
    
    /// Render all tanks
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        tankRenderer.renderTanks(tanks, tankExploding: tankExploding, in: tankNodes)
    }

    /// Render all tanks with smooth animation
    func renderTanksWithSmoothing(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?], duration: TimeInterval) {
        tankRenderer.renderTanksWithSmoothing(tanks, tankExploding: tankExploding, in: tankNodes, duration: duration)
    }
    
    // MARK: - Projectile Rendering
    
    /// Render all projectiles
    func renderProjectiles(_ projectiles: [Projectile], in projectilesNode: SKNode) {
        projectileRenderer.renderProjectiles(projectiles, in: projectilesNode)
    }
    
    // MARK: - Helper Methods
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return gridRenderer.gridPosition(row: row, col: col)
    }
}
