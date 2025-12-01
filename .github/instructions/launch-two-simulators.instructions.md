---
applyTo: '**'
description: "Instruction for launching and testing the game"
---

# Testing Multiplayer with Two Simulators

This game is designed to be played with two simulators running on your Mac. To test the multiplayer functionality, use the XcodeBuildMCP tools to launch two separate instances of the built app.

## Prerequisites

- Xcode installed on your Mac
- XcodeBuildMCP server configured in `.vscode/mcp.json`
- Two iOS simulators available (e.g., iPhone 15 Pro, iPhone 14)

## Step-by-Step Instructions

### Step 1: Build the App

Use XcodeBuildMCP to build the iOS app:

```
Use the xcodebuild tool to build the TankGame iOS scheme for the iOS Simulator
```

### Step 2: Boot Two Simulators

Boot two different iOS simulators:

```
Use the xcodebuild tool to:
1. List available simulators
2. Boot "iPhone 15 Pro" simulator
3. Boot "iPhone 14" simulator
```

Or use the Simulator app: **File → Open Simulator** and select two different devices.

### Step 3: Install and Launch on Both Simulators

Use XcodeBuildMCP to install and launch the app on both booted simulators:

```
Use the xcodebuild tool to install and launch TankGame on all booted simulators
```

### Step 4: Test Multiplayer

1. On one simulator, tap "Host Game" to create a multiplayer session
2. On the other simulator, tap "Join Game" to search for available sessions
3. Connect the two devices and start playing!

## Important Notes

### MultipeerConnectivity Limitations in Simulators

| Feature | Simulator Support |
|---------|------------------|
| Infrastructure Wi-Fi | ✅ Supported |
| Bluetooth Discovery | ❌ Not Supported |
| Peer-to-Peer Wi-Fi | ❌ Not Supported |
| Simulator-to-Simulator (same Mac) | ⚠️ May be unreliable |

**For reliable MultipeerConnectivity testing:**
- Use at least one real iOS device alongside the simulator
- Or use simulators on different Macs on the same network
- Or run a simulator + real device on the same Wi-Fi network

### Recommended Testing Workflow

1. **UI/Logic Development**: Use multiple simulators for initial development
2. **Integration Testing**: Test with at least one real device for MultipeerConnectivity
3. **Full Testing**: Use multiple real devices for complete multiplayer validation

## Alternative: Command Line (simctl)

For manual control, you can use `xcrun simctl` directly:

```bash
# List available simulators
xcrun simctl list devices

# Boot simulators
xcrun simctl boot "iPhone 15 Pro"
xcrun simctl boot "iPhone 14"

# Build the app (run from project root directory)
xcodebuild -scheme "tankgame iOS" -configuration Debug -sdk iphonesimulator -derivedDataPath ./build

# Install app on booted simulators
# The .app file is located in: ./build/Build/Products/Debug-iphonesimulator/tankgame iOS.app
xcrun simctl install booted "./build/Build/Products/Debug-iphonesimulator/tankgame iOS.app"

# Launch app (bundle identifier: com.joshspicer.tankgame)
xcrun simctl launch "iPhone 15 Pro" com.joshspicer.tankgame
xcrun simctl launch "iPhone 14" com.joshspicer.tankgame
```

**Note:** If you built via Xcode's default settings, the app is in:
`~/Library/Developer/Xcode/DerivedData/tankgame-<hash>/Build/Products/Debug-iphonesimulator/tankgame iOS.app`

## Testing Checklist

- [ ] Both simulators boot successfully
- [ ] App installs on both simulators
- [ ] App launches on both simulators
- [ ] Host game creates a session
- [ ] Join game discovers the session
- [ ] Devices connect successfully
- [ ] Gameplay synchronizes between devices
- [ ] Sound effects work on both devices
- [ ] Crash reporting works if crashes occur