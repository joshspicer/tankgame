# Tank Game Testing Guide

## Overview
This document provides guidance for testing the refactored Tank Game codebase.

## Manual Testing Checklist

### Pre-Game Testing
- [ ] App launches successfully on iOS device/simulator
- [ ] Lobby UI displays correctly with all buttons visible
- [ ] Permissions are requested on first launch
- [ ] Bluetooth permissions work correctly

### Multiplayer Connection Testing
- [ ] Device can be discovered by other devices
- [ ] Device can discover other devices
- [ ] Connection can be established between two devices
- [ ] Multiple devices (up to 4) can connect successfully
- [ ] Connection state is displayed correctly
- [ ] Device names are shown in the peers list

### Game Start Testing
- [ ] Host can start the game when ready
- [ ] All connected players receive the game start signal
- [ ] Game scene loads correctly on all devices
- [ ] Grid generates consistently across all devices (same seed)
- [ ] Tanks spawn at correct positions for each player
- [ ] Each player sees their own tank and opponent tanks

### Gameplay Testing
- [ ] Joystick controls tank movement correctly
- [ ] Tank moves in all four directions (up, down, left, right)
- [ ] Tank cannot move through walls
- [ ] Tank cannot move outside grid boundaries
- [ ] Fire button shoots projectiles
- [ ] Projectiles move in the correct direction
- [ ] Projectiles are synchronized across all devices
- [ ] Projectiles destroy tanks on hit
- [ ] Projectiles disappear when hitting walls
- [ ] Explosion effects play when tanks are destroyed

### Audio Testing
- [ ] Sound effects play when firing
- [ ] Sound effects play on explosions
- [ ] Sounds work across all devices

### Visual Effects Testing
- [ ] Tank animations render correctly
- [ ] Rainbow color effect on tanks works
- [ ] Projectiles render with correct color
- [ ] Explosion particle effects work
- [ ] Grid renders correctly
- [ ] UI labels update correctly

### Round End Testing
- [ ] Round ends when only one tank remains
- [ ] Winner is determined correctly
- [ ] Win count increments correctly
- [ ] "Ready for next round" message works
- [ ] New round starts when all players ready
- [ ] New grid generates for next round
- [ ] Tanks respawn at spawn positions

### Edge Cases
- [ ] Player disconnects during game
- [ ] All players destroyed simultaneously
- [ ] Rapid fire button pressing
- [ ] Moving while shooting
- [ ] Multiple projectiles on screen
- [ ] Network latency handling

## Component Testing

### GameState
- Grid generation with consistent seeds
- Tank movement validation
- Projectile updates
- Collision detection
- Round win conditions

### GameScene
- Scene setup and initialization
- Update loop timing
- Input handling
- Rendering coordination

### MultiplayerManager
- Peer discovery
- Connection handling
- Message sending/receiving
- Disconnection handling

### MultiplayerCoordinator
- Player index assignment
- Ready state tracking
- Game state synchronization

## Testing on Different Platforms

### iOS
- iPhone (various screen sizes)
- iPad
- Different iOS versions

### tvOS
- Apple TV navigation
- Remote control input

### macOS
- Keyboard/mouse input
- Window resizing

## Performance Testing
- Frame rate during gameplay
- Network message latency
- Memory usage
- Battery consumption

## Known Limitations
- Maximum 4 players supported
- Requires local network/Bluetooth
- No AI players for single-player mode

## Automated Testing (Future)

### Unit Tests to Add
- `Tank.move()` with various grid configurations
- `Projectile.advance()` and collision detection
- `GameState.isRoundOver()` logic
- `GridGenerator.generate()` determinism
- `GameMessage` encoding/decoding

### Integration Tests to Add
- Full game round simulation
- Multiplayer message flow
- Reconnection scenarios

## Testing After Refactoring

The refactoring maintained all functionality, so test results should be identical to pre-refactoring:
- ✅ No new features added
- ✅ No features removed
- ✅ All game mechanics unchanged
- ✅ All networking unchanged

If any test fails, it indicates a regression introduced during refactoring.
