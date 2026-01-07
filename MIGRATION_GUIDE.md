# Migration from Old to New Architecture

## Overview

This document explains the transition from the old monolithic architecture to the new clean architecture implementation.

## Why the Rewrite?

The original codebase had several challenges:
- **Tight coupling** between UI, game logic, and networking
- **Hard to test** - business logic mixed with framework code
- **Hard to scale** - difficult to add features without breaking existing code
- **Mixed concerns** - single files handling multiple responsibilities

The new architecture addresses all of these issues.

## Key Differences

### File Organization

**Old:**
```
tankgame Shared/
├── GameScene.swift (291 lines - everything!)
├── GameState.swift (190 lines - business logic)
├── Tank.swift, Projectile.swift (entities mixed with rendering)
└── Many helper files...
```

**New:**
```
tankgame Shared/
├── Domain/                    # Pure business logic
│   ├── Entities/              # Clean entities
│   ├── ValueObjects/          # Immutable values
│   └── Services/              # Domain operations
├── Application/               # Use cases
├── Infrastructure/            # External systems
└── Presentation/              # UI
```

### Dependency Flow

**Old:**
```
GameViewController → GameScene → Everything
     ↓                  ↓
NetworkManager    SpriteKit
     ↓                  ↓
GameState         Rendering
```
*Everything depends on everything*

**New:**
```
Presentation → Application → Domain
                    ↑
              Infrastructure
```
*Clear one-way dependency flow*

## Code Comparison

### Entity Definition

**Old (Tank.swift):**
```swift
struct Tank {
    var row: Int
    var col: Int
    var direction: Direction
    var isAlive: Bool
    
    // Mixed concerns - position is primitive types
    mutating func move(in direction: Direction) {
        // Direct manipulation
        switch direction {
        case .up: row -= 1
        case .down: row += 1
        // ...
        }
    }
}
```

**New (TankEntity.swift):**
```swift
struct TankEntity: Equatable, Codable {
    let id: UUID
    let playerID: PlayerID           // Type-safe ID
    var position: Position           // Value object
    var direction: Direction
    var health: Int
    var isAlive: Bool
    
    // Clear business rules
    func canFire(currentTime: TimeInterval) -> Bool {
        return isAlive && (currentTime - lastFireTime) >= fireRateDelay
    }
    
    mutating func moveForward() {
        position = position.moved(in: direction)  // Immutable operation
    }
}
```

### Game Logic

**Old (GameScene.swift):**
```swift
override func update(_ currentTime: TimeInterval) {
    // Everything mixed together
    updateProjectiles()
    checkCollisions()
    updateUI()
    sendNetworkUpdates()
    updateAI()
    // ...
}

private func updateProjectiles() {
    // Direct manipulation of arrays
    for i in projectiles.indices.reversed() {
        projectiles[i].advance()
        if projectiles[i].hits(wall) {
            projectiles.remove(at: i)
        }
    }
}
```

**New (GameEngineUseCase.swift):**
```swift
func updateGameState(_ session: inout GameSessionEntity, deltaTime: TimeInterval) {
    guard session.state == .playing else { return }
    
    updateProjectiles(&session)
    processCollisions(&session)
    
    if gameRules.isRoundOver(tanks: session.tanks) {
        session.endRound()
    }
}

private func processCollisions(_ session: inout GameSessionEntity) {
    // Use dedicated service
    let collisions = collisionService.findProjectileTankCollisions(
        projectiles: session.projectiles,
        tanks: session.tanks
    )
    // Clear separation of concerns
}
```

### Networking

**Old (MultiplayerManager.swift):**
```swift
func didReceive(_ data: Data, from peer: MCPeerID) {
    // Decode and directly manipulate game state
    if let message = decodeMessage(data) {
        switch message {
        case .move(let direction):
            gameState.localTank.direction = direction
            gameState.localTank.move()
        }
    }
}
```

**New (BluetoothNetworkAdapter.swift):**
```swift
func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    do {
        let message = try serializer.deserialize(data)
        delegate?.networkAdapter(self, didReceive: message, from: peerID.displayName)
    } catch {
        delegate?.networkAdapter(self, didFailWithError: error)
    }
}

// In GameCoordinator:
func handleRemoteMove(playerID: PlayerID, direction: Direction) -> Bool {
    guard var session = session else { return false }
    
    let success = playerActionUseCase.moveTank(
        playerID: playerID,
        direction: direction,
        in: &session
    )
    
    if success {
        self.session = session
        onSessionUpdated?(session)
    }
    
    return success
}
```

### View Controller

**Old (GameViewController.swift - 423 lines):**
```swift
class GameViewController: UIViewController {
    var gameScene: GameScene?
    var multiplayerManager: MultiplayerManager!
    var gameState: GameState?
    
    // Everything in one file
    func startGame() { /* ... */ }
    func handleMessage(_ message: GameMessage) { /* ... */ }
    func updateUI() { /* ... */ }
    func sendNetworkMessage() { /* ... */ }
    // ... 400+ more lines
}
```

