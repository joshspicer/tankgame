# Tank Game - Comprehensive Help Guide

Welcome to Tank Game! This guide will help you understand, build, test, and develop this multiplayer iOS tank game.

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Building the Project](#building-the-project)
5. [Testing Multiplayer with Two Simulators](#testing-multiplayer-with-two-simulators)
6. [Project Architecture](#project-architecture)
7. [Development Workflow](#development-workflow)
8. [Common Tasks](#common-tasks)
9. [Troubleshooting](#troubleshooting)
10. [Additional Resources](#additional-resources)

---

## 🚀 Quick Start

Tank Game is a multiplayer iOS game where players control tanks in a grid-based arena, using Bluetooth (MultipeerConnectivity) to connect and battle.

**Key Info:**
- Platform: iOS, macOS, tvOS (primary focus: iOS)
- Language: Swift
- Framework: SpriteKit for rendering
- Networking: MultipeerConnectivity (Bluetooth)
- Development: Built with Xcode, designed with AI assistance

---

## ✨ Features

- 🎮 **Multiplayer Gameplay** - Connect via Bluetooth using MultipeerConnectivity
- 🤖 **AI Bots** - Single-player mode with AI-controlled opponents
- 💥 **Combat** - Shoot projectiles and destroy opponents
- 🎨 **Visual Effects** - Explosions, smooth animations, rainbow tank colors
- 🔊 **Sound Effects** - Audio feedback for actions
- 🧱 **Procedural Maps** - Randomly generated grid-based arenas
- 🦎 **Lizard NPCs** - Wandering creatures with AI behavior
- 🐬 **Alternative Skins** - Dolphin sprite mode option
- 💥 **Crash Reporting** - Automatic GitHub issue creation for crashes

---

## 📦 Prerequisites

### Required
- **macOS** with Xcode 14.0 or later
- **iOS Simulator** or physical iOS device (iOS 14.0+)
- **Git** for version control

### Recommended for Multiplayer Testing
- **Two iOS Simulators** running simultaneously on your Mac
- Sufficient system resources (8GB+ RAM recommended)

---

## 🔨 Building the Project

### Step 1: Clone the Repository
```bash
git clone https://github.com/joshspicer/tankgame.git
cd tankgame
```

### Step 2: Open in Xcode
```bash
open tankgame.xcodeproj
```

### Step 3: Select a Target
In Xcode, select one of the following schemes:
- **tankgame iOS** - iPhone/iPad app
- **tankgame macOS** - macOS app
- **tankgame tvOS** - Apple TV app

### Step 4: Build and Run
1. Select a simulator or connected device
2. Press `Cmd+R` or click the Play button
3. Wait for the build to complete

---

## 🎮 Testing Multiplayer with Two Simulators

Testing multiplayer functionality requires running two separate instances of the app. Here's how:

### Method 1: Using Xcode (Recommended)

#### Launch First Simulator
1. Open Xcode with `tankgame.xcodeproj`
2. Select **tankgame iOS** scheme
3. Choose **iPhone 15 Pro** (or any iOS simulator)
4. Press `Cmd+R` to build and run
5. The app will launch in the first simulator

#### Launch Second Simulator
1. In Xcode, select a **different simulator** (e.g., iPhone 15)
2. Press `Cmd+R` again
3. The app will now run in the second simulator

**Note:** Both simulators will run the same build. Xcode manages multiple simulator instances automatically.

### Method 2: Using XCodeBuildMCP Tools (if available)
If you have XCodeBuildMCP tools installed, you can script the launch:

```bash
# Build the app first
xcodebuild -scheme "tankgame iOS" -destination "platform=iOS Simulator,name=iPhone 15 Pro" build

# Launch first instance
xcodebuild -scheme "tankgame iOS" -destination "platform=iOS Simulator,name=iPhone 15 Pro" run

# Launch second instance (in a new terminal)
xcodebuild -scheme "tankgame iOS" -destination "platform=iOS Simulator,name=iPhone 15" run
```

### Testing Multiplayer Connection

Once both simulators are running:

1. **On First Device:**
   - Tap "Host Game" to create a session
   - Wait for the lobby to appear

2. **On Second Device:**
   - Tap "Join Game"
   - The first device should appear in the list
   - Tap to connect

3. **Start Playing:**
   - Once connected, start the game
   - Use the virtual joystick to move
   - Tap the fire button to shoot

**Troubleshooting Connection:**
- Ensure both simulators are on the same network
- MultipeerConnectivity uses Bluetooth/WiFi - simulators may have limitations
- Physical devices work best for multiplayer testing
- Check that permissions are granted (the app will prompt)

---

## 🏗️ Project Architecture

Tank Game uses a highly modular architecture to minimize merge conflicts and improve maintainability. See [ARCHITECTURE.md](ARCHITECTURE.md) for full details.

### Key Architectural Layers

```
Application Layer (iOS/macOS/tvOS specific)
├── GameViewController - Main view controller (93 lines)
├── UI Components - Lobby, buttons, tables
└── Platform-specific logic

Game Coordination Layer
├── GameScene - Central coordinator (154 lines)
├── GameSceneSetup - Initialization
├── GameSceneUpdateLoop - Game loop
└── GameSceneInputHandler - Input processing

Rendering Layer
├── GameSceneRenderer - Rendering coordinator (64 lines)
├── GridRenderer - Grid rendering
├── TankRenderer - Tank rendering
├── ProjectileRenderer - Projectile rendering
└── Various sprite renderers

Game Logic Layer
├── GameState - State management
├── GridGenerator - Procedural generation
├── CollisionDetection - Physics
└── AI/Bot managers

Entity Layer
├── Tank - Player/bot entity
├── Projectile - Bullet entity
├── Lizard - NPC entity
└── Direction, GridCell - Supporting types

Networking Layer
├── MultiplayerCoordinator - High-level multiplayer
├── MultiplayerManager - Low-level networking
└── Connection management utilities

Audio Layer
└── SoundManager - Sound effects
```

### File Size Philosophy
- **Average file size:** ~70 lines
- **Largest file:** 154 lines (GameScene.swift)
- **Goal:** Single responsibility, easy to understand

### Modularity Benefits
- 📝 **Easy to read:** Smaller files reduce cognitive load
- 🔍 **Easy to find:** Clear file names indicate purpose
- 🤝 **Parallel development:** Multiple developers/AI agents can work simultaneously
- 🔒 **Fewer merge conflicts:** Changes are isolated to specific files
- 🧪 **Testable:** Components can be unit tested independently

---

## 💻 Development Workflow

### Making Code Changes

Following the modular architecture principles:

1. **Identify the appropriate file** for your change
   - Rendering changes → `*Renderer.swift`
   - Game logic → `GameState.swift`, `CollisionDetection.swift`
   - UI changes → `GameViewController*.swift` or UI components
   - Networking → `Multiplayer*.swift`

2. **Create NEW files when adding features**
   - Prefer creating new focused files over expanding existing ones
   - Keeps files small and reduces conflicts
   - Example: Add `NewFeatureRenderer.swift` rather than expanding `GameSceneRenderer.swift`

3. **Keep changes minimal and focused**
   - Make the smallest possible change to achieve your goal
   - Don't refactor unrelated code
   - One feature per commit/PR

4. **Follow existing patterns**
   - Match the coding style of the file you're editing
   - Use dependency injection where appropriate
   - Keep files under ~150 lines when possible

### Testing Your Changes

#### Build the Project
```bash
# Using Xcode
Cmd+B

# Using command line (if available)
xcodebuild -scheme "tankgame iOS" build
```

#### Run on Simulator
```bash
# Using Xcode
Cmd+R

# Using command line
xcodebuild -scheme "tankgame iOS" -destination "platform=iOS Simulator,name=iPhone 15 Pro" run
```

#### Test Checklist
- [ ] Game launches without crashing
- [ ] Controls work (joystick, fire button)
- [ ] Multiplayer connection works
- [ ] Sound effects play
- [ ] Visuals render correctly
- [ ] No performance issues (60 FPS target)

### Code Quality

#### Linting
The project follows Swift best practices. No specific linter is configured, but follow these guidelines:
- Use Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Keep functions short and focused
- Add comments only when necessary to explain complex logic
- Avoid force unwrapping (`!`) where possible

#### Documentation
- Update README.md if adding major features
- Update ARCHITECTURE.md if changing structure
- Create summary documents for significant changes
- Keep instruction files in `.github/instructions/` up to date

---

## 🛠️ Common Tasks

### Adding a New Feature

1. **Create a new Swift file** in the appropriate directory:
   ```
   tankgame Shared/ - for cross-platform code
   tankgame iOS/ - for iOS-specific code
   tankgame macOS/ - for macOS-specific code
   ```

2. **Add the file to Xcode project:**
   - Right-click on the appropriate folder in Xcode
   - Select "Add Files to tankgame"
   - Check all relevant targets (iOS, macOS, tvOS)

3. **Implement your feature** following the modular pattern

4. **Test thoroughly** with simulators or devices

### Modifying Existing Functionality

1. **Locate the relevant file** using the architecture guide
2. **Make minimal changes** to achieve your goal
3. **Test the specific feature** you modified
4. **Verify multiplayer sync** if applicable

### Adding UI Elements

UI changes typically go in:
- `LobbyUI.swift` - Main menu and lobby
- `GameSceneUI.swift` - In-game UI labels
- `FireButton.swift` - Custom button components
- `GameViewController*.swift` - iOS-specific UI logic

### Adding Sound Effects

1. Add audio files to `tankgame Shared/Sounds/`
2. Update `SoundManager.swift` with new sound cases
3. Call `SoundManager.shared.playSound(.yourSound)` where needed

### Modifying Network Protocol

1. Update `GameMessages.swift` with new message types
2. Implement encoding/decoding in message handling
3. Update both sending and receiving logic
4. **Maintain backward compatibility** when possible

---

## 🐛 Troubleshooting

### Build Issues

**Problem:** "Build failed with errors"
- **Solution:** Check Xcode build output for specific errors
- Common causes: Missing files, syntax errors, misconfigured targets

**Problem:** "Could not find module"
- **Solution:** Ensure all files are added to correct targets
- Clean build folder: `Cmd+Shift+K`, then rebuild

### Runtime Issues

**Problem:** Game crashes on launch
- **Solution:** Check crash logs in Xcode Console
- Verify all assets are included in the bundle
- Check for force-unwrap crashes (`!`)

**Problem:** Multiplayer doesn't connect
- **Solution:** 
  - Grant Bluetooth/Network permissions when prompted
  - Use physical devices instead of simulators when possible
  - Check that both devices are discoverable
  - Restart the app and try again

**Problem:** Poor performance / low FPS
- **Solution:**
  - Test on physical device (simulators are slower)
  - Check for excessive logging or debug code
  - Profile with Instruments if needed

### Simulator Issues

**Problem:** Can't run two simulators
- **Solution:**
  - Close other apps to free memory
  - Restart Xcode
  - Reset simulators: Device → Erase All Content and Settings

**Problem:** Simulator is very slow
- **Solution:**
  - Choose a lighter simulator model (e.g., iPhone SE instead of Pro Max)
  - Close background apps
  - Allocate more RAM to simulators in Xcode settings

---

## 📚 Additional Resources

### Documentation Files
- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture documentation
- [CRASH_REPORTING.md](CRASH_REPORTING.md) - Crash reporting system
- [MOVEMENT_IMPROVEMENTS.md](MOVEMENT_IMPROVEMENTS.md) - Movement system details
- [MOVEMENT_VISUAL_GUIDE.md](MOVEMENT_VISUAL_GUIDE.md) - Visual guide to movement
- [MODULARIZATION_SUMMARY.md](MODULARIZATION_SUMMARY.md) - Refactoring history
- [PR_SUMMARY.md](PR_SUMMARY.md) - Recent changes summary

### Instruction Files
- `.github/instructions/launch-two-simulators.instructions.md` - Multiplayer testing guide
- `.github/instructions/modular.instructions.md` - Modularity principles

### External Resources
- [Apple SpriteKit Documentation](https://developer.apple.com/documentation/spritekit)
- [MultipeerConnectivity Framework](https://developer.apple.com/documentation/multipeerconnectivity)
- [Swift Language Guide](https://docs.swift.org/swift-book/)

### Video Resources
Watch how this game was built:
- [Stream 1: Initial Development](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740)
- [Stream 2: Continued Development](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--)

---

## 🤝 Contributing

This project was built with AI assistance (GitHub Copilot) and follows specific patterns:

### Contribution Guidelines
1. **Keep it modular** - Create new files rather than expanding existing ones
2. **Keep files small** - Aim for under 150 lines per file
3. **Single responsibility** - Each file should have one clear purpose
4. **Minimal changes** - Make the smallest change that works
5. **Test thoroughly** - Especially multiplayer functionality
6. **Document your changes** - Update relevant .md files

### Working with AI Agents
Multiple AI agents can work on this codebase simultaneously due to its modular structure:
- Agent A: Rendering (TankRenderer.swift)
- Agent B: Input (GameSceneInputHandler.swift)
- Agent C: Networking (MultiplayerCoordinator.swift)
- Agent D: UI (GameViewController*.swift)

All without merge conflicts! 🎉

---

## 🆘 Getting Help

If you're stuck:
1. Check this HELP.md file
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) for structure details
3. Look at similar code patterns in the codebase
4. Check the video streams to see how features were implemented
5. Open an issue on GitHub with your question

---

## 📝 License

See the repository for license information.

---

**Happy Gaming! 🎮🚀**
