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
    private var goAgainButton: SKShapeNode?
    var onGoAgainTapped: (() -> Void)?
    
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
    func showRoundEnd(winner: Int?, localPlayerIndex: Int, sceneSize: CGSize) {
        if let winner = winner {
            if winner == localPlayerIndex {
                statusLabel?.text = "You Win!"
            } else {
                statusLabel?.text = "Player \(winner + 1) Wins!"
            }
        } else {
            statusLabel?.text = "Draw!"
        }
        
        // Show "Go Again" button
        showGoAgainButton(in: sceneSize)
    }
    
    /// Show the "Go Again" button
    private func showGoAgainButton(in sceneSize: CGSize) {
        guard goAgainButton == nil else { return }
        
        let button = SKShapeNode(rect: CGRect(x: -100, y: -25, width: 200, height: 50), cornerRadius: 10)
        button.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 - 100)
        button.fillColor = .systemGreen
        button.strokeColor = .white
        button.lineWidth = 3
        button.alpha = 0.9
        button.name = "goAgainButton"
        
        let label = SKLabelNode(fontNamed: "Arial-BoldMT")
        label.text = "GO AGAIN"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        button.addChild(label)
        
        if let statusLabel = statusLabel, let scene = statusLabel.scene {
            scene.addChild(button)
        }
        
        goAgainButton = button
    }
    
    /// Hide the "Go Again" button
    func hideGoAgainButton() {
        goAgainButton?.removeFromParent()
        goAgainButton = nil
    }
    
    #if os(iOS) || os(tvOS)
    /// Check if a touch is within the "Go Again" button and handle it
    /// - Returns: true if touch was handled by button
    func handleTouch(at location: CGPoint) -> Bool {
        guard let button = goAgainButton else { return false }
        
        if button.contains(location) {
            onGoAgainTapped?()
            return true
        }
        
        return false
    }
    #endif
}
