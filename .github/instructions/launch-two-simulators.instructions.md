---
applyTo: '**'
description: "Instructions for launching and testing the multiplayer game"
---

## Testing Multiplayer Functionality

This game is designed to be played with two simulators running simultaneously on your Mac.

### How to Test
To test the multiplayer functionality:
1. Use the **XCodeBuildMCP tools** to build the app
2. Launch **two separate instances** of the built app
3. Both instances should be able to discover and connect to each other via Bluetooth (MultipeerConnectivity)

### Requirements
- macOS with Xcode
- XCodeBuildMCP tools configured
- Two simulator instances or physical devices