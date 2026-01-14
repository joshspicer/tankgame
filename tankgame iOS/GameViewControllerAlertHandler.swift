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
}
