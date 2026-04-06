import Testing
@testable import SwiftMonocle
import SwiftMonocleCore

// MARK: - Top-level package tests

@Test func packageSurfaceExportsCodeScope() async throws {
    let builder = CodeScopeBuilder()
    let snapshot = builder.build(
        from: CodeScopeBuildRequest(
            reason: .manualRefresh,
            workspace: WorkspaceScope(rootPath: "/tmp/SwiftMonocle")
        )
    )

    #expect(snapshot.reason == CodeScopeReason.manualRefresh)
}
