A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

**🎉 NEW: Complete Rewrite with 83% Less Code!**

This repository now includes a **complete rewrite** using modern Swift patterns:
- ✅ **83% code reduction**: 5,384 lines → 912 lines
- ✅ **Modern patterns**: MVVM, Actors, SwiftUI, Combine, Async/Await
- ✅ **Same functionality**: 2-6 player Bluetooth multiplayer preserved

See [COMPLETE_REWRITE_SUMMARY.md](COMPLETE_REWRITE_SUMMARY.md) for details.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Features

- 🎮 Multiplayer gameplay via Bluetooth (MultipeerConnectivity)
- 💥 ~~Crash reporting with automatic GitHub issue creation (see [CRASH_REPORTING.md](CRASH_REPORTING.md))~~ (removed in rewrite)
- 🎨 Modern visual styling
- 🔊 ~~Sound effects~~ (removed in rewrite, can be added back easily)

## Architecture

### New Minimal Implementation (912 lines across 8 files)

**Core Components:**
- `tankgame Shared/Models.swift` - All game data structures
- `tankgame Shared/NetworkManager.swift` - Actor-based networking  
- `tankgame Shared/GameViewModel.swift` - MVVM coordinator
- `tankgame Shared/MinimalGameScene.swift` - SpriteKit renderer

**UI Components:**
- `tankgame iOS/ContentView.swift` - Main SwiftUI coordinator
- `tankgame iOS/LobbyView.swift` - Multiplayer lobby
- `tankgame iOS/GameView.swift` - Game view
- `tankgame iOS/AppDelegate.swift` - Updated for SwiftUI

### Documentation

- [NEW_ARCHITECTURE.md](NEW_ARCHITECTURE.md) - Complete architecture guide
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - How to migrate from old code
- [BEFORE_AFTER_COMPARISON.md](BEFORE_AFTER_COMPARISON.md) - Detailed comparisons
- [COMPLETE_REWRITE_SUMMARY.md](COMPLETE_REWRITE_SUMMARY.md) - Executive summary

### Legacy Implementation (5,384 lines across 55 files)

The original modular implementation is still available in `tankgame Shared/` for reference. See [ARCHITECTURE.md](ARCHITECTURE.md) for the old architecture.

## Getting Started

1. Open `tankgame.xcodeproj` in Xcode
2. Build for iOS simulator
3. Launch two instances to test multiplayer
4. On first device: Tap "Host Game" → "Start Game"
5. On second device: Tap "Join Game" → Select host → Play!

## Design Patterns

The new implementation showcases modern Swift patterns:

- **MVVM**: Clean separation of concerns
- **Actor Model**: Thread-safe networking
- **Value Types**: Immutable game state
- **Combine**: Reactive programming
- **Async/Await**: Modern concurrency
- **SwiftUI**: Declarative UI
- **Protocol-Oriented**: Codable everywhere

## Comparison

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Total Lines | 5,384 | 912 | 83% ↓ |
| Total Files | 55 | 8 | 85% ↓ |
| Design | Delegates | Async/Await | Modern |
| UI | UIKit | SwiftUI | Declarative |

See [BEFORE_AFTER_COMPARISON.md](BEFORE_AFTER_COMPARISON.md) for detailed code comparisons.

