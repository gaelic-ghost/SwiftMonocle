import Testing
@testable import SwiftMonocleGraph

// MARK: - Package graph tests

@Test func packageGraphCarriesSourceBackedNodes() {
    let graph = PackageGraph.swiftMonocleBootstrap

    #expect(graph.packageIdentity == "SwiftMonocle")
    #expect(graph.node(id: .product("SwiftMonocleGraph"))?.sourcePath == "Package.swift")
    #expect(graph.node(id: .target("SwiftMonocleGraph"))?.sourcePath == "Sources/SwiftMonocleGraph")
}

@Test func packageGraphModelsProductAndTargetEdges() {
    let graph = PackageGraph.swiftMonocleBootstrap

    #expect(
        graph.edges.contains(
            PackageGraphEdge(
                source: .product("SwiftMonocleGraph"),
                target: .target("SwiftMonocleGraph"),
                kind: .productContainsTarget
            )
        )
    )
    #expect(
        graph.edges.contains(
            PackageGraphEdge(
                source: .target("SwiftMonocle"),
                target: .target("SwiftMonocleGraph"),
                kind: .targetDependsOnTarget
            )
        )
    )
}

@Test func packageGraphFindsRelatedTestsForTargets() {
    let graph = PackageGraph.swiftMonocleBootstrap
    let relatedTests = graph.relatedTests(for: .target("SwiftMonocleGraph"))

    #expect(relatedTests.map(\.name) == ["SwiftMonocleGraphTests"])
    #expect(relatedTests.first?.kind == .testTarget)
}

@Test func packageGraphIncludesAppProductDependencies() {
    let graph = PackageGraph.swiftMonocleBootstrap
    let appDependencies = graph.outgoingEdges(from: .app("SwiftMonocleApp"))

    #expect(appDependencies.map(\.target).contains(.product("SwiftMonocle")))
    #expect(appDependencies.map(\.target).contains(.product("SwiftMonocleGraph")))
}
