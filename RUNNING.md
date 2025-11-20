# Running Tank Game - Quick Reference

This document provides a quick reference for building and running the Tank Game.

## TL;DR - Just Run It!

```bash
./launch.sh    # Interactive menu (easiest)
# OR
./run.sh       # Run single player
# OR
./run.sh -n 2  # Run multiplayer (2 instances)
# OR
make launch    # Same as ./launch.sh
```

## Three Ways to Run

### 1. Interactive Menu (Recommended for Beginners)
```bash
./launch.sh
```
or
```bash
make launch
```

Presents a user-friendly menu with options to:
- Run iOS single player
- Run iOS multiplayer (2 instances)
- Run macOS
- Build only
- Clean build artifacts
- Show available simulators

### 2. Command Line Scripts (Recommended for Power Users)

**Quick Start:**
```bash
./run.sh              # iOS single player
./run.sh -n 2         # iOS multiplayer
./run.sh -p macOS     # macOS native
```

**Advanced Usage:**
```bash
# Run on specific simulator
./run.sh -d "iPhone 15 Pro"

# Run 2 instances on specific device for multiplayer
./run.sh -n 2 -d "iPhone 15 Pro"

# Build for specific platform
./build.sh -p iOS
./build.sh -p macOS
./build.sh -p tvOS

# Build Release configuration
./build.sh -c Release
```

### 3. Make Targets (Recommended for Developers)

```bash
make                 # Show help
make launch          # Interactive menu
make run             # Run iOS single player
make run-multiplayer # Run iOS with 2 instances
make run-macos       # Run on macOS
make build           # Build iOS Debug
make build-release   # Build iOS Release
make build-macos     # Build macOS
make clean           # Clean build artifacts
```

## Requirements

- **macOS** (iOS Simulator and Xcode only work on macOS)
- **Xcode** (download from App Store)
- **Xcode Command Line Tools**: `xcode-select --install`

## Multiplayer Testing

To test multiplayer functionality locally:

1. Launch two instances:
   ```bash
   ./run.sh -n 2
   ```

2. Wait for both simulators to open and the game to launch

3. In one instance:
   - Tap "Host Game"
   
4. In the other instance:
   - Tap "Join Game"
   - Select the host from the list

5. Start playing!

## Troubleshooting

### xcodebuild not found
```bash
xcode-select --install
```

### No simulators available
Open Xcode > Window > Devices and Simulators, then add simulators.

### Build fails
```bash
make clean
./build.sh
```

### Multiple Instances Don't Connect
- Make sure both simulators are on the same network
- MultipeerConnectivity works over Bluetooth/WiFi
- Try restarting both instances

## File Structure

```
tankgame/
├── launch.sh        # Interactive menu launcher
├── run.sh          # Build and run script
├── build.sh        # Build-only script
├── Makefile        # Make targets
├── README.md       # Full documentation
└── tankgame.xcodeproj  # Xcode project
```

## What Each Script Does

- **launch.sh**: Presents an interactive menu for all operations
- **run.sh**: Builds and launches the game (supports multiple instances)
- **build.sh**: Only builds the game without running it
- **Makefile**: Provides convenient make targets

## Common Use Cases

### I just want to play the game
```bash
./launch.sh
# Select option 1
```

### I want to test multiplayer locally
```bash
./run.sh -n 2
```

### I'm developing and want to test changes
```bash
make run
```

### I want to clean everything and rebuild
```bash
make clean
make build
```

### I want to run on my Mac (not simulator)
```bash
./run.sh -p macOS
```

## Platform Support

- ✅ **iOS**: Fully supported with simulator
- ✅ **macOS**: Native app support
- ✅ **tvOS**: Build supported (requires Apple TV simulator)

## Advanced: Custom Simulator

To find available simulators:
```bash
xcrun simctl list devices available
```

To use a specific one:
```bash
./run.sh -d "iPhone 15 Pro Max"
```

## Need More Help?

- Run any script with `-h` flag for detailed help:
  ```bash
  ./run.sh -h
  ./build.sh -h
  ```

- Check `make help` for all make targets

- Read the full [README.md](README.md) for comprehensive documentation
