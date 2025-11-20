//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene (status and score labels)
class GameSceneUI {
    private var statusLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    private var menuButton: SKShapeNode?
    private var menuButtonLabel: SKLabelNode?
    private var pauseOverlay: SKNode?
    
    var onMenuTapped: (() -> Void)?
    var onResumeTapped: (() -> Void)?
    var onRestartTapped: (() -> Void)?
    var onQuitTapped: (() -> Void)?
    
    init() {}
    
    /// Setup UI elements
    func setup(in scene: SKScene, sceneSize: CGSize) {
        // Create status label
        let newStatusLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        newStatusLabel.fontSize = 20
        newStatusLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 50)
        newStatusLabel.text = "Waiting for game..."
        scene.addChild(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Create score label
        let newScoreLabel = SKLabelNode(fontNamed: "Arial")
        newScoreLabel.fontSize = 16
        newScoreLabel.position = CGPoint(x: sceneSize.width / 2, y: 30)
        newScoreLabel.text = "Score: 0 - 0"
        scene.addChild(newScoreLabel)
        scoreLabel = newScoreLabel
        
        // Create menu button (top right)
        let newMenuButton = SKShapeNode(circleOfRadius: 20)
        newMenuButton.position = CGPoint(x: sceneSize.width - 40, y: sceneSize.height - 40)
        newMenuButton.fillColor = .darkGray
        newMenuButton.strokeColor = .white
        newMenuButton.lineWidth = 2
        newMenuButton.name = "menuButton"
        scene.addChild(newMenuButton)
        menuButton = newMenuButton
        
        let newMenuButtonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        newMenuButtonLabel.fontSize = 14
        newMenuButtonLabel.text = "☰"
        newMenuButtonLabel.verticalAlignmentMode = .center
        newMenuButtonLabel.horizontalAlignmentMode = .center
        newMenuButton.addChild(newMenuButtonLabel)
        menuButtonLabel = newMenuButtonLabel
    }
    
    /// Update status text
    func updateStatus(_ text: String) {
        statusLabel?.text = text
    }
    
    /// Update score display
    func updateScore(wins: [Int]) {
        if wins.count == 2 {
            scoreLabel?.text = "Score: \(wins[0]) - \(wins[1])"
        } else {
            // For 3-4 players, show all scores
            let scoreText = wins.enumerated().map { "P\($0.offset+1): \($0.element)" }.joined(separator: " | ")
            scoreLabel?.text = scoreText
        }
    }
    
    /// Show round end message
    func showRoundEnd(winner: Int?, localPlayerIndex: Int) {
        if let winner = winner {
            if winner == localPlayerIndex {
                statusLabel?.text = "You Win!"
            } else {
                statusLabel?.text = "Player \(winner + 1) Wins!"
            }
        } else {
            statusLabel?.text = "Draw!"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel?.text = "Next round starting..."
        }
    }
    
    /// Show pause menu overlay
    func showPauseMenu(in scene: SKScene, sceneSize: CGSize) {
        // Remove existing overlay if any
        pauseOverlay?.removeFromParent()
        
        // Create semi-transparent background
        let overlay = SKNode()
        overlay.name = "pauseOverlay"
        overlay.zPosition = 1000
        
        let background = SKShapeNode(rectOf: sceneSize)
        background.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        background.fillColor = .black
        background.alpha = 0.7
        background.strokeColor = .clear
        overlay.addChild(background)
        
        // Create menu panel
        let panelWidth: CGFloat = 280
        let panelHeight: CGFloat = 250
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 10)
        panel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        panel.fillColor = .darkGray
        panel.strokeColor = .white
        panel.lineWidth = 2
        overlay.addChild(panel)
        
        // Title
        let title = SKLabelNode(fontNamed: "Arial-BoldMT")
        title.text = "PAUSED"
        title.fontSize = 24
        title.position = CGPoint(x: 0, y: 80)
        title.verticalAlignmentMode = .center
        panel.addChild(title)
        
        // Resume button
        let resumeButton = createMenuButton(text: "Resume Game", yOffset: 30, name: "resumeButton")
        panel.addChild(resumeButton)
        
        // Restart button
        let restartButton = createMenuButton(text: "Restart Match", yOffset: -20, name: "restartButton")
        panel.addChild(restartButton)
        
        // Quit button
        let quitButton = createMenuButton(text: "Return to Lobby", yOffset: -70, name: "quitButton")
        panel.addChild(quitButton)
        
        scene.addChild(overlay)
        pauseOverlay = overlay
    }
    
    /// Hide pause menu overlay
    func hidePauseMenu() {
        pauseOverlay?.removeFromParent()
        pauseOverlay = nil
    }
    
    /// Check if menu button was tapped
    func handleTouch(at location: CGPoint, in scene: SKScene) -> Bool {
        // Check if pause overlay is showing
        if pauseOverlay != nil {
            let nodes = scene.nodes(at: location)
            for node in nodes {
                if node.name == "resumeButton" {
                    onResumeTapped?()
                    return true
                } else if node.name == "restartButton" {
                    onRestartTapped?()
                    return true
                } else if node.name == "quitButton" {
                    onQuitTapped?()
                    return true
                }
            }
            // Clicking outside the menu counts as resume
            onResumeTapped?()
            return true
        }
        
        // Check if menu button was tapped
        if let button = menuButton, button.contains(location) {
            onMenuTapped?()
            return true
        }
        
        return false
    }
    
    /// Helper to create a menu button
    private func createMenuButton(text: String, yOffset: CGFloat, name: String) -> SKNode {
        let buttonWidth: CGFloat = 240
        let buttonHeight: CGFloat = 40
        
        let container = SKNode()
        container.name = name
        container.position = CGPoint(x: 0, y: yOffset)
        
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 5)
        button.fillColor = .gray
        button.strokeColor = .white
        button.lineWidth = 1
        container.addChild(button)
        
        let label = SKLabelNode(fontNamed: "Arial-BoldMT")
        label.text = text
        label.fontSize = 16
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)
        
        return container
    }
    
    /// Check if game is paused
    var isPaused: Bool {
        return pauseOverlay != nil
    }
}
