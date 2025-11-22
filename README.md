# Tank Game 🎮

A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Building and Testing

### Prerequisites
- Xcode (latest version recommended)
- macOS with support for iOS Simulator
- For local multiplayer testing: Two iOS devices or two simulators

### Building the Project

The project supports three platforms:

1. **iOS** (Primary target)
   ```bash
   xcodebuild -project tankgame.xcodeproj -scheme "tankgame iOS" -configuration Debug
   ```

2. **macOS**
   ```bash
   xcodebuild -project tankgame.xcodeproj -scheme "tankgame macOS" -configuration Debug
   ```

3. **tvOS**
   ```bash
   xcodebuild -project tankgame.xcodeproj -scheme "tankgame tvOS" -configuration Debug
   ```

Alternatively, open `tankgame.xcodeproj` in Xcode and build using the GUI (⌘B).

### Testing Multiplayer Functionality

This game is designed for **local multiplayer** using MultipeerConnectivity (Bluetooth/WiFi). To test the multiplayer features:

#### Option 1: Two Physical Devices (Recommended)
1. Build and install the app on two iOS devices
2. Launch the app on both devices
3. Ensure both devices have Bluetooth and WiFi enabled
4. Use the lobby interface to discover and connect players
5. Start a game and test gameplay

#### Option 2: Two Simulators
1. Launch two iOS simulators on your Mac
2. Build and run the app on the first simulator
3. Build and run the app on the second simulator
4. Test the multiplayer connection between simulators

**Note:** Simulator networking may behave differently than physical devices. For the most accurate testing, use physical iOS devices.

### Testing Checklist

Based on the refactored architecture, test these key components:

- [ ] **Multiplayer connection** - Players can discover and connect to each other
- [ ] **Joystick and fire button input** - Controls respond correctly
- [ ] **Sound effects** - Audio plays during gameplay
- [ ] **Explosion animations** - Visual effects display properly
- [ ] **Permissions** - Local network permissions are requested correctly (iOS 14+)
- [ ] **Game state synchronization** - Actions sync between connected devices
- [ ] **Grid generation** - Game arena generates correctly
- [ ] **Tank movement and shooting** - Core gameplay mechanics work

## Architecture

This codebase has been refactored into modular, single-purpose components. For detailed information about the architecture, see:

- [ARCHITECTURE.md](ARCHITECTURE.md) - Complete architecture overview and component dependencies
- [REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md) - Detailed refactoring summary and benefits

## License

See repository for license information.
