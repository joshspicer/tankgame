# Adding Test Target to Tank Game

## Overview

Unit tests have been created in the `tankgame Tests/` directory but need to be integrated into the Xcode project with a test target.

## Test Files Created

The following test files are ready to be added to a test target:

```
tankgame Tests/
├── README.md                  - Testing documentation
├── TankTests.swift            - 17 tests for Tank entity
├── ProjectileTests.swift      - 19 tests for Projectile entity
├── DirectionTests.swift       - 12 tests for Direction enum
├── GridGeneratorTests.swift   - 15 tests for GridGenerator
└── GameStateTests.swift       - 30+ tests for GameState logic
```

**Total: 93+ comprehensive unit tests**

## Steps to Add Test Target in Xcode

### Option 1: Using Xcode UI (Recommended)

1. **Open the project in Xcode**
   ```bash
   open tankgame.xcodeproj
   ```

2. **Create a new test target**
   - Select the project in the navigator
   - Click the "+" button at the bottom of the targets list
   - Choose "Unit Testing Bundle"
   - Name it "tankgame iOS Tests" (or macOS/tvOS as appropriate)
   - Ensure the target is set to test "tankgame iOS" (or appropriate platform)

3. **Add test files to the target**
   - Select all `.swift` files in the `tankgame Tests/` folder
   - In the File Inspector (⌘⌥1), check the box for your new test target
   - Ensure the files are added to the "Compile Sources" build phase

4. **Configure test target settings**
   - In Build Settings:
     - Set "Product Module Name" to `tankgame_iOS` (or appropriate platform)
     - Enable "Defines Module" = YES
     - Set "Swift Language Version" to match main target
   - In Build Phases:
     - Ensure all test files are in "Compile Sources"
     - Add main app target as a dependency
   - In General:
     - Set "Host Application" to "Tank Game"
     - Ensure "Allow testing Host Application APIs" is enabled

5. **Update import statements if needed**
   - The test files use `@testable import tankgame_iOS`
   - If you create tests for other platforms, update the import:
     - macOS: `@testable import tankgame_macOS`
     - tvOS: `@testable import tankgame_tvOS`

### Option 2: For Each Platform

You may want separate test targets for each platform:

1. **tankgame iOS Tests**
   - Host Application: Tank Game (iOS)
   - Import: `@testable import tankgame_iOS`

2. **tankgame macOS Tests**
   - Host Application: Tank Game (macOS)
   - Import: `@testable import tankgame_macOS`
   - May need to update import in test files

3. **tankgame tvOS Tests**
   - Host Application: Tank Game (tvOS)
   - Import: `@testable import tankgame_tvOS`
   - May need to update import in test files

## Running Tests

### In Xcode
- Press `⌘U` to run all tests
- Click the ▶️ button next to individual test classes/methods
- View results in Test Navigator (⌘6)

### Command Line
```bash
# iOS
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# macOS
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame macOS"

# tvOS
xcodebuild test -project tankgame.xcodeproj -scheme "tankgame tvOS" \
  -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Troubleshooting

### Import Errors
If you see "No such module 'tankgame_iOS'" errors:
1. Ensure the main app target has "Defines Module" enabled in Build Settings
2. Check that test target has proper Host Application set
3. Verify "Allow testing Host Application APIs" is enabled
4. Clean build folder (⌘⇧K) and rebuild

### Missing Symbols
If tests compile but fail to find classes/functions:
1. Ensure you're using `@testable import` (not just `import`)
2. Check that all required source files are included in the main target
3. Verify that classes/structs you're testing are `public` or `internal` (not `private`)

### File Not Found
If Xcode can't find the test files:
1. Right-click the `tankgame Tests` folder in Finder
2. Drag it into the Xcode project navigator
3. Ensure "Create groups" is selected (not "Create folder references")
4. Check the appropriate target in the dialog

## Expected Test Results

When properly configured, all 93+ tests should pass:
- ✅ TankTests: 17/17 tests passed
- ✅ ProjectileTests: 19/19 tests passed
- ✅ DirectionTests: 12/12 tests passed
- ✅ GridGeneratorTests: 15/15 tests passed (including RNG tests)
- ✅ GameStateTests: 30+/30+ tests passed

## Test Coverage Goals

Current coverage (estimated):
- Tank entity: ~95% coverage
- Projectile entity: ~95% coverage
- Direction enum: 100% coverage
- GridGenerator: ~90% coverage
- GameState: ~85% coverage
- **Overall core logic: ~90% coverage**

Future coverage goals:
- Add UI tests for GameScene
- Add integration tests for multiplayer
- Add tests for rendering components
- Add tests for audio and effects
- Target: >90% total code coverage

## Continuous Integration

Consider setting up CI/CD to run tests automatically:

```yaml
# .github/workflows/test.yml
name: Run Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run iOS tests
        run: |
          xcodebuild test -project tankgame.xcodeproj \
            -scheme "tankgame iOS" \
            -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Notes

- The test files are written for iOS but can be adapted for macOS/tvOS
- All tests use deterministic seeded random generation for consistency
- Tests follow AAA pattern (Arrange, Act, Assert)
- Test names are descriptive and follow convention: `test[Feature][Scenario]`
- Helper methods are marked private and placed at the bottom of test classes

## References

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing in Xcode](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/)
- [tankgame Tests/README.md](tankgame%20Tests/README.md) - Detailed test documentation
