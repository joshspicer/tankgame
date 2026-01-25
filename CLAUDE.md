# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development

This is a pure Xcode project (no external package managers). Use XcodeBuildMCP tools for building and testing.

**Targets:** `tankgame iOS`, `tankgame macOS`, `tankgame tvOS`

**Testing Multiplayer:** Launch two iOS simulators simultaneously via XcodeBuildMCP to test peer-to-peer networking.

## Architecture

Tank Battle is a multiplayer tank game using SpriteKit for rendering and MultipeerConnectivity for peer-to-peer networking (Bluetooth/WiFi).

### Core Layers

**Game Logic** (`tankgame Shared/`):
- `Game.swift` - Central state container: tank collection, scoring, round management
- `Tank.swift` - Player entity with grid position, direction, movement validation
- `Projectile.swift` - Projectile movement and collision detection
- `Map.swift` - Procedural 8x8 grid generation with seeded RNG for multiplayer sync

**Networking** (`tankgame Shared/`):
- `Network.swift` - MultipeerConnectivity wrapper handling peer discovery, sessions, message encoding
- `Messages.swift` - Network protocol with 6 message types (roundStart, move, shoot, hit, ready, etc.)

**Rendering** (`tankgame Shared/`):
- `GameScene.swift` - SpriteKit scene with joystick input, game loop (movement at 150ms, projectiles at 50ms)

**Platform UI** (`tankgame iOS/`, `tankgame macOS/`, `tankgame tvOS/`):
- `GameViewController.swift` - Lobby UI, network delegation, scene presentation
- `MenuBackgroundView.swift` - Animated 8-bit grid background (iOS)

### Multiplayer Synchronization

Maps use seeded random generation (Linear Congruential Generator) so all clients generate identical maps from the same seed. State changes broadcast via JSON-encoded GameMessage enum. Projectile collisions computed locally, hits broadcast to peers.

### Key Patterns

- Entity-component structure: game state (Game.swift) separate from rendering (GameScene.swift)
- Protocol-based network delegation between Network and GameViewController
- All network callbacks marshaled to main thread via DispatchQueue
- Shared code in `tankgame Shared/` before platform-specific implementations
- All network-transmitted types implement Codable

## Development Guidelines

**Modularity is critical:** When adding features, create NEW Swift files for specific functionality rather than expanding existing files. This prevents merge conflicts during parallel development.

**Avoid refactoring existing code** unless explicitly requested. Keep changes focused and additive.
