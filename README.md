A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Features

- 🎮 Multiplayer tank battles (2-4 players)
- 📡 Bluetooth connectivity via MultipeerConnectivity
- 🎨 Procedural level generation with seeded randomness
- 🏆 Win tracking and scoring
- 🎵 Sound effects for movement, shooting, hits, and victories
- 💥 Particle effects and explosions
- 📱 iOS, macOS, and tvOS support

## Architecture

The codebase is organized into focused, single-purpose files for improved maintainability:
- **Core Entities**: Tank, Projectile, Direction, GridCell
- **Game Logic**: GameState, GridGenerator
- **Rendering**: GameSceneRenderer, ExplosionEffects, GameSceneUI
- **Input**: JoystickController, FireButton
- **Audio**: SoundManager
- **Networking**: MultiplayerManager, MultiplayerCoordinator
- **UI**: LobbyUI, PermissionManager

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

## Testing

Comprehensive unit tests cover all core game components:
- 93+ unit tests across 5 test files
- Tests for Tank, Projectile, Direction, GridGenerator, and GameState
- Deterministic testing with seeded random generation
- Edge case coverage and integration tests

Run tests in Xcode with `⌘U` or see `tankgame Tests/README.md` for details.

## Development

Built with:
- Swift
- SpriteKit for game rendering
- MultipeerConnectivity for networking
- XCTest for unit testing
