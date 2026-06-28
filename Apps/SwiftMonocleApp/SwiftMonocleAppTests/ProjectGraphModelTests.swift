import Testing
@testable import SwiftMonocleApp

@Test func bootstrapGraphIncludesAppAndPackageTargets() {
    let model = ProjectGraphModel.swiftMonocleBootstrap
    let nodeNames = Set(model.nodes.map(\.name))

    #expect(nodeNames.contains("SwiftMonocleApp"))
    #expect(nodeNames.contains("SwiftMonocleCore"))
    #expect(model.edges.contains(ProjectGraphEdge(source: "SwiftMonocleApp", target: "SwiftMonocle")))
}

@Test func bootstrapGraphCarriesScopeSnapshotIdentity() {
    let model = ProjectGraphModel.swiftMonocleBootstrap

    #expect(model.snapshot.workspace.packageIdentity == "SwiftMonocle")
    #expect(model.snapshot.reason == .manualRefresh)
    #expect(model.snapshot.actions.count == 1)
}
