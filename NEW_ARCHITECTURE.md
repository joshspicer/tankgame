# Tank Game - Fresh Architecture

A complete rewrite of the tank game using clean design patterns, SOLID principles, and scalable architecture.

## Architecture Overview

The codebase follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Input, Rendering)                │
│  - NewGameViewController                │
│  - TankGameScene                        │
│  - SpriteKitRenderer                    │
│  - InputController                      │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│      Coordination Layer                 │
│  (Game Logic + Network)                 │
│  - GameCoordinator                      │
└─────────────────────────────────────────┘
         ↓                    ↓
┌──────────────────┐   ┌──────────────────┐
│  Game Engine     │   │  Network Layer   │
│  - TankGameEngine│   │  - BluetoothMgr  │
│  - BoardGenerator│   │  - NetworkMsg    │
└──────────────────┘   └──────────────────┘
         ↓
┌─────────────────────────────────────────┐
│          Domain Models                  │
│  (Pure business logic)                  │
│  - TankEntity, ProjectileEntity         │
│  - GameBoard, Position, Direction       │
│  - GameStateModel, GameEvent            │
└─────────────────────────────────────────┘
```

## Key Design Patterns

### 1. **Protocol-Oriented Design**
- `GameEngine`: Defines game logic interface
- `NetworkManager`: Abstracts network communication
- `GameRenderer`: Separates rendering from logic

### 2. **Dependency Injection**
- Components receive dependencies through constructors
- Easy to test and swap implementations
- Example: `GameCoordinator(engine:networkManager:)`

### 3. **Event-Driven Architecture**
- Game engine emits events (`GameEvent`)
- Renderer listens and updates visuals
- Network layer broadcasts to peers

### 4. **Value Objects & Entities**
- `Position`, `Direction`: Immutable value objects
- `TankEntity`, `ProjectileEntity`: Mutable game entities
- `GameStateModel`: Complete game state snapshot

### 5. **Single Responsibility Principle**
- Each class has one clear purpose
- Small, focused files (average ~150 lines)
- Easy to understand and maintain

## Directory Structure

```
tankgame Shared/
├── Core/                      # Foundation types
│   ├── Position.swift         # Grid position value object
│   ├── DirectionEnum.swift    # Movement directions
│   └── PlayerInfo.swift       # Player metadata
├── Domain/                    # Business entities
│   ├── TankEntity.swift       # Tank state & behavior
│   ├── ProjectileEntity.swift # Projectile state
│   ├── CellType.swift         # Grid cell types
│   ├── GameBoard.swift        # Game board model
│   ├── GameStateModel.swift   # Complete game state
│   └── GameEvent.swift        # Game events
├── Engine/                    # Game logic
│   ├── GameEngine.swift       # Engine protocol
│   ├── TankGameEngine.swift   # Main implementation
│   ├── BoardGenerator.swift   # Procedural generation
│   └── GameCoordinator.swift  # Logic + Network coordinator
├── Network/                   # Multiplayer
│   ├── NetworkManager.swift   # Network protocol
│   ├── NetworkMessage.swift   # Message types
│   └── BluetoothNetworkManager.swift  # Bluetooth impl
└── Presentation/              # UI & Rendering
    ├── GameRenderer.swift     # Renderer protocol
    ├── SpriteKitRenderer.swift # SpriteKit implementation
    ├── InputController.swift   # Touch/joystick input
    └── TankGameScene.swift    # Main game scene

tankgame iOS/
├── NewGameViewController.swift # Lobby & game flow
└── AppDelegate.swift          # App entry point
```

## Component Responsibilities

### Core Layer
**Value objects and shared types**
- Pure data structures with no dependencies
- Immutable where possible
- Used throughout all layers

### Domain Layer
**Business entities and rules**
- Represents game concepts (tanks, projectiles, board)
- Contains game rules (collision, movement validation)
- No dependencies on UI or networking

### Engine Layer
**Game logic and coordination**
- `TankGameEngine`: Manages game state, applies rules, detects collisions
- `BoardGenerator`: Creates game boards procedurally
- `GameCoordinator`: Bridges engine and network layer

### Network Layer
**Multiplayer communication**
- `BluetoothNetworkManager`: Uses MultipeerConnectivity for local multiplayer
- `NetworkMessage`: Type-safe message protocol
- Supports 2-6 players dynamically

### Presentation Layer
**UI and rendering**
- `SpriteKitRenderer`: Renders game state using SpriteKit
- `InputController`: Handles touch input and joystick
- `TankGameScene`: Main SpriteKit scene
- `NewGameViewController`: Lobby and game flow

## Game Flow

### 1. Lobby Phase
```
Player taps "Host Game" or "Join Game"
  ↓
