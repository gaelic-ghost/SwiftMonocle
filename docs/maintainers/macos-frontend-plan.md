# macOS Frontend Integration Plan

## Purpose

This document sets the first concrete plan for integrating a macOS Xcode app frontend into SwiftMonocle.

The frontend should make package dependencies, target relationships, API surfaces, scope snapshots, diagnostics, and future agent state inspectable without turning the package libraries into app-owned implementation details.

## Recommendation

Add the macOS frontend as a companion Xcode app workspace after the first host/control-plane slice is clearer.

This is a durable building-block direction, not a stopgap. The practical effect is that reusable graph extraction, API indexing, scope modeling, and control-plane snapshots stay in Swift package targets, while the Xcode project owns app lifecycle, entitlements, windows, previews, assets, extension targets, signing, and UI-specific validation.

## Why Not Put Everything In The Package Manifest

SwiftPM should remain the source of truth for reusable libraries, tests, and command-line validation. A rich macOS app needs Xcode-managed concerns that SwiftPM alone does not model well:

- app lifecycle and scene configuration
- signing and entitlements
- asset catalogs and app icons
- Xcode Source Editor Extension packaging
- UI previews and app-specific build settings
- runtime accessibility and UI automation validation

The simpler extension path considered first was adding only more package targets such as `SwiftMonocleUI` and trying to defer an Xcode project indefinitely. That works for reusable SwiftUI components, but it does not give us a real app shell, extension target, signing surface, or app-level validation path.

## Proposed Boundary

### Keep In SwiftPM

- `SwiftMonocleCore`: shared snapshot, identity, provenance, references, and graph model primitives
- `SwiftMonocleCodeScope`: syntax-first scope extraction and code-neighborhood construction
- `SwiftMonocleGraph`: dependency graph, target graph, API graph, and graph projection models
- `SwiftMonocleControlPlane`: app-facing immutable snapshots and async streams
- `SwiftMonocleUI`: reusable SwiftUI graph, outline, inspector, and status components when they are useful outside the app target

### Put In The Xcode App Workspace

- `SwiftMonocleApp`: macOS app target, app lifecycle, windows, commands, settings, assets, and entitlements
- `SwiftMonocleXcodeExtension`: future Source Editor Extension target when command-first editor integration is ready
- app-specific UI tests, accessibility checks, preview assets, and signing configuration

## First App Slice

The first app should visualize static package structure before trying to be an always-on Xcode companion.

Scope:

- load the current package root
- parse package products, targets, dependencies, and test targets
- show a target/product dependency graph
- show an API/symbol outline for the selected target or file using the existing syntax extraction path
- expose a detail inspector for node identity, provenance, source path, and related tests
- keep graph state exportable as plain Swift models so tests can verify it without launching the app

Non-goals:

- live Xcode editor overlay
- editable projected UI
- background daemonization
- Codex app-server integration
- broad repository-wide semantic indexing

## Architecture Goal

Goal: create a macOS companion app that visualizes SwiftMonocle's own package dependency and API graph from the package's shared graph/control-plane models, while keeping reusable graph extraction and scope logic testable through SwiftPM.

Done means:

- a maintainer can open the app and see the package target/product graph for this repository
- selecting a graph node shows a concise inspector backed by source-of-truth package or syntax data
- reusable graph data structures live in package targets with Swift tests
- app-only behavior lives in the Xcode project or app target
- accessibility expectations for graph navigation are documented before the UI is treated as shippable

## Milestone Placement

This should follow the current Milestone 2 runtime/scope pipeline unless the visualization work becomes the fastest way to validate `SwiftMonocleGraph` and `SwiftMonocleControlPlane` primitives.

Recommended sequencing:

1. Add a package-level graph model and tests for package target/product relationships.
2. Add API-outline projection on top of the existing syntax extraction path.
3. Add the companion Xcode app workspace with one graph browser window.
4. Add accessibility and UI validation for graph navigation, search, selection, and inspector state.
5. Revisit the Xcode Source Editor Extension only after the app has a useful standalone graph surface.

## Open Decisions

- Whether `SwiftMonocleGraph` should be a distinct package target or part of `SwiftMonocleCore` until graph behavior grows.
- Whether the app should be checked in as a sibling Xcode project at the repo root or generated from a project specification.
- Which graph rendering approach gives the best accessible fallback: custom SwiftUI layout, outline-plus-canvas hybrid, or a native outline/table-first UI with graph preview.
- Whether live package reload belongs in the first app slice or waits for the host/control-plane milestone.
