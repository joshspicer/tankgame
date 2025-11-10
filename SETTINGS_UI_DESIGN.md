# Settings Menu UI Design

## Lobby Screen (GameViewController)

```
┌─────────────────────────────────┐
│                                 │
│         Tank Game               │
│                                 │
│  Host a game or join a nearby   │
│          player                 │
│                                 │
│    ┌───────────────────┐        │
│    │    Host Game      │        │
│    └───────────────────┘        │
│                                 │
│    ┌───────────────────┐        │
│    │    Join Game      │        │
│    └───────────────────┘        │
│                                 │
│    ┌───────────────────┐        │
│    │  ⚙️ Settings       │  ← NEW │
│    └───────────────────┘        │
│                                 │
│  [Available Games List]         │
│                                 │
└─────────────────────────────────┘
```

## Settings Screen (SettingsViewController)

```
┌─────────────────────────────────┐
│                                 │
│         Settings                │
│                                 │
│                                 │
│  Sound Effects          [ON]    │
│                                 │
│  Music                  [ON]    │
│                                 │
│  Joystick Sensitivity   1.0x    │
│  ├─────●─────┤                  │
│  0.5x       2.0x                │
│                                 │
│  Player Name                    │
│  ┌─────────────────────────┐   │
│  │ Enter your name         │   │
│  └─────────────────────────┘   │
│                                 │
│                                 │
│    ┌───────────────────┐        │
│    │       Done        │        │
│    └───────────────────┘        │
│                                 │
└─────────────────────────────────┘
```

## UI Components

### Lobby Screen
- **Settings Button**: Gray button with gear emoji (⚙️) and "Settings" text
  - Position: Below "Join Game" button
  - Style: Medium weight font, gray background
  - Action: Opens settings in full-screen modal

### Settings Screen
- **Title**: Large bold "Settings" text at top
- **Sound Effects Switch**: Toggle for sound effects (ON by default)
- **Music Switch**: Toggle for music (ON by default)
- **Joystick Sensitivity Slider**: 
  - Range: 0.5x to 2.0x
  - Default: 1.0x
  - Real-time value display next to label
- **Player Name Text Field**: 
  - Rounded rect border
  - Placeholder: "Enter your name"
  - Keyboard type: Words
  - Return key: Done
- **Done Button**: Blue button to save and dismiss
  - Position: Bottom of form
  - Action: Saves player name and dismisses modal

## Interaction Flow

1. User launches app → sees lobby
2. User taps "⚙️ Settings" button
3. Settings screen slides up (full screen)
4. User adjusts settings:
   - Toggle sound/music switches
   - Drag sensitivity slider (shows live value)
   - Type in player name
5. User taps "Done" button
6. Settings are saved to UserDefaults
7. Screen dismisses, returns to lobby
8. Settings are applied in gameplay

## Implementation Details

- All controls use Auto Layout with proper constraints
- Settings screen is scrollable (in case of smaller screens)
- Settings are persisted immediately when changed
- Joystick sensitivity is applied in real-time during gameplay
- Full keyboard support for text field
