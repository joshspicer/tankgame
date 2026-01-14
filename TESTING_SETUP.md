# Adding Test Target to Tank Game

This guide walks through adding a test target to the Tank Game Xcode project.

## Prerequisites

- Xcode installed on macOS
- Tank Game project opened in Xcode

## Steps to Add Test Target

### 1. Create the Test Target

1. In Xcode, open `tankgame.xcodeproj`
2. Go to **File → New → Target...**
3. Select **iOS** at the top
4. Choose **Unit Testing Bundle**
5. Click **Next**
6. Configure the target:
   - **Product Name**: `tankgame iOS Tests`
   - **Team**: Select your development team
   - **Organization Identifier**: Use the same as the main app
   - **Project**: tankgame
   - **Embed in Application**: tankgame iOS
7. Click **Finish**

### 2. Add Test Files to Target

1. In the Project Navigator, locate the test files in `tankgame Shared/`:
   - `GameStateTests.swift`
   - `DirectionTests.swift`
   - `TankTests.swift`
   - `CollisionDetectionTests.swift`
   - `ProjectileTests.swift`

2. For each test file:
   - Select the file in Project Navigator
   - Open the File Inspector (right sidebar, first tab)
   - Under **Target Membership**, check `tankgame iOS Tests`
   - Uncheck any other targets if they were automatically added

### 3. Configure Test Target Settings

1. Select the project in Project Navigator
2. Select the `tankgame iOS Tests` target
3. Go to **Build Settings** tab
4. Search for "Allow testing Host Application APIs"
5. Set it to **Yes**

### 4. Add Source Files to Test Target

The test target needs access to the source code. Add the following files from `tankgame Shared/` to the test target:

**Required source files:**
- `GameState.swift`
- `Direction.swift`
- `Tank.swift`
- `Projectile.swift`
- `GridCell.swift`
- `CollisionDetection.swift`
- `Lizard.swift`
- `GridGenerator.swift`
- `LizardSpawner.swift`
- `AIBotManager.swift`

**To add them:**
1. Select each file in Project Navigator
2. In File Inspector, under **Target Membership**
3. Check `tankgame iOS Tests` (in addition to existing targets)

### 5. Run Tests

Once configured, you can run tests:

- **Keyboard**: Press `Cmd+U`
- **Menu**: Product → Test
- **Test Navigator**: Click the play button next to the test target or individual test classes

## Alternative: Manual Test Target via pbxproj

If you prefer to edit the project file directly (advanced):

```bash
# Backup the project file first!
cp tankgame.xcodeproj/project.pbxproj tankgame.xcodeproj/project.pbxproj.backup

# Then carefully edit tankgame.xcodeproj/project.pbxproj
# This is NOT recommended as it's error-prone
```

## Troubleshooting

### Build Errors: "Use of unresolved identifier"

**Solution**: Make sure all required source files are added to the test target's Target Membership.

### "No such module 'tankgame'"

**Solution**: 

Option 1 (Recommended): Remove the `@testable import tankgame` line from each test file and add all required source files to the test target's Target Membership.

Option 2: Change the import to match the actual module name: `@testable import Tank_Game` (note the underscore).

For simplicity, Option 1 is recommended as it doesn't require module imports.

### "Host application not found"

**Solution**: In test target settings, ensure "Host Application" is set to `tankgame iOS`.

### Tests Don't Appear

**Solution**: Make sure test files are added to the test target, not the main app target.

## Running Tests from Command Line

Once the test target is set up in Xcode, you can run tests from the command line:

```bash
# List available schemes
xcodebuild -list -project tankgame.xcodeproj

# Run tests
xcodebuild test \
  -project tankgame.xcodeproj \
  -scheme "tankgame iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Continuous Integration

For CI/CD pipelines, use the command line approach:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    xcodebuild test \
      -project tankgame.xcodeproj \
      -scheme "tankgame iOS" \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      -quiet
```

## Next Steps

After setting up the test target:

1. Run the tests to ensure they pass
2. Add tests to your development workflow
3. Consider adding UI tests for the game interface
4. Set up code coverage reporting in Xcode (Product → Scheme → Edit Scheme → Test → Options → Code Coverage)

## Test Organization

The tests are organized by component:

- **GameStateTests**: Tests game state management and round logic
- **DirectionTests**: Tests the Direction enum and its properties
- **TankTests**: Tests tank movement and shooting
- **CollisionDetectionTests**: Tests collision detection utilities
- **ProjectileTests**: Tests projectile behavior and collisions

Each test file is self-contained and can be run independently.
