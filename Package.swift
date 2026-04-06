// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMonocle",
    platforms: [
        .macOS("15.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftMonocle",
            targets: ["SwiftMonocle"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftMonocle"
        ),
        .testTarget(
            name: "SwiftMonocleTests",
            dependencies: ["SwiftMonocle"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
