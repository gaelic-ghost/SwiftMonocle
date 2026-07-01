// MARK: - SwiftMonocle package graph fixture

public extension PackageGraph {
    static let swiftMonocleBootstrap = PackageGraph(
        packageIdentity: "SwiftMonocle",
        rootPath: ".",
        nodes: [
            PackageGraphNode(
                id: .product("SwiftMonocle"),
                name: "SwiftMonocle",
                kind: .product,
                sourcePath: "Package.swift",
                summary: "Umbrella package product for the current code-scope and graph surfaces."
            ),
            PackageGraphNode(
                id: .product("SwiftMonocleCore"),
                name: "SwiftMonocleCore",
                kind: .product,
                sourcePath: "Package.swift",
                summary: "Product exposing shared snapshot identity, provenance, references, and scope models."
            ),
            PackageGraphNode(
                id: .product("SwiftMonocleCodeScope"),
                name: "SwiftMonocleCodeScope",
                kind: .product,
                sourcePath: "Package.swift",
                summary: "Product exposing syntax-backed scope extraction and CodeScopeInput assembly."
            ),
            PackageGraphNode(
                id: .product("SwiftMonocleGraph"),
                name: "SwiftMonocleGraph",
                kind: .product,
                sourcePath: "Package.swift",
                summary: "Product exposing source-backed package graph primitives."
            ),
            PackageGraphNode(
                id: .target("SwiftMonocle"),
                name: "SwiftMonocle",
                kind: .libraryTarget,
                sourcePath: "Sources/SwiftMonocle",
                summary: "Umbrella target that re-exports the current public package surfaces."
            ),
            PackageGraphNode(
                id: .target("SwiftMonocleCore"),
                name: "SwiftMonocleCore",
                kind: .libraryTarget,
                sourcePath: "Sources/SwiftMonocleCore",
                summary: "Shared snapshot identity, provenance, reference, and scope model target."
            ),
            PackageGraphNode(
                id: .target("SwiftMonocleCodeScope"),
                name: "SwiftMonocleCodeScope",
                kind: .libraryTarget,
                sourcePath: "Sources/SwiftMonocleCodeScope",
                summary: "Syntax-backed target for scope extraction and code-neighborhood construction."
            ),
            PackageGraphNode(
                id: .target("SwiftMonocleGraph"),
                name: "SwiftMonocleGraph",
                kind: .libraryTarget,
                sourcePath: "Sources/SwiftMonocleGraph",
                summary: "Package graph model target for products, targets, dependencies, and related tests."
            ),
            PackageGraphNode(
                id: .target("SwiftMonocleTests"),
                name: "SwiftMonocleTests",
                kind: .testTarget,
                sourcePath: "Tests/SwiftMonocleTests",
                summary: "Tests for the umbrella package product."
            ),
            PackageGraphNode(
                id: .target("SwiftMonocleCoreTests"),
                name: "SwiftMonocleCoreTests",
                kind: .testTarget,
                sourcePath: "Tests/SwiftMonocleCoreTests",
                summary: "Tests for core snapshot and reference models."
            ),
            PackageGraphNode(
                id: .target("SwiftMonocleCodeScopeTests"),
                name: "SwiftMonocleCodeScopeTests",
                kind: .testTarget,
                sourcePath: "Tests/SwiftMonocleCodeScopeTests",
                summary: "Tests for scope input assembly and syntax extraction."
            ),
            PackageGraphNode(
                id: .target("SwiftMonocleGraphTests"),
                name: "SwiftMonocleGraphTests",
                kind: .testTarget,
                sourcePath: "Tests/SwiftMonocleGraphTests",
                summary: "Tests for source-backed package graph relationships."
            ),
            PackageGraphNode(
                id: .app("SwiftMonocleApp"),
                name: "SwiftMonocleApp",
                kind: .appTarget,
                sourcePath: "Apps/SwiftMonocleApp",
                summary: "macOS app shell for dependency graph and API visualization."
            ),
        ],
        edges: [
            PackageGraphEdge(source: .product("SwiftMonocle"), target: .target("SwiftMonocle"), kind: .productContainsTarget),
            PackageGraphEdge(source: .product("SwiftMonocleCore"), target: .target("SwiftMonocleCore"), kind: .productContainsTarget),
            PackageGraphEdge(source: .product("SwiftMonocleCodeScope"), target: .target("SwiftMonocleCodeScope"), kind: .productContainsTarget),
            PackageGraphEdge(source: .product("SwiftMonocleGraph"), target: .target("SwiftMonocleGraph"), kind: .productContainsTarget),
            PackageGraphEdge(source: .target("SwiftMonocle"), target: .target("SwiftMonocleCodeScope"), kind: .targetDependsOnTarget),
            PackageGraphEdge(source: .target("SwiftMonocle"), target: .target("SwiftMonocleGraph"), kind: .targetDependsOnTarget),
            PackageGraphEdge(source: .target("SwiftMonocleCodeScope"), target: .target("SwiftMonocleCore"), kind: .targetDependsOnTarget),
            PackageGraphEdge(source: .target("SwiftMonocleTests"), target: .target("SwiftMonocle"), kind: .testTargetTestsTarget),
            PackageGraphEdge(source: .target("SwiftMonocleCoreTests"), target: .target("SwiftMonocleCore"), kind: .testTargetTestsTarget),
            PackageGraphEdge(source: .target("SwiftMonocleCodeScopeTests"), target: .target("SwiftMonocleCodeScope"), kind: .testTargetTestsTarget),
            PackageGraphEdge(source: .target("SwiftMonocleGraphTests"), target: .target("SwiftMonocleGraph"), kind: .testTargetTestsTarget),
            PackageGraphEdge(source: .app("SwiftMonocleApp"), target: .product("SwiftMonocle"), kind: .appDependsOnProduct),
            PackageGraphEdge(source: .app("SwiftMonocleApp"), target: .product("SwiftMonocleCore"), kind: .appDependsOnProduct),
            PackageGraphEdge(source: .app("SwiftMonocleApp"), target: .product("SwiftMonocleGraph"), kind: .appDependsOnProduct),
        ]
    )
}
