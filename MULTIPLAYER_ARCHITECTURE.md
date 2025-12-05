# Multiplayer Architecture

This document explains how multiplayer functionality works in the tankgame project, covering the architecture, data flow, and key components.

## Overview

Tank Game uses **Apple's MultipeerConnectivity framework** for peer-to-peer multiplayer functionality. This enables local network gameplay without requiring an external server. Players can host games or browse for nearby games, with automatic peer discovery and connection management.

### Key Features
- **Peer-to-peer networking** using MultipeerConnectivity
- **Host/Join model** with automatic peer discovery
- **Up to 4 players** in a single game session
- **Auto-reconnection** with exponential backoff
- **Connection health monitoring** for reliability
- **Cross-platform support** (iOS, macOS, tvOS)

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              GameViewController                              │
│  (iOS: GameViewController.swift + extensions)                               │
│  (macOS: GameViewController.swift)                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────┐        ┌─────────────────────────┐                │
│  │  LobbyUI            │        │  MultiplayerCoordinator │                │
│  │  - Host/Join UI     │        │  - Player management    │                │
│  │  - Peer list        │        │  - Index assignment     │                │
│  │  - Status display   │        │  - Ready tracking       │                │
│  └─────────────────────┘        └───────────┬─────────────┘                │
│                                             │                               │
│  ┌──────────────────────────────────────────┴─────────────────────────────┐│
│  │                         MultiplayerManager                             ││
│  │  - MCSession management                                                ││
│  │  - Peer discovery (advertise/browse)                                   ││
│  │  - Message encoding/sending                                            ││
│  │  - Delegate callbacks                                                  ││
│  └────────────┬───────────────────┬────────────────────┬─────────────────┘│
│               │                   │                    │                   │
│  ┌────────────┴────────┐ ┌───────┴───────────┐ ┌─────┴─────────────────┐ │
│  │ ReconnectionManager │ │InvitationRetry    │ │ConnectionHealthMonitor│ │
│  │ - Auto-reconnect    │ │Manager            │ │ - Periodic health     │ │
│  │ - Exponential       │ │ - Retry failed    │ │   checks              │ │
│  │   backoff           │ │   invitations     │ │ - Stale connection    │ │
│  │ - Max 5 attempts    │ │ - Max 3 attempts  │ │   detection           │ │
│  └─────────────────────┘ └───────────────────┘ └───────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MultipeerConnectivity Framework                       │
│  ┌─────────────────┐  ┌──────────────────────┐  ┌───────────────────────┐  │
│  │   MCSession     │  │MCNearbyServiceBrowser│  │MCNearbyServiceAdvertiser│ │
│  │   - Secure      │  │   - Find peers       │  │   - Announce presence  │ │
│  │   - Encrypted   │  │   - Auto-discovery   │  │   - Accept invitations │ │
│  └─────────────────┘  └──────────────────────┘  └───────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. MultiplayerManager (`tankgame Shared/MultiplayerManager.swift`)

The core networking component that wraps Apple's MultipeerConnectivity framework.

**Responsibilities:**
- Creates and manages `MCSession` for peer communication
- Handles peer discovery via `MCNearbyServiceBrowser` (joining)
- Advertises game availability via `MCNearbyServiceAdvertiser` (hosting)
- Encodes/decodes `GameMessage` objects for network transmission
- Manages connection state transitions
- Coordinates with reliability managers (reconnection, invitation retry, health monitoring)

**Key Methods:**
```swift
// Hosting a game
func startHosting()     // Begin advertising to nearby peers
func stopHosting()      // Stop advertising

// Joining a game  
func startBrowsing()    // Begin searching for hosts
func stopBrowsing()     // Stop searching
func invitePeer(_ peerID: MCPeerID)  // Send invitation to join

// Communication
func sendMessage(_ message: GameMessage, reliability: MessageReliability)

// Connection management
func disconnect()       // End session
func reset()           // Full reset for fresh start
```

**Message Reliability:**
- `.reliable` - For critical messages (hits, game state) - uses TCP-like delivery
- `.unreliable` - For frequent updates (position, movement) - uses UDP-like delivery

### 2. MultiplayerCoordinator (`tankgame iOS/MultiplayerCoordinator.swift`)

High-level game session coordinator that manages players and game flow.

**Responsibilities:**
- Tracks discovered and connected peers
- Assigns player indices for game start
- Manages round readiness state
- Provides player information to game logic

**Key Methods:**
```swift
// Peer management
func addDiscoveredPeer(_ peerID: MCPeerID)
func addConnectedPeer(_ peerID: MCPeerID)
func removeConnectedPeer(_ peerID: MCPeerID)

// Game coordination
func assignPlayerIndices() -> [String: Int]  // Maps peer names to indices
func getConnectedPlayerNames() -> [String]

// Round management
func markPlayerReady(_ playerIndex: Int)
func isAllPlayersReady(totalPlayers: Int) -> Bool
func resetReadyPlayers()
```

### 3. Connection Reliability Components

#### ReconnectionManager (`tankgame Shared/ReconnectionManager.swift`)

Handles automatic reconnection when connections are lost.

