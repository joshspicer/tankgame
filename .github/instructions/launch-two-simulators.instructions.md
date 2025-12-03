---
applyTo: '**'
description: "Instruction for launching and testing the game"
---

This game is designed to be played with two simulators running on your Mac. To test the multiplayer functionality, use the XCodeBuildMCP tools to launch two separate instances of the built app.

## Testing Multiplayer Functionality

1. **Build the app** using the Xcode project (`tankgame.xcodeproj`)
2. **Launch two iOS simulators** on your Mac
3. **Install and run** the app on both simulators
4. **Test the multiplayer connection** via MultipeerConnectivity (uses Wi-Fi on simulators)