//
//  GameScene+Settings.swift
//  Tank Game
//
//  Settings modal and button for elder player.
//

import SpriteKit

extension GameScene {

    // MARK: - Settings Button

    func setupSettingsUI() {
        settingsButton?.removeFromParent()

        guard isLocalPlayerElder else {
            settingsButton = nil
            return
        }

        let gridWidth = CGFloat(currentGridSize) * tileSize
        let gridBottomY = size.height - gridWidth - 60
        let scoreY = gridBottomY - 25

        let button = SKNode()
        button.position = CGPoint(x: size.width - 30, y: scoreY)
        button.zPosition = 100
        button.name = "settings_button"

        let bg = SKShapeNode(circleOfRadius: 14)
        bg.fillColor = SKColor(white: 0.2, alpha: 0.4)
        bg.strokeColor = SKColor(white: 0.4, alpha: 0.3)
        bg.lineWidth = 1
        bg.name = "settings_button"
        button.addChild(bg)

        let gearLabel = SKLabelNode(text: "⚙")
        gearLabel.fontName = "AvenirNext-Medium"
        gearLabel.fontSize = 14
        gearLabel.fontColor = SKColor(white: 0.6, alpha: 0.6)
        gearLabel.horizontalAlignmentMode = .center
        gearLabel.verticalAlignmentMode = .center
        gearLabel.position = CGPoint(x: 0, y: -1)
        gearLabel.name = "settings_button"
        button.addChild(gearLabel)

        addChild(button)
        settingsButton = button
    }

    func updateSettingsUI() {
        setupSettingsUI()
        gridSizeLabel?.text = "\(currentGridSize)×\(currentGridSize)"
    }

    // MARK: - Settings Modal

    func showSettingsModal() {
        guard settingsModal == nil else { return }

        isSettingsModalVisible = true

        let modal = SKNode()
        modal.zPosition = 200

        let dimBg = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimBg.fillColor = SKColor(white: 0, alpha: 0.5)
        dimBg.strokeColor = .clear
        dimBg.name = "settings_modal_bg"
        modal.addChild(dimBg)

        let panelWidth: CGFloat = 240
        let panelHeight: CGFloat = 240
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 16)
        panel.fillColor = SKColor(white: 0.15, alpha: 0.95)
        panel.strokeColor = SKColor(white: 0.4, alpha: 1)
        panel.lineWidth = 2
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.name = "settings_modal_panel"
        modal.addChild(panel)

