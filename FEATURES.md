# Tank Game - New Features

This document describes the newly added features to the Tank Game.

## Power-ups System

### Overview
Power-ups spawn randomly on the battlefield every 15-20 seconds. Players can collect them by moving over them to gain temporary or permanent advantages.

### Power-up Types

1. **Health (Green Star)** 💚
   - Revives a dead tank or provides protection
   - Instant effect
   - Most valuable for staying in the game

2. **Speed Boost (Cyan Star)** 🩵
   - Increases movement speed by 33%
   - Duration: 10 seconds
   - Great for dodging projectiles and repositioning

3. **Shield (Purple Star)** 💜
   - Provides temporary invulnerability to projectiles
   - Duration: 8 seconds
   - Tanks with shields can't be destroyed

4. **Rapid Fire (Orange Star)** 🧡
   - Reduces shooting cooldown from 0.5s to 0.2s (2.5x faster)
   - Duration: 12 seconds
   - Allows aggressive offensive play

### Implementation Details

**Files:**
- `PowerUp.swift` - Power-up entity and effect structures
- `GameState.swift` - Spawning logic and collection detection
- `GameSceneRenderer.swift` - Visual rendering with star shapes and animations
- `Tank.swift` - Effect management and application

**Visual Design:**
- Star-shaped sprites with distinct colors per type
- Pulsing and rotating animations
- Spawns at empty grid locations away from tanks

**Balancing:**
- Maximum 2 power-ups on the field at once
- Spawn interval: 15-20 seconds
- Effects last 8-12 seconds (temporary power-ups)

## AI Opponents (Single-Player Mode)

### Overview
Single-player mode allows you to play against computer-controlled opponents with three difficulty levels.

### Difficulty Levels

1. **Easy** 😊
   - Reaction time: 0.5 seconds
   - Shooting accuracy: 30%
   - Good for learning the game

2. **Medium** 😐
   - Reaction time: 0.3 seconds
   - Shooting accuracy: 60%
   - Balanced challenge

3. **Hard** 😈
   - Reaction time: 0.15 seconds
   - Shooting accuracy: 90%
   - Expert-level challenge

### AI Behavior System

The AI uses a priority-based decision system:

1. **Priority 1: Avoid Projectiles** 🚨
   - Detects incoming projectiles within 3 cells
   - Moves perpendicular to projectile direction
   - Survival is top priority

2. **Priority 2: Shoot at Enemies** 🎯
   - Looks for enemies in line of sight (same row/column)
   - Checks if path is clear of walls
   - Takes the shot if accuracy check passes

3. **Priority 3: Collect Power-ups** ⭐
   - Moves toward nearest power-up
   - Uses simple pathfinding to navigate

4. **Priority 4: Hunt Enemies** 🔍
   - Moves toward nearest enemy tank
   - Uses Manhattan distance for pathfinding

5. **Priority 5: Random Exploration** 🎲
   - 30% chance to move randomly
   - Prevents AI from getting stuck

### Implementation Details

**Files:**
- `AIController.swift` - Complete AI decision-making system
- `GameState.swift` - AI integration and action execution
- `GameScene.swift` - AI update loop
- `GameViewController.swift` - Single-player game start
- `LobbyUI.swift` - Single-player button and UI

**Technical Features:**
- Pathfinding using Manhattan distance
- Line-of-sight checking for shooting
- Projectile trajectory prediction
- Power-up collection behavior
- Difficulty-based reaction times

### How to Play Single-Player

1. From the main menu, tap **"🤖 Single Player"**
2. Select difficulty level (Easy, Medium, or Hard)
3. Game starts immediately with you (blue tank) vs AI (red tank)
4. Same controls as multiplayer:
   - Use joystick to move
   - Tap FIRE button to shoot
5. Rounds auto-restart after victory/defeat

## Gameplay Enhancements

### Speed Boost Effect
- Movement interval changes from 0.12s to 0.08s
- Faster repositioning and dodging
- Visual feedback: Tank moves noticeably quicker

### Shield Effect
- Projectiles pass through shielded tanks
- No visual indicator yet (future enhancement)
- Provides strategic invulnerability window

### Rapid Fire Effect
- Shooting cooldown reduced significantly
- Enables aggressive play style
- Great for suppressing enemies

### Shooting Cooldown
- Normal cooldown: 0.5 seconds between shots
- Rapid Fire cooldown: 0.2 seconds
- Prevents spam while allowing tactical shooting

## Network Synchronization (Multiplayer)

Power-ups are synchronized across all players:
- Host spawns power-ups deterministically (same seed)
- Collection is detected locally
- Future: Add network messages for power-up sync

## Future Enhancements

Potential improvements for the power-up and AI systems:

### Power-ups
- [ ] Add visual indicators for active effects on tanks
- [ ] Add weapon power-ups (bigger bullets, piercing shots)
- [ ] Add defensive structures power-up
- [ ] Add temporary speed trails
- [ ] Add sound effects for power-up collection

### AI
- [ ] Add support for more than 1 AI opponent
- [ ] Add team-based AI cooperation
- [ ] Add AI personality types (aggressive, defensive, balanced)
- [ ] Improve pathfinding with A* algorithm
- [ ] Add AI learning/adaptation

### Single-Player
- [ ] Add campaign mode with levels
- [ ] Add survival mode (waves of AI)
- [ ] Add leaderboard for single-player
- [ ] Add achievements

## Testing Checklist

- [x] Power-ups spawn correctly
- [x] Power-ups have correct effects
- [x] Power-ups render with animations
- [x] AI makes sensible decisions
- [x] AI difficulty levels work as expected
- [x] Single-player mode starts correctly
- [ ] Multiplayer still works with power-ups
- [ ] Power-ups don't break game balance
- [ ] AI doesn't get stuck in corners
- [ ] All three AI difficulties are distinct

## Known Issues

None at this time. Please report any bugs you encounter!

## Credits

- Power-up system: Implemented with star-shaped sprites and smooth animations
- AI system: Priority-based behavior with difficulty scaling
- Single-player integration: Clean menu flow with difficulty selection
