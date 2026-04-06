import Testing
@testable import SwiftMonocleCodeScope
import SwiftMonocleCore

// MARK: - CodeScope builder tests

@Test func builderChoosesHighestRankedFocalSymbol() async throws {
    let file = FileReference(path: "/tmp/SwiftMonocle/Sources/SwiftMonocleCore/CodeScopeSnapshot.swift")
    let range = TextRange(startLine: 1, startColumn: 1, endLine: 10, endColumn: 1)

    let snapshot = CodeScopeBuilder().build(
        from: CodeScopeInput(
            reason: .agentRequest,
            workspace: WorkspaceScope(rootPath: "/tmp/SwiftMonocle"),
            symbols: CodeScopeSymbolInput(
                candidates: [
                    SymbolReference(
                        name: "WorkspaceScope",
                        kind: .struct,
                        file: file,
                        range: range,
                        relevanceScore: 0.4
                    ),
                    SymbolReference(
                        name: "CodeScopeSnapshot",
                        kind: .struct,
                        file: file,
                        range: range,
                        relevanceScore: 0.9
                    ),
                ]
            )
        )
    )

    #expect(snapshot.symbols.focalSymbol?.name == "CodeScopeSnapshot")
    #expect(snapshot.symbols.neighboringSymbols.count == 1)
}

@Test func builderAddsDiagnosticActionWhenDiagnosticsExist() async throws {
    let file = FileReference(path: "/tmp/SwiftMonocle/Sources/SwiftMonocleCore/CodeScopeSnapshot.swift")

    let snapshot = CodeScopeBuilder().build(
        from: CodeScopeInput(
            reason: .diagnosticsChanged,
            workspace: WorkspaceScope(rootPath: "/tmp/SwiftMonocle"),
            diagnostics: CodeScopeDiagnosticsInput(
                fileDiagnostics: [
                    DiagnosticRecord(
                        severity: .error,
                        message: "Example error",
                        source: "xcode",
                        file: file,
                        relevanceScore: 1
                    )
                ]
            )
        )
    )

    #expect(snapshot.actions.contains { $0.kind == .inspectDiagnostics })
}
