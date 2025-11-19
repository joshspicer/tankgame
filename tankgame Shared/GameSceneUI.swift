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
    private var statisticsLabel: SKLabelNode?
    
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
        
        // Create statistics label (top-right corner)
        let newStatisticsLabel = SKLabelNode(fontNamed: "Arial")
        newStatisticsLabel.fontSize = 12
        newStatisticsLabel.position = CGPoint(x: sceneSize.width - 80, y: sceneSize.height - 40)
        newStatisticsLabel.horizontalAlignmentMode = .right
        newStatisticsLabel.verticalAlignmentMode = .top
        newStatisticsLabel.text = "Stats"
        newStatisticsLabel.alpha = 0.8
        scene.addChild(newStatisticsLabel)
        statisticsLabel = newStatisticsLabel
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
    
    /// Update statistics display for local player
    func updateStatistics(_ stats: PlayerStatistics) {
        let accuracyText = String(format: "%.0f%%", stats.accuracy)
        statisticsLabel?.text = """
        Shots: \(stats.shotsFired)
        Hits: \(stats.hits)
        Accuracy: \(accuracyText)
        Power-ups: \(stats.powerUpsCollected)
        """
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
}
