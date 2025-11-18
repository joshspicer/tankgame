//
//  GameSceneUI.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages UI elements in the game scene (status and score labels)
final class GameSceneUI {
    // MARK: - Properties
    
    /// Label showing game status and messages
    private var statusLabel: SKLabelNode?
    
    /// Label showing player scores
    private var scoreLabel: SKLabelNode?
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Setup
    
    /// Sets up UI elements in the scene
    /// - Parameters:
    ///   - scene: Scene to add labels to
    ///   - sceneSize: Size of the scene for positioning
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
    
    // MARK: - Status Updates
    
    /// Updates the status label text
    /// - Parameter text: New status message to display
    func updateStatus(_ text: String) {
        statusLabel?.text = text
    }
    
    /// Updates the score label based on current wins
    /// - Parameter wins: Array of win counts for each player
    func updateScore(wins: [Int]) {
        if wins.count == 2 {
            scoreLabel?.text = "Score: \(wins[0]) - \(wins[1])"
        } else {
            // For 3-4 players, show all scores
            let scoreText = wins.enumerated().map { "P\($0.offset+1): \($0.element)" }.joined(separator: " | ")
            scoreLabel?.text = scoreText
        }
    }
    
    /// Shows the round end message with winner information
    /// - Parameters:
    ///   - winner: Player index of the winner, or nil for a draw
    ///   - localPlayerIndex: Index of the local player for personalized messages
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
}
