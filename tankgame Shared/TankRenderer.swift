//
//  TankRenderer.swift
//  tankgame Shared
//
//  Tank rendering logic extracted from GameSceneRenderer
//

import SpriteKit

/// Handles rendering of tanks with animations
class TankRenderer: BaseRenderer {
    
    // Tank colors for up to 4 players
    let tankColors: [SKColor] = [.blue, .red, .green, .orange]
    
    // Sprite renderers
    private let tankSpriteRenderer: TankSpriteRenderer
    private let dolphinSpriteRenderer: DolphinSpriteRenderer
    
    override init(tileSize: CGFloat, gridSize: Int) {
        self.tankSpriteRenderer = TankSpriteRenderer(tileSize: tileSize)
        self.dolphinSpriteRenderer = DolphinSpriteRenderer(tileSize: tileSize)
        super.init(tileSize: tileSize, gridSize: gridSize)
    }
    
    /// Render all tanks
    func renderTanks(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?]) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            tankNode.removeAllChildren()
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let tankSprite = createTankNode(color: tankColors[i], direction: tank.direction)
                tankSprite.position = gridPosition(row: tank.row, col: tank.col)
                tankNode.addChild(tankSprite)
            }
        }
    }
    
    /// Render all tanks with smooth animation
    func renderTanksWithSmoothing(_ tanks: [Tank], tankExploding: [Bool], in tankNodes: [SKNode?], duration: TimeInterval) {
        for i in 0..<tanks.count {
            guard let tankNode = tankNodes[i] else { continue }
            
            let tank = tanks[i]
            if tank.isAlive || tankExploding[i] {
                let targetPosition = gridPosition(row: tank.row, col: tank.col)
                
                if let tankSprite = tankNode.children.first {
                    animateSpriteMovement(tankSprite, to: targetPosition, rotation: CGFloat(tank.direction.angle), duration: duration)
                } else {
                    let tankSprite = createTankNode(color: tankColors[i], direction: tank.direction)
                    tankSprite.position = targetPosition
                    tankNode.addChild(tankSprite)
                }
            } else {
                tankNode.removeAllChildren()
            }
        }
    }
    
    /// Create a tank sprite node based on current sprite mode
    private func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        switch GameSettings.shared.spriteMode {
        case .dolphin:
            return dolphinSpriteRenderer.createDolphinNode(color: color, direction: direction)
        case .tank:
            return tankSpriteRenderer.createTankNode(color: color, direction: direction)
        }
    }
}
