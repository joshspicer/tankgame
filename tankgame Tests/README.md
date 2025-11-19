# Tank Game Tests

This directory contains unit tests for the Tank Game's core game logic.

## Test Coverage

### TankTests.swift
Tests for the `Tank` entity:
- Initialization and default values
- Movement in all directions
- Collision detection with walls and boundaries
- Shooting mechanics
- Codable serialization/deserialization

### ProjectileTests.swift
Tests for the `Projectile` entity:
- Initialization and movement
- Advancement in all directions
- Boundary detection
- Wall collision detection
- Tank hit detection
- Codable serialization/deserialization

### GameStateTests.swift
Tests for the `GameState` game logic:
- Initialization with different player counts
- Tank spawn positions
- Game reset functionality
- Local tank accessor
- Projectile updates and collisions
- Round status detection
- Winner determination
- Grid generation consistency

### GridGeneratorTests.swift
Tests for the `GridGenerator`:
- Grid size validation
- Deterministic generation with seeds
- Spawn point protection for all 4 players
- Border path clearing
- Wall density constraints
- Seeded random number generator
- Grid playability

## Running the Tests

These tests are designed to be run with Xcode's XCTest framework:

1. Open `tankgame.xcodeproj` in Xcode
2. Select the test target
3. Press `Cmd+U` to run all tests
4. Or use `Cmd+Ctrl+U` to run a single test

## Test Philosophy

These tests focus on:
- **Core game logic** - Pure functions and state management
- **Determinism** - Ensuring same inputs produce same outputs
- **Edge cases** - Boundary conditions and error cases
- **Multiplayer support** - Validating 2-4 player configurations

## Adding New Tests

When adding new features:
1. Write tests first (TDD approach)
2. Test both success and failure cases
3. Include edge cases and boundary conditions
4. Ensure tests are independent and can run in any order
5. Use descriptive test names that explain what is being tested

## Test Maintenance

- Keep tests simple and focused on one thing
- Update tests when game logic changes
- Remove tests for removed features
- Refactor tests when they become hard to understand
