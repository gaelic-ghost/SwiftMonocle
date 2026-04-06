# SwiftMonocle

SwiftMonocle is a macOS Swift package scaffold for a focused library project.

## Overview

### Motivation

This repository starts from a clean Swift Package Manager baseline so the core package shape, local repo maintenance scripts, and repo-local Codex plugin wiring are already in place before product work begins.

### Current status

The package is intentionally minimal right now. The immediate goal is to keep the repository organized, reproducible, and ready for the first real implementation pass.

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

## Repository Layout

- `Sources/SwiftMonocle`: package source
- `Tests/SwiftMonocleTests`: package tests
- `scripts/repo-maintenance`: validation and release helpers installed during bootstrap
- `.codex/plugins`: repo-local Codex plugin install surface

## Local Codex Plugin Setup

This repository stages the local `apple-dev-skills` plugin in repo scope under `.codex/plugins/apple-dev-skills` and enables it through `.codex/config.toml`.

Because the local Codex app-server install RPC did not return a `plugin/install` response during setup, restart Codex in this repository so the plugin browser picks up the staged repo-local marketplace entry.

## Planning

Project planning lives in [`ROADMAP.md`](./ROADMAP.md). Once the product direction is decided, update the roadmap and README together so the repo stays grounded in the same scope.
