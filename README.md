# Tank Battle

A simple, fun multiplayer tank game using Bluetooth/WiFi peer-to-peer connectivity.

## Features

- **Multiplayer**: 2-4 players over Bluetooth/Local Network using MultipeerConnectivity
- **Procedural Maps**: Seeded random map generation for consistent gameplay
- **Simple Controls**: Joystick to move, button to fire
- **Beautiful Minimal Design**: Clean SpriteKit graphics

## Architecture

The game uses a clean, modular architecture with just 8 core files:

| File | Purpose |
|------|---------|
| `Tank.swift` | Tank entity (position, direction, movement) |
| `Projectile.swift` | Projectile entity with collision detection |
| `Map.swift` | Seeded procedural map generation |
| `Game.swift` | Game state management |
| `Network.swift` | MultipeerConnectivity wrapper |
| `Messages.swift` | Network message types |
| `GameScene.swift` | SpriteKit rendering and game loop |
| `GameViewController.swift` | Lobby UI and game presentation |

## How to Play

1. One player taps **Host Game** to create a session
2. Other players tap **Join Game** and select the host
3. When all players are connected, host taps **Start Game**
4. Use the joystick to move, fire button to shoot
5. Last tank standing wins the round!

## Requirements

- iOS 18.0+
- Xcode 26+

## Building

Open `tankgame.xcodeproj` and build the `tankgame iOS` target.

