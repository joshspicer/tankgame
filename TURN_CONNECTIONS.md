# TURN Relay Connection System

This repository includes infrastructure for **TURN (Traversal Using Relays around NAT)** connections, enabling multiplayer gameplay through firewalls and restrictive network environments when direct peer-to-peer connections fail.

## Overview

By default, the game uses **MultipeerConnectivity** for local Bluetooth/WiFi Direct connections. The TURN infrastructure adds a fallback mechanism that can relay connections through TURN servers when direct connections are blocked by firewalls or NAT (Network Address Translation).

## How It Works

1. **Primary Connection**: The app attempts a direct connection using MultipeerConnectivity (Bluetooth/WiFi Direct).

2. **Timeout & Fallback**: If the direct connection fails or times out (default: 10 seconds), the system can fall back to WebRTC with TURN relay.

3. **TURN Relay**: When enabled, traffic is routed through a TURN server that acts as a relay between players who can't connect directly.

4. **Transparent Switching**: The connection method is abstracted through the `NetworkTransport` protocol, making the switch transparent to game code.

## Architecture

### Transport Abstraction Layer

The system uses a **transport abstraction** to support multiple connection methods:

```
NetworkTransport (Protocol)
    ├── MultipeerTransport (Bluetooth/WiFi Direct)
    └── WebRTCTransport (TURN/STUN relay) [Stub]
```

- **`NetworkTransport.swift`**: Protocol defining common interface for all transport types
- **`MultipeerTransport.swift`**: Adapter wrapping MCSession to conform to NetworkTransport
- **`WebRTCTransport.swift`**: Stub prepared for WebRTC SDK integration (requires GoogleWebRTC)

### TURN Configuration

- **`TURNConfiguration.swift`**: Defines ICE server configuration
  - `TURNServer`: TURN server URL, username, and credentials
  - `ICEServerConfiguration`: Combined STUN and TURN server configuration
  - `TURNSettings`: Global settings for TURN fallback behavior
  - `ConnectionTypePriority`: Priority settings for different connection types

### Connection Management

- **`TURNConnectionManager.swift`**: Orchestrates fallback from direct to TURN relay
  - Configurable timeout before fallback
  - Connection statistics tracking
  - Callbacks for connection events
  - Automatic retry logic

### MultiplayerManager Integration

The existing `MultiplayerManager.swift` has been extended with TURN support:

- `configureTURN(_:)`: Configure TURN settings
- `currentTURNSettings`: Get current TURN configuration
- `isTURNEnabled`: Check if TURN is enabled

## Components

### NetworkTransport Protocol

Located in `tankgame Shared/NetworkTransport.swift`, this protocol:
- Abstracts different transport mechanisms
- Provides uniform interface for:
  - Hosting and browsing
  - Peer discovery and invitation
  - Data transmission (reliable/unreliable)
  - Connection state management
- Enables switching between MultipeerConnectivity and WebRTC

### TURNConfiguration

Located in `tankgame Shared/TURNConfiguration.swift`, provides:
- **TURNServer**: Configuration for individual TURN servers
  ```swift
  TURNServer(
      urls: ["turn:turnserver.example.com:3478"],
      username: "user",
      credential: "password"
  )
  ```
- **ICEServerConfiguration**: Combined STUN/TURN configuration
  - Default configuration with public STUN servers
  - Custom configuration with TURN servers
- **TURNSettings**: Global settings
  - Enable/disable TURN fallback
  - Connection timeout before fallback
  - ICE configuration
  - Connection type priorities

### TURNConnectionManager

Located in `tankgame Shared/TURNConnectionManager.swift`, this class:
- Manages fallback from direct to TURN connections
- Monitors connection attempts with timeout
- Provides callbacks for connection events:
  - `onConnectionAttempt`: Called when attempting a connection type
  - `onConnectionSuccess`: Called when connection succeeds
  - `onConnectionFailed`: Called when connection fails
  - `onFallbackToTURN`: Called when falling back to TURN
- Tracks connection statistics per transport type
- Recommends optimal transport based on network conditions

### MultipeerTransport

Located in `tankgame Shared/MultipeerTransport.swift`, this adapter:
- Wraps existing MCSession functionality
- Conforms to NetworkTransport protocol
- Maintains backward compatibility with existing code
- Handles peer discovery and connection
- Manages data transmission

### WebRTCTransport (Stub)

Located in `tankgame Shared/WebRTCTransport.swift`, this stub:
- Implements NetworkTransport protocol structure
- Includes detailed implementation notes for WebRTC
- Requires WebRTC SDK (GoogleWebRTC) for full functionality
- Prepared for ICE server configuration with TURN

## Usage

### Basic Configuration (TURN Disabled)

By default, TURN is disabled and the app uses MultipeerConnectivity:

```swift
// TURN is disabled by default - no configuration needed
multiplayerManager.startBrowsing()
```

