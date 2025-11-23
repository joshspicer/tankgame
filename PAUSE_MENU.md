# Pause Menu Feature

## Overview
Added a pause menu to the game that allows players to pause gameplay and access game control options.

## UI Components

### Menu Button
- **Location**: Top-right corner of the game screen
- **Icon**: ☰ (hamburger menu icon)
- **Color**: Dark gray button with white border
- **Action**: Taps the button to open the pause menu

### Pause Overlay
When the pause menu is active:
- Semi-transparent black background covers the entire screen
- Game is paused (no movement, no projectile updates)
- Central menu panel with three options

## Menu Options

### 1. Resume Game
- Closes the pause menu and resumes gameplay
- Can also be triggered by tapping outside the menu panel

### 2. Restart Match
- **Host-only feature** - Only the game host can restart the match
- Resets all player scores to 0-0
- Starts a new round with a fresh grid
- All players are synchronized automatically
- Non-host players will see an error if they try to restart

### 3. Return to Lobby
- Any player can initiate this action
- All connected players return to the lobby
- Connections are preserved
- Host can start a new game without reconnecting

## Technical Details

### Network Messages
Two new message types were added:
- `restartMatch`: Coordinates match restart between players
- `quitToLobby`: Returns all players to the lobby

### Game State Management
- Pause state prevents game updates (projectiles, tank movement)
- Touch events are blocked when paused (except menu interactions)
- Round end sequence is not affected by pause state

### Synchronization
- When host restarts match, all clients receive the restart message
- Scores are reset on all devices
- A new `roundStart` message is sent to synchronize the new game state
- When any player quits to lobby, all players return to lobby together

## User Experience

### During Gameplay
1. Player taps the menu button (☰) in the top-right
2. Game pauses and menu overlay appears
3. Player selects an option
4. Action is executed and synchronized across all players

### Host vs Non-Host
- **Host**: Can access all three menu options
- **Non-Host**: Can resume or quit, but "Restart Match" shows an error message

### Error Handling
- If non-host tries to restart: Alert shown with "Only the host can restart the match"
- If player disconnects during menu: Standard disconnect handling applies
- Network errors are handled by existing multiplayer error system

## Implementation Files

### Modified Files
1. **GameSceneUI.swift** (+144 lines)
   - Menu button creation and positioning
   - Pause overlay rendering
   - Touch handling for menu interactions

2. **GameScene.swift** (+49 lines)
   - Menu callback integration
   - Pause state handling in update loop
   - Touch event prioritization

3. **GameMessages.swift** (+2 cases)
   - `restartMatch` message type
   - `quitToLobby` message type

4. **GameViewController.swift** (+76 lines)
   - Host validation for restart
   - Score reset logic
   - Lobby return functionality
   - Network message handlers

## Future Enhancements

Potential improvements:
- Add a confirmation dialog for "Restart Match"
- Show a countdown before resuming (3, 2, 1, GO!)
- Add sound effects for menu interactions
- Add settings options (sound volume, etc.)
- Show match statistics before returning to lobby
- Add a "New Game" option that disconnects and starts fresh
