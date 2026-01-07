A multiplayer ([bluetooth](https://developer.apple.com/documentation/multipeerconnectivity)) iOS tank game, built entirely with VS Code agent mode 🚀  Built to kill time in long car rides with your siblings.

**🎉 Now with Clean Architecture!** This game has been completely rewritten using clean architecture principles for better scalability, testability, and maintainability.

See how copilot and I built it on the VS Code livestream. ([1](https://www.youtube.com/live/EXURiXZ-8YU?si=CxOHRCNSuBTQnlv0&t=7740), [2](https://www.youtube.com/live/IdPtTBbYOtw?si=GZP3EgKK21EYIz--))

![pewpew.gif](images/pewpew.gif)

## Features

- 🎮 **2-6 Player Multiplayer** via Bluetooth (MultipeerConnectivity)
- 🏗️ **Clean Architecture** - Domain, Application, Infrastructure, Presentation layers
- 🧪 **Testable Design** - Pure business logic, dependency injection
- 📱 **iOS Native** - Built with Swift, SpriteKit, UIKit
- 🎨 **Modern Design Patterns** - Protocols, Value Types, Use Cases
- 🔄 **Scalable** - Easy to add features and support more players
- 💥 Crash reporting with automatic GitHub issue creation (see [CRASH_REPORTING.md](CRASH_REPORTING.md))

## Quick Start

1. Open `tankgame.xcodeproj` in Xcode
2. Build and run on iOS simulator or device
3. For multiplayer: Run on two simulators
   - Device 1: Tap "Host Game"
   - Device 2: Tap "Join Game"
   - Device 1: Tap "Start Game"

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │  ← UI (Views, ViewControllers)
├─────────────────────────────────────┤
│      Application Layer              │  ← Use Cases, Coordinators
├─────────────────────────────────────┤
│       Domain Layer                  │  ← Business Logic (Entities, Services)
├─────────────────────────────────────┤
│    Infrastructure Layer             │  ← External Systems (Network, Rendering)
└─────────────────────────────────────┘
```

See [CLEAN_ARCHITECTURE.md](CLEAN_ARCHITECTURE.md) for detailed architecture documentation.

## Documentation

- 📖 [CLEAN_ARCHITECTURE.md](CLEAN_ARCHITECTURE.md) - Architecture design and principles
- 🛠️ [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - How to develop and extend the game
- 📝 [CLEAN_IMPLEMENTATION_SUMMARY.md](CLEAN_IMPLEMENTATION_SUMMARY.md) - Implementation details
- 🐛 [CRASH_REPORTING.md](CRASH_REPORTING.md) - Crash reporting system

## Project Structure

```
tankgame Shared/
├── Domain/              # Business logic (no framework dependencies)
│   ├── Entities/        # Core business objects
│   ├── ValueObjects/    # Immutable values
│   └── Services/        # Domain operations
├── Application/         # Use cases and coordination
│   ├── UseCases/        # Application-specific logic
│   └── Coordinators/    # Flow orchestration
├── Infrastructure/      # External systems
│   ├── Networking/      # Bluetooth multiplayer
│   └── Rendering/       # SpriteKit rendering
└── Presentation/        # UI layer
```

## Design Patterns

- **Dependency Injection** - Components receive dependencies
- **Protocol-Oriented** - Abstractions via protocols
- **Value Types** - Immutable structs for safety
- **Use Case Pattern** - Single-purpose operations
- **Repository Pattern** - Data access abstraction
- **Coordinator Pattern** - Navigation and flow

## Contributing

1. Check the [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for guidelines
2. Follow the clean architecture layers
3. Add tests for new features
4. Update documentation

## License

See LICENSE file for details.