        let title = SKLabelNode(text: "SETTINGS")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 20
        title.fontColor = .white
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 90)
        panel.addChild(title)

        let gridLabel = SKLabelNode(text: "Grid Size")
        gridLabel.fontName = "AvenirNext-Medium"
        gridLabel.fontSize = 14
        gridLabel.fontColor = SKColor(white: 0.7, alpha: 1)
        gridLabel.horizontalAlignmentMode = .center
        gridLabel.verticalAlignmentMode = .center
        gridLabel.position = CGPoint(x: 0, y: 50)
        panel.addChild(gridLabel)

        let controlsY: CGFloat = 15

        let minusBtn = SKShapeNode(circleOfRadius: 20)
        minusBtn.fillColor = SKColor(white: 0.3, alpha: 1)
        minusBtn.strokeColor = SKColor(white: 0.5, alpha: 1)
        minusBtn.lineWidth = 2
        minusBtn.position = CGPoint(x: -60, y: controlsY)
        minusBtn.name = "settings_minus"
        panel.addChild(minusBtn)

        let minusLabel = SKLabelNode(text: "−")
        minusLabel.fontName = "AvenirNext-Bold"
        minusLabel.fontSize = 28
        minusLabel.fontColor = .white
        minusLabel.horizontalAlignmentMode = .center
        minusLabel.verticalAlignmentMode = .center
        minusLabel.position = CGPoint(x: 0, y: -2)
        minusBtn.addChild(minusLabel)

        let sizeLabel = SKLabelNode(text: "\(currentGridSize)×\(currentGridSize)")
        sizeLabel.fontName = "AvenirNext-Bold"
        sizeLabel.fontSize = 22
        sizeLabel.fontColor = .white
        sizeLabel.horizontalAlignmentMode = .center
        sizeLabel.verticalAlignmentMode = .center
        sizeLabel.position = CGPoint(x: 0, y: controlsY)
        panel.addChild(sizeLabel)
        gridSizeLabel = sizeLabel

        let plusBtn = SKShapeNode(circleOfRadius: 20)
        plusBtn.fillColor = SKColor(white: 0.3, alpha: 1)
        plusBtn.strokeColor = SKColor(white: 0.5, alpha: 1)
        plusBtn.lineWidth = 2
        plusBtn.position = CGPoint(x: 60, y: controlsY)
        plusBtn.name = "settings_plus"
        panel.addChild(plusBtn)

        let plusLabel = SKLabelNode(text: "+")
        plusLabel.fontName = "AvenirNext-Bold"
        plusLabel.fontSize = 28
        plusLabel.fontColor = .white
        plusLabel.horizontalAlignmentMode = .center
        plusLabel.verticalAlignmentMode = .center
        plusLabel.position = CGPoint(x: 0, y: -2)
        plusBtn.addChild(plusLabel)

        // AI Players section
        let aiLabel = SKLabelNode(text: "AI Players")
        aiLabel.fontName = "AvenirNext-Medium"
        aiLabel.fontSize = 14
        aiLabel.fontColor = SKColor(white: 0.7, alpha: 1)
        aiLabel.horizontalAlignmentMode = .center
        aiLabel.verticalAlignmentMode = .center
        aiLabel.position = CGPoint(x: 0, y: -35)
        panel.addChild(aiLabel)

        let aiButtonY: CGFloat = -70

        let addAIBtn = SKShapeNode(rectOf: CGSize(width: 100, height: 36), cornerRadius: 8)
        addAIBtn.fillColor = SKColor(white: 0.3, alpha: 1)
        addAIBtn.strokeColor = SKColor(white: 0.5, alpha: 1)
        addAIBtn.lineWidth = 2
        addAIBtn.position = CGPoint(x: 0, y: aiButtonY)
        addAIBtn.name = "settings_add_ai"
        panel.addChild(addAIBtn)

        let addAILabel = SKLabelNode(text: "Add AI")
        addAILabel.fontName = "AvenirNext-Bold"
        addAILabel.fontSize = 16
        addAILabel.fontColor = .white
        addAILabel.horizontalAlignmentMode = .center
        addAILabel.verticalAlignmentMode = .center
        addAILabel.position = CGPoint(x: 0, y: -1)
        addAIBtn.addChild(addAILabel)

        let closeBtn = SKShapeNode(circleOfRadius: 16)
        closeBtn.fillColor = SKColor(white: 0.25, alpha: 1)
        closeBtn.strokeColor = SKColor(white: 0.5, alpha: 1)
        closeBtn.lineWidth = 1
        closeBtn.position = CGPoint(x: panelWidth / 2 - 20, y: panelHeight / 2 - 20)
        closeBtn.name = "settings_close"
        panel.addChild(closeBtn)

        let closeLabel = SKLabelNode(text: "✕")
        closeLabel.fontName = "AvenirNext-Bold"
        closeLabel.fontSize = 16
        closeLabel.fontColor = .white
        closeLabel.horizontalAlignmentMode = .center
        closeLabel.verticalAlignmentMode = .center
        closeLabel.position = CGPoint(x: 0, y: -1)
        closeBtn.addChild(closeLabel)

        modal.alpha = 0
        addChild(modal)
        modal.run(SKAction.fadeIn(withDuration: 0.15))

        settingsModal = modal
    }

    func hideSettingsModal() {
        guard let modal = settingsModal else { return }

        isSettingsModalVisible = false

        modal.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.removeFromParent()
        ]))

        settingsModal = nil
        gridSizeLabel = nil
    }
}
