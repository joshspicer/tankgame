A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

> **⚡ NEW**: Complete rewrite with clean architecture! See [ARCHITECTURE_V2.md](ARCHITECTURE_V2.md) for details.
> - 58% less code (2.2K lines vs 5.2K)
> - 82% fewer files (9 files vs 51)
> - Simple, scalable design patterns
> - Support for 2-6 players

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Features

- 🎮 2-6 player multiplayer via Bluetooth (MultipeerConnectivity)
- 🎯 Simple touch controls (joystick + fire button)
- 🏗️ Clean, maintainable architecture
- 📱 Cross-platform (iOS, macOS, tvOS)

## Quick Start

1. Open `tankgame.xcodeproj` in Xcode
2. Build and run on iOS simulator or device
3. Tap "Host Game" on one device
4. Tap "Join Game" on another device
5. Host taps "Start Game"
6. Play!

## Architecture

See [ARCHITECTURE_V2.md](ARCHITECTURE_V2.md) for complete documentation.

**Core Components:**
- `GameEngine` - Pure game logic (movement, collision, scoring)
- `NetworkManager` - Bluetooth multiplayer (host/join)
- `GameScene` - SpriteKit rendering
- `GameViewController` - iOS UI coordination

