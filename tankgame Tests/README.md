# Tank Game Tests

This directory contains comprehensive unit tests for the Tank Game core components.

## Test Coverage

### Core Entities
- **TankTests.swift** - Tests for Tank entity
  - Initialization with default and custom parameters
  - Movement in all four directions
  - Boundary collision detection
  - Wall collision detection
  - Shooting mechanics
  - Codable conformance

- **ProjectileTests.swift** - Tests for Projectile entity
  - Initialization
  - Advancement in all four directions
  - Out-of-bounds detection
  - Wall collision detection
  - Tank hit detection (alive and dead tanks)
  - Codable conformance

- **DirectionTests.swift** - Tests for Direction enum
  - Angle calculations for each direction
  - Row/column offset calculations
  - CaseIterable conformance
  - Raw value initialization
  - Codable conformance
  - Offset application sequences

### Game Logic
- **GameStateTests.swift** - Tests for GameState management
  - Initialization with various player counts
  - Tank spawn position verification
  - Round reset functionality
  - Local tank getter/setter
  - Projectile update logic
  - Tank collision and death
  - Round completion detection
  - Winner determination
  - Win tracking
  - Complete game scenario integration tests

- **GridGeneratorTests.swift** - Tests for procedural grid generation
  - Grid size and structure validation
  - Deterministic generation with same seeds
  - Spawn area protection (4 corners)
  - Border path clearing
  - Wall density constraints (15-30%)
  - SeededRandomNumberGenerator determinism
  - Random number distribution

## Running the Tests

### Using Xcode
1. Open `tankgame.xcodeproj` in Xcode
2. Select the test target (tankgame iOS Tests, tankgame macOS Tests, or tankgame tvOS Tests)
3. Press `⌘U` to run all tests, or click individual test files to run specific test suites
4. View test results in the Test Navigator (⌘6)

### Using xcodebuild (Command Line)
```bash
# Run all iOS tests
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame iOS" -destination 'platform=iOS Simulator,name=iPhone 15'

# Run all macOS tests
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame macOS"

# Run all tvOS tests
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame tvOS" -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Test Statistics

- **Total Test Count**: 93+ unit tests
- **Test Files**: 5
- **Coverage**: Core game logic entities and state management
- **Test Types**: Unit tests, integration tests, edge case tests

## Test Design Principles

1. **Single Responsibility**: Each test verifies one specific behavior
2. **Descriptive Names**: Test names clearly describe what is being tested
3. **Arrange-Act-Assert**: Tests follow the AAA pattern
4. **Independence**: Tests don't depend on each other
5. **Edge Cases**: Tests include boundary conditions and error cases
6. **Determinism**: Tests produce consistent results on every run

## Adding New Tests

When adding new tests:

1. Create a new test file named `[ComponentName]Tests.swift`
2. Import XCTest and `@testable import tankgame_iOS` (or appropriate target)
3. Create a test class that inherits from `XCTestCase`
4. Use descriptive test names starting with `test`
5. Follow the existing test structure and patterns
6. Add the test file to the test target in Xcode

Example:
```swift
import XCTest
@testable import tankgame_iOS

final class NewComponentTests: XCTestCase {
    func testSpecificBehavior() {
        // Arrange
        let component = NewComponent()
        
        // Act
        let result = component.doSomething()
        
        // Assert
        XCTAssertEqual(result, expectedValue)
    }
}
```

## Future Testing Goals

- [ ] Add UI tests for game scenes
- [ ] Add integration tests for multiplayer functionality
- [ ] Add performance tests for rendering
- [ ] Add tests for sound manager
- [ ] Add tests for visual effects
- [ ] Achieve >80% code coverage
- [ ] Add continuous integration testing

## Notes

- Tests use the iOS target by default (`@testable import tankgame_iOS`)
- Tests are deterministic thanks to seeded random number generation
- Grid generation tests verify spawn area protection for all 4 players
- Game state tests include complete game scenarios to validate integration
