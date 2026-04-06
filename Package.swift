// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMonocle",
    platforms: [
        .macOS("15.0"),
    ],
    products: [
        .library(
            name: "SwiftMonocle",
            targets: ["SwiftMonocle"]
        ),
        .library(
            name: "SwiftMonocleCore",
            targets: ["SwiftMonocleCore"]
        ),
        .library(
            name: "SwiftMonocleCodeScope",
            targets: ["SwiftMonocleCodeScope"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftMonocleCore"
        ),
        .target(
            name: "SwiftMonocleCodeScope",
            dependencies: ["SwiftMonocleCore"]
        ),
        .target(
            name: "SwiftMonocle",
            dependencies: ["SwiftMonocleCodeScope"]
        ),
        .testTarget(
            name: "SwiftMonocleTests",
            dependencies: ["SwiftMonocle"]
        ),
        .testTarget(
            name: "SwiftMonocleCoreTests",
            dependencies: ["SwiftMonocleCore"]
        ),
        .testTarget(
            name: "SwiftMonocleCodeScopeTests",
            dependencies: ["SwiftMonocleCodeScope"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
