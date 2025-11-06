# Integrating Unit Tests into Xcode Project

This guide explains how to add the unit test files to your Xcode project.

## Steps to Add Tests to Xcode

### 1. Open the Project
Open `tankgame.xcodeproj` in Xcode.

### 2. Create a Test Target (if not exists)

1. In Xcode, select **File** → **New** → **Target...**
2. Choose **iOS** → **Unit Testing Bundle** (or **macOS** → **Unit Testing Bundle** for macOS)
3. Name it `tankgame Tests`
4. Set the target to be tested to your main app target
5. Click **Finish**

### 3. Add Test Files to the Test Target

#### Option A: Using Xcode UI

1. In the Project Navigator (left sidebar), locate the `tankgame Tests` folder
2. Right-click on it and select **Add Files to "tankgame"...**
3. Navigate to the `tankgame Tests` folder in your project directory
4. Select all the `.swift` test files:
   - `DirectionTests.swift`
   - `GridCellTests.swift`
   - `TankTests.swift`
   - `ProjectileTests.swift`
   - `GridGeneratorTests.swift`
   - `GameStateTests.swift`
   - `GameMessageTests.swift`
5. Make sure "Copy items if needed" is **unchecked** (files are already in place)
6. Make sure the `tankgame Tests` target is **checked** in "Add to targets"
7. Click **Add**

#### Option B: Drag and Drop

1. Open Finder and navigate to your project directory
2. Locate the `tankgame Tests` folder
3. Drag all `.swift` files from Finder into the `tankgame Tests` group in Xcode
4. In the dialog that appears:
   - Uncheck "Copy items if needed"
   - Check the `tankgame Tests` target
   - Click **Finish**

### 4. Configure Test Target

1. Select your project in the Project Navigator
2. Select the `tankgame Tests` target
3. Go to **Build Phases** → **Link Binary With Libraries**
4. Add the main app target if it's not already there
5. Go to **Build Settings** and ensure:
   - **Test Host** points to your main app
   - **Bundle Loader** is set correctly

### 5. Configure Shared Code Access

The tests need access to the shared game code. Ensure the shared Swift files are included in the main target:

1. Select each shared Swift file (Tank.swift, Direction.swift, etc.) in the Project Navigator
2. In the File Inspector (right sidebar), check that the appropriate target membership is set
3. The files in `tankgame Shared` should be members of:
   - `tankgame iOS` (for iOS tests)
   - `tankgame macOS` (for macOS tests)

### 6. Run the Tests

#### In Xcode
- Press `Cmd + U` to run all tests
- Or use `Cmd + 6` to open the Test Navigator
- Click the play button next to individual test classes or methods to run specific tests

#### From Command Line
```bash
# For iOS Simulator
xcodebuild test \
  -project tankgame.xcodeproj \
  -scheme "tankgame iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'

# For macOS
xcodebuild test \
  -project tankgame.xcodeproj \
  -scheme "tankgame macOS" \
  -destination 'platform=macOS'
```

## Troubleshooting

### "Use of unresolved identifier" errors

If you see errors like `Use of unresolved identifier 'Tank'`:

1. Make sure you have `@testable import tankgame` at the top of each test file
2. Verify that the main source files are part of the target you're testing
3. Clean the build folder: **Product** → **Clean Build Folder** (`Shift + Cmd + K`)

### "No such module 'tankgame'" error

1. Make sure the test target has the correct **Host Application** set in Build Settings
2. Verify the main app builds successfully before running tests
3. Check that the scheme includes the main app target

### Tests not appearing in Test Navigator

1. Make sure test files are added to the test target (check target membership)
2. Make sure test methods start with `test` (e.g., `testTankMovement`)
3. Make sure test classes inherit from `XCTestCase`
4. Clean and rebuild the project

### Build errors in shared files

If the shared files show errors:

1. Check that they have the correct target membership
2. Verify all dependencies are properly linked
3. Make sure import statements are correct (e.g., `import SpriteKit`, `import Foundation`)

## Test Coverage

Once the tests are integrated, you can view code coverage:

1. Edit your scheme: **Product** → **Scheme** → **Edit Scheme...**
2. Select **Test** in the left sidebar
3. Go to the **Options** tab
4. Check **Gather coverage for some targets** and select your main target
5. Run tests with `Cmd + U`
6. View coverage: **Show the Report Navigator** (Cmd + 9) → **Coverage** tab

## Continuous Integration

To run these tests in CI:

### GitHub Actions Example

```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          xcodebuild test \
            -project tankgame.xcodeproj \
            -scheme "tankgame iOS" \
            -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Next Steps

After integrating the tests:

1. Run all tests to ensure they pass
2. Add tests to your CI/CD pipeline
3. Write additional tests as you add new features
4. Aim for high code coverage (>80%)
5. Consider adding UI tests for game interactions
