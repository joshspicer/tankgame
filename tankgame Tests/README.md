# Tank Game Unit Tests

This directory contains comprehensive unit tests for the Tank Game project.

## Test Coverage

The test suite includes tests for the following components:

### 1. **DirectionTests**
- Tests for the Direction enum
- Validates angle calculations for each direction
- Tests offset calculations (row/col changes)
- Verifies CaseIterable conformance
- Tests Codable encoding/decoding

### 2. **TankTests**
- Tests tank initialization
- Tests tank movement in all directions
- Tests boundary collision detection
- Tests wall collision detection
- Tests shooting projectiles
- Tests Codable encoding/decoding

### 3. **ProjectileTests**
- Tests projectile initialization
- Tests projectile advancement
- Tests out-of-bounds detection
- Tests wall collision detection
- Tests tank hit detection
- Tests Codable encoding/decoding

### 4. **GridCellTests**
- Tests GridCell enum values
- Tests equality comparisons
- Tests Codable encoding/decoding
- Tests raw value initialization

### 5. **GridGeneratorTests**
- Tests grid generation with correct size
- Tests deterministic generation (same seed = same grid)
- Tests that different seeds produce different grids
- Tests spawn area protection (top-left and bottom-right)
- Tests border path clearing
- Tests SeededRandomNumberGenerator

### 6. **GameStateTests**
- Tests game state initialization for both players
- Tests tank starting positions
- Tests grid size
- Tests game state reset
- Tests projectile updates and collisions
- Tests round-over detection
- Tests win condition logic

### 7. **GameMessageTests**
- Tests encoding/decoding of all message types
- Tests roundStart messages
- Tests playerMove messages
- Tests playerShoot messages
- Tests playerHit messages
- Tests readyForNextRound messages

## How to Run Tests

### In Xcode

1. Open `tankgame.xcodeproj` in Xcode
2. Add the test files to your test target (if not already included)
3. Select the test target in the scheme selector
4. Press `Cmd + U` to run all tests
5. Or use `Cmd + 6` to open the Test Navigator and run individual tests

### From Command Line

```bash
xcodebuild test -project tankgame.xcodeproj -scheme tankgame -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or for macOS:

```bash
xcodebuild test -project tankgame.xcodeproj -scheme tankgame -destination 'platform=macOS'
```

## Test Structure

Each test file follows the standard XCTest pattern:

```swift
import XCTest
@testable import tankgame

class SomeTests: XCTestCase {
    func testSomething() {
        // Arrange
        let object = SomeObject()
        
        // Act
        let result = object.doSomething()
        
        // Assert
        XCTAssertEqual(result, expectedValue)
    }
}
```

## Adding New Tests

When adding new functionality to the game:

1. Create a new test file or add to an existing one
2. Follow the naming convention: `ComponentNameTests.swift`
3. Use descriptive test method names: `testWhatIsBeingTested`
4. Use the Arrange-Act-Assert pattern
5. Test both success and failure cases
6. Test edge cases and boundary conditions

## Test Data

Tests use predefined seeds for GridGenerator to ensure reproducibility:
- `12345` - Common test seed
- `54321` - Alternative test seed
- `99999`, `88888`, etc. - Specific scenario seeds

## Continuous Integration

These tests can be integrated into a CI/CD pipeline using:
- GitHub Actions
- Xcode Cloud
- Fastlane
- Other CI systems that support `xcodebuild`

## Notes

- All tests are independent and can run in any order
- Tests do not modify shared state
- Tests use deterministic random generation for reproducibility
- Mock objects may be needed for MultiplayerManager tests (not included yet)
