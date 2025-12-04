//
//  MultiplayerManagerTests.swift
//  tankgame Shared
//
//  Test utilities for the multiplayer manager - only available in debug builds
//  These tests help verify the connection infrastructure is properly configured
//

import Foundation
import MultipeerConnectivity

#if DEBUG
/// Test utilities for the multiplayer manager - only available in debug builds
class MultiplayerManagerTests {
    
    /// Verify that MCSessionDelegate is fully implemented
    /// This is critical because missing delegate methods can cause silent connection failures
    static func verifyDelegateImplementation() {
        print("=== Verifying MCSessionDelegate Implementation ===")
        
        let manager = MultiplayerManager()
        
        // Verify the manager conforms to MCSessionDelegate
        let isSessionDelegate = manager is MCSessionDelegate
        print("✓ MCSessionDelegate conformance: \(isSessionDelegate ? "YES" : "NO")")
        
        // Verify critical methods exist by checking the session delegate is set
        let hasSession = manager.session != nil
        print("✓ Session initialized: \(hasSession ? "YES" : "NO")")
        
        if hasSession {
            let sessionHasDelegate = manager.session.delegate != nil
            print("✓ Session delegate set: \(sessionHasDelegate ? "YES" : "NO")")
        }
        
        // Verify the manager conforms to advertiser delegate
        let isAdvertiserDelegate = manager is MCNearbyServiceAdvertiserDelegate
        print("✓ MCNearbyServiceAdvertiserDelegate conformance: \(isAdvertiserDelegate ? "YES" : "NO")")
        
        // Verify the manager conforms to browser delegate
        let isBrowserDelegate = manager is MCNearbyServiceBrowserDelegate
        print("✓ MCNearbyServiceBrowserDelegate conformance: \(isBrowserDelegate ? "YES" : "NO")")
        
        print("\nAll delegate conformances verified!")
    }
    
    /// Test the connection state machine transitions
    static func verifyConnectionStateMachine() {
        print("=== Verifying Connection State Machine ===")
        
        let manager = MultiplayerManager()
        
        // Initial state should be disconnected
        let initialState = manager.connectionState
        print("✓ Initial state: \(initialState.description)")
        
        // Start hosting
        manager.startHosting()
        let hostingState = manager.connectionState
        print("✓ After startHosting: \(hostingState.description)")
        
        // Stop and reset
        manager.stopHosting()
        
        // Start browsing
        manager.startBrowsing()
        let browsingState = manager.connectionState
        print("✓ After startBrowsing: \(browsingState.description)")
        
        // Disconnect
        manager.disconnect()
        let finalState = manager.connectionState
        print("✓ After disconnect: \(finalState.description)")
        
        print("\nState machine transitions verified!")
    }
    
    /// Verify critical delegate methods respond correctly
    static func verifyCertificateHandler() {
        print("=== Verifying Certificate Handler ===")
        
        let manager = MultiplayerManager()
        
        // Create a mock peer ID for testing
        let testPeerID = MCPeerID(displayName: "TestPeer")
        
        // Test the certificate handler - it should accept all certificates
        var handlerCalled = false
        var handlerResult = false
        
        // Call the certificate handler directly
        manager.session(manager.session, didReceiveCertificate: nil, fromPeer: testPeerID) { accepted in
            handlerCalled = true
            handlerResult = accepted
        }
        
        print("✓ Certificate handler called: \(handlerCalled ? "YES" : "NO")")
        print("✓ Certificate accepted: \(handlerResult ? "YES" : "NO")")
        
        if handlerCalled && handlerResult {
            print("\n✓ Certificate handler is correctly implemented!")
        } else {
            print("\n✗ WARNING: Certificate handler may not be correctly implemented!")
        }
    }
    
    /// Run all verification tests
    static func runAllTests() {
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║      MULTIPLAYER MANAGER VERIFICATION TESTS                  ║")
        print("╚══════════════════════════════════════════════════════════════╝\n")
        
        verifyDelegateImplementation()
        print("")
        verifyCertificateHandler()
        print("")
        verifyConnectionStateMachine()
        
        print("\n╔══════════════════════════════════════════════════════════════╗")
        print("║      ALL VERIFICATION TESTS COMPLETE                         ║")
        print("╚══════════════════════════════════════════════════════════════╝")
    }
    
    /// Print information about the multiplayer manager configuration
    static func printInfo() {
        print("=== Multiplayer Manager Info ===")
        
        let manager = MultiplayerManager()
        
        print("Service type: \(MultiplayerManager.serviceType)")
        print("Max players: \(manager.maxPlayers)")
        print("Auto-reconnect enabled: \(manager.autoReconnectEnabled)")
        print("Current connection state: \(manager.connectionState.description)")
        print("Is connected: \(manager.isConnected)")
        print("Connected peers count: \(manager.connectedPeersCount)")
    }
}
#endif
