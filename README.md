# SwiftMonocle

SwiftMonocle is an early macOS-first Swift package for building scoped, syntax-aware coding context.

## Overview

### Motivation

The project is exploring a single canonical `CodeScope` model that can merge editor context, syntax-derived symbols, diagnostics, docs, and agent state into one bounded snapshot for local coding workflows.

### Current status

SwiftMonocle is very under construction.

The package is still in its foundation stage, the public API is not stable, and the repository is currently closer to a live design-and-implementation sandbox than a consumable library release.

Recent work has focused on:

- defining the first shared scope snapshot model
- splitting the package into `Core` and `CodeScope` targets
- wiring in the first `SwiftSyntax`-backed symbol extraction from live editor buffers

Expect rapid changes, missing features, rough edges, and frequent restructuring while the real product boundary settles.

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

This build is still exploratory. Passing builds and tests only mean the current prototype is internally consistent, not that the package is feature-complete or ready for external adoption.

Run the repo-maintenance validation wrapper:

```bash
scripts/repo-maintenance/validate-all.sh
```

## Repository Layout

- `Sources/SwiftMonocle`: package source
- `Sources/SwiftMonocleCore`: shared snapshot, reference, and scope model types
- `Sources/SwiftMonocleCodeScope`: scope assembly and syntax-driven symbol extraction
- `Tests`: package test suites
- `scripts/repo-maintenance`: validation and release helpers installed during bootstrap
- `.codex/plugins`: repo-local Codex plugin install surface

## Local Codex Plugin Setup

This repository stages the local `apple-dev-skills` plugin in repo scope under `.codex/plugins/apple-dev-skills` and enables it through `.codex/config.toml`.

Because the local Codex app-server install RPC did not return a `plugin/install` response during setup, restart Codex in this repository so the plugin browser picks up the staged repo-local marketplace entry.

## Planning

Project planning lives in [`ROADMAP.md`](./ROADMAP.md), with additional maintainer design notes in [`docs/maintainers`](./docs/maintainers). Until the first product milestone is fully defined, treat the roadmap and the maintainer docs as the source of truth for what this repository is actually trying to become.
