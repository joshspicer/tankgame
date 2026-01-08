# Tank Game - Architecture Diagram

## Component Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│                    AppDelegate.swift                     │
│                    (Entry Point)                         │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              GameViewController.swift                    │
│              (iOS Coordinator)                           │
│  ┌────────────────┐  ┌──────────────┐                   │
│  │  Lobby UI      │  │  Game State  │                   │
│  │  - Host/Join   │  │  - Players   │                   │
│  │  - Player List │  │  - Local ID  │                   │
│  └────────────────┘  └──────────────┘                   │
└───────┬───────────────────────────────┬─────────────────┘
        │                               │
        ▼                               ▼
┌──────────────────┐          ┌──────────────────┐
│ NetworkManager   │          │   GameEngine     │
│                  │          │                  │
│ - Host/Join      │          │ - Game Logic     │
│ - Send/Receive   │          │ - Collision      │
│ - Auto-discover  │          │ - Win/Loss       │
│                  │          │                  │
│ Uses:            │          │ Uses:            │
│ ▼                │          │ ▼                │
│ NetworkMessage   │          │ Models           │
│   - playerMove   │          │   - Position     │
│   - playerShoot  │          │   - Direction    │
│   - gameState    │          │   - Player       │
│   - gameStart    │          │   - Projectile   │
│   - gameOver     │          │   - GameGrid     │
└──────────────────┘          └────────┬─────────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │   GameScene      │
                              │                  │
                              │ - Render Grid    │
                              │ - Render Players │
                              │ - Render Bullets │
                              │ - Input (Touch)  │
                              │   - Joystick     │
                              │   - Fire Button  │
                              └──────────────────┘
```

## Data Flow

### Game Start Flow
```
1. User taps "Host Game"
   └─> GameViewController.hostTapped()
       └─> NetworkManager.startHosting()
           └─> Advertises via MultipeerConnectivity

2. Other user taps "Join Game"  
   └─> GameViewController.joinTapped()
       └─> NetworkManager.startBrowsing()
           └─> Discovers and auto-connects to host

3. Host taps "Start Game"
   └─> GameViewController.startTapped()
       └─> Sends NetworkMessage.gameStart to all peers
       └─> GameViewController.startGame(playerIds)
           └─> GameEngine.startGame(playerIds)
           └─> Creates GameScene
           └─> Starts update timer
```

### Gameplay Flow (Host-Authoritative)
```
Player Input (Client):
  Touch Joystick/Fire
    ├─> GameScene.touchesMoved/touchesBegan
    │   ├─> onMove callback
    │   └─> onShoot callback
    └─> GameViewController receives callbacks
        └─> Sends NetworkMessage to host
            ├─> playerMove(id, direction)
            └─> playerShoot(id)

Host Processes:
  Receives NetworkMessage
    └─> GameViewController.didReceiveMessage
        └─> GameEngine.movePlayer() / shootProjectile()

Update Loop (Host Only):
  Timer (10x/second)
    └─> GameViewController.gameUpdate()
        ├─> GameEngine.update()
        │   ├─> Advance projectiles
        │   ├─> Check collisions
        │   └─> Update scores
        ├─> Send NetworkMessage.gameState to clients
        └─> GameScene.render*()
            ├─> renderPlayers()
            └─> renderProjectiles()

Clients Receive:
  NetworkMessage.gameState
    └─> GameViewController.didReceiveMessage
        └─> Update local GameEngine state
        └─> GameScene.render*()
```

## Module Dependencies

```
Core Models (No Dependencies)
  Position
  Direction
  Player
  Projectile
  GameGrid
      ↑
      │ uses
      │
  GameEngine
  (depends on: Core Models)
      ↑
      │ uses
      │
GameViewController
  ├─> GameEngine (game logic)
  ├─> NetworkManager (networking)
  └─> GameScene (rendering)
      
NetworkManager
  └─> NetworkMessage
