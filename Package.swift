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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftMonocleCore"
        ),
        .target(
            name: "SwiftMonocleCodeScope",
            dependencies: [
                "SwiftMonocleCore",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]
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
