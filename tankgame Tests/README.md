# Tank Game Tests

This directory contains basic unit tests for the core game logic components.

## Overview

These tests validate the fundamental game mechanics without requiring iOS/macOS frameworks or simulators. They focus on the pure Swift logic components:

- **Direction** - Cardinal direction enum and offset calculations
- **Tank** - Tank entity, movement, and collision detection
- **Projectile** - Projectile entity, advancement, and hit detection
- **GridCell** - Grid cell types (empty/wall)

## Running Tests

From the repository root, run:

```bash
./run_tests.sh
```

This script will:
1. Compile the core game logic files with the test file
2. Run all test functions
3. Report results

## Test Coverage

### Direction Tests
- ✅ Offset calculations for all four directions (up, down, left, right)
- ✅ Correct row/column deltas for each direction

### Tank Tests
- ✅ Tank initialization with position and direction
- ✅ Valid movement on empty grid cells
- ✅ Blocked movement into walls
- ✅ Boundary checking to prevent out-of-bounds movement
- ✅ Direction updates when moving

### Projectile Tests
- ✅ Projectile initialization with position and direction
- ✅ Projectile advancement in the correct direction
- ✅ Out-of-bounds detection
- ✅ Wall collision detection
- ✅ Tank collision detection

### Tank Shooting Tests
- ✅ Projectile spawns one cell in front of tank
- ✅ Projectile inherits tank's direction

## Test Architecture

The tests use simple assertion-based testing without external frameworks. Each test function:
1. Sets up test data
2. Performs operations
3. Validates results with assertions
4. Reports success

## Future Improvements

- Add XCTest-based unit tests for iOS/macOS specific components
- Add integration tests for multiplayer functionality
- Add UI tests for game scenes
- Add tests for game state management
- Add tests for grid generation

## Note

These tests only cover the platform-independent game logic. Testing the full game with SpriteKit, MultipeerConnectivity, and UI components requires running on iOS/macOS simulators or devices.
