// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "alticns",
    platforms: [.macOS(.v10_13)],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.3")
    ],
    targets: [
        .executableTarget(
            name: "alticns",
            dependencies: ["SwiftCLI"]),
        .testTarget(
            name: "alticnsTests",
            dependencies: ["alticns"]),
    ]
)