**Features:**
- Exponential backoff: delays start at 1s and double up to 30s max
- Maximum 5 reconnection attempts
- Tracks "known" peers (previously connected successfully)
- Only attempts reconnection to known peers

**Flow:**
1. Connection lost detected
2. Check if peer was previously connected (known)
3. Schedule reconnection with exponential backoff
4. Attempt to re-establish connection
5. Cancel on success or give up after max attempts

#### InvitationRetryManager (`tankgame Shared/InvitationRetryManager.swift`)

Handles retry logic for failed peer invitations.

**Features:**
- Maximum 3 invitation attempts
- 30-second timeout per invitation
- Automatic retry after timeout
- Callbacks for success/failure

#### ConnectionHealthMonitor (`tankgame Shared/ConnectionHealthMonitor.swift`)

Monitors connection health through periodic checks.

**Features:**
- 5-second ping interval
- 15-second timeout threshold
- Tracks last response time per peer
- Notifies of stale connections

### 4. ConnectionState (`tankgame Shared/ConnectionState.swift`)

Enum representing connection states for UI feedback:

```swift
enum ConnectionState {
    case disconnected                          // No connection
    case browsing                              // Searching for games
    case advertising                           // Hosting, waiting for players
    case connecting(peerName: String)          // Connecting to specific peer
    case connected(peerCount: Int)             // Connected with N players
    case reconnecting(attempt: Int, maxAttempts: Int)  // Auto-reconnecting
}
```

### 5. GameMessages (`tankgame Shared/GameMessages.swift`)

Defines network message types for multiplayer communication:

```swift
enum GameMessage: Codable {
    case roundStart(seed: UInt32, playerCount: Int, hostPlayerIndex: Int, playerAssignments: [String: Int])
    case playerJoined(playerIndex: Int, peerName: String)
    case playerMove(playerIndex: Int, row: Int, col: Int, direction: Direction)
    case playerShoot(playerIndex: Int, projectile: Projectile)
    case playerHit(playerIndex: Int)
    case readyForNextRound(playerIndex: Int)
    case startGame  // Host signals game start
}
```

## Message Handling

### Outgoing Messages (`tankgame iOS/GameViewControllerMessageHandling.swift`)

The `handleGameMessage` function processes local game events and broadcasts them:

```swift
func handleGameMessage(_ message: GameMessage) {
    switch message {
    case .playerMove(let playerIndex, let row, let col, let direction):
        multiplayerManager.sendMessage(.playerMove(...))
        
    case .playerShoot(let playerIndex, let projectile):
        multiplayerManager.sendMessage(.playerShoot(...))
        
    case .readyForNextRound(let playerIndex):
        // Track readiness and check if round can start
    }
}
```

### Incoming Messages (`tankgame iOS/GameViewControllerNetworkMessageReceiver.swift`)

The `handleReceivedMessage` function processes messages from peers:

```swift
func handleReceivedMessage(_ message: GameMessage, from peerID: MCPeerID) {
    switch message {
    case .roundStart(let seed, let playerCount, let hostPlayerIndex, let playerAssignments):
        // Initialize or reset game with synchronized seed
        
    case .playerMove(let playerIndex, let row, let col, let direction):
        // Update remote player's tank position
        
    case .playerShoot(let playerIndex, let projectile):
        // Add remote player's projectile
        
    case .readyForNextRound(let playerIndex):
        // Track ready state for next round
    }
}
```

### Delegate Callbacks (`tankgame iOS/GameViewControllerMultiplayerDelegate.swift`)

`GameViewController` implements `MultiplayerManagerDelegate` to handle:
- `didFindPeer` - Update UI when new host discovered
- `didLosePeer` - Update UI when host disappears
- `didConnectToPeer` - Handle successful connection
- `didDisconnectFromPeer` - Handle disconnection
- `isConnectingToPeer` - Show connecting status
- `didReceiveMessage` - Route to message handler
- `didEncounterError` - Display error alerts
- `didChangeConnectionState` - Update UI state
- `isAttemptingReconnection` - Show reconnection progress

## Multiplayer Game Flow

### 1. Hosting a Game

```
1. User taps "Host Game"
2. MultiplayerManager.startHosting()
   └── MCNearbyServiceAdvertiser starts advertising
3. ConnectionState → .advertising
4. Wait for players to join
5. MCNearbyServiceAdvertiserDelegate receives invitation requests
   └── Auto-accept if room available (< maxPlayers)
6. MCSessionDelegate.didChange → .connected
7. MultiplayerCoordinator.addConnectedPeer()
8. UI shows connected players
9. Host taps "Start Game"
10. Host assigns player indices via MultiplayerCoordinator.assignPlayerIndices()
11. Host generates random seed
12. Host sends .roundStart message to all peers
13. All players initialize GameState with same seed → identical grids
```

### 2. Joining a Game

