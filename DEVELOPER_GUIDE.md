# Tank Game - Developer Guide

## Clean Architecture Overview

This project follows clean architecture principles with clear separation between layers.

## Quick Start

### Building the Project

1. Open `tankgame.xcodeproj` in Xcode
2. Select "Tank Game" iOS scheme
3. Choose a simulator or device
4. Press ⌘R to build and run

### Testing Multiplayer

To test multiplayer, you need two simulators:

```bash
# In terminal 1 - Launch first simulator
open -a Simulator
# Select iPhone 15 Pro

# In terminal 2 - Launch second simulator
open -a Simulator
# Select iPhone 15 (different from first)
```

Then:
1. Run the app from Xcode on the first simulator
2. Use Xcode's device selector to switch to the second simulator
3. Run the app again (it will run on the second simulator)
4. On simulator 1: Tap "Host Game"
5. On simulator 2: Tap "Join Game"
6. On simulator 1: Tap "Start Game" when you see 2 players connected

## Architecture Layers

### Domain Layer (`tankgame Shared/Domain/`)

**Purpose**: Pure business logic with zero dependencies on frameworks.

- **Entities**: Core business objects (TankEntity, ProjectileEntity, etc.)
- **Value Objects**: Immutable values (Position, Direction, etc.)
- **Services**: Domain operations (CollisionService, GameRulesService, etc.)

**Rules**:
- No imports of UIKit, SpriteKit, or other frameworks
- Only Foundation imports allowed
- All logic should be pure and testable

### Application Layer (`tankgame Shared/Application/`)

**Purpose**: Use cases and application coordination.

- **Use Cases**: Application-specific business rules
  - `GameEngineUseCase`: Game loop, collision detection
  - `PlayerActionUseCase`: Handle player input
  - `CreateGameSessionUseCase`: Session management
- **Coordinators**: Orchestrate use cases
  - `GameCoordinator`: Main game flow coordinator

**Rules**:
- Depends on Domain layer only
- No framework dependencies (except Foundation)
- Orchestrates domain services and entities

### Infrastructure Layer (`tankgame Shared/Infrastructure/`)

**Purpose**: Implementation of external systems.

- **Networking**: Bluetooth multiplayer
  - `BluetoothNetworkAdapter`: MultipeerConnectivity wrapper
  - `NetworkMessage`: Network protocol
- **Rendering**: Visual presentation
  - `SpriteKitGameRenderer`: SpriteKit implementation

**Rules**:
- Implements protocols defined in Application layer
- Depends on frameworks (SpriteKit, MultipeerConnectivity)
- Provides concrete implementations

### Presentation Layer (`tankgame Shared/Presentation/` and `tankgame iOS/Presentation/`)

**Purpose**: User interface and interaction.

- `CleanGameScene`: SpriteKit scene
- `CleanGameViewController`: iOS view controller

**Rules**:
- Depends on Application and Infrastructure layers
- Contains UI logic only
- Delegates business logic to coordinators

## Key Design Patterns

### 1. Dependency Injection

Components receive dependencies through initializers:

```swift
let coordinator = GameCoordinator(
    createSessionUseCase: CreateGameSessionUseCase(),
    gameEngineUseCase: GameEngineUseCase(),
    playerActionUseCase: PlayerActionUseCase()
)
```

### 2. Protocol-Oriented Design

Use protocols for abstraction:

```swift
protocol NetworkAdapter: AnyObject {
    func broadcast(_ message: NetworkMessage) throws
    // ...
}

class BluetoothNetworkAdapter: NetworkAdapter {
    // Implementation
}
```

### 3. Value Objects

Use structs for immutable values:

```swift
struct Position: Equatable, Hashable, Codable {
    let row: Int
    let col: Int
    
    func moved(in direction: Direction) -> Position {
        // Returns new Position
    }
}
```

### 4. Result Type

Use Result for operations that can fail:

```swift
func createSession(...) -> Result<Void, GameSessionError> {
    // ...
}
```

## Adding Features

### Adding a New Entity

1. Create entity in `Domain/Entities/`
2. Add to `GameSessionEntity`
3. Create renderer in `Infrastructure/Rendering/`
4. Update `SpriteKitGameRenderer` to render it

