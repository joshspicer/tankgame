# Tank Game 🎮

A multiplayer tank battle game for iOS and macOS built with SpriteKit and MultipeerConnectivity.

## Features

- **Multiplayer Gameplay**: Connect two devices on the same network for head-to-head tank battles
- **Grid-Based Combat**: Navigate through procedurally generated maze-like arenas
- **Cross-Platform**: Play on iOS or macOS devices
- **Touch Controls**: Intuitive joystick and fire button controls
- **Projectile Physics**: Shoot projectiles that interact with walls and tanks
- **Round-Based Scoring**: First to win multiple rounds wins the match

## Game Mechanics

### Grid System
- 8x8 grid-based arena
- Procedurally generated walls for each round
- Protected spawn areas for fair gameplay
- Deterministic generation using seeds for synchronized multiplayer

### Tanks
- Start at opposite corners (top-left and bottom-right)
- Move in four directions (up, down, left, right)
- Fire projectiles in the direction they're facing
- One hit eliminates a tank for that round

### Projectiles
- Travel in straight lines
- Destroyed when hitting walls
- Eliminate tanks on contact
- Multiple projectiles can be active simultaneously

## Controls

### iOS/tvOS
- **Joystick** (bottom-left): Move your tank in any direction
- **Fire Button** (bottom-right): Shoot a projectile

### macOS
- Controls to be implemented

## Project Structure

```
tankgame/
├── tankgame Shared/          # Shared game logic for all platforms
│   ├── GameScene.swift       # Main game scene and rendering
│   ├── GameState.swift       # Game state management
│   ├── Tank.swift            # Tank entity logic
│   ├── Projectile.swift      # Projectile entity logic
│   ├── Direction.swift       # Direction enum and utilities
│   ├── GridCell.swift        # Grid cell types
│   ├── GridGenerator.swift   # Procedural grid generation
│   └── MultiplayerManager.swift  # Multiplayer networking
├── tankgame iOS/             # iOS-specific code
├── tankgame macOS/           # macOS-specific code
├── tankgame tvOS/            # tvOS-specific code
└── tankgame Tests/           # Unit tests
```

## Development

### Requirements
- Xcode 14.0 or later
- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+
- Swift 5.7+

### Building the Project

1. Open `tankgame.xcodeproj` in Xcode
2. Select your target platform (iOS, macOS, or tvOS)
3. Choose your destination device/simulator
4. Press `Cmd + R` to build and run

### Testing the Multiplayer

To test the multiplayer functionality:

1. Launch two separate instances of the app
   - For iOS: Use two simulators
   - For macOS: Build and run two instances
2. One player hosts, the other browses and connects
3. The host initiates the first round

For detailed instructions, see [launch-two-simulators.instructions.md](.github/instructions/launch-two-simulators.instructions.md)

## Testing

This project includes comprehensive unit tests covering:

- Direction calculations
- Tank movement and collision detection
- Projectile physics
- Grid generation
- Game state management
- Network message encoding/decoding

### Running Tests

#### In Xcode
Press `Cmd + U` to run all tests

#### From Command Line
```bash
# iOS
./run_tests.sh --ios

# macOS
./run_tests.sh --macos

# With code coverage
./run_tests.sh --ios --coverage
```

For detailed testing setup instructions, see [TESTING_SETUP.md](TESTING_SETUP.md)

### Test Coverage

The test suite includes:
- `DirectionTests.swift` - Direction enum tests
- `TankTests.swift` - Tank movement and shooting tests
- `ProjectileTests.swift` - Projectile advancement and collision tests
- `GridCellTests.swift` - Grid cell type tests
- `GridGeneratorTests.swift` - Grid generation tests
- `GameStateTests.swift` - Game state and round management tests
- `GameMessageTests.swift` - Network message serialization tests

See [tankgame Tests/README.md](tankgame Tests/README.md) for more details.

## Architecture

### Multiplayer Networking

The game uses Apple's MultipeerConnectivity framework for peer-to-peer networking:

- **Auto-discovery**: Devices automatically find each other on the local network
- **Deterministic gameplay**: Same seed generates identical grids on both devices
- **Message-based sync**: Position updates, shots, and hits are synchronized
- **Round coordination**: Both devices agree on round start/end

### Game Flow

1. **Connection Phase**: Players connect via MultipeerConnectivity
2. **Round Start**: Host generates a seed and shares with the opponent
3. **Active Play**: Players move and shoot, with updates synced between devices
4. **Round End**: When a tank is hit, round ends and scores update
5. **Next Round**: New seed generated, tanks reset to starting positions

### State Management

- `GameState`: Central game state including grid, tanks, and projectiles
- `GameScene`: Handles rendering and user input
- `MultiplayerManager`: Manages network connections and message passing

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]

## Credits

Created by [@joshspicer](https://github.com/joshspicer)
