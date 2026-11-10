// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VibeArmory",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VibeArmory",
            targets: ["VibeArmory"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "VibeArmory",
            dependencies: [],
            path: "Sources/VibeArmory",
            exclude: ["App/Info.plist", "Resources"]
        )
    ]
)
