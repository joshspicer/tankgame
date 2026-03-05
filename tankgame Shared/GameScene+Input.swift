//
//  GameScene+Input.swift
//  Tank Game
//
//  Touch handling: joystick, fire button, settings.
//

import SpriteKit

extension GameScene {

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            // Handle settings modal if visible
            if isSettingsModalVisible, let modal = settingsModal {
                handleSettingsModalTouch(touch, in: modal)
                return
            }

            // Check settings button (elder only)
            if isLocalPlayerElder, let button = settingsButton {
                let buttonDist = hypot(location.x - button.position.x, location.y - button.position.y)
                if buttonDist < 22 {
                    showSettingsModal()
                    return
                }
            }

            // Fire button
            if fireButton.contains(location) {
                fire()
                return
            }

            // Joystick
            let joystickDist = hypot(location.x - joystickBase.position.x, location.y - joystickBase.position.y)
            if joystickDist < 100 {
                joystickTouch = touch
                updateJoystick(touch: touch)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                updateJoystick(touch: touch)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                joystickTouch = nil
                currentDirection = nil
                joystickStick.position = joystickBase.position
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: - Settings Modal Touch

    private func handleSettingsModalTouch(_ touch: UITouch, in modal: SKNode) {
        let modalLocation = touch.location(in: modal)
        let node = modal.atPoint(modalLocation)
        let name = node.name ?? node.parent?.name ?? node.parent?.parent?.name

        if name == "settings_minus" && currentGridSize > 4 {
            gameDelegate?.gameScene(self, didChangeGridSize: -1)
            return
        } else if name == "settings_plus" && currentGridSize < 12 {
            gameDelegate?.gameScene(self, didChangeGridSize: 1)
            return
        } else if name == "settings_add_ai_easy" {
            addAIPlayer(difficulty: .easy)
            hideSettingsModal()
            return
        } else if name == "settings_add_ai_medium" {
            addAIPlayer(difficulty: .medium)
            hideSettingsModal()
            return
        } else if name == "settings_add_ai_hard" {
            addAIPlayer(difficulty: .hard)
            hideSettingsModal()
            return
        } else if name == "settings_add_ai_expert" {
            addAIPlayer(difficulty: .expert)
            hideSettingsModal()
            return
        } else if name == "settings_close" || name == "settings_modal_bg" {
            hideSettingsModal()
            return
        } else if name == "settings_modal_panel" {
            return
        }

        hideSettingsModal()
    }

    // MARK: - AI Player Management

    func addAIPlayer(difficulty: AIDifficulty = .easy) {
        guard let game = game else { return }

        // Generate unique AI ID
        let aiId = "AI-\(UUID().uuidString.prefix(8))"

        // Add AI player to game
        game.addAIPlayer(id: aiId, difficulty: difficulty)

        // Broadcast to other players via delegate
        gameDelegate?.gameScene(self, playerMoved: .up)  // Trigger sync

        // Update rendering
        renderTanksSmooth()
        updateScores()
    }

    // MARK: - Joystick

    func updateJoystick(touch: UITouch) {
        let location = touch.location(in: self)
        let basePos = joystickBase.position

        var dx = location.x - basePos.x
        var dy = location.y - basePos.y
        let dist = hypot(dx, dy)
        let maxDist: CGFloat = 40

        if dist > maxDist {
            dx = dx / dist * maxDist
            dy = dy / dist * maxDist
        }

        joystickStick.position = CGPoint(x: basePos.x + dx, y: basePos.y + dy)

        if dist > 20 {
            let angle = atan2(dy, dx)
            if angle > .pi * 0.25 && angle < .pi * 0.75 {
                currentDirection = .up
            } else if angle < -.pi * 0.25 && angle > -.pi * 0.75 {
                currentDirection = .down
            } else if abs(angle) < .pi * 0.25 {
                currentDirection = .right
            } else {
                currentDirection = .left
            }
        } else {
            currentDirection = nil
        }
    }

    // MARK: - Fire

    func fire() {
        guard let game = game else { return }
        guard game.localTank.isAlive else { return }

        var projectile = game.localTank.shoot()
        projectile.ownerId = game.localPeerId
        gameDelegate?.gameScene(self, playerShot: projectile)
    }
}
