A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Features

- 🎮 Multiplayer gameplay via Bluetooth (MultipeerConnectivity) or WiFi
- 📶 WiFi mode with room codes for easy game joining
- 💥 Crash reporting with automatic GitHub issue creation (see [CRASH_REPORTING.md](CRASH_REPORTING.md))
- 🎨 Modern visual styling
- 🔊 Sound effects

## Multiplayer Modes

### Bluetooth Mode (Default)
Uses Apple's MultipeerConnectivity framework for peer-to-peer connections. Works great for nearby devices without needing WiFi.

### WiFi Mode
Connect over your local WiFi network using room codes:
1. Toggle the mode selector to "WiFi" in the lobby
2. **Host**: Tap "Host Game" to start hosting and receive a 6-character room code
3. **Join**: Enter the room code or select a discovered game from the list
4. Share the room code with friends on the same network!

