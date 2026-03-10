//
//  GameScene+Reload.swift
//  Tank Game
//
//  Ammo tracking, reload timer, and ammo indicator UI.
//

import SpriteKit

extension GameScene {

    // MARK: - Ammo Indicator Setup

    func setupAmmoIndicator() {
        let container = SKNode()
        container.position = CGPoint(x: size.width - 100, y: 185)
        container.zPosition = 102
        addChild(container)
        ammoIndicator = container
        updateAmmoIndicator()
    }

    // MARK: - Ammo Indicator Update

    func updateAmmoIndicator() {
        guard let container = ammoIndicator else { return }
        container.removeAllChildren()

        if isReloading {
            // Show "RELOAD" label while reloading
            let reloadLabel = SKLabelNode(text: "RELOAD")
            reloadLabel.fontName = "AvenirNext-Bold"
            reloadLabel.fontSize = 11
            reloadLabel.fontColor = SKColor.yellow
            reloadLabel.horizontalAlignmentMode = .center
            reloadLabel.verticalAlignmentMode = .center
            reloadLabel.position = .zero
            container.addChild(reloadLabel)
        } else {
            // Show one dot per ammo unit
            let dotRadius: CGFloat = 5
            let spacing: CGFloat = 14
            let totalWidth = CGFloat(maxAmmo - 1) * spacing
            for i in 0..<maxAmmo {
                let dot = SKShapeNode(circleOfRadius: dotRadius)
                dot.fillColor = i < ammo ? SKColor.white : SKColor(white: 0.3, alpha: 1)
                dot.strokeColor = .clear
                dot.position = CGPoint(x: -totalWidth / 2 + CGFloat(i) * spacing, y: 0)
                container.addChild(dot)
            }
        }
    }

    // MARK: - Reload Logic

    /// Begin a reload cycle; disables firing until complete.
    func startReload(currentTime: TimeInterval) {
        guard !isReloading else { return }
        isReloading = true
        reloadEndTime = currentTime + reloadDuration
        updateFireButtonState()
        updateAmmoIndicator()
    }

    /// Called each frame to check whether reload is complete.
    func updateReload(currentTime: TimeInterval) {
        guard isReloading else { return }
        if currentTime >= reloadEndTime {
            isReloading = false
            ammo = maxAmmo
            updateFireButtonState()
            updateAmmoIndicator()
        }
    }

    // MARK: - Fire Button State

    /// Syncs the fire button appearance with the current reload/ammo state.
    func updateFireButtonState() {
        if isReloading {
            fireButton.fillColor = SKColor(white: 0.3, alpha: 0.7)
        } else {
            fireButton.fillColor = .systemRed.withAlphaComponent(0.7)
        }
    }
}
