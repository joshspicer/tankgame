---
applyTo: '**'
description: "Guidelines for organizing and structuring files"
---

# File Organization Guidelines

## File Naming Conventions

### Descriptive Names
File names should clearly indicate their purpose:

**Good**:
- `GameSceneRenderer.swift` - Renders the game scene
- `MultiplayerCoordinator.swift` - Coordinates multiplayer sessions
- `TankSpriteRenderer.swift` - Renders tank sprites

**Bad**:
- `Helper.swift` - Too generic
- `Utils.swift` - Too vague
- `Stuff.swift` - Not descriptive

### Extension Files
When splitting a large class, use the pattern `ClassName+Purpose.swift` or `ClassNamePurpose.swift`:

**Examples**:
- `GameViewController.swift` (base class)
- `GameViewControllerButtonHandlers.swift` (extensions)
- `GameViewControllerNetworkMessageReceiver.swift` (extensions)

## File Size Limits

### Target Sizes
- **Ideal**: 50-100 lines
- **Acceptable**: 100-200 lines
- **Requires refactoring**: 200-300 lines
- **Must refactor**: 300+ lines

### When to Split a File

Split a file when:
1. It exceeds 200 lines
2. It has multiple distinct responsibilities
3. Different parts could be worked on independently
4. It's hard to understand at a glance

### How to Split a File

#### Option 1: Extract Related Functionality
```swift
// Before: GameScene.swift (500 lines)
// - Scene setup (50 lines)
// - Rendering (200 lines)
// - Input handling (100 lines)
// - Update loop (150 lines)

// After: Split into 4 files
// GameScene.swift (50 lines) - Core coordination
// GameSceneRenderer.swift (200 lines) - All rendering
// GameSceneInputHandler.swift (100 lines) - Input
// GameSceneUpdateLoop.swift (150 lines) - Game loop
```

#### Option 2: Use Extensions
```swift
// GameViewController.swift (100 lines)
class GameViewController: UIViewController {
    // Core setup and properties
}

// GameViewControllerButtonHandlers.swift (50 lines)
extension GameViewController {
    func handleHostTapped() { ... }
    func handleJoinTapped() { ... }
}

// GameViewControllerNetworkMessageReceiver.swift (80 lines)
extension GameViewController {
    func handleNetworkMessage(_ message: GameMessage) { ... }
}
```

## Directory Structure

### Platform-Specific Code

```
tankgame Shared/     # Code that works on all platforms
tankgame iOS/        # iOS-specific UI and features
tankgame macOS/      # macOS-specific code
tankgame tvOS/       # tvOS-specific code
```

### Logical Grouping

Files are organized by functionality, not by type:

**Good** (group by feature):
```
tankgame Shared/
  ├── Tank.swift              # Tank entity
  ├── TankRenderer.swift      # Tank rendering
  ├── TankSpriteRenderer.swift # Tank sprite creation
  ├── Projectile.swift        # Projectile entity
  └── ProjectileRenderer.swift # Projectile rendering
```

**Bad** (group by type):
```
tankgame Shared/
  ├── Entities/
  │   ├── Tank.swift
  │   └── Projectile.swift
  └── Renderers/
      ├── TankRenderer.swift
      └── ProjectileRenderer.swift
```

## Component Organization

### Single Responsibility Principle

Each file should have ONE clear purpose:

✅ **Good Examples**:
- `SoundManager.swift` - Only handles sound playback
- `GridGenerator.swift` - Only generates game grids
- `Direction.swift` - Only defines direction enum

❌ **Bad Examples**:
- `GameHelpers.swift` - Too vague, multiple responsibilities
- `Utils.swift` - Catch-all for unrelated functions
- `Managers.swift` - Multiple managers in one file

### Dependency Direction

Follow clear dependency flow:

```
View Controllers (top level)
    ↓
Coordinators (orchestration)
    ↓
Managers (logic and state)
    ↓
Renderers / Handlers (specialized tasks)
    ↓
Entities (data models)
```

**Never** create circular dependencies:
- ❌ `GameScene` → `GameState` → `GameScene`
- ✅ `GameScene` → `GameState` (one direction)

## Creating New Files

### Checklist for New Files

When creating a new file, ensure:

