# SwiftMonocle

SwiftMonocle is an early macOS-first Swift package for building scoped, syntax-aware coding context for local coding workflows.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Development](#development)
- [Repo Structure](#repo-structure)
- [Release Notes](#release-notes)
- [License](#license)
- [Requirements](#requirements)
- [Package Surface](#package-surface)
- [Local Codex Setup](#local-codex-setup)
- [Planning](#planning)

## Overview

### Status

Unstable prototype.

### What This Project Is

SwiftMonocle is a Swift Package Manager project centered on a canonical `CodeScopeSnapshot` model. The package is intended to become the shared code-awareness layer beneath local editor integrations, documentation retrieval, agent coordination, and future visualization surfaces.

The package now has:

- a concrete `CodeScopeSnapshot` model in `SwiftMonocleCore`
- a `SwiftMonocleCodeScope` target that assembles snapshots from editor, docs, diagnostics, and agent inputs
- a first `SwiftSyntax`-backed symbol extractor that ranks focal, enclosing, and neighboring declarations from a live buffer
- a `SwiftMonocleGraph` target with source-backed package/product/target graph primitives
- package tests around the early input and scope-building surface
- refreshed repo-maintenance scripts, SwiftFormat, and SwiftLint baseline configuration

What does not exist yet is just as important:

- there is no host process yet
- there is no docs engine yet
- there is no Xcode bridge yet
- there is no Codex-facing bridge yet
- the macOS app frontend is only a bootstrap shell with package-backed graph fixture data
- the public API is not stable

Expect rapid changes, missing features, rough edges, and frequent restructuring while the first real product slice gets nailed down.

### Motivation

The project is centered on a single canonical `CodeScopeSnapshot` model that can merge editor context, syntax-derived symbols, diagnostics, documentation, and agent state into one bounded working view.

The intended product boundary is not "give an agent the whole repository and hope for the best." It is to give both the user and the agent one shared, inspectable, provenance-aware snapshot of the current coding moment.

## Quick Start

Build the package:

```bash
swift build
```

Run the tests:

```bash
swift test
```

Run the repo-maintenance validation wrapper:

```bash
scripts/repo-maintenance/validate-all.sh
```

Regenerate the macOS app project after editing `Apps/SwiftMonocleApp/project.yml`:

```bash
xcodegen generate --spec Apps/SwiftMonocleApp/project.yml
```

Passing builds and tests mean the current prototype is internally consistent. They do not mean the package is feature-complete or ready for external adoption.

## Usage

The package is not ready for external production use yet. The current useful integration surface is the package test suite and the early library products described below.

For now, treat `SwiftMonocleCore` as the source of the shared snapshot model, `SwiftMonocleCodeScope` as the first implemented scope-building surface, and `SwiftMonocleGraph` as the source of reusable package graph models. The umbrella `SwiftMonocle` product re-exports the current code-scope and graph surfaces for experiments.

## Development

Use Swift Package Manager as the source of truth for package structure and validation.

Default local checks:

```bash
swift build
swift test
scripts/repo-maintenance/validate-all.sh
```

Formatting and linting configuration now lives in `.swiftformat` and `.swiftlint.yml`. The repo-maintenance wrapper owns the local validation entrypoint, while `Package.swift` remains the source of truth for products, targets, language mode, and dependencies.

## Repo Structure

```text
.
├── Package.swift
├── SwiftMonocle.xcworkspace
├── Apps/
│   └── SwiftMonocleApp/
├── Extensions/
├── Sources/
│   ├── SwiftMonocle/
│   ├── SwiftMonocleCore/
│   ├── SwiftMonocleCodeScope/
│   └── SwiftMonocleGraph/
├── Tests/
├── docs/
│   └── maintainers/
├── scripts/
│   └── repo-maintenance/
├── AGENTS.md
├── CONTRIBUTING.md
├── ACCESSIBILITY.md
├── README.md
└── ROADMAP.md
```

`Package.swift` is the package graph source of truth. `Apps/SwiftMonocleApp` contains the XcodeGen-backed macOS app shell. `Extensions` is reserved for future Xcode extension targets. `docs/maintainers` contains architecture and planning notes, including the macOS frontend plan. `scripts/repo-maintenance` contains the managed local validation, sync, and release helpers.

## Release Notes

No public release has been tagged from this repository yet.

Use `scripts/repo-maintenance/release.sh --mode standard --version vX.Y.Z` only when a protected-main release or publish workflow is explicitly requested.

## License

No license file has been added to this repository yet. Until a license is chosen and checked in, treat the project as private and not redistributable.

## Requirements

- macOS 15 or newer
- Swift 6.3 or newer
- Xcode 26 or newer for the app target
- XcodeGen 2.39.0 or newer for regenerating `Apps/SwiftMonocleApp/SwiftMonocleApp.xcodeproj`

## Package Surface

The package currently exposes four library products:

- `SwiftMonocle`
  - umbrella surface that currently re-exports `SwiftMonocleCodeScope` and `SwiftMonocleGraph`
- `SwiftMonocleCore`
  - shared snapshot identity, provenance, reference, and scope model types
- `SwiftMonocleCodeScope`
  - `CodeScopeInput`, `CodeScopeBuilder`, and the first syntax-driven symbol extraction logic
- `SwiftMonocleGraph`
  - `PackageGraph`, `PackageGraphNode`, `PackageGraphEdge`, and the first source-backed package graph fixture

`SwiftMonocleCodeScope` currently depends on [`swift-syntax`](https://github.com/swiftlang/swift-syntax) for phase-1 declaration extraction from active editor buffers.

## Local Codex Setup

The `.codex/` directory is tracked for repo-local Codex configuration and action environments.

Use the installed Apple and productivity skills from the active Codex environment for Swift package guidance and repo-maintenance refreshes.

## Planning

Project planning lives in [`ROADMAP.md`](./ROADMAP.md), with additional maintainer design notes in [`docs/maintainers`](./docs/maintainers).

The most useful current maintainer docs are:

- [`docs/maintainers/architecture.md`](./docs/maintainers/architecture.md)
- [`docs/maintainers/open-questions.md`](./docs/maintainers/open-questions.md)
- [`docs/maintainers/codescope-snapshot.md`](./docs/maintainers/codescope-snapshot.md)
- [`docs/maintainers/macos-frontend-plan.md`](./docs/maintainers/macos-frontend-plan.md)

Treat the roadmap plus those maintainer docs as the source of truth for what the repository has already decided versus what is still exploratory.
