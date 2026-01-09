# Unit Testing Guide

This project includes comprehensive unit tests for the core game logic components.

## Test Coverage

The test suite covers the following components:

### 1. DirectionTests
Tests for the `Direction` enum including:
- Angle calculations for all 8 directions
- Offset calculations (cardinal and diagonal)
- Diagonal direction detection
- Cardinal directions array
- Codable conformance

### 2. TankTests
Tests for the `Tank` struct including:
- Initialization with default and custom directions
- Movement in all cardinal directions
- Boundary checking (preventing out-of-bounds movement)
- Wall collision detection
- Shooting projectiles in all directions
- Codable conformance

### 3. ProjectileTests
Tests for the `Projectile` struct including:
- Advancement in all directions including diagonals
- Out of bounds detection
- Grid collision (hitting walls)
- Tank collision detection (alive vs dead tanks)
- Lizard collision detection
- Codable conformance

### 4. GridGeneratorTests
Tests for the `GridGenerator` including:
- Grid size validation (8x8)
- Deterministic generation (same seed → same grid)
- Spawn area protection (corners clear for player spawns)
- Border path protection (edges clear for movement)
- Wall density validation
- Seeded random number generator determinism

### 5. GameStateTests
Tests for the `GameState` class including:
- Initialization with multiple player counts
- Tank spawn positioning
- Local tank getter/setter
- Reset functionality (projectiles, tank positions, alive status)
- Projectile updates (advancement, removal, collisions)
- Round over detection
- Winner determination
- Lizard spawning

## Running Tests

### In Xcode

1. Open `tankgame.xcodeproj` in Xcode
2. Select the "tankgame Tests" scheme
3. Press `Cmd+U` to run all tests
4. Or use `Cmd+Ctrl+U` to run tests without building

Alternatively, you can:
- Click on any individual test method and click the diamond icon to run that specific test
- Right-click on a test class and select "Run" to run all tests in that class

### Test Target

The test target is configured to:
- Test against the iOS app target (`tankgame iOS`)
- Use iOS SDK 18.0+
- Import the main app module using `@testable import Tank_Game`
- Run as unit tests (not UI tests)

## Test Structure

All test files follow this structure:

```swift
import XCTest
@testable import Tank_Game

final class [Component]Tests: XCTestCase {

    // MARK: - [Category] Tests

    func test[Behavior]() {
        // Arrange
        // Act
        // Assert
    }
}
```

## Adding New Tests

To add new tests:

1. Create a new Swift file in the `tankgame Tests` directory
2. Import XCTest and the main module:
   ```swift
   import XCTest
   @testable import Tank_Game
   ```
3. Create a test class that inherits from `XCTestCase`
4. Add test methods starting with `test` prefix
5. Use XCTest assertions (`XCTAssertEqual`, `XCTAssertTrue`, etc.)

## Best Practices

- **Test naming**: Use descriptive names that explain what is being tested
- **Arrange-Act-Assert**: Structure tests clearly with setup, execution, and verification
- **Independence**: Each test should be independent and not rely on other tests
- **Coverage**: Focus on testing business logic and edge cases
- **Fast**: Unit tests should run quickly (no network calls, no file I/O when possible)

## Notes

- The test target uses the file system synchronized groups feature (Xcode 15+)
- Tests automatically discover and run all methods prefixed with `test`
- Helper methods (without `test` prefix) can be used for common setup
- The `@testable` import allows tests to access internal types and methods

## CI/CD Integration

Tests can be run in CI/CD pipelines using:

```bash
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame Tests" -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or with more verbose output:

```bash
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame Tests" -destination 'platform=iOS Simulator,name=iPhone 15' | xcpretty
```