**New (CleanGameViewController.swift - Clean separation):**
```swift
class CleanGameViewController: UIViewController {
    // Dependencies injected
    private var coordinator: GameCoordinator!
    private var networkAdapter: BluetoothNetworkAdapter!
    private var renderer: GameRenderer!
    
    // Single responsibility: UI management
    @objc private func startTapped() {
        startGame()
    }
    
    private func startGame() {
        let result = coordinator.createSession(
            players: connectedPlayers,
            localPlayerID: localPlayerID
        )
        
        switch result {
        case .success:
            _ = coordinator.startRound()
            showGameScene()
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
}
```

## Migration Path

If you have custom code in the old architecture, here's how to migrate:

### 1. Custom Entity

**Old:**
```swift
// In GameState.swift
struct Obstacle {
    var row: Int
    var col: Int
}
```

**New:**
```swift
// Create Domain/Entities/ObstacleEntity.swift
struct ObstacleEntity: Equatable, Codable {
    let id: UUID
    var position: Position
    
    init(id: UUID = UUID(), position: Position) {
        self.id = id
        self.position = position
    }
}

// Add to GameSessionEntity
var obstacles: [ObstacleEntity] = []
```

### 2. Custom Game Logic

**Old:**
```swift
// In GameScene.swift
func checkPowerUpCollision() {
    // Logic mixed with rendering
}
```

**New:**
```swift
// Create Application/UseCases/CollectPowerUpUseCase.swift
final class CollectPowerUpUseCase {
    func execute(playerID: PlayerID, in session: inout GameSessionEntity) -> Bool {
        // Pure business logic
    }
}

// Use in GameCoordinator
func checkPowerUpCollisions() {
    guard var session = session else { return }
    _ = collectPowerUpUseCase.execute(playerID: localPlayerID, in: &session)
    self.session = session
}
```

### 3. Custom Networking

**Old:**
```swift
// In MultiplayerManager.swift
func sendCustomMessage() {
    let data = // encode
    send(data)
}
```

**New:**
```swift
// Add to NetworkMessage enum
enum NetworkMessage: Codable {
    case customMessage(data: CustomData)
}

// Send via adapter
let message = NetworkMessage.customMessage(data: myData)
try? networkAdapter.broadcast(message)
```

## Benefits Realized

### Testability

**Old:** Hard to test without full app setup
```swift
// Need full GameScene, SpriteKit, etc.
```

**New:** Easy to test in isolation
```swift
func testCollision() {
    let service = CollisionService()
    let projectile = ProjectileEntity(...)
    let tank = TankEntity(...)
    
    let hit = service.projectileHitsTank(projectile, tank)
    XCTAssertTrue(hit)
}
```

### Extensibility

**Old:** Adding features requires modifying many files

**New:** Add feature by extending a layer
```swift
// Add new entity in Domain
// Add use case in Application
// Add renderer in Infrastructure
// Use in Presentation
```

### Maintainability

**Old:** One change can break multiple things

**New:** Changes isolated to specific layers
- Domain change? Only Application layer affected
- UI change? Only Presentation layer affected
- Network change? Only Infrastructure layer affected

## Backward Compatibility

The old code is kept in the repository for reference. The new architecture can coexist with the old code during a transition period.

To use old code:
- Keep old files
- Use `GameViewController` instead of `CleanGameViewController`
- Reference old architecture documentation

To use new code:
- Use `CleanGameViewController`
- Follow new architecture patterns
- Reference `CLEAN_ARCHITECTURE.md`

## Common Migration Issues

### Issue: "Where do I put this code?"

**Solution:** Follow the dependency rule:
- Pure logic → Domain layer
- Application flow → Application layer
- External system → Infrastructure layer
- UI → Presentation layer

### Issue: "How do I share state?"

**Solution:** Don't! Use immutable updates:
```swift
// Old: Direct mutation
gameState.tank.position = newPosition

// New: Immutable update
var session = currentSession
session.tanks[index].position = newPosition
self.session = session  // Trigger update
```

### Issue: "How do I handle networking?"

**Solution:** Use the adapter pattern:
```swift
// Define protocol
protocol NetworkAdapter {
    func send(_ message: NetworkMessage)
}

// Implement
class BluetoothAdapter: NetworkAdapter {
    func send(_ message: NetworkMessage) {
        // Implementation
    }
}

// Use via protocol
let adapter: NetworkAdapter = BluetoothAdapter()
adapter.send(message)
```

## Conclusion

The new architecture provides:
- ✅ Clear separation of concerns
- ✅ Testable business logic
- ✅ Flexible and extensible design
- ✅ Maintainable codebase
- ✅ Scalable to 2-6 players

While the rewrite required significant effort, the benefits in code quality, maintainability, and extensibility make it worthwhile for long-term development.

For questions or issues, see:
- [CLEAN_ARCHITECTURE.md](CLEAN_ARCHITECTURE.md) - Architecture design
- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - Development guide
- [CLEAN_IMPLEMENTATION_SUMMARY.md](CLEAN_IMPLEMENTATION_SUMMARY.md) - Implementation details
