---
applyTo: '**'
description: "Instruction for launching and testing the game"
---

# Testing Multiplayer Functionality

This game is designed to be played with two simulators running on your Mac. To test the multiplayer functionality, use the XCodeBuildMCP tools to launch two separate instances of the built app.

## Prerequisites

- Xcode installed on your Mac
- Two iOS simulators available (e.g., iPhone 15 Pro, iPhone 15)
- XCodeBuildMCP tools configured

## Testing Steps

1. **Build the app** for the iOS simulator target
2. **Launch the first simulator** and install/run the app - this will act as the host
3. **Launch the second simulator** and install/run the app - this will act as the client
4. **On the host device**: Create a new game session
5. **On the client device**: Join the available game session
6. **Test multiplayer features**: Tank movement, firing projectiles, collision detection

## Bluetooth/MultipeerConnectivity

The game uses Apple's MultipeerConnectivity framework for peer-to-peer communication. When testing on simulators:
- Both simulators must be on the same Mac for connectivity to work
- The host creates a session that the client can discover and join
- Game state is synchronized between both instances

## Troubleshooting

- If simulators cannot discover each other, restart both simulators
- Ensure both apps are using the same build version
- Check console logs for any MultipeerConnectivity errors