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
    
    // Feature flag for modern UI
    private var useModernUI: Bool {
        return scene?.modernJoystick != nil
    }
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func handleTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = scene, scene.gameState != nil else { return }
        
        for touch in touches {
            let location = touch.location(in: scene)
            
            // Check if touching fire button (modern or legacy)
            if useModernUI {
                if scene.modernFireButton.handleTouch(at: location) {
                    continue
                }
                
                // Check if touching modern joystick area
                if scene.modernJoystick.handleTouchBegan(touch, in: scene) {
                    continue
                }
            } else {
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
        for touch in touches {
            if useModernUI {
                scene.modernJoystick.handleTouchMoved(touch, in: scene)
            } else {
                scene.joystickController.handleTouchMoved(touch, in: scene)
            }
        }
    }
    
    func handleTouchesEnded(_ touches: Set<UITouch>) {
        guard let scene = scene else { return }
        for touch in touches {
            if useModernUI {
                scene.modernJoystick.handleTouchEnded(touch)
            } else {
                scene.joystickController.handleTouchEnded(touch)
            }
        }
    }
    
    /// Get current direction from joystick (modern or legacy)
    var currentDirection: Direction? {
        guard let scene = scene else { return nil }
        if useModernUI {
            return scene.modernJoystick.currentDirection
        } else {
            return scene.joystickController.currentDirection
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
        
        // Send shoot message
        scene.onGameMessage?(.playerShoot(playerIndex: state.localPlayerIndex, projectile: projectile))
    }
}
#endif
