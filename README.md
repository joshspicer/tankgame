A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Building and Testing

### Building the App
Open the project in Xcode:
```bash
open tankgame.xcodeproj
```

Or build from command line:
```bash
xcodebuild -project tankgame.xcodeproj -scheme "tankgame iOS" -configuration Debug
```

### Testing Multiplayer
To test the multiplayer functionality, you'll need two devices:
1. Run the app on two iOS simulators or physical devices
2. Both players should tap "Host Game" or one hosts and the other joins
3. Once connected, players will see each other in the lobby
4. The host can start the game when both players are ready
5. Use the joystick to move and the fire button to shoot

For simulator testing, launch two separate simulator instances from Xcode.
