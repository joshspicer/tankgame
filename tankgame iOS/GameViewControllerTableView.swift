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
        if tableView === wifiLobbyUI?.wifiHostsTableView {
            return wifiCoordinator?.discoveredHosts.count ?? 0
        }
        return multiplayerCoordinator.discoveredPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === wifiLobbyUI?.wifiHostsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WiFiHostCell", for: indexPath)
            if let host = wifiCoordinator?.discoveredHosts[indexPath.row] {
                cell.textLabel?.text = "📶 \(host.name) (\(host.roomCode))"
            }
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
        let peer = multiplayerCoordinator.discoveredPeers[indexPath.row]
        cell.textLabel?.text = "📱 \(peer.displayName)"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView === wifiLobbyUI?.wifiHostsTableView {
            if let host = wifiCoordinator?.discoveredHosts[indexPath.row] {
                wifiMultiplayerManager?.joinHost(host)
                lobbyUI.statusLabel.text = "Connecting to \(host.name)..."
                lobbyUI.activityIndicator.startAnimating()
            }
            return
        }
        
        let peer = multiplayerCoordinator.discoveredPeers[indexPath.row]
        multiplayerManager.invitePeer(peer)
        lobbyUI.statusLabel.text = "Connecting to \(peer.displayName)..."
        lobbyUI.activityIndicator.startAnimating()
    }
}
