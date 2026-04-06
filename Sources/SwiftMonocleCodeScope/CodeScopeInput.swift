import Foundation
import SwiftMonocleCore

// MARK: - CodeScope input

public struct CodeScopeInput: Sendable {
    public var reason: CodeScopeReason
    public var workspace: WorkspaceScope
    public var editor: CodeScopeEditorInput?
    public var symbols: CodeScopeSymbolInput
    public var diagnostics: CodeScopeDiagnosticsInput
    public var docs: CodeScopeDocsInput
    public var agent: CodeScopeAgentInput?

    public init(
        reason: CodeScopeReason,
        workspace: WorkspaceScope,
        editor: CodeScopeEditorInput? = nil,
        symbols: CodeScopeSymbolInput = .init(),
        diagnostics: CodeScopeDiagnosticsInput = .init(),
        docs: CodeScopeDocsInput = .init(),
        agent: CodeScopeAgentInput? = nil
    ) {
        self.reason = reason
        self.workspace = workspace
        self.editor = editor
        self.symbols = symbols
        self.diagnostics = diagnostics
        self.docs = docs
        self.agent = agent
    }
}

// MARK: - Input feeds

public struct CodeScopeEditorInput: Sendable {
    public var scope: EditorScope
    public var bufferText: String?
    public var source: ScopeSourceRecord

    public init(
        scope: EditorScope,
        bufferText: String? = nil,
        source: ScopeSourceRecord
    ) {
        self.scope = scope
        self.bufferText = bufferText
        self.source = source
    }
}

public struct CodeScopeSymbolInput: Sendable {
    public var candidates: [SymbolReference]
    public var sources: [ScopeSourceRecord]

    public init(
        candidates: [SymbolReference] = [],
        sources: [ScopeSourceRecord] = []
    ) {
        self.candidates = candidates
        self.sources = sources
    }
}

public struct CodeScopeDiagnosticsInput: Sendable {
    public var fileDiagnostics: [DiagnosticRecord]
    public var relatedDiagnostics: [DiagnosticRecord]
    public var sources: [ScopeSourceRecord]

    public init(
        fileDiagnostics: [DiagnosticRecord] = [],
        relatedDiagnostics: [DiagnosticRecord] = [],
        sources: [ScopeSourceRecord] = []
    ) {
        self.fileDiagnostics = fileDiagnostics
        self.relatedDiagnostics = relatedDiagnostics
        self.sources = sources
    }
}

public struct CodeScopeDocsInput: Sendable {
    public var directMatches: [DocumentReference]
    public var supportingMatches: [DocumentReference]
    public var pendingRefresh: Bool
    public var sources: [ScopeSourceRecord]

    public init(
        directMatches: [DocumentReference] = [],
        supportingMatches: [DocumentReference] = [],
        pendingRefresh: Bool = false,
        sources: [ScopeSourceRecord] = []
    ) {
        self.directMatches = directMatches
        self.supportingMatches = supportingMatches
        self.pendingRefresh = pendingRefresh
        self.sources = sources
    }
}

public struct CodeScopeAgentInput: Sendable {
    public var scope: AgentScope
    public var source: ScopeSourceRecord

    public init(scope: AgentScope, source: ScopeSourceRecord) {
        self.scope = scope
        self.source = source
    }
}
