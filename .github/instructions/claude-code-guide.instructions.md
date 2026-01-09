---
applyTo: '**'
description: "Comprehensive guide for working with this codebase using Claude Code"
---

# Claude Code Guidelines for TankGame

This document provides guidance for Claude Code when working with the TankGame codebase.

## Codebase Overview

TankGame is a multiplayer iOS game built with SpriteKit and MultipeerConnectivity. The codebase is highly modularized with 55+ Swift files, each with a single, focused responsibility.

### Project Structure

```
tankgame Shared/          # Cross-platform game logic (40+ files)
  ├── Game Entities        # Tank.swift, Projectile.swift, Lizard.swift
  ├── Game Logic           # GameState.swift, GridGenerator.swift
  ├── Rendering            # GameSceneRenderer.swift, TankRenderer.swift, etc.
  ├── Input                # JoystickController.swift, GameSceneInputHandler.swift
  ├── Audio                # SoundManager.swift
  ├── Networking           # MultiplayerManager.swift, ReconnectionManager.swift
  ├── AI                   # AIBotManager.swift, AIBotTank.swift
  └── Crash Reporting      # CrashReporter.swift

tankgame iOS/             # iOS-specific UI (12 files)
  ├── GameViewController.swift + 7 extension files
  ├── LobbyUI.swift
  ├── MultiplayerCoordinator.swift
  └── PermissionManager.swift

tankgame macOS/           # macOS-specific code
tankgame tvOS/            # tvOS-specific code
```

## File Size Guidelines

- **Largest acceptable file**: 300 lines
- **Target file size**: 100-150 lines
- **Current largest files**:
  - LobbyUI.swift (411 lines) - UI layout code
  - MultiplayerManager.swift (397 lines) - networking
  - CrashReporter.swift (265 lines) - error reporting
  - AIBotTank.swift (245 lines) - AI logic

## Working with This Codebase

### 1. Always Create New Files for New Functionality

When adding features, create NEW files rather than modifying existing ones when possible. This minimizes merge conflicts with other AI agents.

**Good**: Create `NewFeature.swift` for new functionality
**Bad**: Add 100 lines to existing `GameScene.swift`

### 2. File Organization Principles

Each file should have:
- **One clear responsibility** (rendering, input, networking, etc.)
- **A descriptive name** that indicates its purpose
- **Minimal dependencies** on other files
- **Clean public interfaces** with private implementation details

### 3. Extension Pattern for Large Classes

When a class grows large, use Swift extensions in separate files:

```swift
// GameViewController.swift - Core setup
class GameViewController: UIViewController { ... }

// GameViewControllerButtonHandlers.swift
extension GameViewController {
    // Button handling code
}

// GameViewControllerNetworkMessageReceiver.swift
extension GameViewController {
    // Network message handling
}
```

### 4. Common Patterns in This Codebase

#### Delegation Pattern
Most managers use delegation for callbacks:
```swift
protocol SomeManagerDelegate: AnyObject {
    func manager(_ manager: SomeManager, didDoSomething: Void)
}
```

#### Callback Closures
UI components use closures for events:
```swift
lobbyUI.onHostTapped = { [weak self] in
    self?.handleHostTapped()
}
```

#### Component Injection
Dependencies are injected rather than created:
```swift
let coordinator = MultiplayerCoordinator(multiplayerManager: manager)
```

## Modifying Existing Code

### Before Making Changes

1. **Read the entire file** you're modifying
2. **Check ARCHITECTURE.md** to understand component relationships
3. **Look for related files** (extensions, protocols, delegates)
4. **Understand the dependency flow**

### Making Changes

1. **Keep changes minimal** - only modify what's necessary
2. **Preserve existing patterns** - match the coding style
3. **Don't refactor unrelated code** - focus on your task
4. **Update documentation** if you change public interfaces

### After Making Changes

1. **Test your changes** - build and run the app
2. **Check for broken dependencies** - search for usages
3. **Update related documentation** if needed

## Common Tasks

### Adding a New Game Feature

