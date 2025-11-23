A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game with AI opponents, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

## Features

- 🎮 Multiplayer gameplay via Bluetooth (2-4 players)
- 🤖 AI bot opponents for single-player or mixed play
- 💥 Tank battles with shooting mechanics
- 🎯 Grid-based gameplay with procedural map generation

## Playing with AI Bots

When hosting a game, you can now add AI-controlled bot players:

1. Tap "🎯 Host Game"
2. Tap "🤖 Add AI Player" to add one or more bot opponents (up to 4 total players)
3. Tap "🚀 Start Game" when ready (minimum 2 players including bots)

AI bots will automatically move towards enemies and shoot when they have a clear line of sight!

![pewpew.gif](images/pewpew.gif)

## Testing

Basic unit tests for the core game logic are available. Run them with:

```bash
./run_tests.sh
```

See [tankgame Tests/README.md](tankgame%20Tests/README.md) for more details.
