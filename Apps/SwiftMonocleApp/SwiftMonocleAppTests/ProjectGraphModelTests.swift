import Testing
@testable import SwiftMonocleApp

@Test func bootstrapGraphIncludesAppAndPackageTargets() {
    let model = ProjectGraphModel.swiftMonocleBootstrap
    let nodeNames = Set(model.nodes.map(\.name))

    #expect(nodeNames.contains("SwiftMonocleApp"))
    #expect(nodeNames.contains("SwiftMonocleGraph"))
    #expect(nodeNames.contains("SwiftMonocleCore"))
    #expect(model.edges.contains { $0.id == "appDependsOnProduct:app:SwiftMonocleApp->product:SwiftMonocle" })
    #expect(model.edges.contains { $0.source == "SwiftMonocleApp [App Target]" })
}

@Test func bootstrapGraphExposesSourceBackedDetails() {
    let model = ProjectGraphModel.swiftMonocleBootstrap
    let graphNode = model.nodes.first { $0.id == "target:SwiftMonocleGraph" }

    #expect(graphNode?.sourcePath == "Sources/SwiftMonocleGraph")
    #expect(graphNode?.relatedTests == ["SwiftMonocleGraphTests"])
}

@Test func bootstrapGraphCarriesScopeSnapshotIdentity() {
    let model = ProjectGraphModel.swiftMonocleBootstrap

    #expect(model.snapshot.workspace.packageIdentity == "SwiftMonocle")
    #expect(model.snapshot.reason == .manualRefresh)
    #expect(model.snapshot.actions.count == 1)
}
