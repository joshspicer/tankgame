//
//  GameScene+TVInput.swift
//  tankgame tvOS
//
//  Game controller input for tvOS using GameController framework.
//  Supports MFi controllers and the Siri Remote (micro gamepad).
//

import SpriteKit
import GameController

extension GameScene {

    // MARK: - Controller Setup

    /// Call from didMove(to:) to begin listening for game controller input.
    func setupControllerInput() {
        // Register any already-connected controllers
        for controller in GCController.controllers() {
            registerController(controller)
        }

        // Observe future connections using closure-based API
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let controller = notification.object as? GCController else { return }
            self?.registerController(controller)
        }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.currentDirection = nil
        }
    }

    // MARK: - Controller Registration

    private func registerController(_ controller: GCController) {
        if let gamepad = controller.extendedGamepad {
            registerExtendedGamepad(gamepad)
        } else if let gamepad = controller.microGamepad {
            registerMicroGamepad(gamepad)
        }
    }

    /// Register an extended MFi gamepad (d-pad + buttons).
    private func registerExtendedGamepad(_ gamepad: GCExtendedGamepad) {
        gamepad.dpad.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.handleDpadInput(xValue: xValue, yValue: yValue)
        }
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.handleDpadInput(xValue: xValue, yValue: yValue)
        }
        gamepad.buttonA.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.fire() }
        }
        gamepad.buttonX.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.fire() }
        }
    }

    /// Register a Siri Remote (micro gamepad).
    private func registerMicroGamepad(_ gamepad: GCMicroGamepad) {
        // Report absolute values so the d-pad direction maps cleanly
        gamepad.reportsAbsoluteDpadValues = true
        gamepad.dpad.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.handleDpadInput(xValue: xValue, yValue: yValue)
        }
        gamepad.buttonA.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.fire() }
        }
        gamepad.buttonX.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.fire() }
        }
    }

    // MARK: - D-Pad Mapping

    private func handleDpadInput(xValue: Float, yValue: Float) {
        let deadzone: Float = 0.3
        if abs(xValue) < deadzone && abs(yValue) < deadzone {
            currentDirection = nil
            return
        }
        if abs(yValue) >= abs(xValue) {
            currentDirection = yValue > 0 ? .up : .down
        } else {
            currentDirection = xValue > 0 ? .right : .left
        }
    }
}
