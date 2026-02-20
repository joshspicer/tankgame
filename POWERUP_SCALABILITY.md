# PowerUp System - Scalability Guide

## Overview

The powerup system is designed to be easily extensible without modifying core wrapper classes. New powerup types can be added by implementing the `PowerUpEffect` protocol and registering them with the system.

## Architecture

### Core Components

1. **PowerUpEffect Protocol** - Defines the interface for all powerup effects
   - `effectType: String` - Unique identifier for serialization
   - `duration: TimeInterval` - Effect duration (0 for instant effects)
   - `apply(to:)` - Applies effect to a tank
   - `remove(from:)` - Removes effect from a tank

2. **PowerUpEffectRegistry** - Dynamic registry for effect types
   - Enables runtime registration of new effect types
   - Handles serialization/deserialization without enum switches
   - Extensible without modifying core code

3. **PowerUpEffectWrapper** - Type-erased wrapper for effects
   - Uses registry for dynamic decoding
   - No need to add new enum cases for new effect types
   - Fully protocol-based implementation

4. **PowerUpType Enum** - Defines available powerup types
   - Still uses enum for type safety and case iteration
   - Only requires adding new case for new types
   - Symbol and effect creation handled per type

## Adding New PowerUp Types

### Step 1: Create Effect Implementation

```swift
struct NewEffect: PowerUpEffect, Codable {
    let effectType = "newEffect"
    let duration: TimeInterval
    let customParameter: Double

    func apply(to tank: inout Tank) {
        // Modify tank properties
        tank.customProperty *= customParameter
    }

    func remove(from tank: inout Tank) {
        // Revert changes
        tank.customProperty /= customParameter
    }
}
```

### Step 2: Register Effect Type (Optional for Runtime Addition)

```swift
// Register at app launch if adding dynamically
PowerUpEffectRegistry.register(type: "newEffect") { decoder in
    try NewEffect(from: decoder)
}
```

Note: Built-in effects (speed, fireRate, shield, health) are pre-registered in the registry.

### Step 3: Add PowerUp Type

```swift
enum PowerUpType: String, Codable, CaseIterable {
    // ... existing cases
    case newType

    func createEffect() -> PowerUpEffectWrapper {
        switch self {
        // ... existing cases
        case .newType:
            return PowerUpEffectWrapper(NewEffect(duration: 8.0, customParameter: 2.0))
        }
    }

    var symbol: String {
        switch self {
        // ... existing cases
        case .newType: return "🎯"
        }
    }
}
```

### Step 4: Add Tank Property (if needed)

```swift
struct Tank {
    // ... existing properties
    var customProperty: Double = 1.0
}
```

### Step 5: Add Visual Representation

```swift
// In GameScene+PowerUps.swift
private func powerUpColor(for type: PowerUpType) -> UIColor {
    switch type {
    // ... existing cases
    case .newType:
        return UIColor(red: 0.5, green: 0.8, blue: 0.3, alpha: 1.0)
    }
}
```

## Scalability Benefits

### 1. No Enum Proliferation
- The `PowerUpEffectWrapper` is now a struct using a registry pattern
- No need to add new enum cases in the wrapper for each effect type
- Reduces code coupling between effect definitions and wrapper

### 2. Runtime Extensibility
- Effects can be registered at runtime using `PowerUpEffectRegistry.register()`
- Enables plugin-like architecture for future DLC or mods
- Easy to test new effects without modifying core code

### 3. Protocol-Based Design
- All effects conform to `PowerUpEffect` protocol
- Type-safe compilation checks ensure all methods are implemented
- Easy to mock for testing

### 4. Minimal Code Changes
- Adding a new powerup requires changes in only 3-4 places:
  1. Effect implementation (new file)
  2. PowerUpType enum (add case)
  3. Visual representation (color/symbol)
  4. Tank property (if new hook needed)

### 5. Network Serialization
- Automatic encoding/decoding through Codable
- Registry-based deserialization handles unknown types gracefully
- Extensible without protocol changes

## Example: Adding Damage Multiplier PowerUp

```swift
// 1. Create effect
struct DamageMultiplierEffect: PowerUpEffect, Codable {
    let effectType = "damageMultiplier"
    let duration: TimeInterval
    let multiplier: Double

    func apply(to tank: inout Tank) {
        tank.damageMultiplier *= multiplier
    }

    func remove(from tank: inout Tank) {
        tank.damageMultiplier /= multiplier
    }
}

// 2. Add to Tank.swift
struct Tank {
    // ... existing properties
    var damageMultiplier: Double = 1.0
}

// 3. Add to PowerUpType enum
case damage

// In createEffect()
case .damage:
    return PowerUpEffectWrapper(DamageMultiplierEffect(duration: 7.0, multiplier: 2.0))

// In symbol
case .damage: return "💥"

// 4. Add color in GameScene+PowerUps.swift
case .damage:
    return UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
```

## Testing Recommendations

1. **Unit Tests**: Test each effect's apply/remove logic independently
2. **Integration Tests**: Verify effect stacking and expiration
3. **Network Tests**: Ensure effects serialize/deserialize correctly across peers
4. **Performance Tests**: Verify registry lookup performance with many effect types

## Future Enhancements

1. **Effect Stacking Rules**: Add configuration for whether effects stack or override
2. **Effect Conditions**: Add conditional effects (e.g., only applies when moving)
3. **Effect Triggers**: Add lifecycle hooks (onHit, onKill, etc.)
4. **Effect Combos**: Add special effects when multiple powerups are active
5. **Dynamic Parameters**: Load effect parameters from configuration files
