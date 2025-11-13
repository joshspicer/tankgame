# Test Plan for Bluetooth Debug Page

## Prerequisites
- Two iOS devices or simulators with the Tank Game app installed
- Devices on the same local network
- Local Network permission granted on both devices

## Test Cases

### Test 1: Access Debug Page from Lobby
**Steps:**
1. Launch the Tank Game app
2. Observe the main lobby screen
3. Look for the "🔧 Debug" button at the bottom
4. Tap the debug button

**Expected Result:**
- Debug page opens as a modal sheet
- Title shows "🔧 Bluetooth Debug Info"
- All info cards are displayed
- Current peer information is shown correctly

### Test 2: Verify Peer ID Display
**Steps:**
1. Open debug page
2. Check the "My Peer Info" section

**Expected Result:**
- Display name matches device name (e.g., "iPhone", "iPad")
- Peer ID is a valid string identifier

### Test 3: Check Connection Status (Not Connected)
**Steps:**
1. Open debug page before connecting to another device
2. Observe the "Connection Status" section

**Expected Result:**
- Shows "⚪️ Connection Status"
- "Connected Peers: 0"
- "Is Connected: No"

### Test 4: Check Browsing Status
**Steps:**
1. From lobby, tap "🔍 Join Game"
2. Open debug page while browsing

**Expected Result:**
- "Browsing Status" shows "🟢"
- "Currently Browsing: Yes"
- Shows "Searching for nearby games..."

### Test 5: Check Advertising Status
**Steps:**
1. From lobby, tap "🎯 Host Game"
2. Open debug page while hosting

**Expected Result:**
- "Advertising Status" shows "🟢"
- "Currently Advertising: Yes"
- Shows "Game is visible to others"
- Service Type displayed correctly ("tankgame")

### Test 6: Verify Auto-Refresh
**Steps:**
1. Open debug page
2. Wait 2+ seconds without interacting
3. Observe if information updates

**Expected Result:**
- Information refreshes automatically every 2 seconds
- No need to manually refresh

### Test 7: Manual Refresh
**Steps:**
1. Open debug page
2. Tap "🔄 Refresh Now" button

**Expected Result:**
- Information immediately updates
- Haptic feedback occurs (on supported devices)

### Test 8: Connected State
**Steps:**
1. Connect two devices using Host Game and Join Game
2. Open debug page on both devices after connection
3. Verify connected peer information

**Expected Result:**
- Both devices show "✅ Connection Status"
- "Is Connected: Yes"
- Connected peer's display name appears in the list
- Connected Peers count is 1

### Test 9: Close Debug Page
**Steps:**
1. Open debug page
2. Tap "✕ Close" button

**Expected Result:**
- Debug page dismisses with animation
- Returns to lobby screen
- Game state unchanged

### Test 10: Sheet Presentation
**Steps:**
1. Open debug page
2. Try to drag the sheet to different heights

**Expected Result:**
- Sheet supports medium and large detents
- Grabber visible at top
- Can be dismissed by dragging down

## Integration Testing

### Test 11: Debug During Active Game
**Steps:**
1. Start a game with connected devices
2. Return to lobby (if possible)
3. Open debug page

**Expected Result:**
- Debug page shows active connection
- Game connection maintained
- Debug page doesn't interfere with game state

### Test 12: Connection Drop
**Steps:**
1. Connect two devices
2. Open debug page on one device
3. Disable WiFi/Bluetooth on the other device
4. Observe connection status updates

**Expected Result:**
- Connection status updates to disconnected
- Connected peers list becomes empty
- "Is Connected: No" appears

## Notes for Testers

- The debug page is read-only and doesn't modify any connection state
- Auto-refresh happens every 2 seconds to minimize performance impact
- The page uses modern iOS sheet presentation with detents
- All status indicators use emoji for quick visual feedback
- Closing the debug page properly cleans up the auto-refresh timer

## Known Limitations

- Discovered peers list is not directly accessible (shows info message)
- Historical connection data is not stored
- No export functionality for debug logs
- Cannot force disconnect from debug page