```
1. User taps "Join Game"
2. MultiplayerManager.startBrowsing()
   └── MCNearbyServiceBrowser starts searching
3. ConnectionState → .browsing
4. MCNearbyServiceBrowserDelegate.foundPeer()
5. MultiplayerCoordinator.addDiscoveredPeer()
6. UI shows available games
7. User taps on a game to join
8. MultiplayerManager.invitePeer()
   └── InvitationRetryManager tracks invitation
9. ConnectionState → .connecting(peerName)
10. MCSessionDelegate.didChange → .connected
11. Wait for host to send .roundStart
12. Initialize GameState with received seed
```

### 3. Gameplay Synchronization

```
Player Movement:
1. Local player moves via joystick
2. GameScene updates local tank position
3. GameScene calls onGameMessage(.playerMove(...))
4. GameViewController.handleGameMessage() sends to network
5. Remote peers receive in handleReceivedMessage()
6. Remote peers update tank position and re-render

Shooting:
1. Local player fires
2. GameScene creates Projectile
3. GameScene calls onGameMessage(.playerShoot(...))
4. Remote peers receive and add projectile to their state
5. Collision detection runs locally on each device

Round End:
1. All tanks destroyed except winner
2. Winner's device detects victory
3. Each player sends .readyForNextRound when ready
4. Host waits for all players ready
5. Host generates new seed and sends .roundStart
```

## Cross-Platform Support

The codebase is organized for maximum code reuse across platforms:

### Shared Code (`tankgame Shared/`)
- **MultiplayerManager.swift** - Core networking (shared)
- **GameMessages.swift** - Message definitions (shared)
- **ConnectionState.swift** - State enum (shared)
- **ReconnectionManager.swift** - Auto-reconnect (shared)
- **InvitationRetryManager.swift** - Invitation retry (shared)
- **ConnectionHealthMonitor.swift** - Health monitoring (shared)
- **GameState.swift** - Game logic (shared)
- **Tank.swift**, **Projectile.swift**, etc. - Game entities (shared)

### Platform-Specific Code (`tankgame iOS/`, `tankgame macOS/`)
- **GameViewController.swift** - Main view controller (platform-specific)
- **MultiplayerCoordinator.swift** - iOS-specific coordinator
- **LobbyUI.swift** - iOS lobby UI
- **PermissionManager.swift** - iOS permission handling

### Platform Differences

| Feature | iOS | macOS | tvOS |
|---------|-----|-------|------|
| Touch input | ✓ | - | - |
| Mouse input | - | ✓ | - |
| Remote input | - | - | ✓ |
| Local Network permission | Required | Not required | Not required |
| Bluetooth permission | Required | Not required | Not required |

## Server Component Clarification

**Important:** The `server/` directory contains a **crash reporting server**, not a multiplayer game server. 

The crash reporting server (`server/app.py`):
- Receives crash reports from the app
- Creates GitHub issues automatically
- Assigns issues to @copilot for investigation

Multiplayer functionality is entirely **peer-to-peer** using MultipeerConnectivity - no server is required for gameplay.

## Security Considerations

1. **Encryption**: `MCSession` is configured with `.required` encryption
2. **Certificates**: All certificates are accepted for local network play
3. **Persistent Peer IDs**: Peer IDs are persisted to UserDefaults for consistent identification
4. **Local Network Only**: MultipeerConnectivity only works on local networks

## Best Practices for Development

1. **Test with Two Simulators**: Use XCode to launch two simulator instances for multiplayer testing
2. **Handle All Connection States**: Always update UI based on ConnectionState changes
3. **Use Appropriate Reliability**: Use `.reliable` for game state, `.unreliable` for frequent updates
4. **Implement Reconnection**: Leverage ReconnectionManager for robust connections
5. **Monitor Connection Health**: Use ConnectionHealthMonitor to detect stale connections

## Related Files

| File | Location | Purpose |
|------|----------|---------|
| MultiplayerManager.swift | tankgame Shared/ | Core networking |
| MultiplayerCoordinator.swift | tankgame iOS/ | Session coordination |
| GameMessages.swift | tankgame Shared/ | Message definitions |
| ConnectionState.swift | tankgame Shared/ | State enum |
| ReconnectionManager.swift | tankgame Shared/ | Auto-reconnection |
| InvitationRetryManager.swift | tankgame Shared/ | Invitation retry |
| ConnectionHealthMonitor.swift | tankgame Shared/ | Health monitoring |
| GameViewControllerMultiplayerDelegate.swift | tankgame iOS/ | Delegate callbacks |
| GameViewControllerMessageHandling.swift | tankgame iOS/ | Outgoing messages |
| GameViewControllerNetworkMessageReceiver.swift | tankgame iOS/ | Incoming messages |
| LobbyUI.swift | tankgame iOS/ | Lobby interface |
| PermissionManager.swift | tankgame iOS/ | iOS permissions |

## Troubleshooting

### Connection Issues
- Ensure Local Network permission is granted (iOS)
- Ensure Bluetooth permission is granted (iOS)
- Check that devices are on same network
- Verify Wi-Fi is enabled

### Message Delivery Issues
- Critical messages should use `.reliable` mode
- Check for encoder/decoder errors in console
- Verify message types match on all clients

### Reconnection Issues
- Auto-reconnect only works for previously connected peers
- Check if max attempts (5) has been exceeded
- Verify both devices are still discoverable
