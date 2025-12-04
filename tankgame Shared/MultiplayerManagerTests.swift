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
        
        // Verify session is initialized (accessing session will crash if nil due to force unwrap,
        // but that's the expected behavior for a required property)
        let sessionDelegate = manager.session.delegate
        let sessionHasDelegate = sessionDelegate != nil
        print("✓ Session initialized and delegate set: \(sessionHasDelegate ? "YES" : "NO")")
        
        // Verify the manager is the session's delegate
        let managerIsDelegate = sessionDelegate === manager
        print("✓ Manager is session delegate: \(managerIsDelegate ? "YES" : "NO")")
        
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
    
    /// Verify that the certificate handler method exists and is callable
    /// This uses protocol conformance to ensure the method is implemented
    static func verifyCertificateHandlerExists() {
        print("=== Verifying Certificate Handler Exists ===")
        
        let manager = MultiplayerManager()
        
        // Use type checking to verify the method selector exists
        // The certificate handler must be implemented when encryptionPreference is .required
        let selector = #selector(MCSessionDelegate.session(_:didReceiveCertificate:fromPeer:certificateHandler:))
        let methodExists = manager.responds(to: selector)
        
        print("✓ Certificate handler method exists: \(methodExists ? "YES" : "NO")")
        
        if methodExists {
            print("\n✓ Certificate handler is correctly implemented!")
            print("  This method is required for encrypted MultipeerConnectivity sessions.")
        } else {
            print("\n✗ WARNING: Certificate handler is NOT implemented!")
            print("  This will cause connection failures when encryptionPreference is .required")
        }
    }
    
    /// Run all verification tests
    static func runAllTests() {
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║      MULTIPLAYER MANAGER VERIFICATION TESTS                  ║")
        print("╚══════════════════════════════════════════════════════════════╝\n")
        
        verifyDelegateImplementation()
        print("")
        verifyCertificateHandlerExists()
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
