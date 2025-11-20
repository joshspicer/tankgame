# Multiplayer Session Guide

This guide explains how to start and manage multiplayer game sessions in Tank Game.

## Overview

Tank Game supports 2-4 players in a multiplayer session using Bluetooth and local network connectivity via Apple's MultipeerConnectivity framework. All players must be on the same local network or within Bluetooth range.

## Prerequisites

Before starting a multiplayer session, ensure:

1. **Permissions Granted**: The app requires:
   - Local Network permission (iOS 14+)
   - Bluetooth permission
   
2. **All Devices Ready**: Have 2-4 iOS devices available with the Tank Game app installed

3. **Same Network**: All devices should be on the same Wi-Fi network or within Bluetooth range

## Starting a Session

### For the Host (Player 1)

1. **Launch the App**: Open Tank Game on your device
2. **Tap "Host Game"**: This will:
   - Start advertising your game session
   - Display "Hosting game..." status
   - Show a "Connected Players" view
3. **Wait for Players**: Other players will see your game in their available games list
4. **Monitor Connections**: Watch the "Connected Players" count update as players join
5. **Start the Game**: Once 2-4 players are connected, tap "🚀 Start Game"

#### Host Responsibilities
- The host (Player 1) controls when the game starts
- The host can accept up to 3 other players (4 players total)
- After each round ends, the host initiates the next round

### For Joining Players (Players 2-4)

1. **Launch the App**: Open Tank Game on your device
2. **Tap "Join Game"**: This will:
   - Start searching for nearby games
   - Display "Searching for nearby games..." status
3. **Select a Game**: When games appear in the list, tap the one you want to join
4. **Wait for Host**: You'll see "Connected! Waiting for host to start game..."
5. **Game Starts**: When the host taps "Start Game", the game begins for all players

## Session States

### Lobby State
- **Hosting**: Device is advertising a game session
- **Browsing**: Device is searching for available games
- **Connected**: Device is connected and waiting for game to start

### In-Game State
- **Playing**: Active game round in progress
- **Between Rounds**: Players can ready up for the next round
- **Disconnected**: A player lost connection during gameplay

## Troubleshooting

### "Unable to Start Multiplayer" Error

If you encounter this error:

1. **Check Permissions**:
   - Go to Settings → Privacy & Security → Local Network
   - Find "Tank Game" and ensure it's enabled
   - Check Bluetooth permissions as well

2. **Try Again**: Close and reopen the app

3. **Restart Devices**: If issues persist, restart all devices

### No Games Found When Joining

If you can't find any games:

1. **Verify Host is Advertising**: Ensure the host tapped "Host Game"
2. **Check Network**: Confirm all devices are on the same network
3. **Bluetooth Range**: Move devices closer together
4. **Restart Search**: Tap "Cancel" and then "Join Game" again

### Player Disconnected During Game

If a player disconnects during gameplay:

1. All players return to the lobby automatically
2. An alert shows which player disconnected
3. Players can reconnect and start a new session

## Session Management

### Canceling Before Game Start

To cancel hosting or joining:
- Tap the "Cancel" button
- This will:
  - Stop advertising/browsing
  - Disconnect from peers
  - Return to the initial lobby screen

### Ending a Session

To end an active game session:
- Close the app
- All connected players will be disconnected
- They will return to their lobby screens

## Technical Details

### Connection Protocol

Tank Game uses Apple's MultipeerConnectivity framework:
- **Service Type**: `tankgame`
- **Transport**: Bluetooth and Wi-Fi
- **Encryption**: Required
- **Max Peers**: 3 (4 players total including host)

### Session Architecture

```
Host Device (Player 1)
    ├── Advertises game session
    ├── Accepts incoming connections (max 3)
    ├── Assigns player indices (0-3)
    ├── Controls game start
    └── Synchronizes game state

Joining Devices (Players 2-4)
    ├── Browse for sessions
    ├── Invite self to host's session
    ├── Receive player index assignment
    └── Wait for game start signal
```

### Message Flow

1. **Connection Phase**:
   - Host starts advertising
   - Clients browse and find host
   - Clients send invitation to host
   - Host accepts (if room available)
   - Connection established

2. **Game Start Phase**:
   - Host assigns player indices
   - Host sends `roundStart` message with:
     - Random seed for grid generation
     - Player count
     - Player assignments
   - All clients initialize game state

3. **Gameplay Phase**:
   - Players send `playerMove` messages
   - Players send `playerShoot` messages
   - All devices update shared game state

4. **Round End Phase**:
   - Players send `readyForNextRound` messages
   - When all ready, host starts next round
   - New seed generated for new grid

## Best Practices

### For Smooth Sessions

1. **Stable Connection**: Keep devices close together
2. **Charged Batteries**: Ensure devices are charged
3. **Close Other Apps**: Free up system resources
4. **Strong Signal**: Use good Wi-Fi or stay within Bluetooth range

### For Best Experience

1. **Test Connections**: Do a quick test round before serious play
2. **Communicate**: Talk to other players about ready status
3. **Be Patient**: Wait for all players to connect before starting
4. **Stay Connected**: Don't lock your device during gameplay

## Common Scenarios

### Scenario 1: Quick 2-Player Game
```
1. Player 1: Tap "Host Game"
2. Player 2: Tap "Join Game" → Select Player 1's game
3. Player 1: See Player 2 connected → Tap "Start Game"
4. Both players: Start playing!
```

### Scenario 2: 4-Player Tournament
```
1. Player 1: Tap "Host Game"
2. Players 2-4: Tap "Join Game" → Select Player 1's game
3. Player 1: Wait for all 3 players to connect
4. Player 1: Tap "Start Game" when ready
5. All players: Battle begins!
6. After round ends: All tap "Next Round"
7. Player 1: New round automatically starts when all ready
```

### Scenario 3: Player Joins Mid-Lobby
```
1. Player 1: Hosting with Player 2 connected
2. Player 3: Can still join before game starts
3. Player 1: Sees Player 3 added to connected list
4. Player 1: Can start with 3 players now
```

## Support

For issues or questions about multiplayer sessions:
- Check the troubleshooting section above
- Ensure you have the latest version of the app
- Verify all devices meet the prerequisites

## Session Limitations

- **Maximum Players**: 4 (including host)
- **Minimum Players**: 2 (can't start with 1)
- **Platform**: iOS only (macOS and tvOS builds available but not cross-compatible)
- **Network**: Local network/Bluetooth only (no internet multiplayer)
- **Version**: All players must use the same app version

## Security & Privacy

- All session data is encrypted
- No data leaves the local network
- Peer IDs are persisted locally for stable connections
- No server or cloud services involved
- Fully peer-to-peer architecture
