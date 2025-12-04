//
//  GameViewControllerTableView.swift
//  tankgame iOS
//
//  Table view delegate/datasource implementation extracted from GameViewController
//

import UIKit
import MultipeerConnectivity

/// Handles table view delegate and datasource for GameViewController
extension GameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = multiplayerCoordinator.discoveredPeers.count
        print("[GameViewController] tableView numberOfRows: \(count)")
        return count
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
        print("[GameViewController] User selected peer: \(peer.displayName) at index \(indexPath.row)")
        multiplayerManager.invitePeer(peer)
        lobbyUI.statusLabel.text = "Connecting to \(peer.displayName)..."
        lobbyUI.activityIndicator.startAnimating()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
