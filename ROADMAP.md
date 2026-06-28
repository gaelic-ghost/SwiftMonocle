# Project Roadmap

## Table of Contents

- [Vision](#vision)
- [Product Principles](#product-principles)
- [Milestone Progress](#milestone-progress)
- [Milestone 0: Foundation](#milestone-0-foundation)
- [Milestone 1: Product Definition](#milestone-1-product-definition)
- [Milestone 2: First Integrated Scope Pipeline](#milestone-2-first-integrated-scope-pipeline)
- [Milestone 3: macOS Frontend Planning](#milestone-3-macos-frontend-planning)
- [Small Tickets](#small-tickets)
- [Backlog Candidates](#backlog-candidates)
- [History](#history)

## Vision

- Build SwiftMonocle into a focused macOS-first Swift package with a clear API, grounded documentation, and deterministic local tooling.

## Product Principles

- Keep delivery deterministic and reviewable.
- Keep the package surface small and explicit until the first real use cases are settled.
- Keep docs, roadmap, and implementation aligned in the same pass.
- Keep reusable graph, scope, and control-plane logic in Swift package targets even after a macOS app target exists.

## Milestone Progress

- Milestone 0: Foundation - Completed
- Milestone 1: Product Definition - In Progress
- Milestone 2: First Integrated Scope Pipeline - Planned
- Milestone 3: macOS Frontend Planning - Planned

## Milestone 0: Foundation

### Status

Completed

### Scope

- [x] Bootstrap the Swift package repository.
- [x] Install the repo-local `apple-dev-skills` plugin surface.
- [x] Add baseline project documentation and planning files.
- [x] Define the first `CodeScopeSnapshot` model and related scope types.
- [x] Split the package into `SwiftMonocle`, `SwiftMonocleCore`, and `SwiftMonocleCodeScope`.
- [x] Add first-pass `SwiftSyntax` symbol extraction and scope assembly tests.

### Tickets

- [x] Confirm that the initial package center is the shared `CodeScopeSnapshot` model.
- [x] Replace the placeholder library surface with the first real domain model and scope-building slice.

### Exit Criteria

- [x] The repo has a stable starting point for implementation.
- [x] The first implementation slice is concrete enough to build against.

## Milestone 1: Product Definition

### Status

In Progress

### Scope

- [ ] Lock the first end-to-end product slice around one bounded coding moment.
- [ ] Define the initial public API intent for package consumers versus internal package seams.
- [ ] Decide which future subsystems stay as package libraries versus companion-app deliverables.

### Tickets

- [x] Capture the current implementation slice in this roadmap and README.
- [ ] Define the minimum host responsibilities for the first local runtime.
- [ ] Define the minimum Xcode/editor context we need before the host is worth standing up.
- [ ] Define the minimum docs retrieval surface for phase 1.
- [ ] Confirm the first external consumer of `CodeScopeSnapshot`.
- [x] Capture the first macOS frontend integration plan in `docs/maintainers/macos-frontend-plan.md`.

### Exit Criteria

- [ ] The first integrated runtime slice is concrete enough to implement without another direction-setting pass.
- [ ] The public README and maintainer docs describe the same product boundary.

## Milestone 2: First Integrated Scope Pipeline

### Status

Planned

### Scope

- [ ] Stand up one local host process around the current package surface.
- [ ] Ingest live editor context into `CodeScopeInput`.
- [ ] Expose one curated outward-facing scope surface for a hosted agent or UI consumer.

### Tickets

- [ ] Add the first host target or companion runtime package.
- [ ] Feed live editor context into the existing `CodeScopeBuilder`.
- [ ] Attach diagnostics and docs inputs through real adapters instead of placeholder-only model plumbing.
- [ ] Prove one end-to-end snapshot flow from live input to rendered or exported scope.

### Exit Criteria

- [ ] A real runtime can build and publish a `CodeScopeSnapshot` from live inputs.
- [ ] The next milestone is about capability depth, not repository shape.

## Milestone 3: macOS Frontend Planning

### Status

Planned

### Scope

- [ ] Add package-level graph primitives for products, targets, source files, symbols, and API relationships.
- [ ] Add an API-outline projection using the existing syntax extraction path.
- [ ] Add a companion macOS Xcode app workspace after the package graph/control-plane boundary is clear.
- [ ] Visualize the package target/product graph and selected API/symbol outline.
- [ ] Define accessibility acceptance criteria for graph navigation, selection, search, and inspector state.

### Tickets

- [ ] Decide whether `SwiftMonocleGraph` starts as a new package target or stays in `SwiftMonocleCore` until graph behavior grows.
- [ ] Decide whether the app project is checked in directly or generated from a project specification.
- [ ] Build a static package graph prototype for this repository.
- [ ] Build the first app window around graph browser, outline, and inspector panels.
- [ ] Validate keyboard and VoiceOver navigation before treating the graph UI as shippable.

### Exit Criteria

- [ ] A maintainer can open the app and inspect SwiftMonocle's package dependency graph.
- [ ] Selecting a graph node shows source-backed details and related tests where available.
- [ ] Reusable graph extraction stays covered by Swift package tests.
- [ ] App-only lifecycle, signing, assets, and UI validation stay in the Xcode app boundary.

## Small Tickets

- [ ] Add a `SwiftMonocleGraph` design note or extend the frontend plan once the graph target decision is made.
- [ ] Add release/license decisions before any public package publication.
- [ ] Revisit `.codex/` tracking if repo-local Codex environment files should become committed project setup.

## Backlog Candidates

- Add `SwiftMonocleDocs` for documentation retrieval, ranking, and cache policy.
- Add `SwiftMonocleXcodeBridge` for Xcode/editor context ingestion.
- Add `SwiftMonocleAgentBridge` for Codex app-server integration.
- Add `SwiftMonocleControlPlane` for app-facing immutable snapshots and async streams.
- Add `SwiftMonocleUI` only when reusable SwiftUI components have a concrete app or preview consumer.

## History

- 2026-06-28: Refreshed repo-maintenance guidance and added the macOS frontend integration plan.
