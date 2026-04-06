import Foundation
import Testing
@testable import SwiftMonocleCodeScope
import SwiftMonocleCore

// MARK: - CodeScope input tests

@Test func builderMergesProvenanceFromSeparateFeeds() async throws {
    let file = FileReference(path: "/tmp/SwiftMonocle/Sources/SwiftMonocleCore/CodeScopeSnapshot.swift")
    let now = Date()

    let snapshot = CodeScopeBuilder().build(
        from: CodeScopeInput(
            reason: .editorChanged,
            workspace: WorkspaceScope(rootPath: "/tmp/SwiftMonocle"),
            editor: CodeScopeEditorInput(
                scope: EditorScope(
                    file: file,
                    cursor: TextCursor(line: 12, column: 5)
                ),
                source: ScopeSourceRecord(
                    source: .editorExtension,
                    observedAt: now.addingTimeInterval(-2),
                    freshness: .live
                )
            ),
            diagnostics: CodeScopeDiagnosticsInput(
                fileDiagnostics: [
                    DiagnosticRecord(
                        severity: .warning,
                        message: "Example warning",
                        source: "xcode",
                        file: file,
                        relevanceScore: 0.8
                    )
                ],
                sources: [
                    ScopeSourceRecord(
                        source: .xcodeMCP,
                        observedAt: now.addingTimeInterval(-1),
                        freshness: .recent
                    )
                ]
            ),
            docs: CodeScopeDocsInput(
                directMatches: [
                    DocumentReference(
                        title: "XcodeKit",
                        url: "https://developer.apple.com/documentation/xcodekit",
                        source: "apple",
                        relevanceScore: 1
                    )
                ],
                pendingRefresh: true,
                sources: [
                    ScopeSourceRecord(
                        source: .docsEngine,
                        observedAt: now,
                        freshness: .recent
                    )
                ]
            )
        )
    )

    #expect(snapshot.provenance.sources.count == 3)
    #expect(snapshot.provenance.sources.first?.source == .docsEngine)
    #expect(snapshot.docs.pendingRefresh)
}

@Test func builderDerivesSyntaxSymbolsFromEditorBuffer() async throws {
    let file = FileReference(path: "/tmp/SwiftMonocle/Sources/Feature/Greeter.swift")
    let source = """
    struct Greeter {
        let name: String

        func greet() {
            print(name)
        }

        func helper() {}
    }
    """

    let snapshot = CodeScopeBuilder().build(
        from: CodeScopeInput(
            reason: .editorChanged,
            workspace: WorkspaceScope(rootPath: "/tmp/SwiftMonocle"),
            editor: CodeScopeEditorInput(
                scope: EditorScope(
                    file: file,
                    cursor: TextCursor(line: 4, column: 12)
                ),
                bufferText: source,
                source: ScopeSourceRecord(
                    source: .editorExtension,
                    observedAt: .now,
                    freshness: .live
                )
            )
        )
    )

    #expect(snapshot.symbols.focalSymbol?.name == "greet")
    #expect(snapshot.symbols.enclosingSymbols.map(\.name) == ["Greeter"])
    #expect(snapshot.symbols.neighboringSymbols.contains { $0.name == "helper" })
    #expect(snapshot.provenance.sources.contains { $0.source == .swiftSyntax })
}
