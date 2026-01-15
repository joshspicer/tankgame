---
applyTo: '**'
description: "Instruction for launching and testing the game"
---

This game is designed to be played with two simulators running on your Mac. To test the multiplayer functionality, follow these steps to launch two separate instances of the app.

## Prerequisites
- Xcode installed on your Mac
- iOS Simulator
- The tankgame Xcode project

## Method 1: Using Xcode GUI (Recommended for Manual Testing)

### Step 1: Build and Launch First Simulator
1. Open `tankgame.xcodeproj` in Xcode
2. Select the iOS scheme (Product → Scheme → tankgame iOS)
3. Choose a simulator device (e.g., iPhone 15 Pro) from the device dropdown
4. Build and run (⌘+R)
5. Wait for the first simulator to launch and the app to start

### Step 2: Launch Second Simulator
1. Keep the first simulator running
2. In Xcode, select a **different** simulator device (e.g., iPhone 15)
3. Build and run again (⌘+R)
4. The second simulator will launch alongside the first

### Step 3: Test Multiplayer
1. On one device, tap to host or join a game
2. On the other device, the peer should appear in the nearby devices list
3. Connect and start playing!

## Method 2: Using Command Line (For Automated Testing)

### Build the App
```bash
xcodebuild -project tankgame.xcodeproj \
  -scheme "tankgame iOS" \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath ./build
```

### Launch First Simulator
```bash
# Boot first simulator (e.g., iPhone 15 Pro)
xcrun simctl boot "iPhone 15 Pro"

# Install the app
xcrun simctl install "iPhone 15 Pro" ./build/Build/Products/Debug-iphonesimulator/tankgame.app

# Launch the app
xcrun simctl launch "iPhone 15 Pro" com.joshspicer.tankgame
```

### Launch Second Simulator
```bash
# Boot second simulator (e.g., iPhone 15)
xcrun simctl boot "iPhone 15"

# Install the app
xcrun simctl install "iPhone 15" ./build/Build/Products/Debug-iphonesimulator/tankgame.app

# Launch the app
xcrun simctl launch "iPhone 15" com.joshspicer.tankgame
```

## Method 3: Using XCodeBuildMCP Tools (For AI Agents)

If XCodeBuildMCP tools are available, use them to:
1. Build the project for the iOS simulator
2. Launch the first simulator instance with the built app
3. Launch the second simulator instance with the built app
4. The app should automatically discover nearby peers via MultipeerConnectivity

## Available Simulators

To list available simulators:
```bash
xcrun simctl list devices available
```

Common simulator choices for testing:
- iPhone 15 Pro
- iPhone 15
- iPhone 14 Pro
- iPhone 14
- iPad Pro (12.9-inch)

## Troubleshooting

### Simulators Don't See Each Other
- **Issue**: MultipeerConnectivity requires both simulators to be on the same network
- **Solution**: Ensure both simulators are running and have network access. Try restarting both simulators.

### Build Fails
- **Issue**: Missing dependencies or invalid configuration
- **Solution**: Clean build folder (⌘+Shift+K) and rebuild

### App Crashes on Launch
- **Issue**: Code signing or provisioning profile issues
- **Solution**: Check that the simulator build doesn't require code signing (it shouldn't)

### Only One Simulator Appears
- **Issue**: Second simulator failed to boot
- **Solution**: Check that your Mac has enough resources. Close other applications and try again.

### Performance Issues
- **Issue**: Running two simulators is resource-intensive
- **Solution**: 
  - Use simpler device models (e.g., iPhone 15 instead of iPhone 15 Pro Max)
  - Close other applications
  - Ensure your Mac has at least 16GB RAM

## Testing Checklist

When testing multiplayer functionality, verify:
- [ ] Both simulators launch successfully
- [ ] App starts on both devices
- [ ] Devices discover each other via Bluetooth/MultipeerConnectivity
- [ ] Can establish connection between devices
- [ ] Game state syncs correctly between devices
- [ ] Tank movements appear on both screens
- [ ] Projectiles sync correctly
- [ ] Scoring updates on both devices
- [ ] Connection remains stable during gameplay
- [ ] Reconnection works if one device disconnects

## Notes

- The game uses MultipeerConnectivity for peer-to-peer communication
- Simulators must be running iOS 14.0 or later (check project requirements)
- For best results, use the same iOS version on both simulators
- The bundle identifier is `com.joshspicer.tankgame`