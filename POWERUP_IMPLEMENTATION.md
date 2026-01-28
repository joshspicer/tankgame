# Powerup System Implementation

This commit implements a generic powerup system with hooks into various game variables.

## New Files Created

The following new Swift files need to be added to the Xcode project in the "tankgame Shared" group:

1. **PowerUpEffect.swift** - Effect protocol and implementations
2. **PowerUp.swift** - Powerup entity and types
3. **GameScene+PowerUps.swift** - Rendering and visual effects

## Modified Files

- **Tank.swift** - Added powerup modifiers (speed, fire rate, shield) and effect management
- **Game.swift** - Added powerup spawning, collection, and cleanup logic
- **Messages.swift** - Added powerup network messages
- **GameScene.swift** - Added powerUpsNode and delegate methods
- **GameScene+GameLoop.swift** - Added powerup update loop
- **GameViewController.swift** (iOS) - Added powerup network handlers

## System Architecture

### PowerUp Types
- **Speed Boost** - Increases tank movement speed by 1.5x for 5 seconds
- **Fire Rate Boost** - Increases fire rate by 1.5x for 5 seconds
- **Shield** - Prevents one hit for 10 seconds
- **Health Restore** - Instant effect (currently just for demonstration)

### How It Works

1. **Spawning**: Elder device spawns powerups every 10 seconds at random empty locations
2. **Collection**: Tanks collect powerups by moving over them
3. **Effects**: Powerups apply effects with configurable durations
4. **Expiration**: Powerups disappear after 30 seconds if not collected
5. **Networking**: All powerup events (spawn, collect) are synchronized across peers

### Hook Points

The system uses multipliers that can be easily extended:
- `Tank.speedMultiplier` - Affects movement speed
- `Tank.fireRateMultiplier` - Affects firing rate
- `Tank.hasShield` - Boolean shield state
- `Tank.activePowerUps` - Tracks active timed effects

## Adding New Powerup Types

To add a new powerup type:

1. Add case to `PowerUpType` enum in PowerUp.swift
2. Create effect struct implementing `PowerUpEffect` protocol in PowerUpEffect.swift
3. Add to `PowerUpType.createEffect()` switch statement
4. Add new tank property if needed (e.g., `tank.damageMultiplier`)
5. Implement `apply()` and `remove()` methods for the effect

## Next Steps

### To complete integration:

1. Open `tankgame.xcworkspace` in Xcode
2. Add the three new files to the project:
   - Right-click "tankgame Shared" folder
   - Select "Add Files to tankgame..."
   - Select: PowerUp.swift, PowerUpEffect.swift, GameScene+PowerUps.swift
   - Ensure all three targets (iOS, macOS, tvOS) are checked
3. Build and test with two simulators

### Testing Checklist:

- [ ] Powerups spawn every 10 seconds
- [ ] Powerups render with correct colors and symbols
- [ ] Collection works when tank moves over powerup
- [ ] Collection effect shows particles
- [ ] Speed boost increases movement speed
- [ ] Fire rate boost increases firing rate
- [ ] Shield prevents one hit
- [ ] Effects expire after their duration
- [ ] Powerups sync correctly across devices
- [ ] Powerups despawn after 30 seconds

## Implementation Notes

- Powerup spawning is elder-only to avoid conflicts
- All effects are applied via multipliers for easy stacking
- Network messages ensure all clients see the same powerups
- Visual effects use SpriteKit particle-like animations
- The system is fully extensible for new effect types
