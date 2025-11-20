A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Testing Multiplayer

This game uses MultipeerConnectivity for peer-to-peer multiplayer. **Important**: iOS Simulators do not support Bluetooth or Bonjour networking, so you must test on physical devices.

### Quick Start
1. Connect 2-4 iOS devices to your Mac (USB or wireless debugging)
2. Run the helper script: `./scripts/test_multiplayer.sh`
3. Follow the on-screen instructions

### Manual Testing
1. Build and run on multiple physical devices
2. One device hosts, others join
3. Test gameplay and synchronization

See [SIMULATOR_TESTING.md](SIMULATOR_TESTING.md) for detailed testing documentation and troubleshooting.
