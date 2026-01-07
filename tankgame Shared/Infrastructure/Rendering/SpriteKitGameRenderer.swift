//
//  GameRenderer.swift
//  tankgame Shared
//
//  Clean Architecture - Infrastructure Layer
//

import Foundation
import SpriteKit

/// Protocol for rendering the game
protocol GameRenderer: AnyObject {
    func render(session: GameSessionEntity, in scene: SKScene)
    func renderMap(_ map: GameMapEntity, in scene: SKScene)
    func renderTanks(_ tanks: [TankEntity], in scene: SKScene)
    func renderProjectiles(_ projectiles: [ProjectileEntity], in scene: SKScene)
}

/// SpriteKit implementation of game renderer
final class SpriteKitGameRenderer: GameRenderer {
    
    private let tileSize: CGFloat
    private var gridNode: SKNode?
    private var tanksNode: SKNode?
    private var projectilesNode: SKNode?
    
    // Node caches
    private var tankNodes: [UUID: SKNode] = [:]
    private var projectileNodes: [UUID: SKNode] = [:]
    
    init(tileSize: CGFloat = 60) {
        self.tileSize = tileSize
    }
    
    func render(session: GameSessionEntity, in scene: SKScene) {
        // Setup nodes if needed
        setupNodesIfNeeded(in: scene)
        
        // Render everything
        renderMap(session.map, in: scene)
        renderTanks(session.tanks, in: scene)
        renderProjectiles(session.projectiles, in: scene)
    }
    
    func renderMap(_ map: GameMapEntity, in scene: SKScene) {
        guard let gridNode = gridNode else { return }
        
        gridNode.removeAllChildren()
        
        for row in 0..<map.size {
            for col in 0..<map.size {
                let position = Position(row: row, col: col)
                guard let cellType = map.cellType(at: position) else { continue }
                
                let x = CGFloat(col) * tileSize
                let y = CGFloat(row) * tileSize
                
                let cell = SKSpriteNode(color: cellColor(for: cellType), size: CGSize(width: tileSize - 2, height: tileSize - 2))
                cell.position = CGPoint(x: x, y: y)
                gridNode.addChild(cell)
            }
        }
    }
    
    func renderTanks(_ tanks: [TankEntity], in scene: SKScene) {
        guard let tanksNode = tanksNode else { return }
        
        // Remove tanks that no longer exist
        let tankIDs = Set(tanks.map { $0.id })
        for (id, node) in tankNodes {
            if !tankIDs.contains(id) {
                node.removeFromParent()
                tankNodes.removeValue(forKey: id)
            }
        }
        
        // Update or create tank nodes
        for tank in tanks {
            if let node = tankNodes[tank.id] {
                updateTankNode(node, with: tank)
            } else {
                let node = createTankNode(for: tank)
                tanksNode.addChild(node)
                tankNodes[tank.id] = node
            }
        }
    }
    
    func renderProjectiles(_ projectiles: [ProjectileEntity], in scene: SKScene) {
        guard let projectilesNode = projectilesNode else { return }
        
        // Remove inactive projectiles
        let activeIDs = Set(projectiles.filter { $0.isActive }.map { $0.id })
        for (id, node) in projectileNodes {
            if !activeIDs.contains(id) {
                node.removeFromParent()
                projectileNodes.removeValue(forKey: id)
            }
        }
        
        // Update or create projectile nodes
        for projectile in projectiles where projectile.isActive {
            if let node = projectileNodes[projectile.id] {
                updateProjectileNode(node, with: projectile)
            } else {
                let node = createProjectileNode(for: projectile)
                projectilesNode.addChild(node)
                projectileNodes[projectile.id] = node
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupNodesIfNeeded(in scene: SKScene) {
        if gridNode == nil {
            let node = SKNode()
            node.name = "grid"
            scene.addChild(node)
            gridNode = node
        }
        
        if tanksNode == nil {
            let node = SKNode()
            node.name = "tanks"
            scene.addChild(node)
            tanksNode = node
        }
        
        if projectilesNode == nil {
            let node = SKNode()
            node.name = "projectiles"
            scene.addChild(node)
            projectilesNode = node
        }
    }
    
    private func cellColor(for type: GridCellType) -> SKColor {
        switch type {
        case .empty:
            return SKColor.darkGray
        case .wall:
            return SKColor.gray
        }
    }
    
    private func createTankNode(for tank: TankEntity) -> SKNode {
        let size = tileSize * 0.8
        let sprite = SKSpriteNode(color: tankColor(for: tank.playerID), size: CGSize(width: size, height: size))
        sprite.name = "tank_\(tank.id)"
        updateTankNode(sprite, with: tank)
        return sprite
    }
    
    private func updateTankNode(_ node: SKNode, with tank: TankEntity) {
        let x = CGFloat(tank.position.col) * tileSize
        let y = CGFloat(tank.position.row) * tileSize
        node.position = CGPoint(x: x, y: y)
        node.zRotation = tank.direction.angleInRadians
        node.alpha = tank.isAlive ? 1.0 : 0.3
    }
    
    private func createProjectileNode(for projectile: ProjectileEntity) -> SKNode {
        let size = tileSize * 0.3
        let sprite = SKSpriteNode(color: .yellow, size: CGSize(width: size, height: size))
        sprite.name = "projectile_\(projectile.id)"
        updateProjectileNode(sprite, with: projectile)
        return sprite
    }
    
    private func updateProjectileNode(_ node: SKNode, with projectile: ProjectileEntity) {
        let x = CGFloat(projectile.position.col) * tileSize
        let y = CGFloat(projectile.position.row) * tileSize
        node.position = CGPoint(x: x, y: y)
    }
    
    private func tankColor(for playerID: PlayerID) -> SKColor {
        // Generate consistent color based on player ID
        let hash = abs(playerID.value.hashValue)
        let hue = CGFloat(hash % 360) / 360.0
        return SKColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1.0)
    }
}
