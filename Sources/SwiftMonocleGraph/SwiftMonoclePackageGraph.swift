// MARK: - SwiftMonocle package graph bootstrap

public extension PackageGraph {
    static let swiftMonocleBootstrap = PackageGraph(
        packageDescription: .swiftMonocleBootstrap,
        rootPath: ".",
        appOverlays: [.swiftMonocleApp]
    )
}

public extension SwiftPackageDescription {
    static let swiftMonocleBootstrap = SwiftPackageDescription(
        name: "SwiftMonocle",
        path: ".",
        products: [
            Product(name: "SwiftMonocle", targets: ["SwiftMonocle"]),
            Product(name: "SwiftMonocleCore", targets: ["SwiftMonocleCore"]),
            Product(name: "SwiftMonocleCodeScope", targets: ["SwiftMonocleCodeScope"]),
            Product(name: "SwiftMonocleGraph", targets: ["SwiftMonocleGraph"]),
        ],
        targets: [
            Target(
                name: "SwiftMonocle",
                path: "Sources/SwiftMonocle",
                type: .library,
                targetDependencies: ["SwiftMonocleCodeScope", "SwiftMonocleGraph"]
            ),
            Target(
                name: "SwiftMonocleCore",
                path: "Sources/SwiftMonocleCore",
                type: .library
            ),
            Target(
                name: "SwiftMonocleCodeScope",
                path: "Sources/SwiftMonocleCodeScope",
                type: .library,
                targetDependencies: ["SwiftMonocleCore"],
                productDependencies: ["SwiftSyntax", "SwiftParser"]
            ),
            Target(
                name: "SwiftMonocleGraph",
                path: "Sources/SwiftMonocleGraph",
                type: .library
            ),
            Target(
                name: "SwiftMonocleTests",
                path: "Tests/SwiftMonocleTests",
                type: .test,
                targetDependencies: ["SwiftMonocle"]
            ),
            Target(
                name: "SwiftMonocleCoreTests",
                path: "Tests/SwiftMonocleCoreTests",
                type: .test,
                targetDependencies: ["SwiftMonocleCore"]
            ),
            Target(
                name: "SwiftMonocleCodeScopeTests",
                path: "Tests/SwiftMonocleCodeScopeTests",
                type: .test,
                targetDependencies: ["SwiftMonocleCodeScope"]
            ),
            Target(
                name: "SwiftMonocleGraphTests",
                path: "Tests/SwiftMonocleGraphTests",
                type: .test,
                targetDependencies: ["SwiftMonocleGraph"]
            ),
        ]
    )
}

public extension PackageGraphAppOverlay {
    static let swiftMonocleApp = PackageGraphAppOverlay(
        name: "SwiftMonocleApp",
        sourcePath: "Apps/SwiftMonocleApp",
        summary: "macOS app shell for dependency graph and API visualization.",
        productDependencies: ["SwiftMonocle", "SwiftMonocleCore", "SwiftMonocleGraph"]
    )
}
