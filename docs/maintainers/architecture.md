# SwiftMonocle Architecture

## Purpose

This document captures the current architectural direction for SwiftMonocle as a shared, curated code-awareness layer between the user, Xcode, and a hosted coding agent.

The core product idea is not "give the agent raw repo access and hope for the best." The product idea is to give both the user and the agent one shared, finer-grained working view into the code, editor context, diagnostics, relevant documentation, and agent activity.

## Product intent

SwiftMonocle should eventually support:

- a curated view of the open file, surrounding symbols, diagnostics, and codebase context
- an Xcode-adjacent editing and command surface
- a hosted-agent bridge that works well with Codex app-server
- a human-friendly UI for code understanding, agent status, and a future voice interface
- proactive documentation retrieval, caching, curation, and refresh

## Architectural stance

SwiftMonocle should use separate Swift package libraries for major responsibilities, but it should not start as a pile of separate local daemons.

The recommended shape is:

- separate code organization
- one primary local host process at first
- one canonical internal scope model
- MCP exposed outward from the main host instead of from many early independent services

This keeps the code modular without paying the coordination cost of too many process boundaries before the seams are proven.

## Current implemented package graph

The repository already ships three package products:

- `SwiftMonocleCore`
  - shared snapshot identity, provenance, reference, and scope model types
- `SwiftMonocleCodeScope`
  - `CodeScopeInput`, `CodeScopeBuilder`, and the first `SwiftSyntax`-derived symbol extraction path
- `SwiftMonocle`
  - umbrella surface that currently re-exports `SwiftMonocleCodeScope`

That means the architecture is no longer purely aspirational. The current codebase has already committed to:

- one canonical `CodeScopeSnapshot` model
- one input-normalization layer
- one scope-construction layer
- syntax-first symbol extraction as the first semantic source

## Recommended next package graph

### Next package libraries

- `SwiftMonocleCore`
  - shared IDs, snapshots, events, errors, transport-neutral models
- `SwiftMonocleCodeScope`
  - open-file scope, selection scope, symbol scope, workspace scope, code projections
- `SwiftMonocleDocs`
  - doc ingestion, caching, ranking, refresh policy, document snapshots
- `SwiftMonocleXcodeBridge`
  - Xcode MCP integration, editor-context ingestion, Xcode-facing adapters
- `SwiftMonocleAgentBridge`
  - Codex-facing integration, streamed events, approvals, agent-session coordination
- `SwiftMonocleControlPlane`
  - orchestration, lifecycle, task coordination, state snapshots for UI consumers
- `SwiftMonocleUI`
  - reusable SwiftUI components built atop control-plane state
- `SwiftMonocleServer`
  - the main Hummingbird host exposing the curated MCP surface

### Later companion-app targets

These should likely live in a companion app/workspace rather than inside pure SwiftPM alone:

- a macOS application target
- an Xcode Source Editor Extension target

Shared logic for those targets should still live in the Swift package libraries above.

## Process model

### Recommended initial runtime shape

Start with one primary local Hummingbird host process.

That host should own:

- the canonical `CodeScope` state and snapshot building
- the docs engine
- the Codex-facing bridge
- the outward-facing MCP surface
- the control plane used by the future app UI

This means the early "docs engine MCP server" and "codescope MCP server" should be internal subsystems, not separate processes yet.

### Why collapse the early servers

Separate daemons are tempting, but they introduce early costs:

- duplicated caches
- stale state between editor, docs, and agent views
- more transport code than product code
- harder approval routing
- more difficult local debugging
- more failure modes around startup ordering and reconnection

The current recommendation is to split into separate processes only if one of these becomes true:

- a subsystem needs independent lifecycle or crash isolation
- a subsystem needs different resource limits or security boundaries
- a subsystem must be reused independently by external tools

## Canonical scope model

SwiftMonocle should center on one canonical scope model. The user, Xcode bridge, docs engine, control plane, and hosted agent should all derive from the same internal view rather than each building their own.

This is already true in the current codebase for the phase-1 scope surface: `CodeScopeSnapshot` is the source-of-truth model and `CodeScopeBuilder` is the current assembly point.

### Current scope types

- `EditorScope`
  - open file, current selections, cursor position, visible range, editing buffer metadata
- `SymbolScope`
  - enclosing declaration, neighboring declarations, referenced symbols, semantic anchors
- `WorkspaceScope`
  - related files, package target context, diagnostics, relevant tests, active project state
- `DocScope`
  - ranked Apple docs, Swift docs, local docs, recent lookups, anticipated next-needed docs
- `AgentScope`
  - active thread or session, approvals, pending actions, status, output summaries

Everything else should be composed from those instead of introducing parallel truth sources.

The current implementation already includes those top-level scope families in `SwiftMonocleCore`, even though several of them are still fed by placeholder or future adapter paths rather than live runtime integrations.

## Xcode integration stance

The Xcode Source Editor Extension is still worth doing, but it should be treated as a command-oriented editor integration first, not as the guaranteed home of a rich always-on overlay.

### Expected near-term jobs for the extension

- slash-style editor commands
- selection-aware or cursor-aware actions
- editor-buffer context handoff
- explicit user-initiated transforms

### Caution

The projected and editable UI vision atop the open buffer is promising but risky. It should be validated through a focused spike before being treated as a core guaranteed capability.

## Codex integration stance

SwiftMonocle expects a real rich-client role, including:

- streamed agent events
- approvals
- session and conversation state
- hosted-agent interaction
- future voice-interface status and transcript presentation

Because of that, Codex `app-server` is currently the preferred primary Codex integration surface.

The Codex SDK is still relevant for automation-oriented jobs, but it should not become a parallel primary control path unless a concrete use case requires both.

### Current recommendation

- treat Codex `app-server` as the main interactive boundary
- keep any SDK-based automation as a secondary capability, only after an actual need appears

## Control plane stance

The control plane should not be "just `@Observable` everywhere."

The recommended model is:

- actors and plain services own backend coordination and source-of-truth state
- immutable snapshots and async streams move state between boundaries
- `@Observable` types adapt that state for SwiftUI and app presentation

That keeps UI concerns from becoming the architecture of the backend.

## Docs engine stance

The docs engine should begin narrowly.

### Recommended first scope

- current file
- current diagnostics
- nearby symbols
- relevant Apple and Swift documentation
- recent and active task context

### Avoid at first

- broad speculative crawling of everything
- independent daemonization
- too many ranking dimensions before the base scope model is stable

## Major risks

- the Xcode extension may not support the full projected-editable-buffer UI vision cleanly
- too many MCP boundaries could create stale or conflicting state
- `SwiftSyntax` alone may not provide enough semantic fidelity for the best scope model
- the docs engine could sprawl before its actual retrieval and ranking model is proven

## Recommended next milestone

The original first milestone has been partially completed already:

1. Define the shared core scope model.
2. Define the first scope-input normalization layer.
3. Add syntax-first symbol extraction and ranking.

The next concrete milestone should be:

1. Build the first local host around the existing package surfaces.
2. Ingest live editor context plus Xcode MCP context into the existing internal state model.
3. Expose one curated outward-facing scope surface to a hosted agent or UI consumer.
4. Add docs ranking as an internal subsystem.
5. Leave the richer app UI and extension-heavy workflows for the next layer once the scope model and host feel real.
