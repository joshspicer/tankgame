# Tank Game 🎮

A multiplayer ([Bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game with clean architecture and modern design patterns.

Built entirely with VS Code agent mode 🚀 - See the livestreams: ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## ✨ Features

- 🎮 **2-6 Player Multiplayer** via Bluetooth (MultipeerConnectivity)
- 🏗️ **Clean Architecture** with SOLID principles
- 📱 **iOS, tvOS, macOS** support
- 🎯 **Protocol-Oriented Design** for testability
- 🔄 **Real-time Synchronization** with host-authoritative model
- 🎨 **Modern UI** with SpriteKit rendering
- 🕹️ **Touch Controls** with virtual joystick

## 🏛️ Architecture

This project demonstrates clean software architecture with clear separation of concerns:

```
┌─────────────────────┐
│   Presentation      │  UI, Input, Rendering
├─────────────────────┤
│   Coordination      │  Game Logic + Network
├─────────────────────┤
│  Engine + Network   │  Business Logic
├─────────────────────┤
│   Domain Models     │  Pure Data & Rules
└─────────────────────┘
```

**Key Design Patterns:**
- Protocol-Oriented Programming
- Dependency Injection
- Event-Driven Architecture
- Value Objects & Entities
- Single Responsibility Principle

See [NEW_ARCHITECTURE.md](NEW_ARCHITECTURE.md) for detailed architecture documentation.

## 📁 Project Structure

```
tankgame Shared/
├── Core/           # Foundation types (Position, Direction, PlayerInfo)
├── Domain/         # Business entities (Tank, Projectile, GameBoard)
├── Engine/         # Game logic (TankGameEngine, BoardGenerator)
├── Network/        # Multiplayer (BluetoothNetworkManager)
└── Presentation/   # UI & Rendering (SpriteKit)

tankgame iOS/
└── NewGameViewController.swift  # Lobby & game flow
```

## 🚀 Getting Started

### Requirements
- Xcode 15+
- iOS 15+ / tvOS 15+ / macOS 12+
- Two devices or simulators for multiplayer testing

### Build & Run
1. Open `tankgame.xcodeproj` in Xcode
2. Select target: "tankgame iOS", "tankgame tvOS", or "tankgame macOS"
3. Build and run (⌘R)

### Testing Multiplayer
1. **Device A**: Launch app → Tap "Host Game"
2. **Device B**: Launch app → Tap "Join Game"
3. **Device A**: Once players are connected, tap "Start Game"
4. Play! Use the joystick to move, red button to fire

## 🎮 How to Play

- **Movement**: Use the left joystick to move your tank
- **Shooting**: Tap the FIRE button to shoot
- **Objective**: Destroy other tanks to score points
- **Rounds**: Each round ends when 1 or fewer tanks remain
- **Winner**: First to reach the target score wins

## 🧪 Code Quality

- **22 focused files** averaging ~200 lines each
- **Clean separation** of concerns across layers
- **Protocol-based** abstractions for testability
- **No massive files** - largest is ~350 lines
- **Well-documented** with comprehensive architecture guide

## 🔧 Technical Highlights

### Domain Layer
Pure business logic with no framework dependencies:
- `TankEntity`, `ProjectileEntity`: Game entities
- `GameBoard`: Grid management with procedural generation
- `GameStateModel`: Complete game state snapshots

### Engine Layer
Game logic and coordination:
- `TankGameEngine`: Core game loop, collision detection, scoring
- `BoardGenerator`: Procedural level generation with seeding
- `GameCoordinator`: Bridges engine and network layers

### Network Layer
Bluetooth multiplayer:
- `BluetoothNetworkManager`: MultipeerConnectivity wrapper
- `NetworkMessage`: Type-safe message protocol
- Host-authoritative synchronization model

### Presentation Layer
Rendering and input:
- `SpriteKitRenderer`: SpriteKit-based rendering
- `InputController`: Touch and joystick handling
- `TankGameScene`: Main game scene
- `NewGameViewController`: Lobby interface

## 📚 Documentation

- [NEW_ARCHITECTURE.md](NEW_ARCHITECTURE.md) - Comprehensive architecture guide
- [ARCHITECTURE.md](ARCHITECTURE.md) - Previous architecture reference
- [CRASH_REPORTING.md](CRASH_REPORTING.md) - Crash reporting system (deprecated)

## 🎯 Benefits of This Architecture

1. **Testability**: Pure domain logic can be unit tested
2. **Maintainability**: Clear organization, easy to locate code
3. **Scalability**: Add features without changing core
4. **Reusability**: Components work across platforms
5. **Parallel Development**: Multiple developers work simultaneously

## 🔮 Future Enhancements

With this architecture, these additions become straightforward:
- Single-player mode with AI bots
- Power-ups and special abilities
- Different game modes
- Replay system
- Online multiplayer
- 3D graphics

## 📜 License

See repository for license information.

## 🙏 Acknowledgments

Built with GitHub Copilot and VS Code agent mode. A showcase of AI-assisted software development with clean design principles.