Bluetooth discovery starts
  ↓
Players connect
  ↓
Host taps "Start Game"
```

### 2. Game Phase
```
GameCoordinator creates engine & scene
  ↓
Host generates round seed
  ↓
All players receive seed
  ↓
Board generated identically on all devices
  ↓
Tanks spawn, game begins
  ↓
Players control tanks via touch input
  ↓
Engine updates: movement, projectiles, collisions
  ↓
Renderer displays updates
  ↓
Round ends when ≤1 tank remains
  ↓
Scores updated
  ↓
Repeat for next round
```

## Network Synchronization

### Authority Model
- **Host is authoritative** for game state
- **Clients predict locally** for responsiveness
- **Host broadcasts events** for synchronization

### Message Flow
```
Client: Player moves tank
  ↓
Client: Applies move locally (prediction)
  ↓
Client → Host: TankAction.move message
  ↓
Host: Validates and applies move
  ↓
Host → All: GameEvent.tankMoved
  ↓
Clients: Apply authoritative update
```

## Benefits of This Architecture

### 1. **Testability**
- Pure domain logic can be unit tested
- Mock implementations for protocols
- Test engine without networking or UI

### 2. **Maintainability**
- Clear file organization
- Small, focused classes
- Easy to locate functionality

### 3. **Scalability**
- Add new game modes without changing core
- Support different input methods (keyboard, gamepad)
- Easy to add new network transports

### 4. **Reusability**
- Domain models work across platforms
- Engine can be reused for different UIs
- Network layer is game-agnostic

### 5. **Parallel Development**
- Multiple developers can work simultaneously
- Clear boundaries minimize merge conflicts
- Easy to delegate work to AI agents

## Code Metrics

| Metric | Value |
|--------|-------|
| Total Swift files | 22 |
| Average file size | ~200 lines |
| Max file size | ~350 lines |
| Lines of code | ~4,400 |
| Protocol interfaces | 3 |
| Value objects | 5 |
| Domain entities | 6 |

## Design Principles Applied

1. **SOLID Principles**
   - Single Responsibility: Each class has one job
   - Open/Closed: Extend via protocols, not modification
   - Liskov Substitution: Protocol implementations are interchangeable
   - Interface Segregation: Focused protocol interfaces
   - Dependency Inversion: Depend on abstractions, not concretions

2. **Clean Architecture**
   - Dependency rule: Inner layers don't know about outer layers
   - Domain models have no framework dependencies
   - Business logic isolated from UI and infrastructure

3. **Protocol-Oriented Programming**
   - Protocols define contracts
   - Implementations are injected
   - Easy to mock for testing

## Multiplayer Support

- **Players**: 2-6 players
- **Connection**: Bluetooth/WiFi via MultipeerConnectivity
- **Discovery**: Automatic peer discovery
- **Reliability**: Critical messages sent reliably, positions sent unreliably
- **Synchronization**: Host-authoritative model

## Future Enhancements

With this architecture, these additions become easy:

- **Single-player mode**: Add AI bot engine implementation
- **Power-ups**: Extend `CellType` and `TankEntity`
- **Different game modes**: Implement new `GameEngine` subclass
- **Replay system**: Serialize `GameEvent` stream
- **Network play**: Implement `NetworkManager` for internet
- **Alternative rendering**: Implement `GameRenderer` for 3D

## Getting Started

### Build & Run
1. Open `tankgame.xcodeproj` in Xcode
2. Select "tankgame iOS" scheme
3. Run on two simulators or devices

### Testing Multiplayer
1. Launch app on Device A
2. Tap "Host Game"
3. Launch app on Device B
4. Tap "Join Game"
5. On Device A, tap "Start Game"

## License

See repository root for license information.
