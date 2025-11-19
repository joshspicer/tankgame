# Tank Game Unit Tests

This directory contains comprehensive unit tests for the Tank Game's modular components.

## Overview

After the major refactoring that broke down monolithic files into focused, single-purpose components, these unit tests demonstrate how the modular architecture enables thorough testing of individual components in isolation.

## Test Files

### Core Entity Tests

#### `TankTests.swift`
Tests for the `Tank` entity covering:
- Initialization and default values
- Movement in all directions
- Boundary collision detection
- Wall collision detection
- Direction updates during movement
- Shooting mechanics
- Codable conformance (serialization/deserialization)

**Test Coverage**: 15+ test cases

#### `ProjectileTests.swift`
Tests for the `Projectile` entity covering:
- Initialization
- Movement in all directions
- Boundary detection
- Wall collision
- Tank hit detection
- Dead tank exclusion
- Codable conformance

**Test Coverage**: 12+ test cases

#### `DirectionTests.swift`
Tests for the `Direction` enum covering:
- Offset calculations for all directions
- Opposite direction logic
- All cases enumeration
- Codable conformance

**Test Coverage**: 10+ test cases

### Game Logic Tests

#### `GridGeneratorTests.swift`
Tests for the `GridGenerator` utility covering:
- Grid size validation
- Deterministic generation (same seed → same grid)
- Randomness (different seeds → different grids)
- Spawn position validation (must be empty)
- Wall/empty cell distribution
- Edge cases (zero seed, max seed)
- Reproducibility

**Test Coverage**: 10+ test cases

#### `GameStateTests.swift`
Tests for the `GameState` class covering:
- Initialization with various player counts
- Tank spawn positioning
- Grid generation integration
- Reset functionality
- Projectile management
- Win tracking persistence across resets
- Local player index handling
- Spawn position validation

**Test Coverage**: 20+ test cases

## Total Test Coverage

- **5 test files**
- **67+ test cases**
- Covers all core game entities and logic
- Tests both happy paths and edge cases
- Validates Codable conformance for network synchronization

## Running the Tests

### In Xcode

1. Open `tankgame.xcodeproj` in Xcode
2. Select the test target from the scheme selector
3. Press `Cmd+U` to run all tests
4. Or use `Cmd+6` to open the Test Navigator and run individual tests

### From Command Line

```bash
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame iOS" -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Benefits of the Modular Architecture for Testing

### Before Refactoring
- Monolithic 571-line `GameScene.swift` file
- Difficult to test individual components
- Heavy mocking requirements
- Coupling made isolation impossible

### After Refactoring
- Small, focused entities (`Tank`, `Projectile`, `Direction`)
- Pure functions and structs are easy to test
- No external dependencies for core logic
- Simple initialization without complex setup

## Test Design Principles

1. **Isolation**: Each test is independent and doesn't rely on other tests
2. **Clarity**: Test names clearly describe what is being tested
3. **Coverage**: Tests cover both success and failure paths
4. **Edge Cases**: Boundary conditions and special cases are explicitly tested
5. **Fast**: Unit tests run quickly without external dependencies

## Future Test Additions

Consider adding tests for:
- `SoundManager` (audio playback mock testing)
- `ExplosionEffects` (particle system testing)
- `JoystickController` (input handling)
- `FireButton` (UI interaction)
- `GameSceneRenderer` (rendering logic)
- `MultiplayerManager` (network protocol)
- Integration tests for multiplayer scenarios

## CI/CD Integration

These tests are designed to be run in continuous integration pipelines:
- Fast execution (< 1 second for all tests)
- No external dependencies
- Deterministic results
- Clear pass/fail reporting

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure tests pass before committing
3. Maintain test coverage above 80%
4. Follow existing test naming conventions
5. Add comments for complex test scenarios

## Test Naming Convention

```swift
func test<ComponentName><Scenario>() {
    // Arrange
    // Act
    // Assert
}
```

Examples:
- `testTankMovementBlockedByWall()`
- `testProjectileHitsTankAtPosition()`
- `testGridGeneratorSameSeedProducesSameGrid()`
