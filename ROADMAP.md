# Project Roadmap

## Vision

- Build SwiftMonocle into a focused macOS-first Swift package with a clear API, grounded documentation, and deterministic local tooling.

## Product principles

- Keep delivery deterministic and reviewable.
- Keep the package surface small and explicit until the first real use cases are settled.
- Keep docs, roadmap, and implementation aligned in the same pass.

## Milestone Progress

- [x] Milestone 0: Foundation
- [ ] Milestone 1: Product definition
- [ ] Milestone 2: First integrated scope pipeline

## Milestone 0: Foundation

Scope:

- [x] Bootstrap the Swift package repository.
- [x] Install the repo-local `apple-dev-skills` plugin surface.
- [x] Add baseline project documentation and planning files.
- [x] Define the first `CodeScopeSnapshot` model and related scope types.
- [x] Split the package into `SwiftMonocle`, `SwiftMonocleCore`, and `SwiftMonocleCodeScope`.
- [x] Add first-pass `SwiftSyntax` symbol extraction and scope assembly tests.

Tickets:

- [x] Confirm that the initial package center is the shared `CodeScopeSnapshot` model.
- [x] Replace the placeholder library surface with the first real domain model and scope-building slice.

Exit criteria:

- [x] The repo has a stable starting point for implementation.
- [x] The first implementation slice is concrete enough to build against.

## Milestone 1: Product definition

Scope:

- [ ] Lock the first end-to-end product slice around one bounded coding moment.
- [ ] Define the initial public API intent for package consumers versus internal package seams.
- [ ] Decide which future subsystems stay as package libraries versus companion-app deliverables.

Tickets:

- [x] Capture the current implementation slice in this roadmap and README.
- [ ] Define the minimum host responsibilities for the first local runtime.
- [ ] Define the minimum Xcode/editor context we need before the host is worth standing up.
- [ ] Define the minimum docs retrieval surface for phase 1.
- [ ] Confirm the first external consumer of `CodeScopeSnapshot`.

Exit criteria:

- [ ] The first integrated runtime slice is concrete enough to implement without another direction-setting pass.
- [ ] The public README and maintainer docs describe the same product boundary.

## Milestone 2: First integrated scope pipeline

Scope:

- [ ] Stand up one local host process around the current package surface.
- [ ] Ingest live editor context into `CodeScopeInput`.
- [ ] Expose one curated outward-facing scope surface for a hosted agent or UI consumer.

Tickets:

- [ ] Add the first host target or companion runtime package.
- [ ] Feed live editor context into the existing `CodeScopeBuilder`.
- [ ] Attach diagnostics and docs inputs through real adapters instead of placeholder-only model plumbing.
- [ ] Prove one end-to-end snapshot flow from live input to rendered or exported scope.

Exit criteria:

- [ ] A real runtime can build and publish a `CodeScopeSnapshot` from live inputs.
- [ ] The next milestone is about capability depth, not repository shape.
