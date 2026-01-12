//
//  GameViewControllerUI.swift
//  tankgame iOS
//
//  Consolidated UI handling: button events, UI updates, message handling, and table view
//

import UIKit
import MultipeerConnectivity

// MARK: - Button Handlers

extension GameViewController {

    func handleHostTapped() {
        isSinglePlayerMode = false
        multiplayerManager.isHost = true
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.singlePlayerButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.connectedPlayersView.isHidden = false
        lobbyUI.startGameButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Hosting game...\nWaiting for players to join (2-4 players)"
        updateConnectedPlayersUI()

        multiplayerManager.startHosting()
    }

    func handleJoinTapped() {
        isSinglePlayerMode = false
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.singlePlayerButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Searching for nearby games..."
        lobbyUI.peerTableView.isHidden = false
        updatePeerListUI()

        multiplayerManager.startBrowsing()
    }

    func handleSinglePlayerTapped() {
        isSinglePlayerMode = true
        lobbyUI.showSinglePlayerMode()
    }

    func handleCancelTapped() {
        isSinglePlayerMode = false
        multiplayerManager.stopHosting()
        multiplayerManager.stopBrowsing()
        multiplayerCoordinator.clearAll()
        lobbyUI.reset()
        lobbyUI.peerTableView.reloadData()
        multiplayerManager.isHost = false
    }

    func handleStartGameTapped() {
        if isSinglePlayerMode {
            // Start single player game with AI bots
            let botCount = lobbyUI.botCount
            let totalPlayers = 1 + botCount // Player + bots

            // Bot indices start from 1 (player is 0)
            var botIndices: [Int] = []
            for i in 1...botCount {
                botIndices.append(i)
            }

            startGameWithBots(playerCount: totalPlayers, localPlayerIndex: 0, botIndices: botIndices)
        } else {
            // Multiplayer mode
            let playerCount = multiplayerCoordinator.playerCount

            if playerCount < 2 {
                let alert = UIAlertController(
                    title: "Not Enough Players",
                    message: "You need at least 2 players to start the game.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }

            let playerAssignments = multiplayerCoordinator.assignPlayerIndices()
            startGame(playerCount: playerCount, localPlayerIndex: 0, playerAssignments: playerAssignments)
        }
    }
}

// MARK: - UI Updates

extension GameViewController {

    func updateUI() {
        lobbyUI.peerTableView.reloadData()
        updatePeerListUI()
        updateConnectedPlayersUI()
    }

    func updateConnectedPlayersUI() {
        let playerCount = multiplayerCoordinator.playerCount
        let playerNames = multiplayerCoordinator.getConnectedPlayerNames()
        let namesText = playerNames.enumerated().map { "P\($0.offset + 1): \($0.element)" }.joined(separator: "\n")
        lobbyUI.connectedPlayersLabel.text = "Connected Players (\(playerCount)/4):\n\n\(namesText)"

        if multiplayerManager.isHost {
            lobbyUI.startGameButton.isEnabled = playerCount >= 2
            lobbyUI.startGameButton.alpha = playerCount >= 2 ? 1.0 : 0.5
        }
    }

    func updatePeerListUI() {
        if multiplayerCoordinator.discoveredPeers.isEmpty {
            lobbyUI.peerTableView.isHidden = true
            lobbyUI.emptyStateLabel.isHidden = false
        } else {
            lobbyUI.peerTableView.isHidden = false
            lobbyUI.emptyStateLabel.isHidden = true
        }
    }
}

// MARK: - Message Handling

extension GameViewController {

    func handleGameMessage(_ message: GameMessage) {
        guard let state = gameState else { return }

        switch message {
        case .playerMove(let playerIndex, let row, let col, let direction):
            multiplayerManager.sendMessage(.playerMove(playerIndex: playerIndex, row: row, col: col, direction: direction))

        case .playerShoot(let playerIndex, let projectile):
            multiplayerManager.sendMessage(.playerShoot(playerIndex: playerIndex, projectile: projectile))

        case .readyForNextRound(let playerIndex):
            multiplayerCoordinator.markPlayerReady(playerIndex)
            checkAndStartNextRound()

        default:
            break
        }
    }
}

// MARK: - Table View

extension GameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multiplayerCoordinator.discoveredPeers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
        let peer = multiplayerCoordinator.discoveredPeers[indexPath.row]
        cell.textLabel?.text = "📱 \(peer.displayName)"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peer = multiplayerCoordinator.discoveredPeers[indexPath.row]
        multiplayerManager.invitePeer(peer)
        lobbyUI.statusLabel.text = "Connecting to \(peer.displayName)..."
        lobbyUI.activityIndicator.startAnimating()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
