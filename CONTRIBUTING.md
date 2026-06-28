# Contributing

SwiftMonocle is an early macOS-first Swift Package Manager project. This guide is for contributors and agents making focused local changes in this repository.

## Table of Contents

- [Overview](#overview)
- [Contribution Workflow](#contribution-workflow)
- [Local Setup](#local-setup)
- [Development Expectations](#development-expectations)
- [Pull Request Expectations](#pull-request-expectations)
- [Communication](#communication)
- [License and Contribution Terms](#license-and-contribution-terms)

## Overview

### Who This Guide Is For

Use this guide when making source, test, documentation, package, or repo-maintenance changes in SwiftMonocle.

### Before You Start

Read `README.md`, `ROADMAP.md`, and `AGENTS.md` first. The package is still unstable, so align changes with the current milestone instead of treating the public API as frozen.

## Contribution Workflow

### Choosing Work

Prefer small, coherent changes tied to the current roadmap. Keep package libraries focused on reusable model, parsing, bridge, and control-plane behavior; keep app-target changes inside the explicit Xcode app boundary.

### Making Changes

Use Swift Package Manager as the source of truth. Prefer `swift package` commands for structural package changes when a command exists, and keep `Package.swift`, `Package.resolved`, target files, and tests aligned in the same change.

### Asking For Review

Summarize the changed surface, the reason for the change, and the validation performed. Call out skipped checks plainly.

## Local Setup

### Runtime Config

Local work currently uses the Swift package, the XcodeGen-backed macOS app target, repo-maintenance scripts, and checked-in formatting/linting configuration.

### Runtime Behavior

The current package builds library products and tests. The macOS app target is a bootstrap visualization shell; new runtime, graph extraction, or editor-integration behavior should be introduced through explicit roadmap items and maintainer docs before implementation.

## Development Expectations

### Naming Conventions

Use stable names when a model keeps the same meaning across package layers. Preserve wire, persistence, and package names unless a concrete boundary requires a different name.

### Accessibility Expectations

Package-only changes should avoid creating accessibility claims that cannot be verified. UI work belongs behind the macOS app or extension boundary and should follow `ACCESSIBILITY.md`.

### Verification

Run the narrowest useful checks while working and the repo-maintenance wrapper before handing off a broader change:

```bash
swift build
swift test
scripts/repo-maintenance/validate-all.sh
```

## Pull Request Expectations

Keep pull requests focused. Include source, tests, docs, and package graph updates together when they are part of the same behavior change.

## Communication

Flag architecture pivots early, especially if a change needs a new target, app boundary, host process, service, package dependency, or long-lived compatibility path.

## License and Contribution Terms

No license file has been added to this repository yet. Do not redistribute the project or accept externally sourced code until licensing and contribution terms are made explicit.
