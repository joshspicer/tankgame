# Testing Internet Multiplayer

This document describes how to test the internet multiplayer feature.

## Prerequisites

- Python 3.7 or higher
- iOS Simulator or physical iOS devices
- Xcode (for building and running the app)

## Test Scenario 1: Two Simulators on Same Mac

This is the simplest test scenario for local development.

### Steps

1. **Start the WebSocket Server**
   ```bash
   cd server
   pip install -r requirements.txt
   python server.py
   ```
   
   You should see:
   ```
   INFO - Starting Tank Game WebSocket server on port 8765
   INFO - Server ready and listening on ws://0.0.0.0:8765
   ```

2. **Build and Run the App**
   - Open `tankgame.xcodeproj` in Xcode
   - Select iOS target
   - Build and run the app (⌘R)

3. **Launch First Simulator Instance**
   - The app should open in the simulator
   - You'll see three buttons:
     - 🎯 Host Game (local network)
     - 🔍 Join Game (local network)
     - 🌐 Connect to Internet Lobby

4. **Tap "Connect to Internet Lobby"**
   - Enter a passphrase like `jump-rocket`
   - Tap "Connect"
   - You should see "Connecting to internet lobby..." and "Waiting for opponent"

5. **Launch Second Simulator Instance**
   - In Xcode, go to Window > Devices and Simulators
   - Right-click on your simulator and select "Clone"
   - Boot the cloned simulator
   - Run the app again (it will launch in the new simulator)

6. **Connect Second Player**
   - On the second simulator, tap "Connect to Internet Lobby"
   - Enter the SAME passphrase (`jump-rocket`)
   - Tap "Connect"

7. **Game Starts!**
   - Both simulators should now show the game
   - One player spawns at top-left (blue tank)
   - Other player spawns at bottom-right (red tank)
   - Use the joystick to move and FIRE button to shoot

## Test Scenario 2: Two Different Devices

This tests actual internet connectivity.

### Steps

1. **Deploy the Server**
   - Deploy `server/server.py` to a server with a public IP or use a service like ngrok
   - If using ngrok: `ngrok http 8765` and note the WebSocket URL

2. **Update Server URL in App**
   - Edit `tankgame iOS/GameViewController.swift`
   - Find the line `let serverURL = "ws://localhost:8765"`
   - Replace with your server URL (e.g., `ws://your-server.com:8765`)
   - Rebuild the app

3. **Install on Devices**
   - Build and install the app on two iOS devices
   - Both devices need internet connectivity

4. **Connect Both Players**
   - On both devices, tap "Connect to Internet Lobby"
   - Enter the same passphrase
   - The game should start when both are connected

## What to Test

### Connectivity
- ✅ Both players can connect with same passphrase
- ✅ Players with different passphrases don't match
- ✅ Third player trying to join full lobby gets error
- ✅ Disconnecting one player notifies the other

### Gameplay
- ✅ Tank movement is synchronized
- ✅ Projectiles are visible to both players
- ✅ Hits are detected correctly
- ✅ Score updates after each round
- ✅ Next round starts after both players are ready

### Edge Cases
- ✅ Invalid passphrase format (no hyphen) shows error
- ✅ Empty passphrase shows error
- ✅ Server not running shows connection error
- ✅ Network loss during game disconnects gracefully

## Expected Server Logs

When testing, you should see logs like:
```
INFO - Client joined lobby [hash]. Lobby size: 1
INFO - Client joined lobby [hash]. Lobby size: 2
INFO - Lobby [hash] is ready with 2 players
... game messages being forwarded ...
INFO - Removed client from lobby [hash]. Remaining: 1
INFO - Removed client from lobby [hash]. Remaining: 0
INFO - Removed empty lobby [hash]
```

Note: Passphrases are hashed in logs for security.

## Troubleshooting

### "Connection Error: Unable to connect to internet lobby"
- Check that the server is running
- Verify the server URL in the code is correct
- Check firewall settings if using remote server

### "Lobby is full"
- Another game with the same passphrase is already in progress
- Choose a different passphrase

### Game starts but opponent doesn't appear
- Check network connectivity
- Look at server logs for errors
- Try restarting both clients

### Tanks are in wrong positions
- This is a known issue with player ordering
- Both clients should see themselves as the blue tank
- The remote player should appear as red
