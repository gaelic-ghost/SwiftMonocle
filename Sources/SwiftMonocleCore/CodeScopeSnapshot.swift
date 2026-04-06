import Foundation

// MARK: - Snapshot identity

public struct CodeScopeSnapshotID: Sendable, Codable, Hashable, RawRepresentable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init() {
        self.rawValue = UUID().uuidString
    }
}

public enum CodeScopeReason: String, Sendable, Codable, CaseIterable {
    case editorChanged
    case selectionChanged
    case userCommand
    case agentRequest
    case diagnosticsChanged
    case docsRefresh
    case manualRefresh
}

// MARK: - Provenance

public struct ScopeProvenance: Sendable, Codable, Hashable {
    public var sources: [ScopeSourceRecord]

    public init(sources: [ScopeSourceRecord] = []) {
        self.sources = sources
    }
}

public struct ScopeSourceRecord: Sendable, Codable, Hashable, Identifiable {
    public var id: UUID
    public var source: ScopeSource
    public var observedAt: Date
    public var freshness: ScopeFreshness
    public var notes: String?

    public init(
        id: UUID = UUID(),
        source: ScopeSource,
        observedAt: Date,
        freshness: ScopeFreshness,
        notes: String? = nil
    ) {
        self.id = id
        self.source = source
        self.observedAt = observedAt
        self.freshness = freshness
        self.notes = notes
    }
}

public enum ScopeSource: String, Sendable, Codable, CaseIterable {
    case editorExtension
    case xcodeMCP
    case swiftSyntax
    case sourceKit
    case docsEngine
    case codexAppServer
    case workspaceScanner
    case inference
}

public enum ScopeFreshness: String, Sendable, Codable, CaseIterable {
    case live
    case recent
    case stale
    case unknown
}

// MARK: - Top-level snapshot

public struct CodeScopeSnapshot: Sendable, Codable, Hashable, Identifiable {
    public var id: CodeScopeSnapshotID
    public var createdAt: Date
    public var reason: CodeScopeReason
    public var workspace: WorkspaceScope
    public var editor: EditorScope?
    public var symbols: SymbolScope
    public var diagnostics: DiagnosticsScope
    public var docs: DocScope
    public var agent: AgentScope?
    public var actions: [RecommendedAction]
    public var provenance: ScopeProvenance

    public init(
        id: CodeScopeSnapshotID = .init(),
        createdAt: Date = .now,
        reason: CodeScopeReason,
        workspace: WorkspaceScope,
        editor: EditorScope? = nil,
        symbols: SymbolScope = .init(),
        diagnostics: DiagnosticsScope = .init(),
        docs: DocScope = .init(),
        agent: AgentScope? = nil,
        actions: [RecommendedAction] = [],
        provenance: ScopeProvenance = .init()
    ) {
        self.id = id
        self.createdAt = createdAt
        self.reason = reason
        self.workspace = workspace
        self.editor = editor
        self.symbols = symbols
        self.diagnostics = diagnostics
        self.docs = docs
        self.agent = agent
        self.actions = actions
        self.provenance = provenance
    }
}
