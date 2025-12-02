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
    private var statsLabel: SKLabelNode?
    
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
        
        // Create stats label (for detailed player statistics)
        let newStatsLabel = SKLabelNode(fontNamed: "Arial")
        newStatsLabel.fontSize = 12
        newStatsLabel.fontColor = .lightGray
        newStatsLabel.position = CGPoint(x: sceneSize.width / 2, y: 12)
        newStatsLabel.text = ""
        scene.addChild(newStatsLabel)
        statsLabel = newStatsLabel
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
    
    /// Update score display with animation when score changes
    func updateScoreAnimated(wins: [Int], changedPlayerIndex: Int?) {
        updateScore(wins: wins)
        
        // Animate the score label on change
        if changedPlayerIndex != nil {
            animateScoreChange()
        }
    }
    
    /// Update player statistics display
    func updateStats(scoringEngine: ScoringEngine, localPlayerIndex: Int) {
        guard let stats = scoringEngine.getStats(for: localPlayerIndex) else {
            statsLabel?.text = ""
            return
        }
        
        var statsText = "K: \(stats.kills) D: \(stats.deaths)"
        if stats.currentStreak > 1 {
            statsText += " 🔥\(stats.currentStreak)"
        }
        if stats.bestStreak > 2 {
            statsText += " (Best: \(stats.bestStreak))"
        }
        statsLabel?.text = statsText
    }
    
    /// Animate the score label to draw attention
    private func animateScoreChange() {
        guard let label = scoreLabel else { return }
        
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        label.run(pulse)
    }
    
    /// Show a floating score popup at a specific position
    func showScorePopup(text: String, at position: CGPoint, in scene: SKScene, color: SKColor = .white) {
        let popup = SKLabelNode(fontNamed: "Arial-BoldMT")
        popup.text = text
        popup.fontSize = 18
        popup.fontColor = color
        popup.position = position
        popup.zPosition = 100
        scene.addChild(popup)
        
        // Animate: float up and fade out
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        
        popup.run(SKAction.sequence([group, remove]))
    }
    
    /// Show a streak notification
    func showStreakNotification(streak: Int, in scene: SKScene) {
        guard streak > 2 else { return }
        
        let streakLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        streakLabel.text = "🔥 \(streak) KILL STREAK!"
        streakLabel.fontSize = 24
        streakLabel.fontColor = .orange
        streakLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 50)
        streakLabel.zPosition = 100
        scene.addChild(streakLabel)
        
        // Animate: scale up, pause, fade out
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        streakLabel.run(SKAction.sequence([scaleUp, wait, fadeOut, remove]))
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
