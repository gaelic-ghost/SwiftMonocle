# macOS Frontend Integration Plan

## Purpose

This document sets the first concrete plan for integrating a macOS Xcode app frontend into SwiftMonocle.

The frontend should make package dependencies, target relationships, API surfaces, scope snapshots, diagnostics, and future agent state inspectable without turning the package libraries into app-owned implementation details.

## Recommendation

Add the macOS frontend as a companion Xcode app workspace after the first host/control-plane slice is clearer.

This is a durable building-block direction, not a stopgap. The practical effect is that reusable graph extraction, API indexing, scope modeling, and control-plane snapshots stay in Swift package targets, while the Xcode project owns app lifecycle, entitlements, windows, previews, assets, extension targets, signing, and UI-specific validation.

## Current Scaffold

The first XcodeGen-backed macOS 26+ app shell now lives in `Apps/SwiftMonocleApp`.

It currently provides:

- `SwiftMonocle.xcworkspace` at the repository root
- `Apps/SwiftMonocleApp/project.yml` as the XcodeGen source of truth
- checked-in `.xcconfig` files for app and test build settings
- a SwiftUI `SwiftMonocleApp` entry point with a first graph dashboard window
- a SwiftPM-manifest-backed bootstrap graph model linked against `SwiftMonocle`, `SwiftMonocleCore`, and `SwiftMonocleGraph`
- source path and related-test details in the app inspector
- Swift Testing coverage for the package graph model and the app graph adapter
- `.codex/environments/xcode-project.toml` actions for project generation, build, and test

The scaffold is intentionally bootstrap-backed. `SwiftMonocleGraph` now owns reusable package/product/target graph primitives, SwiftPM manifest JSON decoding, and graph construction from that decoded manifest shape. Live package graph reload should build on that target before the app depends on long-running package parsing or indexing behavior.

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
- `SwiftMonocleGraph`: package/product/target graph primitives now; dependency graph, API graph, and graph projection models as the target grows
- `SwiftMonocleControlPlane`: app-facing immutable snapshots and async streams
- `SwiftMonocleUI`: reusable SwiftUI graph, outline, inspector, and status components when they are useful outside the app target

### Put In The Xcode App Workspace

- `SwiftMonocleApp`: macOS app target, app lifecycle, windows, commands, settings, assets, and entitlements
- `SwiftMonocleXcodeExtension`: future Source Editor Extension target when command-first editor integration is ready
- app-specific UI tests, accessibility checks, preview assets, and signing configuration

## Proposed Directory Layout

The planned app target should make the Xcode-owned surface obvious while leaving package libraries at the repository root:

```text
.
├── Package.swift
├── SwiftMonocle.xcworkspace
├── Apps/
│   └── SwiftMonocleApp/
│       ├── SwiftMonocleApp.xcodeproj
│       ├── SwiftMonocleApp/
│       │   ├── SwiftMonocleApp.swift
│       │   ├── Scenes/
│       │   ├── Views/
│       │   ├── Commands/
│       │   ├── Assets.xcassets/
│       │   └── Info.plist
│       ├── SwiftMonocleAppTests/
│       └── SwiftMonocleAppUITests/
├── Extensions/
│   └── SwiftMonocleXcodeExtension/
│       ├── SwiftMonocleXcodeExtension/
│       └── SwiftMonocleXcodeExtensionTests/
├── Sources/
│   ├── SwiftMonocle/
│   ├── SwiftMonocleCore/
│   ├── SwiftMonocleCodeScope/
│   ├── SwiftMonocleGraph/
│   ├── SwiftMonocleControlPlane/
│   └── SwiftMonocleUI/
├── Tests/
├── docs/
├── scripts/
└── .codex/
```

`Apps/` is the app lifecycle and signing boundary. `Extensions/` is reserved for the Xcode Source Editor Extension so it does not get mixed into the package library tree. The root workspace ties those Xcode surfaces to the SwiftPM package, while `Package.swift` remains the source of truth for reusable code and tests.

## First App Slice

The first app should visualize static package structure before trying to be an always-on Xcode companion.

Scope:

- load the current package root
- parse package products, targets, dependencies, and test targets
- show a target/product dependency graph
- show git branches and worktrees once repository-state modeling exists
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

1. Add a package-level graph model and tests for package target/product relationships. Done for the manifest-backed `SwiftMonocleGraph` slice.
2. Add live package reload on top of SwiftPM manifest JSON loading.
3. Add API-outline projection on top of the existing syntax extraction path.
4. Add a git branches/worktrees viewer backed by explicit repository-state models.
5. Continue evolving the companion Xcode app workspace from the current graph browser window.
6. Add accessibility and UI validation for graph navigation, search, selection, and inspector state.
7. Revisit the Xcode Source Editor Extension only after the app has a useful standalone graph surface.

## Open Decisions

- Which graph rendering approach gives the best accessible fallback: custom SwiftUI layout, outline-plus-canvas hybrid, or a native outline/table-first UI with graph preview.
- Whether live package reload belongs in the first app slice or waits for the host/control-plane milestone.
- Whether git branch and worktree state belongs in `SwiftMonocleGraph`, a future repository-state target, or the app boundary until it needs reuse.

## Decisions Made

- `SwiftMonocleGraph` is a distinct package target so graph primitives can evolve without overloading `SwiftMonocleCore`.
- The app project is generated from `Apps/SwiftMonocleApp/project.yml`, with the generated Xcode project checked in for normal Xcode use.
