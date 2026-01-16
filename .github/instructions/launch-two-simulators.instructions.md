---
applyTo: '**'
description: "Testing multiplayer functionality with dual simulators"
---

# Testing Tank Game Multiplayer

## Overview
Tank Game is a multiplayer Bluetooth-based game. To properly test multiplayer functionality, you need two running instances of the game.

## Testing Instructions

### Launch Two Simulators
Use the XCodeBuildMCP tools to launch two separate instances of the built app on your Mac.

### Test Procedure
1. **Launch Instance 1**: Start the first simulator/instance
2. **Launch Instance 2**: Start the second simulator/instance
3. **Host Session**: On one device, create a game session (become host)
4. **Join Session**: On the other device, join the session (become client)
5. **Test Gameplay**:
   - Test tank movement with virtual joystick
   - Test shooting with fire button
   - Test collision detection
   - Test scoring system
   - Test connection stability

### Single Player Testing
The game now supports AI bots for single-player mode. You can test single-player functionality with just one simulator.

### What to Verify
- ✅ Bluetooth connection establishes successfully
- ✅ Both players appear on the game grid
- ✅ Movement is synchronized across clients
- ✅ Projectiles spawn and move correctly
- ✅ Collisions are detected properly
- ✅ Scores update correctly
- ✅ Sound effects play
- ✅ Reconnection works after disconnection
- ✅ AI bots function in single-player mode

### Known Issues
- See issue #112: Crash when clients connect and host starts game
- Check GitHub issues for latest known problems

### Troubleshooting
- If connection fails, check Bluetooth permissions
- If crash occurs, check CRASH_REPORTING.md for automatic issue creation
- Restart both simulators if connection becomes unstable