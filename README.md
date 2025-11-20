A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## 🚀 Quick Start

### Prerequisites
- macOS with Xcode installed
- Xcode Command Line Tools: `xcode-select --install`

### Running the Game

#### Interactive Menu (Easiest)
For the simplest experience, use the interactive launcher:
```bash
./launch.sh
```
This will present a menu with all available options.

#### Direct Commands

The easiest way to build and run Tank Game is using the provided scripts:

#### Run on iOS Simulator (Single Player)
```bash
./run.sh
```

#### Run Two Instances for Multiplayer Testing
```bash
./run.sh -n 2
```
This will launch two iOS simulator instances so you can test the multiplayer functionality locally.

#### Run on macOS
```bash
./run.sh -p macOS
```

#### Run on Specific iOS Device
```bash
./run.sh -d "iPhone 15 Pro"
```

### Build Options

If you want to build without running:

```bash
./build.sh                  # Build iOS Debug
./build.sh -p macOS         # Build macOS Debug
./build.sh -p iOS -c Release # Build iOS Release
```

### Using Make

You can also use the Makefile for convenient shortcuts:

```bash
make launch           # Interactive menu
make run             # Run iOS single player
make run-multiplayer # Run 2 instances for multiplayer
make run-macos       # Run on macOS
make build           # Build iOS Debug
make clean           # Clean build artifacts
make help            # Show all available targets
```

### Script Options

**run.sh**
- `-p platform` - Platform to run: iOS, macOS, or tvOS (default: iOS)
- `-c configuration` - Build configuration: Debug or Release (default: Debug)
- `-n instances` - Number of instances (1 or 2, for multiplayer testing)
- `-d device` - Specific simulator device name
- `-h` - Display help

**build.sh**
- `-p platform` - Platform to build: iOS, macOS, or tvOS
- `-c configuration` - Build configuration: Debug or Release
- `-h` - Display help

### Manual Build with Xcode

You can also open `tankgame.xcodeproj` in Xcode and build/run from there:

1. Open `tankgame.xcodeproj` in Xcode
2. Select the target (tankgame iOS, tankgame macOS, or tankgame tvOS)
3. Choose your simulator or device
4. Press `⌘R` to build and run

For multiplayer testing in Xcode:
1. Run the first instance on one simulator
2. Stop the run
3. Select a different simulator
4. Run again for the second instance

## 🎮 How to Play

1. Launch two instances of the game (on different devices or simulators)
2. On one device, host a game session
3. On the other device, join the session
4. Use the virtual joystick to move your tank
5. Press the fire button to shoot
6. First player to get 5 hits wins!

The game uses MultipeerConnectivity for local multiplayer over Bluetooth/WiFi.
