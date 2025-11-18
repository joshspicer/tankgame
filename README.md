A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Features

- 🎮 Multiplayer support (2-4 players) via Bluetooth
- 🚀 Procedurally generated maps with seeded randomization
- 💥 Tank combat with projectiles and explosions
- 🎨 Rainbow tank animations and visual effects
- 🎵 Sound effects
- 📱 Touch controls with virtual joystick

## Architecture

The codebase is modularly organized for maintainability and testability. See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed component breakdown.

## Testing

Unit tests are available for core game components. See [TESTING_SETUP.md](TESTING_SETUP.md) for setup instructions.

Run tests in Xcode with `Cmd+U` or via command line:
```bash
xcodebuild test -scheme "tankgame iOS" -destination "platform=iOS Simulator,name=iPhone 15"
```
