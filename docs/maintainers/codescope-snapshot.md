# CodeScope Snapshot Model

## Purpose

This document defines the first concrete `CodeScope` snapshot model for SwiftMonocle.

The goal is to give the user and the hosted agent one shared, curated, inspectable view of the code and surrounding context at a finer detail than "the whole repository" while avoiding multiple competing truth sources.

## Design goals

- keep one canonical scope snapshot model
- make provenance visible so the user and agent can tell where each piece of data came from
- make freshness visible so stale state can be detected instead of silently trusted
- keep the phase-1 model small enough to ship
- preserve room for deeper semantic understanding later

## Non-goals for phase 1

- full semantic indexing of the entire workspace
- speculative project-wide knowledge graph construction
- broad autonomous docs crawling without a triggering context
- process isolation between each scope-producing subsystem

## Snapshot philosophy

A `CodeScopeSnapshot` is not the entire state of the project. It is a curated working set assembled for a specific user-and-agent moment.

That means:

- it is intentionally partial
- it is assembled from multiple sources
- it carries source and freshness metadata
- it is designed to be regenerated often

## Top-level model

The first concrete top-level shape should be conceptually equivalent to:

```swift
public struct CodeScopeSnapshot: Sendable, Codable {
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
}
```

This should live in `SwiftMonocleCore`, with richer builders and adapters living elsewhere.

## Why this shape

This structure gives us:

- one stable transport-neutral object that UI, MCP, and internal services can all consume
- optional editor and agent attachments so the same model works both with and without live Xcode or active Codex sessions
- a clear split between "what the code context is" and "what the system recommends doing next"

The simpler extension path considered first was exposing several sibling snapshots like `EditorSnapshot`, `DocsSnapshot`, and `AgentSnapshot` independently with no unified parent. That would be easier short-term, but it would make merging, ranking, and explaining scope quality much messier almost immediately.

## Identity and lifecycle

## Snapshot identity

`CodeScopeSnapshotID` should be opaque and stable only for the lifetime of the snapshot.

It does not need to survive process restarts as a durable global identifier. It only needs to support:

- UI diffing
- agent-side references
- traceability in logs and diagnostics

## Snapshot reasons

`CodeScopeReason` should explain why the snapshot was built.

Suggested initial cases:

- `editorChanged`
- `selectionChanged`
- `userCommand`
- `agentRequest`
- `diagnosticsChanged`
- `docsRefresh`
- `manualRefresh`

This gives us traceable intent without dragging transport-specific event details into the core model.

## Provenance model

Every scope should carry source metadata. The product needs to distinguish between:

- directly observed editor state
- Xcode-derived state
- syntax-derived state
- doc-engine derived state
- inferred or ranked relationships

Suggested structure:

```swift
public struct ScopeProvenance: Sendable, Codable {
    public var sources: [ScopeSourceRecord]
}

public struct ScopeSourceRecord: Sendable, Codable {
    public var source: ScopeSource
    public var observedAt: Date
    public var freshness: ScopeFreshness
    public var notes: String?
}
```

Suggested initial `ScopeSource` cases:

- `editorExtension`
- `xcodeMCP`
- `swiftSyntax`
- `sourceKit`
- `docsEngine`
- `codexAppServer`
- `workspaceScanner`
- `inference`

Suggested initial `ScopeFreshness` cases:

- `live`
- `recent`
- `stale`
- `unknown`

## Workspace scope

`WorkspaceScope` should answer: what project context surrounds this moment?

Suggested phase-1 contents:

```swift
public struct WorkspaceScope: Sendable, Codable {
    public var rootPath: String
    public var packageIdentity: String?
    public var activeTarget: TargetReference?
    public var relatedFiles: [RelatedFile]
    public var relevantTests: [RelatedTest]
}
```

### Notes

- `rootPath` is the current workspace root path
- `packageIdentity` is optional because the same model should still work before project detection becomes richer
- `activeTarget` should be best-effort
- `relatedFiles` should be ranked, not exhaustive
- `relevantTests` should be only the tests near the current file or symbol, not every test in the repository

## Editor scope

`EditorScope` should answer: what is the user actively looking at and where are they focused?

Suggested phase-1 contents:

```swift
public struct EditorScope: Sendable, Codable {
    public var file: FileReference
    public var selections: [TextSelection]
    public var cursor: TextCursor?
    public var visibleRange: TextRange?
    public var bufferVersion: BufferVersion?
}
```

### Notes

- `file` should carry canonical path plus display name
- `selections` should preserve order
- `cursor` is separate so empty selections are not overloaded
- `visibleRange` is optional because not every source can provide it
- `bufferVersion` should help detect stale symbol or doc attachments after edits

## Symbol scope

`SymbolScope` should answer: what declaration neighborhood matters right now?

Suggested phase-1 contents:

```swift
public struct SymbolScope: Sendable, Codable {
    public var focalSymbol: SymbolReference?
    public var enclosingSymbols: [SymbolReference]
    public var neighboringSymbols: [SymbolReference]
    public var referencedSymbols: [SymbolReference]
}
```

### Ranking intent

- `focalSymbol` is the symbol the current cursor or selection is most likely inside
- `enclosingSymbols` describes lexical containment
- `neighboringSymbols` captures useful nearby declarations in the same file or region
- `referencedSymbols` should be a curated list, not an eager call graph

### Phase-1 source expectation

