//
//  TURNConnectionManager.swift
//  tankgame Shared
//
//  Manages TURN relay connections and fallback logic
//  Coordinates between direct MultipeerConnectivity and WebRTC with TURN
//

import Foundation
import MultipeerConnectivity

/// Connection attempt result
enum ConnectionAttemptResult {
    case success(transport: TransportType)
    case failed(error: Error)
    case timeout
}

/// TURN connection manager - handles fallback from direct to TURN-based connections
class TURNConnectionManager {
    // MARK: - Properties

    private var turnSettings: TURNSettings
    private var directConnectionTimer: Timer?
    private var connectionAttemptInProgress = false

    // Callbacks
    var onConnectionAttempt: ((TransportType) -> Void)?
    var onConnectionSuccess: ((TransportType) -> Void)?
    var onConnectionFailed: ((TransportType, Error) -> Void)?
    var onFallbackToTURN: (() -> Void)?

    // MARK: - Initialization

    init(settings: TURNSettings = .enabled) {
        self.turnSettings = settings
    }

    // MARK: - Configuration

    /// Update TURN settings
    func updateSettings(_ settings: TURNSettings) {
        self.turnSettings = settings
    }

    /// Check if TURN fallback is enabled
    var isTURNFallbackEnabled: Bool {
        return turnSettings.enableTURNFallback
    }

    /// Check if TURN servers are configured
    var hasTURNServers: Bool {
        return turnSettings.iceConfiguration.hasTURNServers
    }

    // MARK: - Connection Management

    /// Start connection attempt with fallback support
    /// - Parameters:
    ///   - primaryTransport: Primary transport to try first (usually MultipeerConnectivity)
    ///   - fallbackTransport: Fallback transport to use if primary fails (WebRTC with TURN)
    ///   - onPrimaryConnected: Callback when primary transport connects
    ///   - onFallbackConnected: Callback when fallback transport connects
    func startConnectionAttempt(
        primaryTransport: NetworkTransport,
        fallbackTransport: NetworkTransport?,
        onPrimaryConnected: @escaping () -> Void,
        onFallbackConnected: @escaping () -> Void
    ) {
        guard !connectionAttemptInProgress else { return }
        connectionAttemptInProgress = true

        // Start with primary transport
        onConnectionAttempt?(primaryTransport.transportType)

        // Start timeout timer for fallback if enabled
        if turnSettings.enableTURNFallback, let fallback = fallbackTransport {
            startFallbackTimer(
                timeout: turnSettings.directConnectionTimeout,
                primaryTransport: primaryTransport,
                fallbackTransport: fallback,
                onPrimaryConnected: onPrimaryConnected,
                onFallbackConnected: onFallbackConnected
            )
        }
    }

    /// Cancel any in-progress connection attempts
    func cancelConnectionAttempt() {
        cancelFallbackTimer()
        connectionAttemptInProgress = false
    }

    /// Notify that primary connection succeeded
    func notifyPrimaryConnectionSuccess() {
        cancelFallbackTimer()
        connectionAttemptInProgress = false
        onConnectionSuccess?(.multipeerConnectivity)
    }

    /// Notify that primary connection failed
    func notifyPrimaryConnectionFailed(error: Error) {
        onConnectionFailed?(.multipeerConnectivity, error)

        // Fallback timer will handle switching to TURN if enabled
    }

    /// Notify that fallback connection succeeded
    func notifyFallbackConnectionSuccess() {
        cancelFallbackTimer()
        connectionAttemptInProgress = false
        onConnectionSuccess?(.webRTC)
    }

    /// Notify that fallback connection failed
    func notifyFallbackConnectionFailed(error: Error) {
        cancelFallbackTimer()
        connectionAttemptInProgress = false
        onConnectionFailed?(.webRTC, error)
    }

    // MARK: - Private Methods

    private func startFallbackTimer(
        timeout: TimeInterval,
        primaryTransport: NetworkTransport,
        fallbackTransport: NetworkTransport,
        onPrimaryConnected: @escaping () -> Void,
        onFallbackConnected: @escaping () -> Void
    ) {
        cancelFallbackTimer()

        directConnectionTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            // Check if primary transport connected
            if primaryTransport.isConnected {
                onPrimaryConnected()
                self.notifyPrimaryConnectionSuccess()
                return
            }

            // Primary connection failed or timed out - try fallback
            print("Direct connection timed out after \(timeout)s, falling back to TURN...")
            self.onFallbackToTURN?()

            // Stop primary transport
            primaryTransport.stopBrowsing()
            primaryTransport.stopHosting()

            // Start fallback transport
            self.onConnectionAttempt?(fallbackTransport.transportType)
            fallbackTransport.startBrowsing()
        }
    }

    private func cancelFallbackTimer() {
        directConnectionTimer?.invalidate()
        directConnectionTimer = nil
    }

    // MARK: - Connection Type Recommendation

    /// Recommend connection type based on network conditions
    /// - Returns: Recommended transport type
    func recommendedTransportType() -> TransportType {
        // For now, always prefer direct connection first
        // In the future, could check network conditions and adjust
        return .multipeerConnectivity
    }

    /// Should use TURN based on failure count
    /// - Parameter failureCount: Number of consecutive direct connection failures
    /// - Returns: Whether to prefer TURN
    func shouldPreferTURN(failureCount: Int) -> Bool {
        // After 2 failed direct connections, prefer TURN if available
        return failureCount >= 2 && hasTURNServers
    }

    // MARK: - Statistics

    private var directConnectionAttempts = 0
    private var directConnectionSuccesses = 0
    private var turnConnectionAttempts = 0
    private var turnConnectionSuccesses = 0

    /// Record connection attempt statistics
    func recordConnectionAttempt(transport: TransportType, success: Bool) {
        switch transport {
        case .multipeerConnectivity:
            directConnectionAttempts += 1
            if success {
                directConnectionSuccesses += 1
            }
        case .webRTC:
            turnConnectionAttempts += 1
            if success {
                turnConnectionSuccesses += 1
            }
        }
    }

    /// Get connection statistics
    var statistics: ConnectionStatistics {
        return ConnectionStatistics(
            directAttempts: directConnectionAttempts,
            directSuccesses: directConnectionSuccesses,
            turnAttempts: turnConnectionAttempts,
            turnSuccesses: turnConnectionSuccesses
        )
    }

    /// Reset statistics
    func resetStatistics() {
        directConnectionAttempts = 0
        directConnectionSuccesses = 0
        turnConnectionAttempts = 0
        turnConnectionSuccesses = 0
    }
}

/// Connection statistics
struct ConnectionStatistics {
    let directAttempts: Int
    let directSuccesses: Int
    let turnAttempts: Int
    let turnSuccesses: Int

    var directSuccessRate: Double {
        guard directAttempts > 0 else { return 0 }
        return Double(directSuccesses) / Double(directAttempts)
    }

    var turnSuccessRate: Double {
        guard turnAttempts > 0 else { return 0 }
        return Double(turnSuccesses) / Double(turnAttempts)
    }
}
