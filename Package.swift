// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TankGameTests",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TankGameCore",
            targets: ["TankGameCore"]),
    ],
    targets: [
        // Core game logic library (platform-independent)
        .target(
            name: "TankGameCore",
            dependencies: [],
            path: "Sources/TankGameCore"
        ),
        // Unit tests
        .testTarget(
            name: "TankGameCoreTests",
            dependencies: ["TankGameCore"],
            path: "Tests/TankGameCoreTests"
        ),
    ]
)
