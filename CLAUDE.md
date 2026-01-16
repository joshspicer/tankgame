# Tank Game - Project Context for Claude Code

## Project Overview
Tank Game is a multiplayer iOS/macOS tank battle game built with SpriteKit and Swift. Players connect via Bluetooth (MultipeerConnectivity) to battle in real-time on procedurally generated grids. The game supports both multiplayer and single-player modes with AI bots.

## Technology Stack
- **Language**: Swift
- **Framework**: SpriteKit (game engine)
- **Networking**: MultipeerConnectivity (Bluetooth peer-to-peer)
- **Platforms**: iOS, macOS, tvOS
- **Architecture**: Highly modular, 37+ focused single-purpose files

## Repository Structure

```
tankgame/
├── tankgame Shared/          # Cross-platform game logic (37+ files)
│   ├── Core Entities/        # Data models (Tank, Projectile, Direction, etc.)
│   ├── Game Logic/           # GameState, GridGenerator, CollisionDetection
│   ├── Rendering/            # Modular renderers (Grid, Tank, Projectile, Lizard)
│   ├── Input/                # JoystickController, GameSceneInputHandler
│   ├── Audio/                # SoundManager
│   ├── Networking/           # MultiplayerManager, MultiplayerCoordinator
│   ├── AI/                   # AIBotManager, AIBotTank
│   └── Game Coordination/    # GameScene, GameSceneUpdateLoop, GameSceneSetup
├── tankgame iOS/             # iOS-specific UI (11+ files)
│   ├── GameViewController    # Split across 7 extension files
│   ├── LobbyUI.swift         # Complete lobby interface
│   └── PermissionManager.swift
├── tankgame macOS/           # macOS-specific code
├── tankgame tvOS/            # tvOS-specific code
├── server/                   # Node.js crash reporting server
└── .github/
    ├── instructions/         # Claude Code instructions
    └── agents/              # Custom agent definitions
```

## Key Architecture Principles

### Modularity for Parallel Development
The codebase is designed to minimize merge conflicts when multiple AI agents work simultaneously:
- **37+ focused files** with single responsibilities
- **Average file size: ~70 lines** (max 154 lines)
- Each component is self-contained and loosely coupled
- Clear separation: rendering, logic, networking, UI, input

### Component Organization
1. **Core Game Entities**: Tank, Projectile, Lizard, Direction, GridCell
2. **Game Logic**: GameState, GridGenerator, LizardSpawner, CollisionDetection
3. **Rendering**: GameSceneRenderer delegates to specialized renderers (Grid, Tank, Projectile, Lizard)
4. **Input**: JoystickController, GameSceneInputHandler, FireButton
5. **Audio**: SoundManager
6. **Networking**: MultiplayerManager (low-level), MultiplayerCoordinator (high-level)
7. **UI**: LobbyUI, GameViewController (split into 7 extension files)
8. **AI**: AIBotManager, AIBotTank (for single-player mode)

## Development Guidelines

### Code Style
- **No emojis** in code unless explicitly requested
- **Minimal changes**: Only modify what's necessary for the task
- **Modular approach**: Create new files for new functionality to avoid merge conflicts
- **Don't refactor** existing code unless absolutely necessary
- **Extensions over modifications**: Prefer Swift extensions to keep files separate

### Testing & Building
- Use XCodeBuildMCP tools to launch two simulator instances for multiplayer testing
- Build targets: iOS, macOS, tvOS
- Crash reporting automatically creates GitHub issues (see CRASH_REPORTING.md)

### Common Tasks
- **Rendering changes**: Modify specific renderer files (TankRenderer, GridRenderer, etc.)
- **Game logic**: Update GameState, GameSceneUpdateLoop
- **Networking**: Modify MultiplayerManager or MultiplayerCoordinator
- **UI changes**: Update LobbyUI or GameViewController extensions
- **Input handling**: Modify JoystickController or GameSceneInputHandler
- **AI bots**: Update AIBotManager or AIBotTank

## Important Files

### Core Game Files
- `GameScene.swift` (154 lines) - Main game coordinator
- `GameState.swift` - Game state management (tanks, projectiles, scoring)
- `GameSceneUpdateLoop.swift` - Game loop (runs at 60 FPS)
- `GameSceneRenderer.swift` (64 lines) - Rendering coordinator

### Networking
- `MultiplayerManager.swift` - Low-level MultipeerConnectivity wrapper
- `MultiplayerCoordinator.swift` - High-level session and player management
- `ReconnectionManager.swift` - Auto-reconnection logic
- `ConnectionHealthMonitor.swift` - Connection health monitoring

### UI (iOS)
- `GameViewController.swift` (93 lines) - Main view controller
- Split across 7 extension files for maintainability:
  - ButtonHandlers, UIUpdates, GameManagement, MessageHandling
  - MultiplayerDelegate, NetworkMessageReceiver, TableView
- `LobbyUI.swift` - Complete lobby interface

### AI (Single Player)
- `AIBotManager.swift` - Manages AI bot lifecycle
- `AIBotTank.swift` - AI bot behavior and decision-making

### Crash Reporting
- `CrashReporter.swift` - Automatic GitHub issue creation on crashes
- See CRASH_REPORTING.md for details

## Documentation
- `README.md` - Basic project information
- `ARCHITECTURE.md` - Detailed architecture documentation
- `CRASH_REPORTING.md` - Crash reporting system details
- `MOVEMENT_IMPROVEMENTS.md` - Movement system documentation
- `MODULARIZATION_SUMMARY.md` - Refactoring history

## Build System
- Xcode project: `tankgame.xcodeproj`
- Info.plist files for each platform (iOS, macOS, tvOS)
- Assets in `tankgame Shared/Assets.xcassets`
- Sound files in `tankgame Shared/Sounds`

## Multiplayer Architecture
- Uses MultipeerConnectivity for peer-to-peer Bluetooth connections
- Host-client architecture (host runs game simulation)
- Network messages defined in `GameMessages.swift`
- Automatic reconnection and connection health monitoring
- Invitation retry logic for robust connections

## AI Bot System
- AI bots provide single-player experience
- Bots use pathfinding and decision trees
- Can be added/removed dynamically
- Bot difficulty can be adjusted

## Recent Major Changes
- Refactored from 2 monolithic files to 37+ focused files
- Added AI bot system for single-player mode
- Implemented automatic crash reporting
- Enhanced connection reliability with retry and health monitoring
- Modularized rendering system for parallel development

## Known Issues
- Issue #112: Crash when clients connect and host starts game
- See open issues at: https://github.com/joshspicer/tankgame/issues

## Tips for AI Assistants
1. **Read before editing**: Always read files before modifying them
2. **Stay focused**: Only change what's needed for the task
3. **Test multiplayer**: Use XCodeBuildMCP to launch two simulators
4. **Avoid breaking changes**: Maintain backward compatibility
5. **Use modularity**: Create new files instead of expanding existing ones
6. **Follow patterns**: Match existing code style and patterns
7. **Check dependencies**: Understand component relationships before changes
8. **Parallel-safe**: Multiple agents can work on different renderers/handlers simultaneously

## Contact
- Repository: https://github.com/joshspicer/tankgame
- Built with Claude Code (Anthropic's agentic coding CLI)
- See YouTube streams for development history (links in README.md)