Example:
```swift
// 1. Domain/Entities/PowerUpEntity.swift
struct PowerUpEntity: Codable {
    let id: UUID
    var position: Position
    let type: PowerUpType
}

// 2. Add to GameSessionEntity
var powerUps: [PowerUpEntity] = []

// 3. Infrastructure/Rendering/PowerUpRenderer.swift
// 4. Update SpriteKitGameRenderer.render()
```

### Adding a New Use Case

1. Create use case in `Application/UseCases/`
2. Inject into coordinator
3. Call from coordinator

Example:
```swift
// 1. Application/UseCases/CollectPowerUpUseCase.swift
final class CollectPowerUpUseCase {
    func execute(playerID: PlayerID, in session: inout GameSessionEntity) -> Bool {
        // Logic here
    }
}

// 2. Inject into GameCoordinator
init(collectPowerUp: CollectPowerUpUseCase = CollectPowerUpUseCase()) {
    self.collectPowerUp = collectPowerUp
}

// 3. Call from coordinator
func checkPowerUpCollisions() {
    collectPowerUp.execute(playerID: localPlayerID, in: &session)
}
```

### Adding Network Messages

1. Add case to `NetworkMessage` enum
2. Handle in `BluetoothNetworkAdapter`
3. Handle in view controller's network delegate

Example:
```swift
// 1. Infrastructure/Networking/NetworkMessage.swift
enum NetworkMessage: Codable {
    case powerUpCollected(playerID: PlayerID, powerUpID: UUID)
}

// 2. Already handled by Codable

// 3. CleanGameViewController network delegate
case .powerUpCollected(let playerID, let powerUpID):
    coordinator.handlePowerUpCollected(playerID, powerUpID)
```

## Testing

### Unit Testing Domain Layer

Domain layer is pure and easily testable:

```swift
func testTankMovement() {
    var tank = TankEntity(
        playerID: PlayerID(),
        position: Position(row: 5, col: 5),
        direction: .up
    )
    
    tank.moveForward()
    
    XCTAssertEqual(tank.position, Position(row: 4, col: 5))
}
```

### Testing Use Cases

Use cases can be tested with mock dependencies:

```swift
func testPlayerAction() {
    let useCase = PlayerActionUseCase()
    var session = createTestSession()
    
    let success = useCase.moveTank(
        playerID: testPlayerID,
        direction: .up,
        in: &session
    )
    
    XCTAssertTrue(success)
    XCTAssertEqual(session.tanks[0].position, expectedPosition)
}
```

## Code Style

### Naming Conventions

- **Entities**: `EntityName` + `Entity` suffix (e.g., `TankEntity`)
- **Value Objects**: Descriptive name (e.g., `Position`, `Direction`)
- **Use Cases**: Action + `UseCase` suffix (e.g., `CreateGameSessionUseCase`)
- **Services**: Purpose + `Service` suffix (e.g., `CollisionService`)

### File Organization

- One class/struct per file
- File name matches type name
- Group related files in folders

### Documentation

- Add doc comments for public APIs
- Explain "why" not "what"
- Include usage examples for complex APIs

## Performance Tips

### Game Loop Optimization

- Minimize object creation in update loop
- Use value types (structs) where possible
- Cache frequently accessed values
- Throttle network messages

### Collision Detection

- Use spatial partitioning for many entities
- Early exit when possible
- Check bounding boxes before detailed collision

### Networking

- Batch small messages
- Use delta updates instead of full state
- Compress data when possible

## Common Issues

### "Cannot find type 'PlayerID' in scope"

Make sure you're importing the correct module and the file is included in the target.

### "Thread 1: Fatal error: Unexpectedly found nil"

Check that dependencies are properly injected and scene is set up before use.

### Multiplayer not connecting

1. Check that both devices are on same network
2. Check Bluetooth/Local Network permissions in Settings
3. Check that service type matches in both apps

## Resources

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity)
- [SpriteKit](https://developer.apple.com/documentation/spritekit)

## Contributing

When adding new features:

1. Start with domain layer (entities, value objects)
2. Add use cases in application layer
3. Add infrastructure implementations
4. Update presentation layer
5. Add tests
6. Update documentation

Keep the dependency flow: Presentation → Application → Domain ← Infrastructure
