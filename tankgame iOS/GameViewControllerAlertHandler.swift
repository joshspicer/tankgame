//
//  GameViewControllerAlertHandler.swift
//  tankgame iOS
//
//  Alert presentation logic extracted from GameViewController
//

import UIKit

/// Handles alert presentation for GameViewController
extension GameViewController {

    func presentNotEnoughPlayersAlert() {
        let alert = UIAlertController(
            title: "Not Enough Players",
            message: "You need at least 2 players to start the game.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func presentConnectionLostAlert() {
        let alert = UIAlertController(
            title: "Connection Lost",
            message: "Unable to reconnect. Returning to lobby.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func presentMultiplayerErrorAlert(error: Error, onOpenSettings: @escaping () -> Void, onTryAgain: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Unable to Start Multiplayer",
            message: "Could not start multiplayer session. This is likely because:\n\n• Local Network permission was denied\n• Bluetooth permission was denied\n\nTo fix:\n1. Open Settings app\n2. Go to Privacy & Security → Local Network\n3. Find Tank Game and turn it ON\n4. Also check Bluetooth permissions\n5. Return here and try again\n\nTechnical error: \(error.localizedDescription)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            onOpenSettings()
        })

        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
            onTryAgain()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            onCancel()
        })

        present(alert, animated: true)
    }
}
