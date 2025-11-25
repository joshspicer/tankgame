// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TankGameTests",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TankGameCore",
            targets: ["TankGameCore"]),
    ],
    targets: [
        .target(
            name: "TankGameCore",
            path: "Sources/TankGameCore"),
        .testTarget(
            name: "TankGameCoreTests",
            dependencies: ["TankGameCore"],
            path: "Tests/TankGameTests"),
    ]
)
