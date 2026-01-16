---
applyTo: '**'
description: "Modularity guidelines for parallel AI agent development"
---

# Modularity Guidelines

## Core Principle
Whenever making code additions or changes, prioritize code modularity. This helps minimize merge conflicts when multiple AI agents work concurrently.

## Guidelines

### Creating New Code
- **CREATE NEW FILES** for new functionality instead of expanding existing files
- Keep files focused on a single responsibility
- Target file size: ~50-150 lines (max 200 lines)
- Use Swift extensions to add functionality without modifying original files

### Modifying Existing Code
- **AVOID REFACTORING** unless absolutely necessary for the task
- Make minimal changes to existing files
- Don't move or reorganize code unless explicitly requested
- Respect existing file boundaries

### File Organization
The project uses 37+ focused files with clear separation:
- Core Entities (Tank, Projectile, etc.)
- Renderers (TankRenderer, GridRenderer, etc.)
- Handlers (InputHandler, MessageHandling, etc.)
- Managers (MultiplayerManager, AIBotManager, etc.)

### Why This Matters
Multiple AI agents can work simultaneously on:
- Agent 1: Modify tank rendering → TankRenderer.swift
- Agent 2: Update input handling → GameSceneInputHandler.swift
- Agent 3: Change network logic → NetworkMessageReceiver.swift
- All without merge conflicts!

## Examples

### ✅ Good: Create New File
```swift
// NEW FILE: TankHealthSystem.swift
extension Tank {
    func takeDamage(_ amount: Int) {
        // New functionality in new file
    }
}
```

### ❌ Bad: Expand Existing File
```swift
// EXISTING FILE: Tank.swift (now 300+ lines)
struct Tank {
    // Original code...
    // + 100 lines of new health system code
}
```
