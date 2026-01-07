# Xcode Project.pbxproj Quick Reference

## What You're Using
**Xcode 15+ File System Synchronization** (`objectVersion = 77`)
- Files auto-discovered from disk
- No manual UUID generation needed
- Minimal pbxproj editing required

---

## File Locations & Behavior

### Platform-Specific Folders (Automatic)
```
tankgame iOS/       → Auto-included in iOS builds only
tankgame macOS/     → Auto-included in macOS builds only  
tankgame tvOS/      → Auto-included in tvOS builds only
```
**Just create the file. No configuration needed!**

### Shared Folder (Needs Configuration)
```
tankgame Shared/    → Must add to exception lists for each target
```
**Files need to be in `membershipExceptions` arrays.**

---

## Exception Lists Explained

### What They Are
Three sections in project.pbxproj that list which Shared files go in which target:
```
Exceptions for "tankgame Shared" folder in "tankgame iOS" target
Exceptions for "tankgame Shared" folder in "tankgame tvOS" target
Exceptions for "tankgame Shared" folder in "tankgame macOS" target
```

### Confusing Name Alert! ⚠️
Files in `membershipExceptions` ARE included (not excluded).
Think of it as "exceptions to being ignored" = "explicitly included"

### Format
```
membershipExceptions = (
    Actions.sks,
    Assets.xcassets,
    AIBotManager.swift,
    Direction.swift,
    GameEngine.swift,        ← Keep alphabetical order
    GameMessages.swift,
    ...
);
```

---

## Adding New Files - Methods

### Method 1: Xcode (BEST) ⭐
```
1. Open tankgame.xcodeproj
2. File → Add Files to "tankgame"
3. Select your new .swift file(s)
4. Check target boxes: ☑ iOS ☑ macOS ☑ tvOS
5. Click Add
```

### Method 2: Automated Script
```bash
cd /home/runner/work/tankgame/tankgame
python3 update_xcode_project.py
```

### Method 3: Manual Edit
```bash
# 1. Backup
cp tankgame.xcodeproj/project.pbxproj{,.backup}

# 2. Edit file
vim tankgame.xcodeproj/project.pbxproj

# 3. Find three sections (search for "membershipExceptions")
# 4. Add filename in alphabetical order to each section
# 5. Save

# 6. Verify in Xcode
open tankgame.xcodeproj
```

---

## Current File Status

### ✅ In Exception Lists
- Direction.swift
- GameScene.swift
- Projectile.swift

### ⚠️ Need to Add
- GameEngine.swift
- GameGrid.swift
- NetworkManager.swift
- NetworkMessage.swift
- Player.swift
- Position.swift

### ✅ Auto-Included (iOS folder)
- AppDelegate.swift
- GameViewController.swift

---

## Quick Commands

### List Files in Shared
```bash
ls "tankgame Shared/"*.swift
```

### See Current iOS Exceptions
```bash
grep -A 50 'tankgame iOS' tankgame.xcodeproj/project.pbxproj | grep '.swift,'
```

### Backup Project File
```bash
cp tankgame.xcodeproj/project.pbxproj{,.backup}
```

### Restore from Backup
```bash
cp tankgame.xcodeproj/project.pbxproj{.backup,}
```

### Test Build (if xcodebuild available)
```bash
xcodebuild -project tankgame.xcodeproj -scheme "tankgame iOS" build
```

---

## File Structure Map

```
project.pbxproj
├── [Lines 1-7]      Header (objectVersion = 77)
├── [Lines 9-13]     PBXFileReference (build products only)
├── [Lines 15-160]   Exception Sets ← YOU EDIT HERE
│   ├── iOS exceptions      (lines ~15-63)
│   ├── tvOS exceptions     (lines ~64-111)
│   └── macOS exceptions    (lines ~112-159)
├── [Lines 162-188]  Synchronized Root Groups
├── [Lines 190-212]  Frameworks Build Phase
├── [Lines 214-236]  PBXGroup
├── [Lines 238-305]  Native Targets
├── [Lines 307-345]  Project
├── [Lines 347-369]  Resources Build Phase
├── [Lines 371-393]  Sources Build Phase (empty arrays)
└── [Lines 395-736]  Build Configuration
```

