# Adding Unit Tests to Tank Game Project

This guide explains how to integrate the unit tests into your Xcode project.

## Overview

Unit tests have been created for the core game components:
- Tank entity
- Projectile entity
- Direction enum
- GameState logic
- GridGenerator

## Integration Steps

### Option 1: Using Xcode GUI (Recommended)

1. **Open the project in Xcode**
   ```bash
   open tankgame.xcodeproj
   ```

2. **Create a new test target**
   - Go to File → New → Target
   - Choose "iOS Unit Testing Bundle"
   - Name it "tankgame Tests"
   - Set the target to be tested: "tankgame iOS"
   - Click Finish

3. **Add test files to the target**
   - Delete the default test file created by Xcode
   - In Finder, drag the `tankgame Tests` folder into your Xcode project
   - Check "Copy items if needed"
   - Select the test target you just created
   - Click Add

4. **Configure the test target**
   - Select the project in the navigator
   - Select the "tankgame Tests" target
   - Go to "Build Settings"
   - Search for "Bundle Identifier" and set it to something like `com.tankgame.tests`
   - Go to "General" tab
   - Under "Testing", ensure "Tank Game" is selected as the "Target to be Tested"

5. **Run the tests**
   - Press `Cmd+U` or
   - Product → Test

### Option 2: Manual Xcode Project File Editing

If you prefer to edit the project file directly:

1. Open `tankgame.xcodeproj/project.pbxproj` in a text editor

2. Add a new PBXNativeTarget for tests (follow existing target patterns)

3. Add test files to PBXFileReference section

4. Add test files to PBXBuildFile section

5. Update PBXProject section to include the new test target

Note: This approach is error-prone and not recommended. Use Xcode GUI instead.

## Verifying the Setup

After integration, verify that:

1. **All test files are visible** in Xcode's Project Navigator under "tankgame Tests"

2. **The test navigator shows all tests**
   - Press `Cmd+6` to open the Test Navigator
   - You should see all test classes and methods

3. **Tests can run**
   - Select the test scheme
   - Press `Cmd+U`
   - All tests should pass (green checkmarks)

## Expected Test Results

All tests should pass:
- ✅ TankTests (15 tests)
- ✅ ProjectileTests (15 tests)
- ✅ DirectionTests (6 tests)
- ✅ GameStateTests (24 tests)
- ✅ GridGeneratorTests (9 tests)

**Total: 69 tests**

## Troubleshooting

### Issue: "No such module 'Tank_Game'"
**Solution**: 
- Ensure the test target has the main app target as a dependency
- Check that the main target's module name is "Tank_Game" (with underscore, not space)
- In Build Settings, verify "Enable Testability" is set to "Yes" for Debug builds

### Issue: Tests don't appear in Test Navigator
**Solution**:
- Clean the build folder (Cmd+Shift+K)
- Build the project (Cmd+B)
- Close and reopen Xcode

### Issue: "Undefined symbols" errors
**Solution**:
- Ensure all tested files are included in the Compile Sources build phase
- Check that `@testable import Tank_Game` is at the top of each test file
- Verify the module name matches your app target name

### Issue: Tests fail on CI/CD
**Solution**:
- Use `xcodebuild` with proper scheme and destination:
  ```bash
  xcodebuild test \
    -project tankgame.xcodeproj \
    -scheme "tankgame iOS" \
    -destination "platform=iOS Simulator,name=iPhone 15"
  ```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app
      
      - name: Run tests
        run: |
          xcodebuild test \
            -project tankgame.xcodeproj \
            -scheme "tankgame iOS" \
            -destination "platform=iOS Simulator,name=iPhone 15" \
            -enableCodeCoverage YES
```

## Code Coverage

To view code coverage:
1. Run tests with coverage enabled
2. Go to Report Navigator (Cmd+9)
3. Select the test report
4. Click the "Coverage" tab

Expected coverage for tested components:
- Tank: ~95%
- Projectile: ~95%
- Direction: ~95%
- GameState: ~85%
- GridGenerator: ~90%

## Next Steps

Consider adding tests for:
- UI components (JoystickController, FireButton)
- Rendering logic (GameSceneRenderer)
- Multiplayer coordination
- Audio components
- Integration tests for full game flow

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing with Xcode](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/)
- [Unit Testing Best Practices](https://developer.apple.com/videos/play/wwdc2020/10147/)
