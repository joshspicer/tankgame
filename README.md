# Tank Game 🎮

A multiplayer ([MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Features

- 🎯 Multiplayer gameplay using Bluetooth/WiFi (MultipeerConnectivity)
- 🕹️ Virtual joystick controls for smooth tank movement
- 💥 Projectile shooting with collision detection
- 🎨 Rainbow tank animations and explosion effects
- 🔊 Sound effects for immersive gameplay
- 📱 iOS, macOS, and tvOS support

## Architecture

This project has been refactored into a clean, modular architecture with 19+ focused files. Each component has a single responsibility, making the codebase easy to understand and maintain.

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Getting Started

### Requirements

- Xcode 12.0 or later
- iOS 14.0+ / macOS 11.0+ / tvOS 14.0+
- Swift 5.3+

### Building & Running

1. Open `tankgame.xcodeproj` in Xcode
2. Select your target device or simulator (iOS, macOS, or tvOS)
3. Build and run (⌘R)

**Testing multiplayer:** Launch two instances of the app on separate devices or simulators to test the multiplayer functionality.

## Project Structure

```
tankgame Shared/          # Cross-platform game code
├── GameScene.swift       # Main game coordinator
├── GameState.swift       # Game state management
├── GameSceneRenderer.swift  # Rendering engine
├── JoystickController.swift # Input handling
├── Tank.swift            # Tank entity
├── Projectile.swift      # Projectile entity
└── ...                   # Other game components

tankgame iOS/             # iOS-specific code
├── GameViewController.swift # Main view controller
├── LobbyUI.swift         # Lobby interface
├── MultiplayerCoordinator.swift # Session management
└── ...                   # Other iOS components
```

See [REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md) for the complete refactoring story.

## Contributing

This project was built as a demonstration of AI-assisted development with GitHub Copilot. Feel free to fork and experiment!

## License

MIT