### Enable TURN with Default Settings

Use default configuration with public STUN servers:

```swift
let settings = TURNSettings.enabled
multiplayerManager.configureTURN(settings)
```

### Enable TURN with Custom Server

Configure a custom TURN server:

```swift
// Create TURN server configuration
let turnServer = TURNServer(
    urls: ["turn:turnserver.example.com:3478"],
    username: "gameuser",
    credential: "gamepass123"
)

// Create settings with custom server and timeout
let settings = TURNSettings.custom(turnServer: turnServer, timeout: 10.0)

// Configure MultiplayerManager
multiplayerManager.configureTURN(settings)

// Start browsing - will fallback to TURN if direct connection fails
multiplayerManager.startBrowsing()
```

### Multiple TURN Servers

Configure multiple TURN servers for redundancy:

```swift
let iceConfig = ICEServerConfiguration(
    stunServers: [
        "stun:stun.l.google.com:19302",
        "stun:stun1.l.google.com:19302"
    ],
    turnServers: [
        TURNServer(
            urls: ["turn:turn1.example.com:3478"],
            username: "user",
            credential: "pass"
        ),
        TURNServer(
            urls: ["turn:turn2.example.com:3478"],
            username: "user",
            credential: "pass"
        )
    ]
)

var settings = TURNSettings()
settings.enableTURNFallback = true
settings.iceConfiguration = iceConfig
settings.directConnectionTimeout = 15.0 // 15 second timeout

multiplayerManager.configureTURN(settings)
```

### Check TURN Status

```swift
// Check if TURN is enabled
if multiplayerManager.isTURNEnabled {
    print("TURN fallback is enabled")

    // Get current settings
    let settings = multiplayerManager.currentTURNSettings
    print("Timeout: \(settings.directConnectionTimeout)s")
    print("TURN servers: \(settings.iceConfiguration.turnServers.count)")
}
```

### Advanced: Connection Type Priorities

Adjust priorities for different connection types:

```swift
var settings = TURNSettings.enabled
settings.connectionTypePriority = ConnectionTypePriority(
    host: 126,              // Direct LAN (highest)
    serverReflexive: 100,   // STUN-based
    peerReflexive: 110,     // Peer-discovered
    relay: 80               // TURN relay (lower priority, fallback only)
)

multiplayerManager.configureTURN(settings)
```

For aggressive TURN usage (prefer relay for stability):

```swift
var settings = TURNSettings.enabled
settings.connectionTypePriority = .aggressiveTURN
multiplayerManager.configureTURN(settings)
```

## Current Implementation Status

### ✅ Implemented

- Transport abstraction layer (NetworkTransport protocol)
- MultipeerTransport adapter for existing functionality
- TURN configuration system with ICE servers
- TURNConnectionManager for fallback orchestration
- MultiplayerManager integration
- Connection statistics tracking
- Modular file structure per project guidelines

### 🚧 Requires Additional Setup

**WebRTC Integration**: The WebRTCTransport is currently a stub. To enable full WebRTC with TURN:

1. **Add WebRTC SDK** (via CocoaPods or Swift Package Manager):
   ```ruby
   # Podfile
   pod 'GoogleWebRTC'
   ```

2. **Implement RTCPeerConnection** in WebRTCTransport.swift:
   - Setup RTCPeerConnectionFactory with ICE servers
   - Create RTCPeerConnection with TURN configuration
   - Implement RTCDataChannel for game messages
   - Handle ICE candidate exchange

3. **Setup Signaling Server**:
   - WebRTC requires a signaling mechanism to exchange SDP offers/answers
   - Implement WebSocket or HTTP-based signaling
   - Exchange ICE candidates between peers

4. **Wire TURNConnectionManager Callbacks**:
   - Connect callbacks to switch between transports
   - Handle transport lifecycle

See detailed implementation notes in `WebRTCTransport.swift`.

## Setting Up a TURN Server

### Option 1: CoTURN (Open Source)

