# Tank Game 🎮

A multiplayer tank battle game for iOS, macOS, and tvOS, built entirely with VS Code agent mode 🚀

Perfect for killing time in long car rides with your siblings - just connect via Bluetooth and start battling!

![pewpew.gif](images/pewpew.gif)

## Features

- **🎮 Real-time Multiplayer**: Up to 4 players via [MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity) (Bluetooth/WiFi)
- **🎯 Simple Controls**: Virtual joystick for movement, dedicated fire button for shooting
- **💥 Dynamic Effects**: Explosion animations with particle effects and screen flash
- **🎵 Sound Effects**: Shooting and explosion sounds with volume control
- **🗺️ Procedural Maps**: Randomized 8x8 grid with varying wall density (15-30%)
- **📊 Score Tracking**: Win counter for each player across multiple rounds
- **🌈 Visual Flair**: Rainbow color animations on tank sprites
- **⚡ Smooth Gameplay**: SpriteKit-powered rendering at 60 FPS

## Gameplay

### How to Play

1. **Launch the game** on 2-4 devices
2. **Host or join** a multiplayer session in the lobby
3. **Wait for all players** to mark themselves as ready
4. **Battle it out!** Move with the joystick, shoot with the fire button
5. **Win rounds** - first to eliminate all opponents wins the round
6. **Play again** - rematch with a new randomly generated map

### Game Mechanics

- **Grid-based movement**: 8x8 tile grid with walls as obstacles
- **Tank direction**: Tanks face up, down, left, or right
- **Projectile physics**: Bullets travel in straight lines until hitting a wall or tank
- **Collision detection**: Tanks are eliminated on projectile hit
- **Spawn positions**: 
  - Player 1: Top-left corner
  - Player 2: Bottom-right corner
  - Player 3: Top-right corner
  - Player 4: Bottom-left corner
- **Protected spawn zones**: 2x2 areas around spawn points are kept clear of walls
- **Border paths**: Outer edges of the grid remain wall-free for strategic movement

## Technical Details

### Architecture

The codebase is organized into 24 focused, single-purpose Swift files across 4 layers:

#### Core Components
- **Game Entities**: `Tank`, `Projectile`, `Direction`, `GridCell`
- **Game Logic**: `GameState` (state management), `GridGenerator` (procedural generation)
- **Rendering**: `GameSceneRenderer` (visual engine), `ExplosionEffects` (particles)
- **Input**: `JoystickController`, `FireButton`
- **UI**: `GameSceneUI` (HUD), `LobbyUI` (multiplayer lobby)
- **Audio**: `SoundManager`
- **Networking**: `MultiplayerManager`, `MultiplayerCoordinator`

See [ARCHITECTURE.md](ARCHITECTURE.md) for complete details on the modular design.

### Platform Support

- **iOS**: Full featured version with touch controls (Primary target)
- **macOS**: Desktop version (requires additional input handling for keyboard/mouse)
- **tvOS**: Apple TV version (requires additional input handling for remote/gamepad)

### Technologies

- **SpriteKit**: 2D game rendering and animation
- **MultipeerConnectivity**: Peer-to-peer networking for local multiplayer
- **Swift**: ~1,700 lines across 24 files (avg ~90 lines per file)

## Development

### Building

Open `tankgame.xcodeproj` in Xcode and build for your target platform:

```bash
# For iOS Simulator
xcodebuild -scheme "tankgame iOS" -sdk iphonesimulator -configuration Debug

# For iOS Device
xcodebuild -scheme "tankgame iOS" -sdk iphoneos -configuration Release
```

### Testing Multiplayer

To test multiplayer functionality, run two instances of the app:
1. Launch on two physical devices, or
2. Launch two iOS simulators simultaneously (see `.github/instructions/launch-two-simulators.instructions.md`)

### Project Structure

```
tankgame/
├── tankgame Shared/        # Cross-platform game code
│   ├── Game logic          # Tank, Projectile, GameState, etc.
│   ├── Rendering           # GameSceneRenderer, ExplosionEffects
│   ├── Input               # JoystickController, FireButton
│   ├── Networking          # MultiplayerManager, GameMessages
│   └── Assets              # Sounds, sprites
├── tankgame iOS/           # iOS-specific code
│   ├── LobbyUI             # Multiplayer lobby interface
│   ├── PermissionManager   # Local network permissions
│   └── GameViewController  # Main coordinator
├── tankgame macOS/         # macOS-specific code
└── tankgame tvOS/          # tvOS-specific code
```

## Credits

Built live on the VS Code livestream with GitHub Copilot:
- [Stream Part 1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740) - Initial development
- [Stream Part 2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--) - Continued development

Created by [joshspicer](https://github.com/joshspicer) with extensive assistance from GitHub Copilot in agent mode.

## License

See repository for license details.
