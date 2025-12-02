---
applyTo: '**'
description: "Instruction for launching and testing the game"
---

# Testing Multiplayer with Two Simulators

This game is designed to be played with two simulators running on your Mac. To test the multiplayer functionality, use the XcodeBuildMCP tools to launch two separate instances of the built app.

## Prerequisites

- Xcode installed on your Mac
- XcodeBuildMCP server configured
- Two iOS simulators available (e.g., iPhone 15 Pro, iPhone 14)

## Step-by-Step Testing Instructions

### Step 1: Build the App

Build the iOS app for the simulator using XcodeBuildMCP:

```
Build the "tankgame iOS" scheme for iOS Simulator
```

### Step 2: Boot Two Simulators

Boot two different iOS simulator devices. You can do this via:
- **Simulator.app**: Open multiple devices from **File → Open Simulator**
- **XcodeBuildMCP**: List available simulators and boot two of them

### Step 3: Install and Launch

Install and launch the app on both simulators:

```
Install and launch TankGame on all booted simulators
```

### Step 4: Test Multiplayer

1. **On Simulator 1**: Tap "Host Game" to create a multiplayer session
2. **On Simulator 2**: Tap "Join Game" to find available sessions
3. Connect the two devices and start the game

## Important Notes

### MultipeerConnectivity in Simulators

| Feature | Simulator Support |
|---------|------------------|
| Infrastructure Wi-Fi | ✅ Works |
| Bluetooth Discovery | ❌ Not Supported |
| Peer-to-Peer Wi-Fi | ❌ Not Supported |
| Same-Mac Simulators | ⚠️ May be unreliable |

**For reliable testing:**
- Use at least one real iOS device with a simulator
- Or test with simulators on different Macs on the same network

### Command Line Alternative (simctl)

```bash
# List available simulators
xcrun simctl list devices

# Boot simulators
xcrun simctl boot "iPhone 15 Pro"
xcrun simctl boot "iPhone 14"

# Build the app
xcodebuild -scheme "tankgame iOS" -configuration Debug -sdk iphonesimulator -derivedDataPath ./build

# Install app on booted simulators
xcrun simctl install booted "./build/Build/Products/Debug-iphonesimulator/tankgame iOS.app"

# Launch app
xcrun simctl launch "iPhone 15 Pro" com.joshspicer.tankgame
xcrun simctl launch "iPhone 14" com.joshspicer.tankgame
```

## Testing Checklist

- [ ] Both simulators boot successfully
- [ ] App installs on both simulators
- [ ] App launches on both simulators
- [ ] Host game creates a session
- [ ] Join game discovers the session
- [ ] Devices connect successfully
- [ ] Gameplay synchronizes between devices
- [ ] Sound effects work on both devices