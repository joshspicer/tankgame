# Tank Game Unit Tests

This directory contains comprehensive unit tests for the Tank Game's core game logic.

## Test Files

### GameStateTests.swift
Tests for the main game state management:
- Game initialization with various player counts
- Bot player initialization
- Spawn position validation
- Round management (isRoundOver, getWinner)
- Local player win detection
- Game reset functionality
- Projectile updates and collision handling
- Lizard spawning and management

### DirectionTests.swift
Tests for the Direction enum:
- Angle calculations for all 8 directions
- Offset calculations (row/col changes)
- Diagonal direction detection
- Cardinal directions array
- Codable conformance
- Raw value initialization

### TankTests.swift
Tests for Tank entity behavior:
- Tank initialization
- Movement in all directions
- Movement blocking (walls, boundaries)
- Diagonal movement
- Shooting mechanics
- Projectile creation
- Codable conformance

### CollisionDetectionTests.swift
Tests for collision detection utilities:
- Wall collision detection
- Bounds checking (various scenarios)
- Position matching
- Projectile-tank collisions
- Projectile-lizard collisions
- Integration scenarios

### ProjectileTests.swift
Tests for Projectile entity behavior:
- Projectile initialization
- Advancement in all directions
- Multiple advances
- Bounds checking
- Grid collision (walls)
- Tank hit detection
- Lizard hit detection
- Codable conformance
- Full lifecycle testing

## Running the Tests

### Option 1: Add to Xcode Project (Recommended)

1. Open `tankgame.xcodeproj` in Xcode
2. Create a new test target:
   - File → New → Target
   - Select "iOS Unit Testing Bundle"
   - Name it "tankgame Tests"
3. Add the test files to the new test target
4. Make sure to set "Allow testing Host Application APIs" in the test target settings
5. Run tests with `Cmd+U` or Product → Test

### Option 2: Swift Package Manager

If the project is converted to use SPM, add a test target to `Package.swift`:

```swift
.testTarget(
    name: "tankgameTests",
    dependencies: ["tankgame"]
)
```

Then run: `swift test`

### Option 3: Command Line with xcodebuild

```bash
xcodebuild test \
  -project tankgame.xcodeproj \
  -scheme "tankgame iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Coverage

These tests cover the core game logic including:
- ✅ Game state management
- ✅ Entity behavior (tanks, projectiles, lizards)
- ✅ Collision detection
- ✅ Movement mechanics
- ✅ Direction and grid utilities
- ✅ Codable conformance for networking

## What's Not Tested

The following areas are not covered by these unit tests and may require different testing approaches:
- UI/View components (requires UI tests)
- Multiplayer networking (requires integration tests)
- SpriteKit rendering (requires integration tests)
- Sound effects
- AI bot behavior (AIBotManager)
- Crash reporting

## Writing New Tests

When adding new features:
1. Create a new test file following the naming pattern: `[Feature]Tests.swift`
2. Import XCTest and the tankgame module with `@testable`
3. Follow the existing test structure with MARK comments for organization
4. Test both success and failure cases
5. Test boundary conditions
6. Add helper methods for common setup code

Example:
```swift
import XCTest
@testable import tankgame

class MyFeatureTests: XCTestCase {
    
    // MARK: - Basic Tests
    
    func testFeatureWorks() {
        // Arrange
        let feature = MyFeature()
        
        // Act
        let result = feature.doSomething()
        
        // Assert
        XCTAssertTrue(result)
    }
}
```

## Test Philosophy

These tests follow these principles:
- **Focused**: Each test tests one specific behavior
- **Independent**: Tests don't depend on each other
- **Readable**: Test names clearly describe what they test
- **Fast**: No external dependencies or network calls
- **Deterministic**: Same input always produces same output

## Contributing

When modifying game logic:
1. Run existing tests to ensure no regressions
2. Add tests for new functionality
3. Update tests when behavior intentionally changes
4. Keep tests in sync with implementation
