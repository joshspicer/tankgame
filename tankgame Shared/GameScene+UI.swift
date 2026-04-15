//
//  GameScene+UI.swift
//  Tank Game
//
//  UI setup, scoreboard, status labels, respawn overlay.
//

import SpriteKit

extension GameScene {

    // MARK: - UI Setup

    func setupUI() {
        // Joystick (bottom left)
        let joystickRadius: CGFloat = 60
        let baseRadius: CGFloat = 80
        let joystickX: CGFloat = 100
        let joystickY: CGFloat = 120

        joystickBase = SKShapeNode(circleOfRadius: baseRadius)
        joystickBase.fillColor = SKColor(white: 0.3, alpha: 0.5)
        joystickBase.strokeColor = SKColor(white: 0.5, alpha: 0.5)
        joystickBase.lineWidth = 2
        joystickBase.position = CGPoint(x: joystickX, y: joystickY)
        joystickBase.zPosition = 100
        addChild(joystickBase)

        joystickStick = SKShapeNode(circleOfRadius: joystickRadius / 2)
        joystickStick.fillColor = SKColor(white: 0.6, alpha: 0.8)
        joystickStick.strokeColor = .clear
        joystickStick.position = joystickBase.position
        joystickStick.zPosition = 101
        addChild(joystickStick)

        // Fire button (bottom right)
        fireButton = SKShapeNode(circleOfRadius: 50)
        fireButton.fillColor = .systemRed.withAlphaComponent(0.7)
        fireButton.strokeColor = .white
        fireButton.lineWidth = 3
        fireButton.position = CGPoint(x: size.width - 100, y: 120)
        fireButton.zPosition = 100
        addChild(fireButton)

        let fireLabel = SKLabelNode(text: "FIRE")
        fireLabel.fontName = "AvenirNext-Bold"
        fireLabel.fontSize = 18
        fireLabel.fontColor = .white
        fireLabel.verticalAlignmentMode = .center
        fireButton.addChild(fireLabel)

        // Scoreboard container
        let gridWidth = CGFloat(currentGridSize) * tileSize
        let gridBottomY = size.height - gridWidth - 60
        scoreboardNode = SKNode()
        scoreboardNode.position = CGPoint(x: size.width / 2, y: gridBottomY - 25)
        scoreboardNode.zPosition = 100
        addChild(scoreboardNode)

        // Status label
        statusLabel = SKLabelNode()
        statusLabel.fontName = "AvenirNext-Bold"
        statusLabel.fontSize = 28
        statusLabel.fontColor = .white
        statusLabel.horizontalAlignmentMode = .center
        statusLabel.verticalAlignmentMode = .center
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        statusLabel.zPosition = 200
        statusLabel.isHidden = true
        addChild(statusLabel)

        // Settings UI
        setupSettingsUI()
    }

    // MARK: - Scoreboard

    func updateScores() {
        guard let game = game else { return }

        let myColor = color(for: game.localPeerId)
        borderNode.strokeColor = myColor

        scoreboardNode.removeAllChildren()

        let sortedPlayers = game.players.sorted { a, b in
            if a.value.score != b.value.score {
                return a.value.score > b.value.score
            }
            return a.key < b.key
        }

        let maxDisplay = min(sortedPlayers.count, 6)
        let spacing: CGFloat = 90
        let startX = -CGFloat(maxDisplay - 1) * spacing / 2

        let elderPeerId = sortedPlayers.map(\.key).sorted().first

        for (i, (peerId, _)) in sortedPlayers.prefix(maxDisplay).enumerated() {
            let playerColor = color(for: peerId)
            let score = game.score(for: peerId)
            let isLocal = peerId == game.localPeerId
            let isElder = peerId == elderPeerId
            let isAI = game.players[peerId]?.tank.isAI ?? false

            if isElder {
                let star = SKLabelNode(text: "★")
                star.fontName = "AvenirNext-Bold"
                star.fontSize = 16
                star.fontColor = playerColor
                star.horizontalAlignmentMode = .center
                star.verticalAlignmentMode = .center
                star.position = CGPoint(x: startX + CGFloat(i) * spacing - 25, y: 0)
                if isLocal {
                    let glow = SKLabelNode(text: "★")
                    glow.fontName = "AvenirNext-Bold"
                    glow.fontSize = 20
                    glow.fontColor = .white
                    glow.alpha = 0.5
                    glow.horizontalAlignmentMode = .center
                    glow.verticalAlignmentMode = .center
                    glow.position = star.position
                    glow.zPosition = -1
                    scoreboardNode.addChild(glow)
                }
                scoreboardNode.addChild(star)
            } else {
                let dot = SKShapeNode(circleOfRadius: 6)
                dot.fillColor = playerColor
                dot.strokeColor = isLocal ? .white : .clear
                dot.lineWidth = isLocal ? 2 : 0
                dot.position = CGPoint(x: startX + CGFloat(i) * spacing - 25, y: 0)
                scoreboardNode.addChild(dot)
            }

            let label = SKLabelNode(text: "\(score)")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = isLocal ? 18 : 14
            label.fontColor = playerColor
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: startX + CGFloat(i) * spacing - 12, y: 0)
            scoreboardNode.addChild(label)

            if isLocal {
                let youLabel = SKLabelNode(text: "YOU")
                youLabel.fontName = "AvenirNext-Bold"
                youLabel.fontSize = 10
                youLabel.fontColor = playerColor.withAlphaComponent(0.7)
                youLabel.horizontalAlignmentMode = .center
                youLabel.verticalAlignmentMode = .center
                youLabel.position = CGPoint(x: startX + CGFloat(i) * spacing - 5, y: -15)
                scoreboardNode.addChild(youLabel)
            }

            // Show display name below score
            let displayName = game.players[peerId]?.displayName
            let nameText = displayName ?? (isAI ? "AI" : String(peerId.prefix(4)))
            let nameLabel = SKLabelNode(text: nameText)
            nameLabel.fontName = "AvenirNext-Medium"
            nameLabel.fontSize = 9
            nameLabel.fontColor = playerColor.withAlphaComponent(0.6)
            nameLabel.horizontalAlignmentMode = .center
            nameLabel.verticalAlignmentMode = .center
            nameLabel.position = CGPoint(x: startX + CGFloat(i) * spacing - 5, y: isLocal ? -26 : -15)
            scoreboardNode.addChild(nameLabel)
        }

