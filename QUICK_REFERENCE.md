# Tank Game - Quick Reference

## Project Structure

```
tankgame/
├── tankgame Shared/          # Platform-agnostic code
│   ├── GameModels.swift      # All data structures
│   ├── GameEngine.swift      # Pure game logic
│   ├── GameSceneMinimal.swift # SpriteKit rendering
│   └── NetworkRepository.swift # Multiplayer networking
│
└── tankgame iOS/             # iOS-specific code
    ├── TankGameApp.swift     # App entry point
    ├── AppCoordinator.swift  # Navigation
    ├── LobbyViewModel.swift  # Lobby logic
    ├── LobbyView.swift       # Lobby UI
    ├── GameViewModel.swift   # Game logic
    └── GameView.swift        # Game UI
```

## Data Flow

### Starting a Game (Host)
1. User taps "Host Game" in `LobbyView`
2. `LobbyViewModel.hostGame()` calls `NetworkRepository.startHosting()`
3. Nearby devices discover the host
4. Clients tap "Join" and connect
5. Host taps "Start Game"
6. `LobbyViewModel.startGame()` creates `GameState` and notifies all clients
7. `AppCoordinator` transitions to game screen

### During Gameplay
1. User moves joystick in `GameSceneMinimal`
2. `GameSceneMinimal.onMove` callback to `GameViewModel.moveTank()`
3. `GameViewModel` calls `GameEngine.moveTank()`
4. `GameEngine` validates and updates state
5. `GameViewModel` sends `.move` message via `NetworkRepository`
6. All clients receive message and update their local state
7. `GameSceneMinimal.render()` updates visuals

### Network Messages
```swift
enum GameMessage {
    case startGame(seed, players)    // Host → All: Start game with grid seed
    case move(playerId, pos, dir)    // Any → All: Tank moved
    case shoot(playerId, bullet)     // Any → All: Bullet fired
    case hit(playerId)               // Any → All: Tank destroyed
    case roundEnd(winnerId)          // Host → All: Round over
}
```

## Key Classes

### GameEngine (Pure Logic)
- **Input**: Player actions (move, shoot)
- **Output**: Updated game state
- **No dependencies**: Completely testable
- **No side effects**: Pure functions only

### NetworkRepository (Networking)
- **Responsibilities**: Peer discovery, connection, messaging
- **Wraps**: MultipeerConnectivity
- **Pattern**: Repository with delegate callbacks
- **Thread-safe**: All callbacks on main thread

### GameState (Data)
```swift
struct GameState {
    var grid: Grid                    // 8x8 grid
    var tanks: [Tank]                 // All player tanks
    var bullets: [Bullet]             // Active bullets
    var scores: [String: Int]         // Player wins
    var localPlayerId: String         // This player
    var playerIds: [String]           // Player order
}
```

## Common Tasks

### Adding a Feature
1. **Model**: Add data structure to `GameModels.swift`
2. **Logic**: Add game logic to `GameEngine.swift`
3. **Network**: Add message to `GameMessage` enum (if needed)
4. **ViewModel**: Handle feature in ViewModels
5. **View**: Update UI in Views
6. **Rendering**: Update `GameSceneMinimal.swift` (if visual)

### Debugging
- **Print game state**: Access via `GameViewModel.gameState`
- **Network messages**: Add logs in `NetworkRepository` delegate methods
- **Game logic**: Test `GameEngine` functions in isolation
- **UI updates**: Use SwiftUI preview or print in ViewModels

### Testing
```swift
// Unit test GameEngine
func testMoveTank() {
    let state = GameState(
        grid: [[.empty, ...]],
        tanks: [Tank(...)],
        playerIds: ["player1"]
    )
    let engine = GameEngine(state: state)

    let moved = engine.moveTank(playerId: "player1", direction: .right)
    XCTAssertTrue(moved)
}

// Mock NetworkRepository
class MockRepo: NetworkRepository {
    var sentMessages: [GameMessage] = []
    override func send(message: GameMessage) {
        sentMessages.append(message)
    }
}
```

## Build & Run

### Requirements
- Xcode 15+
- iOS 17+ / macOS 14+
- Two iOS devices or simulators for multiplayer testing

### Run on Simulator
```bash
# Open project
open tankgame.xcodeproj

# Build for iOS
# Select Tank Game (iOS) scheme
# Run on iPhone simulator
```

### Test Multiplayer
1. Run first instance on iPhone 16 Pro simulator
2. Run second instance on iPhone 16 simulator
3. First device: Tap "Host Game"
4. Second device: Tap "Join Game" → Select host
5. First device: Tap "Start Game"
6. Play!

## Architecture Patterns

### MVVM
- **Model**: `GameModels.swift` - Data structures
- **View**: SwiftUI views - UI only, no logic
- **ViewModel**: Business logic, state management

### Repository
- **Interface**: `NetworkRepository` protocol methods
- **Implementation**: MultipeerConnectivity wrapper
- **Benefit**: Easy to swap networking layer

### Coordinator
- **Navigation**: `AppCoordinator` owns navigation state
- **Benefit**: Views don't navigate, coordinator does

### Observer
- **Mechanism**: Combine framework (`@Published`)
- **Benefit**: Automatic UI updates on state changes

## Performance Tips

1. **Grid rendering**: Reuse SKNodes instead of recreating
2. **Network messages**: Use unreliable mode for frequent updates
3. **State updates**: Batch updates in single frame
4. **Memory**: Use value types (structs) where possible

## Common Issues

### "Peer not discovered"
- Ensure both devices on same network
- Check Bluetooth permissions
- Restart app on both devices

### "Game won't start"
- Ensure host has at least 1 connected peer
- Check network message encoding/decoding

### "Tanks not moving"
- Check `GameEngine.moveTank()` validation logic
- Ensure network messages being sent/received
- Debug with print statements in `GameViewModel`

## Next Steps

See `REWRITE_SUMMARY.md` for:
- Detailed metrics
- Design pattern explanations
- Feature comparison
- Future enhancement ideas
