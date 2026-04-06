import Testing
@testable import SwiftMonocle
import SwiftMonocleCore

// MARK: - Top-level package tests

@Test func packageSurfaceExportsCodeScope() async throws {
    let builder = CodeScopeBuilder()
    let snapshot = builder.build(
        from: CodeScopeInput(
            reason: .manualRefresh,
            workspace: WorkspaceScope(rootPath: "/tmp/SwiftMonocle")
        )
    )

    #expect(snapshot.reason == CodeScopeReason.manualRefresh)
}