---

## Editing Exception Lists

### Where to Add
Search for (3 occurrences):
```
membershipExceptions = (
```

### What to Add
Your filename in alphabetical order:
```
membershipExceptions = (
    Actions.sks,
    Assets.xcassets,
    AIBotManager.swift,
    ...
    GameEngine.swift,        ← ADD HERE (after GameMessages.swift)
    ...
    NetworkManager.swift,    ← ADD HERE (after MultiplayerManager.swift)
    ...
);
```

### Important Rules
1. Include the comma: `GameEngine.swift,`
2. Maintain alphabetical order
3. Same indentation as other entries (4 tabs)
4. Add to ALL THREE target sections
5. Make backup first!

---

## Verification Checklist

After making changes:

```
☐ Files exist on disk
☐ Files in Shared folder are in all 3 exception lists
☐ Alphabetical order maintained
☐ Proper formatting (tabs, commas)
☐ Project opens in Xcode without errors
☐ Files appear in Project Navigator
☐ Target membership is correct (File Inspector)
☐ Project builds successfully
☐ Backup created
```

---

## Common Issues

### File doesn't appear in Xcode
```
→ Close and reopen Xcode
→ Check exception list (for Shared files)
→ Clean build folder (⌘⇧K)
```

### Build error: "no such file"
```
→ Verify file exists on disk
→ Check file extension is .swift
→ Verify in exception list
→ Check target membership in Xcode
```

### Project file corrupted
```
→ Restore from backup
→ Or use: git checkout tankgame.xcodeproj/project.pbxproj
→ Worst case: Remove and re-add files in Xcode
```

### Merge conflict
```
→ File system sync reduces conflicts!
→ Accept both changes for new files
→ Maintain alphabetical order
→ Remove duplicates
```

---

## Don't Need to Know (But FYI)

### UUIDs
- 24-character hex strings
- Auto-generated by Xcode
- **You don't need to create them!**
- Example: `0AEBC8092EB14C4000890CC1`

### Old Approach (Pre-Xcode 15)
- Needed 7+ UUID entries per file
- Manual PBXFileReference creation
- Manual PBXBuildFile creation  
- Much more error-prone
- **You're not using this! 🎉**

---

## Documentation Files

```
XCODE_PROJECT_SUMMARY.md           ← Executive overview
XCODE_PROJECT_MANAGEMENT_GUIDE.md  ← Deep technical guide
ADD_FILES_TO_PROJECT.md            ← Step-by-step instructions
XCODE_PROJECT_QUICK_REFERENCE.md   ← This file
update_xcode_project.py            ← Automation script
```

---

## When to Use Each Method

### Use Xcode When:
- Adding 1-5 files
- Not automating
- Want visual confirmation
- **Most common case**

### Use Script When:
- Adding many files
- Automating workflows
- Batch operations
- CI/CD pipelines

### Use Manual Edit When:
- Xcode not available
- Need precise control
- Understanding the format
- **Rare - not recommended**

---

## Remember

1. **File System Sync is your friend** - minimal manual work needed
2. **Platform folders are automatic** - just create files
3. **Shared folder needs configuration** - add to exception lists
4. **Xcode is the safest method** - let it do the work
5. **Backups are important** - especially for manual edits

---

## One-Liner Solutions

**Add all missing files:**
```bash
python3 update_xcode_project.py
```

**Verify in Xcode:**
```bash
open tankgame.xcodeproj
```

**Build and test:**
```bash
xcodebuild -project tankgame.xcodeproj -scheme "tankgame iOS" build
```

Done! 🎉
