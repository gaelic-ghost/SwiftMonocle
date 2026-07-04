import Foundation
@testable import SwiftMonocleGraph
import Testing

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

@Test func packageGraphBuildsFromSwiftPMDescriptionJSON() throws {
    let description = try SwiftPackageDescription(jsonData: Data(swiftPMDescriptionJSON.utf8))
    let graph = PackageGraph(
        packageDescription: description,
        rootPath: ".",
        appOverlays: [
            PackageGraphAppOverlay(
                name: "ExampleApp",
                sourcePath: "Apps/ExampleApp",
                summary: "App overlay used by graph rendering tests.",
                productDependencies: ["Example"]
            ),
        ]
    )

    #expect(graph.packageIdentity == "Example")
    #expect(graph.node(id: .product("Example"))?.sourcePath == "Package.swift")
    #expect(graph.node(id: .target("ExampleCLI"))?.kind == .executableTarget)
    #expect(graph.node(id: .target("ExampleTests"))?.kind == .testTarget)
    #expect(graph.node(id: .app("ExampleApp"))?.sourcePath == "Apps/ExampleApp")
    #expect(
        graph.edges.contains(
            PackageGraphEdge(
                source: .target("ExampleTests"),
                target: .target("Example"),
                kind: .testTargetTestsTarget
            )
        )
    )
    #expect(graph.outgoingEdges(from: .app("ExampleApp")).map(\.target) == [.product("Example")])
}

private let swiftPMDescriptionJSON = """
{
  "name": "Example",
  "path": "/tmp/Example",
  "products": [
    {
      "name": "Example",
      "targets": [
        "Example"
      ],
      "type": {
        "library": [
          "automatic"
        ]
      }
    }
  ],
  "targets": [
    {
      "name": "Example",
      "path": "Sources/Example",
      "target_dependencies": [
        "ExampleCore"
      ],
      "type": "library"
    },
    {
      "name": "ExampleCore",
      "path": "Sources/ExampleCore",
      "type": "library"
    },
    {
      "name": "ExampleCLI",
      "path": "Sources/ExampleCLI",
      "target_dependencies": [
        "ExampleCore"
      ],
      "type": "executable"
    },
    {
      "name": "ExampleTests",
      "path": "Tests/ExampleTests",
      "target_dependencies": [
        "Example"
      ],
      "type": "test"
    }
  ]
}
"""
