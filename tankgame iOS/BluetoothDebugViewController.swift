//
//  BluetoothDebugViewController.swift
//  tankgame iOS
//
//  Created by Copilot Agent
//

import UIKit
import MultipeerConnectivity

class BluetoothDebugViewController: UIViewController {
    
    private var multiplayerManager: MultiplayerManager
    private var updateTimer: Timer?
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let peerIDLabel = UILabel()
    private let sessionStateLabel = UILabel()
    private let connectedPeersLabel = UILabel()
    private let discoveredPeersLabel = UILabel()
    private let browsingStatusLabel = UILabel()
    private let advertisingStatusLabel = UILabel()
    
    private let refreshButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    
    init(multiplayerManager: MultiplayerManager) {
        self.multiplayerManager = multiplayerManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDebugInfo()
        
        // Auto-refresh every 2 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateDebugInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Title
        titleLabel.text = "🔧 Bluetooth Debug Info"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        
        // Peer ID
        peerIDLabel.text = "Peer ID: Loading..."
        peerIDLabel.font = .systemFont(ofSize: 14, weight: .medium)
        peerIDLabel.numberOfLines = 0
        
        // Session State
        sessionStateLabel.text = "Session State: Unknown"
        sessionStateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        sessionStateLabel.numberOfLines = 0
        
        // Connected Peers
        connectedPeersLabel.text = "Connected Peers: None"
        connectedPeersLabel.font = .systemFont(ofSize: 14, weight: .medium)
        connectedPeersLabel.numberOfLines = 0
        
        // Discovered Peers
        discoveredPeersLabel.text = "Discovered Peers: None"
        discoveredPeersLabel.font = .systemFont(ofSize: 14, weight: .medium)
        discoveredPeersLabel.numberOfLines = 0
        
        // Browsing Status
        browsingStatusLabel.text = "Browsing: Unknown"
        browsingStatusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        browsingStatusLabel.numberOfLines = 0
        
        // Advertising Status
        advertisingStatusLabel.text = "Advertising: Unknown"
        advertisingStatusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        advertisingStatusLabel.numberOfLines = 0
        
        // Refresh button
        refreshButton.setTitle("🔄 Refresh Now", for: .normal)
        refreshButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 12
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Close button
        closeButton.setTitle("✕ Close", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        closeButton.setTitleColor(.systemRed, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to stack view with cards
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(createSeparator())
        stackView.addArrangedSubview(createCard(with: peerIDLabel))
        stackView.addArrangedSubview(createCard(with: sessionStateLabel))
        stackView.addArrangedSubview(createCard(with: connectedPeersLabel))
        stackView.addArrangedSubview(createCard(with: discoveredPeersLabel))
        stackView.addArrangedSubview(createCard(with: browsingStatusLabel))
        stackView.addArrangedSubview(createCard(with: advertisingStatusLabel))
        stackView.addArrangedSubview(refreshButton)
        stackView.addArrangedSubview(closeButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createCard(with label: UILabel) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.separator.cgColor
        
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        
        return card
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    @objc private func refreshTapped() {
        updateDebugInfo()
        
        // Visual feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func updateDebugInfo() {
        let session = multiplayerManager.session
        
        // Peer ID
        let myPeerID = session?.myPeerID
        peerIDLabel.text = """
        📱 My Peer Info
        Display Name: \(myPeerID?.displayName ?? "Unknown")
        """
        
        // Session State
        let connectedCount = session?.connectedPeers.count ?? 0
        let stateEmoji = connectedCount > 0 ? "✅" : "⚪️"
        sessionStateLabel.text = """
        \(stateEmoji) Connection Status
        Connected Peers: \(connectedCount)
        Is Connected: \(multiplayerManager.isConnected ? "Yes" : "No")
        """
        
        // Connected Peers
        let connectedPeers = session?.connectedPeers ?? []
        if connectedPeers.isEmpty {
            connectedPeersLabel.text = """
            👥 Connected Peers
            None
            """
        } else {
            let peerNames = connectedPeers.map { "  • \($0.displayName)" }.joined(separator: "\n")
            connectedPeersLabel.text = """
            👥 Connected Peers (\(connectedPeers.count))
            \(peerNames)
            """
        }
        
        // Note: We can't directly check discovered peers or browsing/advertising status
        // from the MultiplayerManager without modifying it
        discoveredPeersLabel.text = """
        🔍 Discovery Info
        To see discovered peers, check the Join Game screen.
        """
        
        browsingStatusLabel.text = """
        📡 Browsing Status
        Check Join Game to browse for peers.
        """
        
        advertisingStatusLabel.text = """
        📢 Advertising Status
        Check Host Game to advertise.
        """
        
        // Get service type info
        let serviceType = MultiplayerManager.serviceType
        browsingStatusLabel.text = """
        📡 Service Info
        Service Type: \(serviceType)
        Protocol: MultipeerConnectivity (Bluetooth/WiFi)
        """
    }
}