        if sortedPlayers.count > maxDisplay {
            let moreLabel = SKLabelNode(text: "+\(sortedPlayers.count - maxDisplay)")
            moreLabel.fontName = "AvenirNext-Bold"
            moreLabel.fontSize = 12
            moreLabel.fontColor = SKColor(white: 0.6, alpha: 1)
            moreLabel.horizontalAlignmentMode = .left
            moreLabel.verticalAlignmentMode = .center
            moreLabel.position = CGPoint(x: startX + CGFloat(maxDisplay) * spacing - 25, y: 0)
            scoreboardNode.addChild(moreLabel)
        }
    }

    // MARK: - Status Display

    func showStatus(_ text: String, duration: TimeInterval = 2.0) {
        statusLabel.text = text
        statusLabel.isHidden = false
        statusLabel.alpha = 1

        statusLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.run { self.statusLabel.isHidden = true }
        ]))
    }

    // MARK: - Respawn Overlay

    func showRespawnCountdown(duration: TimeInterval) {
        hideRespawnCountdown()

        let overlay = SKNode()
        overlay.zPosition = 150

        let dimBackground = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimBackground.fillColor = SKColor(white: 0, alpha: 0.4)
        dimBackground.strokeColor = .clear
        dimBackground.position = .zero
        overlay.addChild(dimBackground)

        let centerY = size.height / 2

        let spinnerRadius: CGFloat = 40
        let spinner = SKShapeNode()
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: spinnerRadius, startAngle: 0, endAngle: .pi * 1.5, clockwise: false)
        spinner.path = path
        spinner.strokeColor = .white
        spinner.lineWidth = 4
        spinner.lineCap = .round
        spinner.position = CGPoint(x: size.width / 2, y: centerY + 20)
        spinner.zPosition = 151

        let rotate = SKAction.rotate(byAngle: -.pi * 2, duration: 1.0)
        spinner.run(SKAction.repeatForever(rotate))
        overlay.addChild(spinner)

        let countdownLabel = SKLabelNode()
        countdownLabel.fontName = "AvenirNext-Bold"
        countdownLabel.fontSize = 24
        countdownLabel.fontColor = .white
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: size.width / 2, y: centerY + 20)
        countdownLabel.zPosition = 152
        overlay.addChild(countdownLabel)

        let respawnLabel = SKLabelNode(text: "RESPAWNING")
        respawnLabel.fontName = "AvenirNext-Bold"
        respawnLabel.fontSize = 18
        respawnLabel.fontColor = SKColor(white: 0.8, alpha: 1)
        respawnLabel.horizontalAlignmentMode = .center
        respawnLabel.verticalAlignmentMode = .center
        respawnLabel.position = CGPoint(x: size.width / 2, y: centerY - 40)
        respawnLabel.zPosition = 151
        overlay.addChild(respawnLabel)

        addChild(overlay)
        respawnOverlay = overlay
        respawnCountdownLabel = countdownLabel
        respawnEndTime = CACurrentMediaTime() + duration
    }

    func hideRespawnCountdown() {
        respawnOverlay?.removeFromParent()
        respawnOverlay = nil
        respawnCountdownLabel = nil
        respawnEndTime = 0
    }
}
