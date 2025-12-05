//
//  GameSceneInputHandler.swift
//  tankgame Shared
//
//  Input handling logic extracted from GameScene
//

#if os(iOS) || os(tvOS)
import SpriteKit

/// Handles touch-based input events for iOS and tvOS
class GameSceneInputHandler {
    weak var scene: GameScene?
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func handleTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = scene, scene.gameState != nil else { return }
        
        for touch in touches {
            let location = touch.location(in: scene)
            
            // Check if using modern UI
            if scene.useModernUI {
                // Check if touching modern fire button
                if scene.modernFireButton.handleTouch(at: location) {
                    continue
                }
                
                // Check if touching modern joystick area
                if scene.modernJoystickController.handleTouchBegan(touch, in: scene) {
                    continue
                }
            } else {
                // Check if touching fire button
                if scene.fireButton.handleTouch(at: location) {
                    continue
                }
                
                // Check if touching joystick area
                if scene.joystickController.handleTouchBegan(touch, in: scene) {
                    continue
                }
            }
        }
    }
    
    func handleTouchesMoved(_ touches: Set<UITouch>) {
        guard let scene = scene else { return }
        
        if scene.useModernUI {
            for touch in touches {
                scene.modernJoystickController.handleTouchMoved(touch, in: scene)
            }
        } else {
            for touch in touches {
                scene.joystickController.handleTouchMoved(touch, in: scene)
            }
        }
    }
    
    func handleTouchesEnded(_ touches: Set<UITouch>) {
        guard let scene = scene else { return }
        
        if scene.useModernUI {
            for touch in touches {
                scene.modernJoystickController.handleTouchEnded(touch)
            }
        } else {
            for touch in touches {
                scene.joystickController.handleTouchEnded(touch)
            }
        }
    }
    
    func handleShoot() {
        guard let scene = scene,
              let state = scene.gameState,
              state.localTank.isAlive else { return }
        
        let projectile = state.localTank.shoot()
        state.projectiles.append(projectile)
        scene.renderProjectiles()
        scene.soundManager.playSound("shoot.wav")
        
        // Flash the fire button on successful shot
        if scene.useModernUI {
            scene.modernFireButton.playSuccessFlash()
        }
        
        // Send shoot message
        scene.onGameMessage?(.playerShoot(playerIndex: state.localPlayerIndex, projectile: projectile))
    }
}
#endif
