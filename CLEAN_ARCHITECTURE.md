# Tank Game - Clean Architecture Design

## Overview

This is a complete rewrite of the tank game using clean architecture principles, designed for 2-6 player Bluetooth multiplayer gameplay with simplicity and scalability in mind.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  (Views, ViewModels, View Controllers, UI Components)   │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│                   Application Layer                      │
│     (Use Cases, Game Coordinator, Session Manager)      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│                    Domain Layer                          │
│   (Entities, Value Objects, Domain Services, Rules)     │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│                Infrastructure Layer                      │
│  (Networking, Rendering, Audio, Persistence)            │
└─────────────────────────────────────────────────────────┘
```

## Core Design Principles

### 1. Dependency Inversion
- High-level modules don't depend on low-level modules
- Both depend on abstractions (protocols)
- Abstractions don't depend on details

### 2. Single Responsibility
- Each class/struct has one reason to change
- Focused, cohesive components

### 3. Open/Closed Principle
- Open for extension, closed for modification
- Use protocols and composition

### 4. Interface Segregation
- Clients shouldn't depend on interfaces they don't use
- Small, focused protocols

### 5. Entity-Component System
- Separate data from behavior
- Flexible composition of game objects

## Domain Layer (Core Business Logic)

### Entities
- **Tank**: Player-controlled tank with position, health, direction
- **Projectile**: Bullets fired by tanks
- **GameMap**: Grid-based map with walls and obstacles
- **Player**: Player identity and score
- **GameSession**: Complete game state

### Value Objects
- **Position**: Immutable (x, y) coordinate
- **Direction**: Enum for movement direction
- **Velocity**: Speed and direction vector
- **GridCell**: Map cell type (empty, wall, etc.)

### Domain Services
- **CollisionDetector**: Detects collisions between entities
- **MovementValidator**: Validates legal moves
- **GameRules**: Win conditions, scoring rules
- **MapGenerator**: Procedural map generation

### Repositories (Protocols)
- **GameSessionRepository**: Save/load game state
- **PlayerRepository**: Manage player data

## Application Layer (Use Cases)

### Use Cases
- **CreateGameSession**: Host a new game
- **JoinGameSession**: Join existing game
- **MovePlayer**: Move tank in direction
- **FireWeapon**: Shoot projectile
- **UpdateGameState**: Process game tick
- **HandleCollision**: Process collision events
- **DetermineWinner**: Check win conditions

### Coordinators
- **GameCoordinator**: Overall game flow management
- **NetworkCoordinator**: Multiplayer session coordination

## Infrastructure Layer

### Networking
- **BluetoothAdapter**: MultipeerConnectivity wrapper
- **MessageSerializer**: Encode/decode game messages
- **ConnectionManager**: Manage peer connections

### Rendering
- **GameRenderer**: Protocol for rendering
- **SpriteKitRenderer**: SpriteKit implementation
- **EntityRenderer**: Renders individual entities

### Audio
- **SoundPlayer**: Protocol for sound effects
- **AVAudioPlayer**: Implementation

## Key Patterns Used

### 1. Repository Pattern
Abstracts data access, allows swapping implementations

### 2. Command Pattern
Player actions encapsulated as commands for networking

### 3. Observer Pattern
Game state changes notify observers (UI, network, etc.)

### 4. State Machine
Game flow (Lobby → Playing → GameOver → Lobby)

### 5. Factory Pattern
Create entities and components

### 6. Dependency Injection
Components receive dependencies via initializers

## Multiplayer Architecture

### Peer-to-Peer Model
- 2-6 players via MultipeerConnectivity
- Host acts as authoritative server
- All game logic runs on host
- Clients send input, receive state updates

### Message Types
- **Input**: Player actions (move, fire)
- **StateUpdate**: Complete or delta game state
- **Event**: Important events (hit, death, etc.)
- **Control**: Session control (start, pause, end)

### Synchronization Strategy
- Host runs authoritative game loop
- Clients send input at ~60 FPS
- Host broadcasts state at ~30 FPS
- Client-side prediction for local player
- Server reconciliation for corrections

## Testing Strategy

### Unit Tests
- Domain entities (Tank, Projectile, etc.)
- Value objects (Position, Direction, etc.)
- Domain services (CollisionDetector, GameRules)
- Use cases (isolated with mocks)

### Integration Tests
- Game loop with multiple entities
- Collision detection system
- Map generation

### End-to-End Tests
- Complete gameplay scenarios
- Multiplayer sessions (simulated)

## File Organization

```
tankgame/
├── Domain/
│   ├── Entities/
│   │   ├── Tank.swift
│   │   ├── Projectile.swift
│   │   ├── GameMap.swift
│   │   ├── Player.swift
│   │   └── GameSession.swift
│   ├── ValueObjects/
│   │   ├── Position.swift
│   │   ├── Direction.swift
│   │   ├── Velocity.swift
│   │   └── GridCell.swift
│   ├── Services/
│   │   ├── CollisionDetector.swift
│   │   ├── MovementValidator.swift
│   │   ├── GameRules.swift
│   │   └── MapGenerator.swift
│   └── Repositories/
│       ├── GameSessionRepository.swift
│       └── PlayerRepository.swift
├── Application/
│   ├── UseCases/
│   │   ├── CreateGameSession.swift
│   │   ├── JoinGameSession.swift
│   │   ├── MovePlayer.swift
│   │   ├── FireWeapon.swift
│   │   └── UpdateGameState.swift
│   └── Coordinators/
│       ├── GameCoordinator.swift
│       └── NetworkCoordinator.swift
├── Infrastructure/
│   ├── Networking/
│   │   ├── BluetoothAdapter.swift
│   │   ├── MessageSerializer.swift
│   │   └── ConnectionManager.swift
│   ├── Rendering/
│   │   ├── GameRenderer.swift
│   │   ├── SpriteKitRenderer.swift
│   │   └── EntityRenderer.swift
│   └── Audio/
│       ├── SoundPlayer.swift
│       └── AVAudioPlayerAdapter.swift
└── Presentation/
    ├── ViewModels/
    │   ├── LobbyViewModel.swift
    │   └── GameViewModel.swift
    ├── Views/
    │   ├── LobbyView.swift
    │   └── GameView.swift
    └── Controllers/
        └── GameViewController.swift
```

## Benefits

### Simplicity
- Clear separation of concerns
- Easy to understand each layer
- Minimal dependencies between layers

### Scalability
- Easy to add new features (new entities, rules, etc.)
- Can swap implementations (rendering, networking)
- Support for 2-6 players with same architecture

### Testability
- Domain logic testable without UI/network
- Use cases testable with mocked repositories
- UI testable with mocked use cases

### Maintainability
- Changes localized to specific layers
- Clear boundaries prevent tight coupling
- Easy to refactor individual components
