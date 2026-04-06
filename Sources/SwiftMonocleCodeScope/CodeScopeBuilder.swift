import Foundation
import SwiftMonocleCore

// MARK: - CodeScope builder

public struct CodeScopeBuilder: Sendable {
    public init() {}

    public func build(from input: CodeScopeInput) -> CodeScopeSnapshot {
        let rankedSymbols = input.symbols.candidates.sorted { lhs, rhs in
            if lhs.relevanceScore == rhs.relevanceScore {
                return lhs.name < rhs.name
            }
            return lhs.relevanceScore > rhs.relevanceScore
        }

        let focalSymbol = rankedSymbols.first
        let enclosingSymbols = focalSymbol.map { [$0] } ?? []
        let neighboringSymbols = Array(rankedSymbols.dropFirst().prefix(5))

        let diagnostics = DiagnosticsScope(
            fileDiagnostics: rankedByRelevance(input.diagnostics.fileDiagnostics),
            relatedDiagnostics: rankedByRelevance(input.diagnostics.relatedDiagnostics)
        )

        let docs = DocScope(
            directMatches: rankedByRelevance(input.docs.directMatches),
            supportingMatches: rankedByRelevance(input.docs.supportingMatches),
            pendingRefresh: input.docs.pendingRefresh
        )

        let actions = recommendedActions(
            symbols: focalSymbol,
            diagnostics: diagnostics,
            docs: docs,
            agent: input.agent?.scope
        )

        return CodeScopeSnapshot(
            reason: input.reason,
            workspace: normalizedWorkspace(input.workspace),
            editor: input.editor?.scope,
            symbols: SymbolScope(
                focalSymbol: focalSymbol,
                enclosingSymbols: enclosingSymbols,
                neighboringSymbols: neighboringSymbols,
                referencedSymbols: []
            ),
            diagnostics: diagnostics,
            docs: docs,
            agent: input.agent?.scope,
            actions: actions,
            provenance: ScopeProvenance(sources: mergedProvenance(from: input))
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

    private func mergedProvenance(from input: CodeScopeInput) -> [ScopeSourceRecord] {
        var records: [ScopeSourceRecord] = []
        if let editor = input.editor {
            records.append(editor.source)
        }
        records.append(contentsOf: input.symbols.sources)
        records.append(contentsOf: input.diagnostics.sources)
        records.append(contentsOf: input.docs.sources)
        if let agent = input.agent {
            records.append(agent.source)
        }
        return records.sorted { lhs, rhs in
            if lhs.observedAt == rhs.observedAt {
                return lhs.source.rawValue < rhs.source.rawValue
            }
            return lhs.observedAt > rhs.observedAt
        }
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
