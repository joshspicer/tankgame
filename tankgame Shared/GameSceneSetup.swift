//
//  GameSceneSetup.swift
//  tankgame Shared
//
//  Scene setup logic extracted from GameScene
//

import SpriteKit

/// Handles initial scene setup and component initialization
class GameSceneSetup {
    
    /// Setup the scene structure with nodes and UI components
    static func setupScene(in scene: GameScene) {
        // Create grid container (centered)
        let newGridNode = SKNode()
        let gridOffset = CGPoint(
            x: (scene.size.width - CGFloat(scene.gridSize) * scene.tileSize) / 2,
            y: (scene.size.height - CGFloat(scene.gridSize) * scene.tileSize) / 2 + 50
        )
        newGridNode.position = gridOffset
        scene.addChild(newGridNode)
        scene.gridNode = newGridNode
        
        // Create projectiles container
        let newProjectilesNode = SKNode()
        newProjectilesNode.position = gridOffset
        scene.addChild(newProjectilesNode)
        scene.projectilesNode = newProjectilesNode
        
        // Create dinosaur container
        let newDinosaurNode = SKNode()
        newDinosaurNode.position = gridOffset
        scene.addChild(newDinosaurNode)
        scene.dinosaurNode = newDinosaurNode
        
        // Create tank nodes for all possible players
        for i in 0..<4 {
            let tankNode = SKNode()
            tankNode.position = gridOffset
            scene.addChild(tankNode)
            scene.tankNodes[i] = tankNode
        }
        
        // Setup UI components
        scene.joystickController.setup(in: scene, at: CGPoint(x: 80, y: 100))
        scene.fireButton.setup(in: scene, at: CGPoint(x: scene.size.width - 80, y: 100))
        scene.ui.setup(in: scene, sceneSize: scene.size)
        
        // Setup fire button callback
        scene.fireButton.onTap = { [weak scene] in
            scene?.inputHandler.handleShoot()
        }
    }
}
