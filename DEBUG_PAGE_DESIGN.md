# Bluetooth Debug Page - Visual Design

## Overview
The Bluetooth Debug Page uses a modern iOS design with cards, clear typography, and emoji indicators for quick visual feedback.

## Layout Structure

```
┌─────────────────────────────────────────┐
│  [Grabber Bar]                          │
│                                         │
│  🔧 Bluetooth Debug Info                │
│  ═══════════════════════════════════    │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 📱 My Peer Info                   │  │
│  │ Display Name: iPhone              │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ ✅ Connection Status              │  │
│  │ Connected Peers: 1                │  │
│  │ Is Connected: Yes                 │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 👥 Connected Peers (1)            │  │
│  │   • Josh's iPhone                 │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🔍 Discovery Info                 │  │
│  │ To see discovered peers, check    │  │
│  │ the Join Game screen.             │  │
│  │ Note: Discovery uses              │  │
│  │ MultipeerConnectivity             │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🟢 Browsing Status                │  │
│  │ Currently Browsing: Yes           │  │
│  │ Searching for nearby games...     │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🟢 Advertising Status             │  │
│  │ Currently Advertising: Yes        │  │
│  │ Game is visible to others         │  │
│  │ Service Type: tankgame            │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │      🔄 Refresh Now               │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │         ✕ Close                   │  │
│  └───────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

## Color Scheme

### Cards
- Background: `.secondarySystemBackground`
- Border: `.separator` (1pt)
- Corner Radius: 12pt

### Text
- Title: System Font, 28pt, Bold
- Card Labels: System Font, 14pt, Medium
- Multi-line text support for all labels

### Buttons
- Refresh Button:
  - Background: `.systemBlue`
  - Text: White
  - Height: 50pt
  - Corner Radius: 12pt
  
- Close Button:
  - Text: `.systemRed`
  - Height: 50pt
  - No background

### Status Indicators
- Connected: ✅ (green checkmark)
- Disconnected: ⚪️ (white circle)
- Active: 🟢 (green circle)
- Inactive: ⚪️ (white circle)

## Spacing
- Outer margins: 20pt
- Stack view spacing: 16pt
- Card padding: 12pt vertical, 16pt horizontal

## Interaction

### Sheet Presentation
- Modal presentation style: `.pageSheet`
- Detents: Medium and Large
- Grabber visible at top
- Can be dismissed by:
  - Tapping "✕ Close" button
  - Dragging down the sheet
  - Tapping outside the sheet

### Refresh Behavior
- Auto-refresh: Every 2 seconds
- Manual refresh: Tap "🔄 Refresh Now"
- Haptic feedback on manual refresh

### Scrolling
- ScrollView contains all content
- Vertical scrolling enabled
- Bounce effect at edges

## Accessibility

### VoiceOver Support
- All labels are accessible
- Button actions are announced
- Status changes are announced through label updates

### Dynamic Type
- System fonts support Dynamic Type
- Layout adjusts for larger text sizes
- Multi-line labels ensure content is readable

## States

### Not Connected
```
✅ → ⚪️
👥 Connected Peers: None
🔍 Discovery Info: (info message)
⚪️ Browsing Status: Not actively searching
⚪️ Advertising Status: Not hosting a game
```

### Browsing for Game
```
⚪️ Connection Status
🟢 Browsing Status: Currently Browsing: Yes
⚪️ Advertising Status: Not hosting a game
```

### Hosting Game
```
⚪️ Connection Status
⚪️ Browsing Status: Not actively searching
🟢 Advertising Status: Currently Advertising: Yes
```

### Connected
```
✅ Connection Status: Is Connected: Yes
👥 Connected Peers: (list of peer names)
Status depends on hosting/joining mode
```

## Integration with Main App

### Access Point
Location: Main lobby screen
Button: "🔧 Debug" 
Position: Bottom center
Style: System font, 14pt, `.systemGray` color

### Behavior
- Available at all times in lobby
- Does not interfere with game state
- Can be opened during hosting/browsing
- Cannot be opened during active game (lobby hidden)

## Performance Considerations
- Lightweight UI updates every 2 seconds
- Minimal impact on game performance
- Timer properly cleaned up on dismissal
- No background network operations
- Read-only operations only
