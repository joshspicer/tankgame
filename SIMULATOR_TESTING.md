# Testing Multiplayer on iOS Simulators

## Current Implementation

This tank game uses **MultipeerConnectivity** framework for peer-to-peer multiplayer gaming over Bluetooth and Wi-Fi. The implementation includes:

- `MultiplayerManager.swift`: Low-level MultipeerConnectivity wrapper
- `MultiplayerCoordinator.swift`: High-level session and player management
- Service type: "tankgame"
- Supports 2-4 players

## Simulator Limitations

**Important**: iOS Simulators have significant limitations when testing MultipeerConnectivity:

### What Doesn't Work on Simulators
- **Bluetooth discovery**: Simulators cannot discover peers via Bluetooth
- **Bonjour (mDNS)**: Limited or no support for local network service discovery
- **MultipeerConnectivity**: The framework relies on Bluetooth and Bonjour, neither of which work reliably on simulators

### Apple Documentation References
- [MultipeerConnectivity Framework](https://developer.apple.com/documentation/multipeerconnectivity)
- [MCNearbyServiceAdvertiser](https://developer.apple.com/documentation/multipeerconnectivity/mcnearbyserviceadvertiser) - Requires Bluetooth or Wi-Fi
- [MCNearbyServiceBrowser](https://developer.apple.com/documentation/multipeerconnectivity/mcnearbyservicebrowser) - Requires Bluetooth or Wi-Fi
- [Testing on Devices](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)

## Recommended Testing Approaches

### 1. Physical Devices (Recommended)
The most reliable way to test multiplayer functionality:

```bash
# Build and deploy to multiple physical devices
xcodebuild -scheme "tankgame iOS" \
  -destination 'platform=iOS,id=DEVICE_UDID_1' \
  build

xcodebuild -scheme "tankgame iOS" \
  -destination 'platform=iOS,id=DEVICE_UDID_2' \
  build
```

**Steps**:
1. Connect 2-4 iOS devices via USB or wireless debugging
2. Enable "Local Network" permission in Settings when prompted
3. Build and run on all devices
4. One device hosts, others join
5. Test gameplay, communication, and synchronization

### 2. Xcode Wireless Debugging
Test on multiple devices without physical connections:

1. Enable wireless debugging: Window → Devices and Simulators
2. Select each device and check "Connect via network"
3. Deploy to devices over Wi-Fi
4. Test multiplayer with devices on the same local network

### 3. Manual Peer Connection (Development Only)
For limited testing without peer discovery, you can manually connect peers using `MCSession`:

```swift
// In a test/debug build, manually create connections
let peerID = MCPeerID(displayName: "TestPeer")
let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)

// Manually invite a peer (requires both peers to know each other's IDs)
browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
```

**Limitations**: This still requires network connectivity and won't work reliably on simulators.

### 4. Mock Multiplayer Mode (Future Enhancement)
Consider implementing a mock mode for UI/logic testing:

```swift
#if DEBUG
class MockMultiplayerManager: MultiplayerManager {
    // Simulate multiplayer connections and messages
    // Useful for testing game logic without real networking
}
#endif
```

## Testing Checklist

When testing multiplayer functionality:

- [ ] Peer discovery (host advertises, clients browse)
- [ ] Connection establishment (invitation, acceptance)
- [ ] Message sending/receiving (game state synchronization)
- [ ] Disconnection handling (graceful and unexpected)
- [ ] Error scenarios (network loss, timeout)
- [ ] Multiple players (2, 3, and 4 player games)
- [ ] Round transitions (ready states, score synchronization)
- [ ] Game state consistency across all peers

## Known Issues with Simulator Testing

### Issue: "Cannot find peers"
**Cause**: Simulators don't support Bluetooth/Bonjour discovery
**Solution**: Use physical devices

### Issue: "Connection timeout"
**Cause**: Network services not available in simulator
**Solution**: Use physical devices or implement mock mode

### Issue: "Local Network permission not working"
**Cause**: Simulators have limited networking capabilities
**Solution**: Test permissions on physical devices

## Alternative: Network Link Conditioner

While you can't test peer discovery on simulators, you can test network conditions:

1. Install Additional Tools for Xcode
2. Open Network Link Conditioner
3. Select network profiles (3G, LTE, Wi-Fi, etc.)
4. Test how the game handles poor network conditions

This is useful for testing message reliability and timeout handling on physical devices.

## Future Improvements

### Potential Enhancements for Development
1. **Mock Mode**: Implement a fake multiplayer mode for UI testing
2. **Automated Tests**: Create unit tests for game logic without networking
3. **Integration with XCTest**: Test message serialization/deserialization
4. **Network Mocking**: Mock MCSession for isolated testing

### API Modernization
The current implementation uses modern, non-deprecated APIs:
- ✅ `MultipeerConnectivity` (current, active)
- ✅ `MCSession` with required encryption
- ✅ Async delegate callbacks on main queue
- ✅ Proper error handling

## Summary

**For real multiplayer testing**: Use physical iOS devices
**For UI testing**: Consider implementing a mock mode
**For logic testing**: Write unit tests that don't require networking

The iOS Simulator is excellent for many things, but peer-to-peer networking isn't one of them. This is a known platform limitation, not a bug in your code.
