import Foundation
import SwiftMonocleCore

// MARK: - CodeScope build request

public struct CodeScopeBuildRequest: Sendable {
    public var reason: CodeScopeReason
    public var workspace: WorkspaceScope
    public var editor: EditorScope?
    public var symbolCandidates: [SymbolReference]
    public var fileDiagnostics: [DiagnosticRecord]
    public var relatedDiagnostics: [DiagnosticRecord]
    public var directDocuments: [DocumentReference]
    public var supportingDocuments: [DocumentReference]
    public var agent: AgentScope?
    public var provenance: [ScopeSourceRecord]

    public init(
        reason: CodeScopeReason,
        workspace: WorkspaceScope,
        editor: EditorScope? = nil,
        symbolCandidates: [SymbolReference] = [],
        fileDiagnostics: [DiagnosticRecord] = [],
        relatedDiagnostics: [DiagnosticRecord] = [],
        directDocuments: [DocumentReference] = [],
        supportingDocuments: [DocumentReference] = [],
        agent: AgentScope? = nil,
        provenance: [ScopeSourceRecord] = []
    ) {
        self.reason = reason
        self.workspace = workspace
        self.editor = editor
        self.symbolCandidates = symbolCandidates
        self.fileDiagnostics = fileDiagnostics
        self.relatedDiagnostics = relatedDiagnostics
        self.directDocuments = directDocuments
        self.supportingDocuments = supportingDocuments
        self.agent = agent
        self.provenance = provenance
    }
}

// MARK: - CodeScope builder

public struct CodeScopeBuilder: Sendable {
    public init() {}

    public func build(from request: CodeScopeBuildRequest) -> CodeScopeSnapshot {
        let rankedSymbols = request.symbolCandidates.sorted { lhs, rhs in
            if lhs.relevanceScore == rhs.relevanceScore {
                return lhs.name < rhs.name
            }
            return lhs.relevanceScore > rhs.relevanceScore
        }

        let focalSymbol = rankedSymbols.first
        let enclosingSymbols = focalSymbol.map { [$0] } ?? []
        let neighboringSymbols = Array(rankedSymbols.dropFirst().prefix(5))

        let diagnostics = DiagnosticsScope(
            fileDiagnostics: rankedByRelevance(request.fileDiagnostics),
            relatedDiagnostics: rankedByRelevance(request.relatedDiagnostics)
        )

        let docs = DocScope(
            directMatches: rankedByRelevance(request.directDocuments),
            supportingMatches: rankedByRelevance(request.supportingDocuments),
            pendingRefresh: false
        )

        let actions = recommendedActions(
            symbols: focalSymbol,
            diagnostics: diagnostics,
            docs: docs,
            agent: request.agent
        )

        return CodeScopeSnapshot(
            reason: request.reason,
            workspace: normalizedWorkspace(request.workspace),
            editor: request.editor,
            symbols: SymbolScope(
                focalSymbol: focalSymbol,
                enclosingSymbols: enclosingSymbols,
                neighboringSymbols: neighboringSymbols,
                referencedSymbols: []
            ),
            diagnostics: diagnostics,
            docs: docs,
            agent: request.agent,
            actions: actions,
            provenance: ScopeProvenance(sources: request.provenance)
        )
    }

    private func normalizedWorkspace(_ workspace: WorkspaceScope) -> WorkspaceScope {
        WorkspaceScope(
            rootPath: workspace.rootPath,
            packageIdentity: workspace.packageIdentity,
            activeTarget: workspace.activeTarget,
            relatedFiles: rankedByRelevance(workspace.relatedFiles),
            relevantTests: rankedByRelevance(workspace.relevantTests)
        )
    }

    private func recommendedActions(
        symbols: SymbolReference?,
        diagnostics: DiagnosticsScope,
        docs: DocScope,
        agent: AgentScope?
    ) -> [RecommendedAction] {
        var actions: [RecommendedAction] = []

        if !diagnostics.fileDiagnostics.isEmpty || !diagnostics.relatedDiagnostics.isEmpty {
            actions.append(
                RecommendedAction(
                    kind: .inspectDiagnostics,
                    title: "Inspect active diagnostics",
                    rationale: "The current scope contains file or nearby diagnostics that may change what the agent should do next."
                )
            )
        }

        if let symbol = symbols {
            actions.append(
                RecommendedAction(
                    kind: .reviewNeighborSymbol,
                    title: "Review symbol context",
                    rationale: "The focal symbol `\(symbol.name)` anchors the current coding moment and is a good starting point for nearby analysis."
                )
            )
        }

        if !docs.directMatches.isEmpty {
            actions.append(
                RecommendedAction(
                    kind: .openDocumentation,
                    title: "Open ranked documentation",
                    rationale: "The current scope already has directly relevant documentation attached."
                )
            )
        }

        if agent?.status == .waitingForApproval {
            actions.append(
                RecommendedAction(
                    kind: .requestApproval,
                    title: "Resolve pending approval",
                    rationale: "The active agent session is blocked on approval."
                )
            )
        }

        if actions.isEmpty {
            actions.append(
                RecommendedAction(
                    kind: .refreshScope,
                    title: "Refresh scope",
                    rationale: "The current scope is quiet enough that a fresh snapshot may provide better next actions."
                )
            )
        }

        return actions
    }
}

private func rankedByRelevance<Value>(_ values: [Value]) -> [Value] where Value: RelevanceScored {
    values.sorted { lhs, rhs in
        if lhs.relevanceScore == rhs.relevanceScore {
            return lhs.relevanceTieBreaker < rhs.relevanceTieBreaker
        }
        return lhs.relevanceScore > rhs.relevanceScore
    }
}

private protocol RelevanceScored {
    var relevanceScore: Double { get }
    var relevanceTieBreaker: String { get }
}

extension RelatedFile: RelevanceScored {
    fileprivate var relevanceTieBreaker: String { file.path }
}

extension RelatedTest: RelevanceScored {
    fileprivate var relevanceTieBreaker: String { name }
}

extension SymbolReference: RelevanceScored {
    fileprivate var relevanceTieBreaker: String { name }
}

extension DiagnosticRecord: RelevanceScored {
    fileprivate var relevanceTieBreaker: String { message }
}

extension DocumentReference: RelevanceScored {
    fileprivate var relevanceTieBreaker: String { title }
}
