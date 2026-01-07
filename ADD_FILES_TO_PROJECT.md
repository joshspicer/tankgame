# Adding New Files to the Xcode Project

## Current Status

The following files have been created but need to be added to the Xcode project's target membership:

### Files Already in Exception Lists ✅
- Direction.swift
- GameScene.swift
- Projectile.swift

### Files Missing from Exception Lists ⚠️

**tankgame Shared/** (need to be added to all three targets):
- GameEngine.swift
- GameGrid.swift
- NetworkManager.swift
- NetworkMessage.swift
- Player.swift
- Position.swift

**tankgame iOS/** (automatically included):
- AppDelegate.swift
- GameViewController.swift

## Recommended Approach: Use Xcode

### Option 1: Let Xcode Add the Files (EASIEST)

1. Open `tankgame.xcodeproj` in Xcode
2. In the Project Navigator, you should see the new files
3. If files are grayed out or show a warning, select each file
4. In the File Inspector (right panel), check the target membership boxes:
   - ☑ tankgame iOS
   - ☑ tankgame macOS  
   - ☑ tankgame tvOS
5. Xcode will automatically update the project.pbxproj file

### Option 2: Remove and Re-add Files in Xcode

If files don't appear:

1. Open `tankgame.xcodeproj` in Xcode
2. Right-click on "tankgame Shared" in Project Navigator
3. Select "Add Files to 'tankgame'..."
4. Navigate to and select:
   - GameEngine.swift
   - GameGrid.swift
   - NetworkManager.swift
   - NetworkMessage.swift
   - Player.swift
   - Position.swift
5. In the dialog, ensure "Add to targets" has all three checked:
   - ☑ tankgame iOS
   - ☑ tankgame macOS  
   - ☑ tankgame tvOS
6. Click "Add"

## Manual Approach: Edit project.pbxproj

If you must edit manually (not recommended):

### Step 1: Backup
```bash
cp tankgame.xcodeproj/project.pbxproj tankgame.xcodeproj/project.pbxproj.backup
```

### Step 2: Add to iOS Exception List

Find the section starting with:
```
0AEBC84C2EB14C4300890CC1 /* Exceptions for "tankgame Shared" folder in "tankgame iOS" target */
```

Add these lines in alphabetical order within the `membershipExceptions` array:
```
GameEngine.swift,
GameGrid.swift,
NetworkManager.swift,
NetworkMessage.swift,
Player.swift,
Position.swift,
```

The section should look like:
```
membershipExceptions = (
    Actions.sks,
    Assets.xcassets,
    AIBotManager.swift,
    AIBotTank.swift,
    ...
    FireButton.swift,
    GameEngine.swift,        // <-- ADD
    GameGrid.swift,          // <-- ADD  
    GameMessages.swift,
    GameScene.sks,
    GameScene.swift,
    ...
    MultiplayerManager.swift,
    NetworkManager.swift,    // <-- ADD (after MultiplayerManager)
    NetworkMessage.swift,    // <-- ADD (after NetworkManager)
    Player.swift,            // <-- ADD (before Projectile)
    Position.swift,          // <-- ADD (after Player)
    Projectile.swift,
    ...
);
```

### Step 3: Repeat for tvOS

Find the section:
```
0AEBC8502EB14C4300890CC1 /* Exceptions for "tankgame Shared" folder in "tankgame tvOS" target */
```

Add the same files in the same alphabetical positions.

### Step 4: Repeat for macOS

Find the section:
```
0AEBC8542EB14C4300890CC1 /* Exceptions for "tankgame Shared" folder in "tankgame macOS" target */
```

Add the same files in the same alphabetical positions.

### Step 5: Verify

1. Open Xcode and verify no errors
2. Try building each target
3. Check that files appear in Project Navigator with correct target membership

## Automated Script

A Python script is provided to automatically add these files. Run:

```bash
python3 update_xcode_project.py
```

See `update_xcode_project.py` for details.

## Verification

After making changes, verify with Xcode:

1. Open `tankgame.xcodeproj`
2. Select each new Swift file
3. Check File Inspector (⌥⌘1) → Target Membership
4. Ensure all three targets are checked:
   - tankgame iOS
   - tankgame macOS
   - tankgame tvOS
5. Build each target to confirm no missing file errors

## Troubleshooting

### Files don't appear in Xcode
- Close and reopen Xcode
- Clean build folder (⌘⇧K)
- Check file permissions: `ls -la "tankgame Shared/"`

### Build errors about missing files
- Verify files are in exception lists (or in Xcode's target membership)
- Check file paths are correct
- Ensure files have `.swift` extension

### Project file becomes corrupted
- Restore from backup: `cp tankgame.xcodeproj/project.pbxproj.backup tankgame.xcodeproj/project.pbxproj`
- Use git to revert: `git checkout tankgame.xcodeproj/project.pbxproj`
- Let Xcode regenerate by removing and re-adding files

## Notes

- **iOS-specific files** (AppDelegate.swift, GameViewController.swift) don't need exception entries because they're in a platform-specific folder
- **Shared files** must be in exception lists to be included in builds
- **Alphabetical order** is important for maintainability and merge conflict avoidance
- **All three targets** (iOS, macOS, tvOS) should have the same Shared files in most cases
