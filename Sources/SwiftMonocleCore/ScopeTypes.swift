import Foundation

// MARK: - Workspace scope

public struct WorkspaceScope: Sendable, Codable, Hashable {
    public var rootPath: String
    public var packageIdentity: String?
    public var activeTarget: TargetReference?
    public var relatedFiles: [RelatedFile]
    public var relevantTests: [RelatedTest]

    public init(
        rootPath: String,
        packageIdentity: String? = nil,
        activeTarget: TargetReference? = nil,
        relatedFiles: [RelatedFile] = [],
        relevantTests: [RelatedTest] = []
    ) {
        self.rootPath = rootPath
        self.packageIdentity = packageIdentity
        self.activeTarget = activeTarget
        self.relatedFiles = relatedFiles
        self.relevantTests = relevantTests
    }
}

// MARK: - Editor scope

public struct EditorScope: Sendable, Codable, Hashable {
    public var file: FileReference
    public var selections: [TextSelection]
    public var cursor: TextCursor?
    public var visibleRange: TextRange?
    public var bufferVersion: BufferVersion?

    public init(
        file: FileReference,
        selections: [TextSelection] = [],
        cursor: TextCursor? = nil,
        visibleRange: TextRange? = nil,
        bufferVersion: BufferVersion? = nil
    ) {
        self.file = file
        self.selections = selections
        self.cursor = cursor
        self.visibleRange = visibleRange
        self.bufferVersion = bufferVersion
    }
}

// MARK: - Symbol scope

public struct SymbolScope: Sendable, Codable, Hashable {
    public var focalSymbol: SymbolReference?
    public var enclosingSymbols: [SymbolReference]
    public var neighboringSymbols: [SymbolReference]
    public var referencedSymbols: [SymbolReference]

    public init(
        focalSymbol: SymbolReference? = nil,
        enclosingSymbols: [SymbolReference] = [],
        neighboringSymbols: [SymbolReference] = [],
        referencedSymbols: [SymbolReference] = []
    ) {
        self.focalSymbol = focalSymbol
        self.enclosingSymbols = enclosingSymbols
        self.neighboringSymbols = neighboringSymbols
        self.referencedSymbols = referencedSymbols
    }
}

// MARK: - Diagnostics scope

public struct DiagnosticsScope: Sendable, Codable, Hashable {
    public var fileDiagnostics: [DiagnosticRecord]
    public var relatedDiagnostics: [DiagnosticRecord]

    public init(
        fileDiagnostics: [DiagnosticRecord] = [],
        relatedDiagnostics: [DiagnosticRecord] = []
    ) {
        self.fileDiagnostics = fileDiagnostics
        self.relatedDiagnostics = relatedDiagnostics
    }
}

// MARK: - Docs scope

public struct DocScope: Sendable, Codable, Hashable {
    public var directMatches: [DocumentReference]
    public var supportingMatches: [DocumentReference]
    public var pendingRefresh: Bool

    public init(
        directMatches: [DocumentReference] = [],
        supportingMatches: [DocumentReference] = [],
        pendingRefresh: Bool = false
    ) {
        self.directMatches = directMatches
        self.supportingMatches = supportingMatches
        self.pendingRefresh = pendingRefresh
    }
}

// MARK: - Agent scope

public struct AgentScope: Sendable, Codable, Hashable {
    public var sessionID: String?
    public var threadID: String?
    public var status: AgentStatus
    public var pendingApprovals: [PendingApproval]
    public var lastMeaningfulOutput: AgentOutputSummary?

    public init(
        sessionID: String? = nil,
        threadID: String? = nil,
        status: AgentStatus = .idle,
        pendingApprovals: [PendingApproval] = [],
        lastMeaningfulOutput: AgentOutputSummary? = nil
    ) {
        self.sessionID = sessionID
        self.threadID = threadID
        self.status = status
        self.pendingApprovals = pendingApprovals
        self.lastMeaningfulOutput = lastMeaningfulOutput
    }
}

public enum AgentStatus: String, Sendable, Codable, CaseIterable {
    case idle
    case preparing
    case running
    case waitingForApproval
    case interrupted
    case failed
    case completed
}

public struct PendingApproval: Sendable, Codable, Hashable, Identifiable {
    public var id: UUID
    public var title: String
    public var summary: String

    public init(id: UUID = UUID(), title: String, summary: String) {
        self.id = id
        self.title = title
        self.summary = summary
    }
}

public struct AgentOutputSummary: Sendable, Codable, Hashable {
    public var title: String
    public var summary: String

    public init(title: String, summary: String) {
        self.title = title
        self.summary = summary
    }
}

// MARK: - Recommended actions

public struct RecommendedAction: Sendable, Codable, Hashable, Identifiable {
    public var id: UUID
    public var kind: RecommendedActionKind
    public var title: String
    public var rationale: String

    public init(
        id: UUID = UUID(),
        kind: RecommendedActionKind,
        title: String,
        rationale: String
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.rationale = rationale
    }
}

public enum RecommendedActionKind: String, Sendable, Codable, CaseIterable {
    case openDocumentation
    case inspectDiagnostics
    case reviewNeighborSymbol
    case runScopedCommand
    case refreshScope
    case requestApproval
}
