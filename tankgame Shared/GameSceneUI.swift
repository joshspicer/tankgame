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
    private var playAgainButton: SKShapeNode?
    private var playAgainLabel: SKLabelNode?

    var onPlayAgainTapped: (() -> Void)?

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
    }

    /// Show play again button
    func showPlayAgainButton(in scene: SKScene, sceneSize: CGSize) {
        hidePlayAgainButton()

        // Create button background
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        button.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 - 100)
        button.fillColor = .systemGreen
        button.strokeColor = .white
        button.lineWidth = 3
        button.name = "playAgainButton"
        scene.addChild(button)
        playAgainButton = button

        // Create button label
        let label = SKLabelNode(fontNamed: "Arial-BoldMT")
        label.text = "Play Again"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        button.addChild(label)
        playAgainLabel = label
    }

    /// Hide play again button
    func hidePlayAgainButton() {
        playAgainButton?.removeFromParent()
        playAgainButton = nil
        playAgainLabel = nil
    }

    /// Update status for waiting on other players
    func showWaitingForPlayers() {
        statusLabel?.text = "Waiting for other players..."
        hidePlayAgainButton()
    }

    /// Check if a touch is on the play again button
    func isPlayAgainButtonTouched(at location: CGPoint) -> Bool {
        guard let button = playAgainButton else { return false }
        return button.contains(location)
    }
}