[CoTURN](https://github.com/coturn/coturn) is a popular open-source TURN server:

```bash
# Install CoTURN
sudo apt-get install coturn

# Basic configuration (/etc/turnserver.conf)
listening-port=3478
fingerprint
lt-cred-mech
user=gameuser:gamepass123
realm=example.com
```

### Option 2: Cloud TURN Services

Several providers offer managed TURN services:
- **Twilio TURN** (formerly Xirsys)
- **Metered TURN**
- **Open Relay Project**

### Option 3: Self-Hosted Docker

```yaml
# docker-compose.yml
version: '3'
services:
  coturn:
    image: coturn/coturn
    network_mode: host
    volumes:
      - ./turnserver.conf:/etc/coturn/turnserver.conf
    restart: unless-stopped
```

### Testing Your TURN Server

Use [Trickle ICE](https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/) to test your TURN server configuration.

## Configuration Best Practices

### Security

1. **Use Authentication**: Always configure TURN servers with username/credential
2. **HTTPS/TLS**: Use `turns:` (TURN over TLS) instead of `turn:` for encrypted relay
3. **Credential Rotation**: Regularly rotate TURN credentials
4. **Rate Limiting**: Configure rate limits on TURN server to prevent abuse

### Performance

1. **Geographic Distribution**: Deploy TURN servers in multiple regions close to players
2. **Fallback Order**: Configure multiple TURN servers for redundancy
3. **Connection Timeout**: Balance between quick fallback (lower timeout) and allowing time for direct connections (higher timeout)
4. **Prefer Direct**: Keep relay priority low to prefer direct connections when possible

### Example Production Configuration

```swift
let iceConfig = ICEServerConfiguration(
    stunServers: [
        "stun:stun.l.google.com:19302",
        "stun:stun1.l.google.com:19302"
    ],
    turnServers: [
        // Primary TURN server (US East)
        TURNServer(
            urls: [
                "turn:turn-us-east.example.com:3478",
                "turns:turn-us-east.example.com:5349"
            ],
            username: getUsername(),  // Time-limited credentials
            credential: getCredential()
        ),
        // Backup TURN server (EU West)
        TURNServer(
            urls: [
                "turn:turn-eu-west.example.com:3478",
                "turns:turn-eu-west.example.com:5349"
            ],
            username: getUsername(),
            credential: getCredential()
        )
    ]
)

var settings = TURNSettings()
settings.enableTURNFallback = true
settings.iceConfiguration = iceConfig
settings.directConnectionTimeout = 10.0

multiplayerManager.configureTURN(settings)
```

## Troubleshooting

### TURN Connection Fails

1. **Verify TURN server is running**: Test with Trickle ICE tool
2. **Check credentials**: Ensure username/password are correct
3. **Firewall rules**: Verify ports 3478 (UDP/TCP) and 5349 (TLS) are open
4. **Network restrictions**: Some corporate networks block TURN traffic

### Direct Connection Works But TURN Doesn't

- TURN fallback only triggers if direct connection fails or times out
- Increase `directConnectionTimeout` to allow more time for direct connection
- Check `multiplayerManager.isTURNEnabled` to verify TURN is configured

### WebRTC Not Working

- Verify WebRTC SDK is properly installed
- Check WebRTCTransport implementation is complete (not using stub)
- Ensure signaling server is running and accessible
- Review console logs for ICE candidate exchange errors

## Connection Statistics

The TURNConnectionManager tracks statistics for monitoring:

```swift
// Access connection statistics
let stats = turnConnectionManager.statistics

print("Direct connection attempts: \(stats.directAttempts)")
print("Direct connection success rate: \(stats.directSuccessRate * 100)%")
print("TURN connection attempts: \(stats.turnAttempts)")
print("TURN connection success rate: \(stats.turnSuccessRate * 100)%")

// Reset statistics
turnConnectionManager.resetStatistics()
```

Use these metrics to:
- Monitor connection success rates
- Determine if TURN is necessary for your player base
- Optimize timeout and fallback settings

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    MultiplayerManager                       │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         TURNConnectionManager (Fallback Logic)        │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│           ┌────────────────┴────────────────┐               │
│           ▼                                 ▼               │
│  ┌──────────────────┐            ┌──────────────────┐      │
│  │ MultipeerTransport│            │  WebRTCTransport │      │
│  │  (Primary/Direct) │            │  (Fallback/TURN) │      │
│  └──────────────────┘            └──────────────────┘      │
│           │                                 │               │
└───────────┼─────────────────────────────────┼───────────────┘
            │                                 │
            ▼                                 ▼
   ┌────────────────┐              ┌──────────────────┐
   │  MCSession     │              │ RTCPeerConnection│
   │  (Bluetooth/   │              │  (WebRTC with    │
   │   WiFi Direct) │              │   TURN relay)    │
   └────────────────┘              └──────────────────┘
            │                                 │
            ▼                                 ▼
       Direct P2P                      TURN Server Relay
```

## Future Enhancements

Possible improvements:

- **WebRTC Integration**: Complete WebRTC SDK integration for full TURN support
- **Automatic Server Selection**: Choose optimal TURN server based on latency
- **Connection Quality Monitoring**: Track packet loss, latency, and bandwidth
- **Adaptive Bitrate**: Adjust game data transmission based on connection quality
- **Connection Migration**: Seamlessly migrate between transport types during gameplay
- **NAT Type Detection**: Detect NAT type and recommend connection strategy
- **Signaling Server**: Implement robust signaling infrastructure for WebRTC

## References

- [TURN RFC 5766](https://tools.ietf.org/html/rfc5766)
- [ICE RFC 8445](https://tools.ietf.org/html/rfc8445)
- [WebRTC Documentation](https://webrtc.org/)
- [CoTURN Documentation](https://github.com/coturn/coturn/wiki)
- [Apple MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity)
