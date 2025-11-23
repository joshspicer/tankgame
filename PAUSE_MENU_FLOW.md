# Pause Menu Flow Diagram

```
                                    GAME ACTIVE
                                         |
                                         |
                           Player taps menu button (☰)
                                         |
                                         v
                                  GAME PAUSED
                                         |
                    +--------------------+--------------------+
                    |                    |                    |
                    v                    v                    v
              Resume Game          Restart Match        Return to Lobby
                    |                    |                    |
                    |              Host only? Yes              |
                    |                    |                    |
                    v                    v                    |
              GAME ACTIVE     Send restartMatch msg          |
                                         |                    |
                                         v                    |
                              All players reset scores        |
                                         |                    |
                                         v                    |
                              New round with seed=random      |
                                         |                    |
                                         v                    |
                                   GAME ACTIVE                |
                                                              |
              Non-host? Show error alert                     |
                    |                                         |
                    v                                         v
              Stay in GAME PAUSED                  Send quitToLobby msg
                                                              |
                                                              v
                                                   All players see lobby
                                                              |
                                                              v
                                                      LOBBY (Connected)
                                                              |
                                                              v
                                                   Host can start new game
```

## State Transitions

### GAME ACTIVE → GAME PAUSED
- **Trigger**: Menu button tap
- **Effects**:
  - Pause overlay appears
  - Game updates stop
  - Touch controls disabled (except menu)

### GAME PAUSED → GAME ACTIVE (Resume)
- **Trigger**: "Resume Game" tap or tap outside menu
- **Effects**:
  - Pause overlay disappears
  - Game updates resume
  - Touch controls re-enabled

### GAME PAUSED → GAME ACTIVE (Restart)
- **Trigger**: "Restart Match" tap (host only)
- **Network**: `restartMatch` message sent to all peers
- **Effects on all clients**:
  - Scores reset to [0, 0, ...]
  - New round starts with random seed
  - Game updates resume
- **Non-host behavior**: Show error alert, stay paused

### GAME PAUSED → LOBBY
- **Trigger**: "Return to Lobby" tap (any player)
- **Network**: `quitToLobby` message sent to all peers
- **Effects on all clients**:
  - Game scene removed
  - Lobby UI shown
  - Connections preserved
  - Ready for new game

## Network Message Flow

### Restart Match (Host-initiated)
```
Host                                    Client 1                  Client 2
  |                                         |                         |
  | Tap "Restart Match"                     |                         |
  |                                         |                         |
  | Reset local scores                      |                         |
  | Generate new seed                       |                         |
  |                                         |                         |
  |-------- restartMatch message --------->|                         |
  |-------- restartMatch message ------------------------>|         |
  |                                         |                         |
  |                                 Reset local scores        Reset local scores
  |                                         |                         |
  |-------- roundStart(seed) ------------->|                         |
  |-------- roundStart(seed) ---------------------------->|         |
  |                                         |                         |
  | Start new round                 Start new round         Start new round
  |                                         |                         |
```

### Return to Lobby (Any player can initiate)
```
Player 1                                 Player 2                  Player 3
  |                                         |                         |
  | Tap "Return to Lobby"                   |                         |
  |                                         |                         |
  | Call returnToLobby()                    |                         |
  |                                         |                         |
  |-------- quitToLobby message ---------->|                         |
  |-------- quitToLobby message --------------------------->|       |
  |                                         |                         |
  | Show lobby UI                  Call returnToLobby()  Call returnToLobby()
  |                                         |                         |
  |                                 Show lobby UI           Show lobby UI
  |                                         |                         |
  | (All players remain connected)          |                         |
  |<--------- Still connected ------------->|<---------- Connected -->|
```

## UI State Machine

```
┌─────────────────────────────────────────────────────────┐
│                    MENU CLOSED                          │
│                                                         │
│  - Menu button visible (☰)                             │
│  - Game running                                        │
│  - Touch controls active                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
                         │
                         │ Menu button tapped
                         ▼
┌─────────────────────────────────────────────────────────┐
│                     MENU OPEN                           │
│                                                         │
│  - Pause overlay visible                               │
│  - Game frozen                                         │
│  - Only menu touches handled                           │
│                                                         │
│  [Resume Game]                                         │
│  [Restart Match] ← (Host only)                         │
│  [Return to Lobby]                                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
          │               │                │
          │ Resume        │ Restart        │ Quit
          │               │                │
          ▼               ▼                ▼
    MENU CLOSED    Scores → 0-0      LOBBY SCREEN
                   New round starts   (Connected)
```

## Component Interactions

```
GameScene
    │
    ├─► GameSceneUI
    │       │
    │       ├─► Menu Button (always visible)
    │       │       │
    │       │       └─► onMenuTapped() callback
    │       │
    │       └─► Pause Overlay (shown on demand)
    │               │
    │               ├─► onResumeTapped() callback
    │               ├─► onRestartTapped() callback
    │               └─► onQuitTapped() callback
    │
    └─► onGameMessage() callback
            │
            ├─► .restartMatch
            └─► .quitToLobby
                    │
                    ▼
            GameViewController
                    │
                    ├─► handleRestartMatch()
                    │       │
                    │       ├─► Validate host
                    │       ├─► Reset scores
                    │       └─► startNextRound()
                    │
                    └─► handleQuitToLobby()
                            │
                            ├─► Send quitToLobby message
                            └─► returnToLobby()
```

## Touch Handling Priority

When a touch event occurs, it's handled in this order:

1. **Menu UI** (highest priority)
   - If pause overlay is visible, check for button taps
   - If menu button area, toggle pause

2. **Pause State Check**
   - If paused, block all further handling

3. **Fire Button**
   - If fire button area, shoot projectile

4. **Joystick**
   - If joystick area, handle movement

5. **Nothing**
   - Touch is ignored

```
Touch Event
    │
    ├─► Menu UI? Yes ──► Handle menu interaction ──► DONE
    │         No
    │
    ├─► Paused? Yes ────────────────────────────────► BLOCK
    │        No
    │
    ├─► Fire button? Yes ──► Shoot ─────────────────► DONE
    │              No
    │
    ├─► Joystick? Yes ─────► Move ──────────────────► DONE
    │           No
    │
    └─► Ignore ──────────────────────────────────────► DONE
```
