# Tank Game - Complete Rewrite Architecture

## Design Goals
1. **Minimal Code**: Reduce from 55 files to ~15 files
2. **Excellent Design Patterns**: MVVM, Coordinator, Repository, Observer
3. **Keep Core Feature**: 2-6 player Bluetooth multiplayer
4. **Remove Complexity**: No AI bots, lizards, crash reporting, reconnection logic

## Architecture Overview

### 1. **Networking Layer** (Repository Pattern)
- `NetworkRepository.swift` - Single source of truth for all networking
  - Wraps MultipeerConnectivity
  - Manages peer discovery, connection, messaging
  - Simple delegate callbacks

### 2. **Models** (Pure Data)
- `GameModels.swift` - All game data structures in one file
  - `Tank` - position, direction, alive state
  - `Bullet` - position, direction
  - `Grid` - simple 2D array
  - `GameMessage` - network protocol
  - `Player` - peer info

### 3. **Game Engine** (Business Logic)
- `GameEngine.swift` - Pure game logic
  - State management
  - Movement validation
  - Collision detection
  - Win conditions
  - No rendering, no networking

### 4. **View Models** (MVVM Pattern)
- `LobbyViewModel.swift` - Lobby state and actions
- `GameViewModel.swift` - Game state and actions

### 5. **Views** (SwiftUI + SpriteKit)
- `LobbyView.swift` - SwiftUI lobby UI
- `GameView.swift` - SwiftUI wrapper for SpriteKit
- `GameScene.swift` - SpriteKit rendering only

### 6. **Coordinator** (Navigation)
- `AppCoordinator.swift` - Navigation between lobby and game

## File Structure (15 files total)

```
tankgame/
├── App/
│   ├── TankGameApp.swift (SwiftUI App entry)
│   └── AppCoordinator.swift (Navigation)
├── Networking/
│   └── NetworkRepository.swift (MultipeerConnectivity wrapper)
├── Models/
│   └── GameModels.swift (All data structures)
├── Engine/
│   └── GameEngine.swift (Pure game logic)
├── ViewModels/
│   ├── LobbyViewModel.swift (Lobby logic)
│   └── GameViewModel.swift (Game logic)
└── Views/
    ├── LobbyView.swift (SwiftUI lobby)
    ├── GameView.swift (SwiftUI wrapper)
    └── GameScene.swift (SpriteKit scene)
```

## Removed Features
- AI bots
- Lizards/creatures
- Crash reporting
- Auto-reconnection
- Connection health monitoring
- Invitation retry
- Single player mode
- Multiple sprite modes
- Sound effects (can add back later if needed)
- Complex explosion effects

## Key Design Patterns

### 1. **Repository Pattern** (Networking)
Single interface for all network operations, hides MultipeerConnectivity complexity.

### 2. **MVVM** (UI Layer)
Views observe ViewModels, ViewModels don't know about Views.

### 3. **Observer Pattern** (State Updates)
Use Combine/Observable for reactive updates.

### 4. **Coordinator Pattern** (Navigation)
Centralized navigation logic, Views don't navigate directly.

### 5. **Pure Functions** (Game Engine)
Game logic is pure and testable, no side effects.

## Benefits
- **90% less code** (from 5,384 LOC to ~600 LOC)
- **Easy to test** (pure functions, dependency injection)
- **Easy to understand** (clear responsibilities)
- **Modern Swift** (SwiftUI, Combine, async/await if needed)
- **Maintainable** (each file has one clear purpose)
