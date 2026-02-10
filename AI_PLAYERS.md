# AI Players

This document describes the AI player system that provides computer-controlled opponents with adaptive difficulty.

## Overview

AI players are computer-controlled tanks that get progressively better each time you defeat them. They start at Easy difficulty and level up through Medium, Hard, and Expert as they are killed.

## Features

- **Adaptive Difficulty**: Each time an AI player is destroyed, their difficulty increases permanently
- **Four Difficulty Levels**: Easy → Medium → Hard → Expert
- **Intelligent Behavior**: AI tanks track targets, avoid walls, and make tactical decisions
- **Visual Indicators**: AI players display their difficulty level on the scoreboard (e.g., "AI-Easy")
- **Network Sync**: AI players are synchronized across all connected devices

## Adding AI Players

To add an AI player:

1. The elder player (★ icon on scoreboard) opens the settings menu (⚙ icon)
2. Click the "Add AI" button in the settings modal
3. A new AI player spawns at Easy difficulty
4. The AI player appears with a unique color and "AI-Easy" label on the scoreboard

## Difficulty Levels

### Easy
- **Move Frequency**: 30%
- **Shoot Frequency**: 20%
- **Targeting Range**: 3 cells
- **Behavior**: Basic movement and occasional shooting

### Medium
- **Move Frequency**: 50%
- **Shoot Frequency**: 40%
- **Targeting Range**: 5 cells
- **Behavior**: More aggressive with better target tracking

### Hard
- **Move Frequency**: 70%
- **Shoot Frequency**: 60%
- **Targeting Range**: 8 cells
- **Behavior**: Consistently aggressive with long-range targeting

### Expert
- **Move Frequency**: 90%
- **Shoot Frequency**: 80%
- **Targeting Range**: 12 cells (full board)
- **Behavior**: Maximum difficulty - highly responsive and accurate

## AI Behavior

AI players use the following decision-making process:

1. **Target Detection**: Scans in the direction they're facing for enemy tanks
2. **Shooting Decision**: Fires if a target is in line of sight and random chance succeeds
3. **Movement Decision**: Moves toward nearest enemy or explores randomly
4. **Obstacle Avoidance**: Checks for walls and avoids them

## Implementation Details

### Key Files

- **AIPlayer.swift**: Core AI logic, difficulty levels, and decision-making
- **GameScene+AI.swift**: AI update loop and action processing
- **Game.swift**: AI player management and difficulty progression
- **Messages.swift**: Network synchronization for AI state

### Architecture

AI players are integrated into the existing multiplayer architecture:
- Each AI has a unique ID (e.g., "AI-12345678")
- AI state synchronizes via the same network messages as human players
- AI actions are processed locally but broadcast to maintain sync
- The elder player is responsible for AI spawning

### Network Synchronization

AI players sync the following state:
- Position (row, col)
- Direction
- Alive status
- Difficulty level
- Score

This ensures all connected devices see consistent AI behavior.

## Testing

To test AI players:

1. Launch two iOS simulators using XcodeBuildMCP tools
2. Connect both devices
3. On the elder device, add an AI player via settings
4. Observe AI behavior across both simulators
5. Defeat the AI to verify difficulty progression
6. Check that the scoreboard shows updated difficulty levels

## Future Enhancements

Potential improvements for the AI system:

- Multiple AI difficulty presets
- AI personality types (aggressive, defensive, strategic)
- Team-based AI behavior
- AI learning from player strategies
- Custom AI difficulty configuration