Phase 1 can start mostly syntax-first:

- lexical containment
- declaration ranges
- nearby declarations by distance
- explicit references we can derive safely

Deeper semantic linkage can come later.

## Diagnostics scope

`DiagnosticsScope` should answer: what active problems or warnings shape this moment?

Suggested phase-1 contents:

```swift
public struct DiagnosticsScope: Sendable, Codable {
    public var fileDiagnostics: [DiagnosticRecord]
    public var relatedDiagnostics: [DiagnosticRecord]
}
```

### Notes

- `fileDiagnostics` are for the active file
- `relatedDiagnostics` are nearby or target-relevant diagnostics outside the file
- diagnostics should include severity, source, message, and location
- diagnostics should be ranked by relevance, not dumped wholesale

## Docs scope

`DocScope` should answer: what documentation is relevant right now?

Suggested phase-1 contents:

```swift
public struct DocScope: Sendable, Codable {
    public var directMatches: [DocumentReference]
    public var supportingMatches: [DocumentReference]
    public var pendingRefresh: Bool
}
```

### Notes

- `directMatches` should be highly ranked documents tied to the current file, symbol, API, or diagnostic
- `supportingMatches` can include nearby framework guidance or likely-next docs
- `pendingRefresh` tells the consumer that docs are being refreshed and may improve shortly

The doc scope should be intentionally narrow in phase 1.

## Agent scope

`AgentScope` should answer: what active Codex or hosted-agent state matters to this coding moment?

Suggested phase-1 contents:

```swift
public struct AgentScope: Sendable, Codable {
    public var sessionID: String?
    public var threadID: String?
    public var status: AgentStatus
    public var pendingApprovals: [PendingApproval]
    public var lastMeaningfulOutput: AgentOutputSummary?
}
```

### Notes

- this belongs in the unified snapshot because the UI and the user need code context and agent state side by side
- `lastMeaningfulOutput` should be summarized and bounded
- raw event streams should stay out of the core snapshot

## Recommended actions

The snapshot should include bounded recommendations derived from the current context, but those recommendations should not replace the raw scope data.

Suggested shape:

```swift
public struct RecommendedAction: Sendable, Codable {
    public var kind: RecommendedActionKind
    public var title: String
    public var rationale: String
}
```

Suggested early cases:

- `openDocumentation`
- `inspectDiagnostics`
- `reviewNeighborSymbol`
- `runScopedCommand`
- `refreshScope`
- `requestApproval`

This is how SwiftMonocle starts feeling helpful without burying the core snapshot under imperative logic.

## Cross-cutting reference types

The snapshot should normalize repeated concepts into a few shared reference types.

Suggested initial shared references:

- `FileReference`
- `TextRange`
- `TextSelection`
- `TextCursor`
- `BufferVersion`
- `SymbolReference`
- `DiagnosticRecord`
- `DocumentReference`
- `TargetReference`
- `RelatedFile`
- `RelatedTest`

These should live in `SwiftMonocleCore`, not in subsystem-specific packages.

## Merge rules

The snapshot builder needs explicit merge rules because data will arrive from different systems at different speeds.

### Initial merge policy

- editor facts beat inferred editor facts
- Xcode diagnostics beat syntax-only guesses
- syntax-derived symbol structure fills gaps when richer semantic data is missing
- direct user-visible sources outrank speculative inferred relationships
- stale records are kept only when marked stale and only when they still add explanatory value

This prevents "most recent writer wins" from becoming accidental truth.

## Freshness policy

Each major scope attachment should be independently freshenable.

That means a single `CodeScopeSnapshot` can contain:

- live editor state
- recent diagnostics
- stale docs that are waiting on refresh

This is better than blocking the whole snapshot until every subsystem catches up.

## MCP exposure stance

The `CodeScopeSnapshot` should be the primary internal object, but it should not be exposed raw everywhere forever.

Phase 1 MCP exposure should likely offer:

- one high-level tool or resource that returns the current snapshot
- smaller derived tools/resources for focused consumers later

This gives us one shared truth source before we optimize for narrower transports.

## Phase-1 package ownership

### `SwiftMonocleCore`

- snapshot IDs
- shared reference types
- `CodeScopeSnapshot`
- provenance and freshness models

### `SwiftMonocleCodeScope`

- snapshot builders
- symbol ranking
- related-file ranking
- recommendation generation

### `SwiftMonocleDocs`

- document matching
- ranking
- cache refresh state feeding `DocScope`

### `SwiftMonocleXcodeBridge`

- editor and Xcode adapters that produce normalized input for snapshot building

### `SwiftMonocleAgentBridge`

- normalized agent-session state feeding `AgentScope`

## First implementation boundary

To keep scope honest, phase 1 should stop at:

- active file
- selections and cursor
- lexical symbol neighborhood
- file and nearby diagnostics
- top-ranked docs
- bounded active agent status

It should not attempt:

- full workspace symbol graphs
- speculative architecture understanding
- autonomous long-range docs planning
- exhaustive dependency or call graph modeling

## Immediate next step

The next maintainer step after this document should be to define the actual Swift types and package ownership for:

- `CodeScopeSnapshot`
- `FileReference`
- `TextRange`
- `SymbolReference`
- `DiagnosticRecord`
- `DocumentReference`

That is the minimum needed to begin scaffolding `SwiftMonocleCore` and `SwiftMonocleCodeScope`.
