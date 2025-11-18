# Tank Game Unit Tests

This directory contains unit tests for the Tank Game core components.

## Test Coverage

### Core Entities
- **TankTests.swift** - Tests for Tank entity
  - Initialization
  - Movement in all directions
  - Boundary checking
  - Wall collision
  - Shooting mechanics
  
- **ProjectileTests.swift** - Tests for Projectile entity
  - Initialization
  - Advancement in all directions
  - Boundary detection
  - Wall collision detection
  - Tank hit detection

- **DirectionTests.swift** - Tests for Direction enum
  - Offset calculations for all directions
  - Codable conformance
  - Uniqueness of offsets

### Game Logic
- **GameStateTests.swift** - Tests for GameState
  - Initialization with different player counts
  - Spawn positions
  - Tank lifecycle management
  - Projectile management
  - Round completion logic
  - Winner determination
  - Grid generation integration
  
- **GridGeneratorTests.swift** - Tests for GridGenerator
  - Grid size validation
  - Seed reproducibility
  - Corner spawn positions
  - Grid variety

## Running Tests

### Using Xcode
1. Open `tankgame.xcodeproj` in Xcode
2. Select the test target
3. Press `Cmd+U` to run all tests
4. Or select specific test files/methods to run

### Using Command Line
```bash
xcodebuild test -scheme "tankgame iOS" -destination "platform=iOS Simulator,name=iPhone 15"
```

## Adding New Tests

When adding new game components:
1. Create a corresponding test file in this directory
2. Follow the existing naming convention: `ComponentNameTests.swift`
3. Import XCTest and the main module: `@testable import Tank_Game`
4. Write focused, isolated tests for each public method
5. Use descriptive test method names starting with `test`

## Test Philosophy

These tests follow these principles:
- **Isolated**: Each test is independent and doesn't rely on other tests
- **Focused**: Each test verifies one specific behavior
- **Fast**: Tests run quickly without external dependencies
- **Deterministic**: Tests produce the same result every time
- **Readable**: Test names clearly describe what is being tested

## Coverage Notes

Current test coverage focuses on:
- ✅ Core game entities (Tank, Projectile, Direction, GridCell)
- ✅ Game logic (GameState, GridGenerator)
- ⚠️ Not yet covered: UI components, rendering, audio, networking

Future test additions could include:
- UI component tests (JoystickController, FireButton, GameSceneUI)
- Rendering tests (GameSceneRenderer, ExplosionEffects)
- Integration tests for multiplayer functionality
- Performance tests for game loop
