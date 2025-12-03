---
applyTo: '**'
description: "Instruction for launching and testing the game"
---

# Testing Multiplayer with Two Simulators

This game is designed to be played with two simulators running on your Mac. To test the multiplayer functionality, use the XCodeBuildMCP tools to launch two separate instances of the built app.

## Prerequisites

- macOS with Xcode installed
- Two iOS simulators configured (e.g., iPhone 15 and iPhone 15 Pro)
- XCodeBuildMCP tools configured in your environment

## Steps to Launch Two Simulators

1. **Build the project** using the XCodeBuildMCP `build` tool targeting the iOS simulator platform
2. **Boot the first simulator** using the XCodeBuildMCP `boot_simulator` tool (e.g., "iPhone 15")
3. **Launch the app** on the first simulator using the XCodeBuildMCP `launch_app` tool with the bundle identifier `com.joshspicer.tankgame`
4. **Boot the second simulator** using the XCodeBuildMCP `boot_simulator` tool (e.g., "iPhone 15 Pro")
5. **Launch the app** on the second simulator using the XCodeBuildMCP `launch_app` tool with the same bundle identifier
6. **Test multiplayer** by having one device host a game and the other join via MultipeerConnectivity

## Multiplayer Testing Workflow

1. On Simulator 1: Tap "Host Game" to create a session
2. On Simulator 2: Tap "Join Game" to discover and connect to the host
3. Once connected, both players will see each other in the lobby
4. The host can start the game once both players are ready
5. Test gameplay by controlling tanks on both simulators simultaneously

## Notes

- Simulators communicate via MultipeerConnectivity over the local network
- Ensure both simulators can reach each other on the same network interface
- If connection issues occur, try restarting the simulators or the MultipeerConnectivity session