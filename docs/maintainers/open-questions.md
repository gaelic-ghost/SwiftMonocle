# SwiftMonocle Open Questions

## Why this exists

This document tracks the unresolved architectural questions and staged decisions around SwiftMonocle so maintainers can tell the difference between settled direction and active design work.

## Confirmed direction

- SwiftMonocle is a shared code-awareness product for the user and the hosted agent.
- The package should be split into focused libraries by responsibility.
- The early runtime should favor one local host process over many local services.
- `CodeScope` should be the center of the internal model.
- Codex `app-server` is the preferred first-class interactive bridge.
- The future UI should support both human-friendly code understanding and voice-interface status and transcript presentation.

## Active open questions

## 1. Xcode extension capability limits

We still need to validate how far the Xcode Source Editor Extension can take us for:

- user slash commands
- selection-aware and cursor-aware commands
- projected UI behavior
- editable overlays or adjacent editing surfaces

### Current plan

Treat the extension as command-first until a spike proves more ambitious UI interaction is practical.

## 2. Codex app-server versus secondary SDK automation

We expect to need `app-server` for the interactive product shape, but we have not yet defined whether there will also be a real second path for:

- asynchronous background jobs
- non-interactive automation
- automation that wants SDK semantics instead of client-session semantics

### Current plan

Do not build a second primary automation path until a concrete use case requires it.

## 3. CodeScope semantic depth

We expect to use `SwiftSyntax`, but it is still open how much semantic understanding should come from:

- `SwiftSyntax`
- Xcode or SourceKit-derived data
- curated diagnostics and project-state context

### Current plan

Start with syntax plus diagnostics and editor context, then deepen semantic sources only where real scope quality demands it.

## 4. Control plane shape

We know we want an app-facing `@Observable` layer, but the exact adapter model is still open:

- one broad control plane
- feature-sliced control-plane modules
- mixed actor and projection models

### Current plan

Favor feature-sliced state and snapshots over a monolithic app model.

## 5. Package and target boundaries

We still need to confirm which deliverables should remain pure Swift packages versus which should move into a companion app or workspace.

### Current expectation

- package: shared libraries, server, bridges, docs engine, control plane, UI components
- companion app/workspace: macOS app target and Xcode Source Editor Extension target

## Near-term implementation plan

## Stage 1: Core model and host

- define `SwiftMonocleCore`
- define the first `CodeScope` model
- stand up one Hummingbird host
- expose one curated MCP surface

## Stage 2: Editor and Xcode context

- ingest active editor context
- ingest relevant Xcode MCP context
- normalize both into the same scope model

## Stage 3: Agent and docs integration

- wire in Codex `app-server`
- add ranked documentation retrieval and caching
- present agent state and approvals through the same control plane

## Stage 4: App and extension surfaces

- build the macOS app target
- build the Xcode Source Editor Extension target
- validate projected UI and editable-buffer-adjacent workflows

## Package graph to start from

- `SwiftMonocleCore`
- `SwiftMonocleCodeScope`
- `SwiftMonocleDocs`
- `SwiftMonocleXcodeBridge`
- `SwiftMonocleAgentBridge`
- `SwiftMonocleControlPlane`
- `SwiftMonocleUI`
- `SwiftMonocleServer`

## Suggested next design doc

The next maintainer document should define the first concrete `CodeScope` snapshot model:

- identifiers
- file and selection model
- symbol neighborhood model
- diagnostics model
- ranked docs attachments
- agent-session attachments