```

## File Sizes

```
Position.swift          ~30 lines
Direction.swift         ~35 lines
Player.swift            ~55 lines
Projectile.swift        ~35 lines
GameGrid.swift          ~65 lines
GameEngine.swift       ~185 lines
NetworkMessage.swift    ~30 lines
NetworkManager.swift   ~200 lines
GameScene.swift        ~290 lines
GameViewController.swift ~350 lines
AppDelegate.swift       ~25 lines
─────────────────────────────────
TOTAL                 ~1300 lines
```

## Key Design Decisions

### 1. Host-Authoritative Architecture
**Why**: Prevents cheating, simpler synchronization
- Host runs the authoritative game engine
- Clients send inputs only
- Host broadcasts complete state

### 2. Codable for Network Messages
**Why**: Type-safe, automatic serialization
- No manual JSON parsing
- Compile-time safety
- Easy to extend

### 3. Pure Model Structs
**Why**: Value semantics, thread-safe
- Position, Direction, Player, Projectile are structs
- Immutable where possible
- Easy to copy and compare

### 4. Delegate Pattern for Networking
**Why**: Loose coupling, testable
- NetworkManagerDelegate protocol
- GameViewController implements delegate
- Easy to mock for testing

### 5. Single GameEngine Class
**Why**: Centralized game rules
- All game logic in one place
- Easy to understand flow
- Simple to test

## Comparison with Old Architecture

### Old (51 files, 5251 lines)
```
tankgame Shared/
  ├─ 39 Swift files (highly fragmented)
  │  ├─ AIBotManager.swift
  │  ├─ AIBotTank.swift
  │  ├─ ConnectionHealthMonitor.swift
  │  ├─ ReconnectionManager.swift
  │  ├─ InvitationRetryManager.swift
  │  ├─ ExplosionEffects.swift
  │  ├─ ExplosionHandler.swift
  │  ├─ TankRenderer.swift
  │  ├─ TankSpriteRenderer.swift
  │  ├─ ProjectileRenderer.swift
  │  ├─ LizardRenderer.swift
  │  └─ ... 28 more files
  │
tankgame iOS/
  └─ 12 Swift files (over-modularized)
     ├─ GameViewController.swift (93 lines)
     ├─ GameViewControllerButtonHandlers.swift
     ├─ GameViewControllerUIUpdates.swift
     ├─ GameViewControllerGameManagement.swift
     ├─ GameViewControllerMessageHandling.swift
     ├─ GameViewControllerMultiplayerDelegate.swift
     ├─ GameViewControllerNetworkMessageReceiver.swift
     └─ ... 5 more files

Issues:
❌ Too many files
❌ Hard to find functionality
❌ Complex dependencies
❌ Premature optimization
❌ Feature bloat (lizards, bots, dolphins, crash reporting)
```

### New (9 files, 2200 lines)
```
tankgame Shared/
  ├─ Position.swift (core model)
  ├─ Direction.swift (core model)
  ├─ Player.swift (core model)
  ├─ Projectile.swift (core model)
  ├─ GameGrid.swift (core model)
  ├─ GameEngine.swift (game logic)
  ├─ NetworkMessage.swift (protocol)
  ├─ NetworkManager.swift (networking)
  └─ GameScene.swift (rendering)
  
tankgame iOS/
  ├─ GameViewController.swift (coordinator)
  └─ AppDelegate.swift (entry)

Benefits:
✅ Clear structure
✅ Easy to navigate
✅ Simple dependencies
✅ Focus on core features
✅ Maintainable
```

## Summary

The new architecture achieves:
- **Simplicity**: Easy to understand at a glance
- **Scalability**: Easy to add features (2-6 players)
- **Maintainability**: Clear responsibilities
- **Testability**: Decoupled components
- **Performance**: Efficient state synchronization

All within just 9 files and ~2,200 lines of code! 🎉
