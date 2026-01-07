//
//  SpriteKitRenderer.swift
//  tankgame Shared
//
//  SpriteKit implementation of game renderer
//

import SpriteKit

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Renders the game using SpriteKit
final class SpriteKitRenderer: GameRenderer {
    
    private weak var scene: SKScene?
    private var boardNode: SKNode?
    private var tankNodes: [Int: SKSpriteNode] = [:]
    private var projectileNodes: [String: SKSpriteNode] = [:]
    
    private let cellSize: CGFloat = 60
    
    #if os(iOS) || os(tvOS)
    private let tankColors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, 
        .systemOrange, .systemPurple, .systemPink
    ]
    #elseif os(macOS)
    private let tankColors: [NSColor] = [
        .systemRed, .systemBlue, .systemGreen,
        .systemOrange, .systemPurple, .systemPink
    ]
    #endif
    
    func setup(in scene: SKScene) {
        self.scene = scene
        scene.backgroundColor = .black
        
        // Create board container
        let boardNode = SKNode()
        boardNode.name = "board"
        scene.addChild(boardNode)
        self.boardNode = boardNode
    }
    
    func render(state: GameStateModel) {
        guard let scene = scene, let boardNode = boardNode else { return }
        
        // Center board on screen
        let boardWidth = CGFloat(state.board.cols) * cellSize
        let boardHeight = CGFloat(state.board.rows) * cellSize
        boardNode.position = CGPoint(
            x: (scene.size.width - boardWidth) / 2,
            y: (scene.size.height - boardHeight) / 2
        )
        
        // Render board cells
        renderBoard(state.board, in: boardNode)
        
        // Render tanks
        renderTanks(state.tanks, in: boardNode)
        
        // Render projectiles
        renderProjectiles(state.projectiles, in: boardNode)
    }
    
    func handleEvent(_ event: GameEvent) {
        switch event {
        case .tankDestroyed(let playerIndex):
            animateTankExplosion(playerIndex: playerIndex)
            
        case .projectileHitWall(_, let position):
            animateExplosion(at: position)
            
        case .wallDestroyed(let position):
            removeWall(at: position)
            
        default:
            break
        }
    }
    
    // MARK: - Board Rendering
    
    private func renderBoard(_ board: GameBoard, in parent: SKNode) {
        // Remove old cells
        parent.children.filter { $0.name?.hasPrefix("cell_") == true }.forEach { $0.removeFromParent() }
        
        for row in 0..<board.rows {
            for col in 0..<board.cols {
                let position = Position(row: row, col: col)
                guard let cellType = board.cellType(at: position) else { continue }
                
                if cellType != .empty {
                    let cellNode = createCellNode(type: cellType)
                    cellNode.position = gridToScene(row: row, col: col)
                    cellNode.name = "cell_\(row)_\(col)"
                    parent.addChild(cellNode)
                }
            }
        }
    }
    
    private func createCellNode(type: CellType) -> SKSpriteNode {
        let node = SKSpriteNode(color: type == .wall ? .darkGray : .gray, size: CGSize(width: cellSize - 2, height: cellSize - 2))
        return node
    }
    
    // MARK: - Tank Rendering
    
    private func renderTanks(_ tanks: [TankEntity], in parent: SKNode) {
        // Remove tanks that no longer exist
        let currentTankIndices = Set(tanks.map { $0.playerIndex })
        tankNodes.keys.filter { !currentTankIndices.contains($0) }.forEach { index in
            tankNodes[index]?.removeFromParent()
            tankNodes.removeValue(forKey: index)
        }
        
        // Update or create tank nodes
        for tank in tanks {
            guard tank.isAlive else {
                tankNodes[tank.playerIndex]?.removeFromParent()
                tankNodes.removeValue(forKey: tank.playerIndex)
                continue
            }
            
            if let tankNode = tankNodes[tank.playerIndex] {
                // Update existing tank
                updateTankNode(tankNode, with: tank)
            } else {
                // Create new tank
                let tankNode = createTankNode(for: tank)
                parent.addChild(tankNode)
                tankNodes[tank.playerIndex] = tankNode
            }
        }
    }
    
    private func createTankNode(for tank: TankEntity) -> SKSpriteNode {
        let size = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
        let color = tankColors[tank.playerIndex % tankColors.count]
        let node = SKSpriteNode(color: color, size: size)
        node.name = "tank_\(tank.playerIndex)"
        
        // Add turret
        let turret = SKSpriteNode(color: color.withAlphaComponent(0.8), size: CGSize(width: size.width * 0.3, height: size.height * 0.6))
        turret.position = CGPoint(x: 0, y: size.height * 0.2)
        turret.name = "turret"
        node.addChild(turret)
        
        updateTankNode(node, with: tank)
        return node
    }
    
    private func updateTankNode(_ node: SKSpriteNode, with tank: TankEntity) {
        let targetPosition = gridToScene(row: tank.position.row, col: tank.position.col)
        let targetRotation = CGFloat(tank.direction.angle)
        
        // Smooth animation
        node.run(SKAction.group([
            SKAction.move(to: targetPosition, duration: 0.1),
            SKAction.rotate(toAngle: targetRotation, duration: 0.1)
        ]))
    }
    
    // MARK: - Projectile Rendering
    
    private func renderProjectiles(_ projectiles: [ProjectileEntity], in parent: SKNode) {
        // Remove old projectiles
        let currentProjectileIds = Set(projectiles.filter { $0.isActive }.map { $0.id })
        projectileNodes.keys.filter { !currentProjectileIds.contains($0) }.forEach { id in
            projectileNodes[id]?.removeFromParent()
            projectileNodes.removeValue(forKey: id)
        }
        
        // Update or create projectile nodes
        for projectile in projectiles where projectile.isActive {
            if let projectileNode = projectileNodes[projectile.id] {
                // Update existing
                let targetPosition = gridToScene(row: projectile.position.row, col: projectile.position.col)
                projectileNode.run(SKAction.move(to: targetPosition, duration: 0.1))
            } else {
                // Create new
                let projectileNode = createProjectileNode(for: projectile)
                parent.addChild(projectileNode)
                projectileNodes[projectile.id] = projectileNode
            }
        }
    }
    
    private func createProjectileNode(for projectile: ProjectileEntity) -> SKSpriteNode {
        let size = CGSize(width: cellSize * 0.3, height: cellSize * 0.3)
        let node = SKSpriteNode(color: .yellow, size: size)
        node.name = "projectile_\(projectile.id)"
        node.position = gridToScene(row: projectile.position.row, col: projectile.position.col)
        return node
    }
    
    // MARK: - Effects
    
    private func animateTankExplosion(playerIndex: Int) {
        guard let tankNode = tankNodes[playerIndex] else { return }
        
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleBirthRate = 100
        explosion.numParticlesToEmit = 50
        explosion.particleLifetime = 1
        explosion.emissionAngle = 0
        explosion.emissionAngleRange = .pi * 2
        explosion.particleSpeed = 100
        explosion.particleSpeedRange = 50
        explosion.particleColor = .orange
        explosion.particleColorBlendFactor = 1
        explosion.particleScale = 0.3
        explosion.position = tankNode.position
        
        boardNode?.addChild(explosion)
        
        tankNode.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }
    
    private func animateExplosion(at position: Position) {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleBirthRate = 50
        explosion.numParticlesToEmit = 25
        explosion.particleLifetime = 0.5
        explosion.emissionAngle = 0
        explosion.emissionAngleRange = .pi * 2
        explosion.particleSpeed = 80
        explosion.particleColor = .orange
        explosion.particleColorBlendFactor = 1
        explosion.particleScale = 0.2
        explosion.position = gridToScene(row: position.row, col: position.col)
        
        boardNode?.addChild(explosion)
        explosion.run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.removeFromParent()
        ]))
    }
    
    private func removeWall(at position: Position) {
        boardNode?.childNode(withName: "cell_\(position.row)_\(position.col)")?.removeFromParent()
    }
    
    // MARK: - Utilities
    
    private func gridToScene(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * cellSize + cellSize / 2,
            y: CGFloat(row) * cellSize + cellSize / 2
        )
    }
}
