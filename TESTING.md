# Testing Guide

This document describes how to test the Tank Game application.

## Unit Tests

The project includes debug-only test utilities for testing core game functionality:

### GameStateTests

Basic tests for the game state logic:

```swift
#if DEBUG
// In your app, call:
GameStateTests.runAllTests()
#endif
```

Tests included:
- Game state initialization
- Tank spawn positions
- Projectile movement
- Round over detection
- Tank movement
- Game state reset

### CrashReporterTests

Utilities for testing the crash reporting system (see [CRASH_REPORTING.md](CRASH_REPORTING.md)):

```swift
#if DEBUG
CrashReporterTests.runAllTests()
#endif
```

## Multiplayer Testing

To test multiplayer functionality, you need to run two separate instances of the game:

### Using XcodeBuildMCP Tools

If you have the XcodeBuildMCP tools installed, you can launch two simulators:

1. Build the app:
   ```bash
   xcodebuild -project tankgame.xcodeproj -scheme tankgame-iOS -destination 'platform=iOS Simulator,name=iPhone 15' build
   ```

2. Launch first simulator instance:
   ```bash
   xcrun simctl install booted <path-to-app>
   xcrun simctl launch booted com.joshspicer.tankgame
   ```

3. Boot a second simulator and launch there:
   ```bash
   xcrun simctl boot <second-device-uuid>
   xcrun simctl install <second-device-uuid> <path-to-app>
   xcrun simctl launch <second-device-uuid> com.joshspicer.tankgame
   ```

### Using Xcode

1. Open `tankgame.xcodeproj` in Xcode
2. Select a simulator device and run (⌘R)
3. While the app is running, select a different simulator device from the device menu
4. Run again (⌘R) - this will launch a second instance

The two instances should be able to discover each other via Bluetooth/MultipeerConnectivity and play together.

## Manual Testing

Test the following functionality manually:

1. **Single Player Mode**
   - Start game with AI bots
   - Verify tank movement with joystick
   - Verify shooting mechanics
   - Check collision detection
   - Verify win/loss conditions

2. **Multiplayer Mode**
   - Host a game from one device
   - Join from another device
   - Verify synchronization of:
     - Tank movements
     - Projectiles
     - Hit detection
     - Round completion

3. **Lizard AI**
   - Verify lizards spawn correctly
   - Check lizard movement patterns
   - Test lizard-projectile collision

4. **UI/UX**
   - Check lobby UI functionality
   - Verify game controls responsiveness
   - Test pause/resume
   - Check win screen display

## Running Tests in Xcode

Since the tests are utility classes (not XCTest), you need to call them manually:

1. Add a test button or menu item in debug builds
2. Call `GameStateTests.runAllTests()` 
3. Check console output for test results

Alternatively, run tests at app launch in debug builds:

```swift
#if DEBUG
GameStateTests.runAllTests()
#endif
```
