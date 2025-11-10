# Settings Menu Implementation

This PR adds a settings menu to the tank game with the following features:

## Changes Made

### 1. New Files Created

- **`tankgame Shared/Settings.swift`**: A singleton class that manages user preferences using UserDefaults
  - Sound effects toggle
  - Music toggle  
  - Joystick sensitivity (0.5x to 2.0x)
  - Player name

- **`tankgame iOS/SettingsViewController.swift`**: A full-screen settings UI with:
  - Switches for sound and music
  - Slider for joystick sensitivity
  - Text field for player name
  - Done button to dismiss

### 2. Modified Files

- **`tankgame iOS/GameViewController.swift`**:
  - Added a "⚙️ Settings" button to the lobby UI
  - Settings button opens the SettingsViewController in full-screen modal

- **`tankgame Shared/GameScene.swift`**:
  - Applied joystick sensitivity setting to the touch processing
  - The joystick now responds with configurable sensitivity

## Setup Required

⚠️ **IMPORTANT**: The new Swift files need to be added to the Xcode project manually:

1. Open `tankgame.xcodeproj` in Xcode
2. Right-click on the "tankgame Shared" group
3. Select "Add Files to tankgame..."
4. Navigate to and select `tankgame Shared/Settings.swift`
5. Make sure to check all targets (iOS, macOS, tvOS)
6. Right-click on the "tankgame iOS" group  
7. Select "Add Files to tankgame..."
8. Navigate to and select `tankgame iOS/SettingsViewController.swift`
9. Check only the iOS target
10. Build and run

## Features

### Settings Available

1. **Sound Effects**: Toggle sound effects on/off (currently no sounds implemented, but infrastructure is ready)
2. **Music**: Toggle music on/off (currently no music implemented, but infrastructure is ready)
3. **Joystick Sensitivity**: Adjust from 0.5x (slower) to 2.0x (faster)
4. **Player Name**: Set a custom display name (can be used for multiplayer identification in future updates)

### User Experience

- Settings are accessible from the main lobby before starting a game
- All settings are persisted using UserDefaults
- Settings are applied immediately when changed
- Joystick sensitivity affects the responsiveness of tank movement

## Future Enhancements

- Add actual sound effects and music
- Add more settings (e.g., color themes, control layouts)
- Show player name in multiplayer lobby
- Add haptic feedback toggle
- Add accessibility options

## Testing

To test the settings menu:

1. Launch the app
2. Tap the "⚙️ Settings" button on the lobby screen
3. Toggle sound/music switches
4. Adjust joystick sensitivity slider
5. Enter a player name
6. Tap "Done" to return to lobby
7. Start a game and test that joystick sensitivity is applied

## Notes

- The settings UI uses standard UIKit components
- The Settings class is thread-safe (singleton pattern)
- Settings are automatically saved to UserDefaults
- The joystick sensitivity multiplier is applied to touch deltas in real-time