- [ ] File name clearly describes its purpose
- [ ] File has a single, focused responsibility
- [ ] File is under 300 lines (ideally under 150)
- [ ] File includes a header comment
- [ ] File imports only necessary modules
- [ ] File's public interface is well-documented
- [ ] File is added to the appropriate target in Xcode

### Template for New Files

```swift
//
//  NewFeature.swift
//  tankgame Shared
//
//  Created on DATE
//

import Foundation
// Import only what you need

/// Brief description of what this file does
///
/// Longer description if needed, explaining:
/// - Key responsibilities
/// - How it fits into the architecture
/// - Any important constraints or considerations
class NewFeature {
    // Implementation
}
```

## Refactoring Existing Files

### Before Refactoring

1. ✅ Read the entire file
2. ✅ Understand all its responsibilities
3. ✅ Identify natural boundaries for splitting
4. ✅ Check for dependencies (search for imports)
5. ✅ Plan the split (which code goes where)

### During Refactoring

1. ✅ Create new files first (don't delete old code yet)
2. ✅ Move code in logical chunks
3. ✅ Update imports and references
4. ✅ Test after each file is split
5. ✅ Keep commit history clean

### After Refactoring

1. ✅ Verify all files build successfully
2. ✅ Test functionality hasn't changed
3. ✅ Update ARCHITECTURE.md if structure changed significantly
4. ✅ Remove any now-empty files

## Documentation

### File-Level Documentation

Every file should have a clear header comment:

```swift
/// Manages multiplayer game sessions
///
/// This class coordinates peer discovery, connection management,
/// and message passing for multiplayer gameplay. It wraps
/// MultiplayerManager and provides a higher-level interface
/// for game coordination.
class MultiplayerCoordinator {
    // ...
}
```

### When to Document

- ✅ Public classes and protocols
- ✅ Complex algorithms
- ✅ Non-obvious design decisions
- ✅ Public methods and properties
- ❌ Self-explanatory code
- ❌ Private implementation details (unless complex)

## Common Patterns

### Manager Pattern

```swift
// SoundManager.swift
/// Manages game sound effects
class SoundManager {
    static let shared = SoundManager() // Singleton

    private init() { } // Private initializer

    func playSound(named: String) {
        // Implementation
    }
}
```

### Coordinator Pattern

```swift
// MultiplayerCoordinator.swift
/// Coordinates multiplayer game sessions
class MultiplayerCoordinator {
    private let manager: MultiplayerManager

    init(multiplayerManager: MultiplayerManager) {
        self.manager = multiplayerManager
    }

    // Public coordination methods
}
```

### Renderer Pattern

```swift
// TankRenderer.swift
/// Renders tank sprites and animations
class TankRenderer {
    static func render(tank: Tank, in scene: SKScene) {
        // Rendering logic
    }
}
```

## Examples from This Codebase

### Well-Organized Files

- `Direction.swift` (34 lines) - Simple enum, perfect size
- `SoundManager.swift` (24 lines) - Focused manager
- `GridCell.swift` (14 lines) - Simple data type

### Files That Could Be Improved

- `LobbyUI.swift` (411 lines) - Could split into:
  - `LobbyUI.swift` (core setup)
  - `LobbyUILayout.swift` (constraints)
  - `LobbyUIButtons.swift` (button creation)

- `MultiplayerManager.swift` (397 lines) - Already well-organized but could split:
  - `MultiplayerManager.swift` (core)
  - `MultiplayerManagerDelegates.swift` (delegate implementations)

## Best Practices

### DO
- ✅ Create new files for new features
- ✅ Keep files small and focused
- ✅ Use descriptive file names
- ✅ Follow existing patterns
- ✅ Document public interfaces
- ✅ Test after creating/modifying files

### DON'T
- ❌ Create "Utils" or "Helpers" files
- ❌ Mix multiple responsibilities in one file
- ❌ Create circular dependencies
- ❌ Let files grow beyond 300 lines
- ❌ Use vague file names
- ❌ Refactor unrelated code while adding features

## Summary

Good file organization makes the codebase:
- **Easier to navigate** - Find what you need quickly
- **Easier to understand** - Each file has clear purpose
- **Easier to modify** - Changes are localized
- **Easier to test** - Components can be tested independently
- **Easier for AI** - Smaller contexts, clearer boundaries
- **Less prone to conflicts** - Multiple agents can work simultaneously
