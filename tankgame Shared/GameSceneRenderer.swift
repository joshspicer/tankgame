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
    
    // Tank colors for up to 4 players - modernized palette
    let tankColors: [SKColor] = [
        SKColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1.0),   // Blue
        SKColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0),   // Red
        SKColor(red: 0.35, green: 0.85, blue: 0.45, alpha: 1.0),  // Green
        SKColor(red: 1.0, green: 0.65, blue: 0.20, alpha: 1.0)    // Orange
    ]
    
    // Specialized renderers
    private let gridRenderer: ModernGridRenderer
    private let tankRenderer: TankRenderer
    private let projectileRenderer: ProjectileRenderer
    private let lizardRenderer: LizardRenderer
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.gridRenderer = ModernGridRenderer(tileSize: tileSize, gridSize: gridSize)
        self.tankRenderer = TankRenderer(tileSize: tileSize, gridSize: gridSize)
        self.projectileRenderer = ProjectileRenderer(tileSize: tileSize, gridSize: gridSize)
        self.lizardRenderer = LizardRenderer(tileSize: tileSize, gridSize: gridSize)
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
    
    // MARK: - Lizard Rendering
    
    /// Render all lizards
    func renderLizards(_ lizards: [Lizard], in lizardNode: SKNode) {
        lizardRenderer.renderLizards(lizards, in: lizardNode)
    }
    
    /// Render lizards with smooth animation
    func renderLizardsWithSmoothing(_ lizards: [Lizard], in lizardNode: SKNode, duration: TimeInterval) {
        lizardRenderer.renderLizardsWithSmoothing(lizards, in: lizardNode, duration: duration)
    }
    
    // MARK: - Helper Methods
    
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return gridRenderer.gridPosition(row: row, col: col)
    }
}
