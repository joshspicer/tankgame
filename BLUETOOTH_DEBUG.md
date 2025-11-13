# Bluetooth Debug Page

## Overview
The Bluetooth Debug Page provides real-time diagnostics and connection information for the multiplayer functionality in Tank Game. It helps diagnose connection issues between devices.

## Accessing the Debug Page
1. Launch the Tank Game app
2. On the main lobby screen, tap the "🔧 Debug" button at the bottom of the screen
3. The debug page will open as a modal sheet

## Features

### Current Peer Information
- **Display Name**: Shows your device's name as it appears to other players
- **Peer ID**: The unique identifier used for MultipeerConnectivity

### Connection Status
- **Connected Peers Count**: Number of currently connected devices
- **Is Connected**: Boolean indicator of connection status
- **Connection state updates in real-time**

### Connected Peers List
- Shows all currently connected peer devices
- Displays each peer's display name
- Updates dynamically when connections change

### Service Information
- **Service Type**: The MultipeerConnectivity service identifier used for discovery
- **Protocol**: MultipeerConnectivity (uses Bluetooth and WiFi)

### Additional Features
- **Auto-Refresh**: The debug info automatically updates every 2 seconds
- **Manual Refresh**: Tap the "🔄 Refresh Now" button to update immediately
- **Visual Feedback**: Connection status is indicated with emoji indicators (✅ for connected, ⚪️ for disconnected)

## Use Cases

### Troubleshooting Connection Issues
If players can't connect to each other:
1. Open the debug page on both devices
2. Verify that both devices show valid Peer IDs
3. Check that the service type matches on both devices
4. On the hosting device, verify advertising is enabled
5. On the joining device, verify browsing is enabled

### Verifying Active Connections
To confirm a successful connection:
1. After connecting, open the debug page
2. Verify "Is Connected" shows "Yes"
3. Check that the connected peer appears in the "Connected Peers" list
4. The connected peer's display name should match the other device

### Network Diagnostics
The debug page helps identify:
- Peer discovery issues
- Connection drops
- Session state problems
- Multipeer connectivity configuration issues

## Technical Details

### Implementation
- The debug page is implemented in `BluetoothDebugViewController.swift`
- It displays information from the `MultiplayerManager` class
- Uses `MultipeerConnectivity` framework for peer-to-peer networking

### Data Sources
- Peer ID from `MCSession.myPeerID`
- Connected peers from `MCSession.connectedPeers`
- Connection state from `MultiplayerManager.isConnected`
- Service type from `MultiplayerManager.serviceType`

## Notes
- The debug page can be accessed at any time from the lobby
- Information updates automatically while the page is open
- The page does not interfere with game connectivity
- Closing the debug page returns you to the lobby