1. Create new file: `tankgame Shared/NewFeature.swift`
2. Add entity/logic/rendering as needed
3. Wire it into `GameScene.swift` or `GameState.swift`
4. Test in simulator

### Adding UI Elements

1. If small: Add to `LobbyUI.swift` or create `LobbyUINewElement.swift`
2. If large: Create new `NewUIComponent.swift` file
3. Wire callbacks into `GameViewController` extensions

### Modifying Networking

1. Check `MultiplayerManager.swift` for low-level networking
2. Check `MultiplayerCoordinator.swift` for high-level coordination
3. Add new message types to `GameMessages.swift`
4. Handle messages in `GameViewControllerNetworkMessageReceiver.swift`

### Adding AI Behavior

1. Modify `AIBotTank.swift` for bot logic
2. Modify `AIBotManager.swift` for bot coordination
3. Test with single player mode

## Testing

### Running the App

This game requires **two simulators** to test multiplayer:

```bash
# Use XCodeBuildMCP tools to launch two instances
# See .github/instructions/launch-two-simulators.instructions.md
```

### Single Player Testing

Use the "Single Player" button in the lobby to test with AI bots without needing multiple simulators.

### What to Test

- [ ] Lobby UI appears correctly
- [ ] Buttons respond to taps
- [ ] Multiplayer connection works
- [ ] Game starts and plays smoothly
- [ ] Joystick and fire button work
- [ ] Sound effects play
- [ ] Game ends correctly

## Build and Lint

### Building

```bash
xcodebuild -project tankgame.xcodeproj -scheme "tankgame iOS" -sdk iphonesimulator
```

### Linting

No formal linter is configured. Follow Swift conventions:
- Use camelCase for variables and functions
- Use PascalCase for types
- Use 4-space indentation
- Keep lines under 120 characters when possible

## Common Pitfalls

### 1. Don't Break Modular Structure

**Bad**: Adding rendering code to `GameState.swift`
**Good**: Adding rendering code to appropriate `*Renderer.swift` file

### 2. Don't Create Circular Dependencies

**Bad**: `GameScene` → `GameState` → `GameScene`
**Good**: `GameScene` → `GameState` (one direction only)

### 3. Don't Forget iOS/macOS/tvOS Differences

Use `#if os(iOS)` conditionals for platform-specific code:
```swift
#if os(iOS) || os(tvOS)
    // Touch input
#elseif os(macOS)
    // Mouse input
#endif
```

### 4. Don't Skip Weak References in Closures

Always use `[weak self]` in closures to avoid retain cycles:
```swift
someCallback = { [weak self] in
    self?.doSomething()
}
```

## Git and Version Control

### Committing Changes

- DO NOT manually commit - use the `report_progress` tool
- Changes are automatically committed and pushed to the PR branch
- Review commits to ensure only relevant files are included

### .gitignore

Build artifacts and temporary files are automatically excluded:
- `.xcuserstate` files
- `.DS_Store` files
- `DerivedData/` folder
- `build/` folder
- Temporary files in `/tmp/`

## Documentation

### Inline Documentation

Add doc comments for public APIs:
```swift
/// Manages the game lobby user interface
///
/// This class handles all lobby UI setup, layout, and user interactions.
/// It communicates with GameViewController through callback closures.
class LobbyUI {
    /// Called when the host button is tapped
    var onHostTapped: (() -> Void)?
}
```

### Architecture Documentation

- **ARCHITECTURE.md** - Overall architecture overview
- **MODULARIZATION_SUMMARY.md** - Details on file organization
- **CRASH_REPORTING.md** - Crash reporting system details

## Questions?

If you're unsure about something:
1. Check ARCHITECTURE.md
2. Search for similar patterns in existing code
3. Look for related files (extensions, protocols)
4. Ask the user for clarification

## Summary

**Key Principles for Claude Code:**
1. ✅ Create new files for new functionality
2. ✅ Keep files small and focused (under 300 lines)
3. ✅ Follow existing patterns and conventions
4. ✅ Use extensions to break up large classes
5. ✅ Test changes before committing
6. ✅ Use report_progress tool for commits
7. ✅ Minimize merge conflicts through modularity
