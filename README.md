# SwiftMonocle

SwiftMonocle is an early macOS-first Swift package for building scoped, syntax-aware coding context for local coding workflows.

## Overview

### Motivation

The project is centered on a single canonical `CodeScopeSnapshot` model that can merge editor context, syntax-derived symbols, diagnostics, documentation, and agent state into one bounded working view.

The intended product boundary is not "give an agent the whole repository and hope for the best." It is to give both the user and the agent one shared, inspectable, provenance-aware snapshot of the current coding moment.

### Current status

SwiftMonocle is still very under construction, but the repository has moved past pure bootstrap scaffolding.

The package now has:

- a concrete `CodeScopeSnapshot` model in `SwiftMonocleCore`
- a `SwiftMonocleCodeScope` target that assembles snapshots from editor, docs, diagnostics, and agent inputs
- a first `SwiftSyntax`-backed symbol extractor that ranks focal, enclosing, and neighboring declarations from a live buffer
- package tests around the early input and scope-building surface

What does not exist yet is just as important:

- there is no host process yet
- there is no docs engine yet
- there is no Xcode bridge yet
- there is no Codex-facing bridge yet
- the public API is not stable

Expect rapid changes, missing features, rough edges, and frequent restructuring while the first real product slice gets nailed down.

## Requirements

- macOS 15 or newer
- Swift 6.3 or newer

## Getting Started

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

Passing builds and tests mean the current prototype is internally consistent. They do not mean the package is feature-complete or ready for external adoption.

## Package Surface

The package currently exposes three library products:

- `SwiftMonocle`
  - umbrella surface that currently re-exports `SwiftMonocleCodeScope`
- `SwiftMonocleCore`
  - shared snapshot identity, provenance, reference, and scope model types
- `SwiftMonocleCodeScope`
  - `CodeScopeInput`, `CodeScopeBuilder`, and the first syntax-driven symbol extraction logic

`SwiftMonocleCodeScope` currently depends on [`swift-syntax`](https://github.com/swiftlang/swift-syntax) for phase-1 declaration extraction from active editor buffers.

## Repository Layout

- `Package.swift`
  - Swift package manifest and package graph source of truth
- `Sources/SwiftMonocle`
  - umbrella library product surface
- `Sources/SwiftMonocleCore`
  - snapshot, provenance, reference, and scope model types
- `Sources/SwiftMonocleCodeScope`
  - input feeds, snapshot assembly, and syntax-driven symbol extraction
- `Tests`
  - package test suites for the current core and scope surfaces
- `docs/maintainers`
  - maintainer architecture, open questions, and snapshot design notes
- `scripts/repo-maintenance`
  - validation, sync, and release helpers installed during bootstrap
- `.codex/plugins`
  - repo-local Codex plugin install surface

## Local Codex Plugin Setup

This repository stages the local `apple-dev-skills` plugin in repo scope under `.codex/plugins/apple-dev-skills` and enables it through `.codex/config.toml`.

Because the local Codex app-server install RPC did not return a `plugin/install` response during setup, restart Codex in this repository so the plugin browser picks up the staged repo-local marketplace entry.

## Planning

Project planning lives in [`ROADMAP.md`](./ROADMAP.md), with additional maintainer design notes in [`docs/maintainers`](./docs/maintainers).

The most useful current maintainer docs are:

- [`docs/maintainers/architecture.md`](./docs/maintainers/architecture.md)
- [`docs/maintainers/open-questions.md`](./docs/maintainers/open-questions.md)
- [`docs/maintainers/codescope-snapshot.md`](./docs/maintainers/codescope-snapshot.md)

Treat the roadmap plus those maintainer docs as the source of truth for what the repository has already decided versus what is still exploratory.
