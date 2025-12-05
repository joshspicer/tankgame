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
    private let modernGridRenderer: ModernGridRenderer
    private let tankRenderer: TankRenderer
    private let projectileRenderer: ProjectileRenderer
    private let lizardRenderer: LizardRenderer
    
    // Feature flag for modern rendering
    private let useModernRenderer: Bool = true
    
    init(tileSize: CGFloat, gridSize: Int) {
        self.tileSize = tileSize
        self.gridSize = gridSize
        self.gridRenderer = GridRenderer(tileSize: tileSize, gridSize: gridSize)
        self.modernGridRenderer = ModernGridRenderer(tileSize: tileSize, gridSize: gridSize)
        self.tankRenderer = TankRenderer(tileSize: tileSize, gridSize: gridSize)
        self.projectileRenderer = ProjectileRenderer(tileSize: tileSize, gridSize: gridSize)
        self.lizardRenderer = LizardRenderer(tileSize: tileSize, gridSize: gridSize)
    }
    
    // MARK: - Grid Rendering
    
    /// Render the game grid (uses modern or legacy renderer based on flag)
    func renderGrid(_ grid: [[GridCell]], in gridNode: SKNode) {
        if useModernRenderer {
            modernGridRenderer.renderGrid(grid, in: gridNode)
        } else {
            gridRenderer.renderGrid(grid, in: gridNode)
        }
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
        if useModernRenderer {
            return modernGridRenderer.gridPosition(row: row, col: col)
        } else {
            return gridRenderer.gridPosition(row: row, col: col)
        }
    }
}
