# Tank Game 🎮

A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Features

- 🎯 **Real-time Multiplayer** - Battle with friends using Bluetooth via MultipeerConnectivity
- 🕹️ **Intuitive Controls** - Virtual joystick and fire button for smooth gameplay
- 🎨 **Visual Effects** - Explosion animations and particle effects
- 🔊 **Sound Effects** - Audio feedback for shooting and explosions
- 🗺️ **Procedural Maps** - Dynamically generated grid-based battlefields
- 🌈 **Rainbow Tanks** - Animated tank colors to distinguish players
- 📊 **Score Tracking** - Keep track of hits and eliminations

## Requirements

- **iOS 18.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **Two or more iOS devices** for multiplayer gameplay

## Building and Running

1. **Clone the repository**
   ```bash
   git clone https://github.com/joshspicer/tankgame.git
   cd tankgame
   ```

2. **Open in Xcode**
   ```bash
   open tankgame.xcodeproj
   ```

3. **Select your target**
   - Choose `tankgame iOS` for iPhone/iPad
   - Choose `tankgame tvOS` for Apple TV
   - Choose `tankgame macOS` for Mac

4. **Build and run**
   - Select your device or simulator
   - Press `Cmd+R` to build and run
   - For multiplayer testing, run on two physical devices (simulators don't support MultipeerConnectivity)

## How to Play

### Starting a Game

1. **Host a Game**: One player taps "Host Game" to create a session
2. **Join a Game**: Other players tap "Join Game" to see available hosts
3. **Connect**: Players select the host from the list and connect
4. **Ready Up**: Both players press "Ready" when connected
5. **Start**: The host starts the game once all players are ready

### Controls

- **Joystick** (left side): Move your tank in any direction
- **Fire Button** (right side): Shoot projectiles
- **Goal**: Hit your opponent while dodging their shots

### Gameplay

- Navigate around walls and obstacles on the procedurally generated map
- Aim and fire at your opponent to score points
- First player to reach the target score wins the round
- Game continues until players return to the lobby

## Architecture

The codebase is organized into modular, single-purpose components for improved maintainability and AI collaboration. See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed information about:

- Component structure and dependencies
- Separation of concerns (rendering, input, audio, networking)
- File organization (19 focused files vs. 2 monolithic files)
- Design principles applied

Key components:
- **GameScene** - Main game coordinator
- **GameState** - Game logic and state management
- **MultiplayerManager** - Bluetooth networking layer
- **GameSceneRenderer** - All rendering logic
- **JoystickController** & **FireButton** - Input handling

## Development

### Project Structure

```
tankgame/
├── tankgame Shared/       # Cross-platform game logic
│   ├── Core entities      # Tank, Projectile, Direction, GridCell
│   ├── Game logic         # GameState, GridGenerator
│   ├── Rendering          # GameSceneRenderer, ExplosionEffects
│   ├── Input              # JoystickController, FireButton
│   ├── UI                 # GameSceneUI
│   ├── Audio              # SoundManager
│   └── Networking         # MultiplayerManager, GameMessages
├── tankgame iOS/          # iOS-specific code
│   ├── GameViewController # Main coordinator
│   ├── LobbyUI            # Lobby interface
│   ├── MultiplayerCoordinator # Session management
│   └── PermissionManager  # iOS permissions
├── tankgame tvOS/         # tvOS-specific code
└── tankgame macOS/        # macOS-specific code
```

### Testing Multiplayer

To test multiplayer functionality, you need two physical iOS devices:

1. Build and install the app on both devices
2. Ensure Bluetooth is enabled on both devices
3. Launch the app on both devices
4. One device hosts, the other joins
5. Accept any permission prompts for local network access

Note: The iOS Simulator does not support MultipeerConnectivity, so multiplayer testing requires physical devices.

## Contributing

This project was built as a demonstration of AI-assisted development with GitHub Copilot. Feel free to fork and experiment!

## Credits

- Built with [GitHub Copilot](https://github.com/features/copilot) in VS Code
- Created by [Josh Spicer](https://github.com/joshspicer)
- Featured on VS Code livestreams ([Part 1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [Part 2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

## License

This project is provided as-is for educational and entertainment purposes.

