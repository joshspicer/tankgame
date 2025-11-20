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
    private var countdownLabel: SKLabelNode?
    
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
    
    /// Show countdown animation (3... 2... 1... GO!)
    func showCountdown(in scene: SKScene, completion: @escaping () -> Void) {
        // Create a large countdown label
        let countdown = SKLabelNode(fontNamed: "Arial-BoldMT")
        countdown.fontSize = 120
        countdown.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        countdown.zPosition = 100
        countdown.alpha = 0
        scene.addChild(countdown)
        countdownLabel = countdown
        
        // Hide status label during countdown
        statusLabel?.text = ""
        
        // Countdown sequence: 3... 2... 1... GO!
        let countdownTexts = ["3", "2", "1", "GO!"]
        var currentIndex = 0
        
        func showNext() {
            guard currentIndex < countdownTexts.count else {
                // Countdown complete
                countdown.removeFromParent()
                countdownLabel = nil
                completion()
                return
            }
            
            let text = countdownTexts[currentIndex]
            countdown.text = text
            countdown.alpha = 0
            countdown.setScale(0.5)
            
            // Animate in
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
            let wait = SKAction.wait(forDuration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            
            let sequence = SKAction.sequence([
                SKAction.group([fadeIn, scaleUp]),
                wait,
                fadeOut,
                SKAction.run {
                    currentIndex += 1
                    showNext()
                }
            ])
            
            countdown.run(sequence)
        }
        
        showNext()
    }
}
