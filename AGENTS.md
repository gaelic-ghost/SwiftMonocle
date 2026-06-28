# AGENTS.md

This file governs agent work in the SwiftMonocle Swift Package Manager repository. Keep repo-local instructions focused on package structure, validation, documentation, and future macOS app boundary decisions.

## Baseline Provenance

- This template is the full bootstrap `AGENTS.md` used for new Swift package repositories.
- It intentionally incorporates the shared Swift-package baseline from `shared/agents-snippets/apple-swift-package-core.md`.
- Keep baseline guidance aligned with the shared snippet and use this template for deterministic scaffold output.

## Repository Scope

### What This File Covers

This file covers source, tests, docs, package graph changes, repo-maintenance scripts, and planning work in this SwiftPM package. It does not by itself authorize release, publish, protected-main merge, or future Xcode app scaffolding unless the user asks for that lifecycle step.

### Where To Look First

- `Package.swift` is the source of truth for products, targets, dependencies, platforms, and Swift language mode.
- `README.md` is the product overview and quick-start surface.
- `ROADMAP.md` is the milestone and backlog source of truth.
- `docs/maintainers/` contains architecture and planning notes.
- `scripts/repo-maintenance/validate-all.sh` is the local maintainer validation entrypoint.

## Repository Expectations

- Use Swift Package Manager (SPM) as the source of truth for package structure and dependencies.
- Use `sync-swift-package-guidance` if this repo's package-specific `AGENTS.md` guidance later drifts and needs to be refreshed or merged forward.
- Use `scripts/repo-maintenance/validate-all.sh` for local maintainer validation, `scripts/repo-maintenance/sync-shared.sh` for repo-local sync steps, and `scripts/repo-maintenance/release.sh` for releases.
- When Gale says the Xcode session for this repo is open, prefer the Xcode MCP path for inspection, diagnostics, and validation instead of falling back directly to filesystem-only or generic CLI flows.
- When the live `SpeakSwiftly` MCP surface is available in the session, queue the full final reply through that surface in addition to sending the normal text reply.
- Prefer `swift package` CLI commands for structural changes whenever the command exists.
- Use `swift package add-dependency` to add dependencies instead of hand-editing package graphs.
- Use `swift package add-target` to add library, executable, or test targets.
- For package configuration not covered by CLI commands, update `Package.swift` intentionally and keep edits minimal.
- Keep package graph updates together in the same change (`Package.swift`, `Package.resolved`, and target/test layout when applicable).
- Validate package changes with:
  - `swift build`
  - `swift test`

## Working Rules

### Change Scope

Keep changes coherent and grounded in the current package shape. If a change needs a new package target, app target, host process, service boundary, or long-lived compatibility path, make that architecture decision explicit before implementing it.

### Source of Truth

Keep reusable model, graph, parsing, bridge, and control-plane logic in Swift package targets. Future macOS app lifecycle, signing, assets, extension targets, and UI validation belong behind an explicit Xcode app boundary.

### Communication and Escalation

Call out blockers, skipped validation, and scope expansions plainly. Do not turn ordinary package or docs edits into release choreography unless the user explicitly asks for a release or publish step.

## Commands

### Setup

This repository currently has no runtime setup beyond SwiftPM and the checked-in repo-maintenance tooling.

```bash
swift package resolve
```

### Validation

```bash
swift build
swift test
scripts/repo-maintenance/validate-all.sh
```

### Optional Project Commands

```bash
scripts/repo-maintenance/sync-shared.sh
scripts/repo-maintenance/release.sh --mode standard --version vX.Y.Z
```

Use the release command only for explicit release, publish, protected-main merge, tag, or release-PR work.

## Review and Delivery

### Review Expectations

Review diffs for package graph drift, generated-file churn, docs claims that outpace implementation, and app-boundary changes that should be planned before implementation.

### Definition of Done

A change is done when the relevant source, tests, docs, package graph, and maintenance surfaces agree, and the narrowest useful validation has run or been reported as skipped.

## Safety Boundaries

### Never Do

- Do not commit secrets, tokens, `.env` files, or machine-local dependency paths.
- Do not add a future Xcode app project, Source Editor Extension, host process, or daemon as a side effect of an unrelated package update.
- Do not claim UI accessibility, runtime, release, or public API stability that has not been implemented and verified.

### Ask Before

- Ask before adding a new package dependency without an immediate package use.
- Ask before introducing an app target, workspace, service process, generated project system, or public release surface.
- Ask before widening a package cleanup into release, GitHub settings, branch cleanup, or protected-main choreography.

## Local Overrides

- `.codex/` is ignored in this repository, so local Codex environment files created by guidance sync are currently developer-local setup unless tracking policy changes.
- Treat `docs/maintainers/macos-frontend-plan.md` as the current planning artifact for the future macOS app frontend.

## Swift Coding Preferences

- Prefer the simplest correct Swift that is easiest to read, reason about, and maintain.
- Treat idiomatic Swift and Cocoa-style naming conventions as tools in service of readability, not goals by themselves.
- Prefer explicit, consistent, and unambiguous names.
- Prefer compact and concise code; use shorthand syntax and trailing-closure syntax when readability improves.
- Do not add boilerplate, helper types, or extra layers just to make code look more architectural or more "Swifty".
- Strongly prefer synthesized, implicit, and framework-provided behavior over handwritten setup code.
- Prefer applicable existing framework or platform error types before inventing custom error wrappers or error hierarchies.
- Prefer stable, source-of-truth naming across layers when the data and meaning have not changed.
- Treat naming consistency as a reliability feature: if the same data still serves the same purpose, keep the same name.
- Do not rename fields just to match local style conventions when the external schema is already clear and stable.
- Do not use automatic case-conversion strategies such as `.convertFromSnakeCase` or `.convertToSnakeCase` unless the project explicitly wants that behavior and it clearly improves readability overall.
- This guidance is optimized for an advanced Swift reader and may prefer dense but readable modern Swift over beginner-style explicitness.

## Types and Architecture

- Prefer concrete, straightforward types and data flow that keep the code easy to follow.
- Use `struct`, `enum`, `class`, `actor`, and protocols only when each one is the clearest fit for the actual problem.
- Mark classes as `final` by default.
- Prefer synthesized conformances (`Codable`, `Equatable`, `Hashable`, etc.) whenever they satisfy the actual requirements.
- Prefer memberwise and otherwise synthesized initializers, default property values, and framework defaults over handwritten setup code.
- Do not add `CodingKeys`, manual `Codable`, custom initializers, wrappers, helper types, protocols, coordinators, or extra layers unless they are required by a concrete constraint or make the final code clearly easier to understand.
- When an API, cloud service, or wire format already provides clear names, preserve those names directly in Swift models and nearby code unless the meaning actually changes or a concrete collision must be resolved.
- Preserve raw wire and persistence shapes by default; do not add DTO, domain, or view-model conversion layers unless meaning actually changes or a concrete boundary requires it.
- Treat redundant wrappers, rename-and-copy layers, and duplicated logic as anti-patterns by default.
- Use enums as namespaces only when they genuinely reduce clutter instead of adding indirection.
- Keep code modular and cohesive without fragmenting simple logic across unnecessary files or types.
- Prefer pure Swift solutions where practical.

## Concurrency and Language Mode

- Keep code compliant with Swift 6 language mode.
- Keep strict concurrency checking enabled.
- Use modern structured concurrency (`async`/`await`, task groups, actors, `AsyncSequence`) instead of legacy async patterns when it keeps the flow clearer and more direct.
- Prefer compact syntax when it improves local reasoning, including shorthand syntax, ternary expressions, trailing closures, `switch`, `map`, `filter`, `forEach`, and async iteration.
- Prefer explicit default values at initialization when they reduce optional-handling clutter and keep the code easier to follow.
- When lines, chains, or expressions get long, prefer chopping them down into a clean vertical, top-down structure with straight visual flow.
- For app-facing packages, prefer approachable concurrency defaults with main-actor isolation by default.
- Introduce parallelism where it produces clear performance gains.

## State, Frameworks, and Dependencies

- Prefer `@Observation` over Combine for observation/state propagation.
- For Apple app projects, prefer Apple-native logging facilities first and allow Swift Logging where it makes the project API clearer.
- For packages, server-side, or cross-platform Swift, prefer Swift Logging as the primary logging API.
- Prefer Swift OpenTelemetry for telemetry and instrumentation when telemetry is needed, and prefer existing ecosystem integrations over bespoke wrappers.
- Prefer frameworks and packages from Swift.org, Swift on Server, Apple, and Apple Open Source ecosystems when they simplify the code and make it easier to reason about.
- Commonly approved examples include packages such as `swift-configuration`, `swift-async-algorithms`, and `swift-algorithms`.

## Testing and Tooling Baseline

- Use Swift Testing (`import Testing`) as the default test framework.
- Avoid XCTest unless an external constraint requires it.
- Prefer Nick Lockwood's SwiftFormat and/or SwiftLint as baseline Swift formatting and linting tools; at least one should be configured and used in any Swift project.
- Keep formatting consistent with `swift-format` conventions.
- Keep linting clean against `swiftlint` with clear, maintainable rule intent.

## SwiftUI and State Architecture

- Treat SwiftUI views as component UI: keep them small, composable, reusable, and easy to scan from top to bottom.
- Prefer straight, top-down data flow with small focused controller classes that own matching state for a view or small view cluster.
- Do not build monolithic views, monolithic controllers, or broad shared mutable state when a smaller component boundary would be clearer.
- Keep updates to view-driving state minimal and localized.
- Prefer durable identity for types that drive SwiftUI state and view updates.
- Treat `App` as the application entry and scene composition boundary, `Scene` as the container for scene-specific lifecycle and environment, and `View` as the component rendering layer.
- Use app-level lifecycle concerns at the `App` boundary, scene lifecycle concerns at the `Scene` boundary, and view-local active or presentation behavior inside views.
- Use `@Binding` to pass a focused writable piece of parent-owned state into a child view.
- Use `@Bindable` when working with an observable model that should project bindings to its mutable properties in a view.
- Prefer `@Query` for view-driven SwiftData fetching that should stay in sync with the model context; use explicit fetches only when the view should not be driven by a live query.
- Prefer environment values for shared context that truly belongs to the surrounding hierarchy, not as a dumping ground for unrelated dependencies.
- Prefer key-path-based APIs, predicates, and sort descriptors when they keep data access direct and readable.
- Extract repeated chains of view modifiers into custom view modifiers early when that reduces clutter and clearly matches a view or family of views.

## CLI Tooling Preferences

- Prefer `swift package` for package-focused workflows (dependency graph, targets, manifest intent, and local package validation).
- Prefer `swift package` subcommands for structural package edits before manually editing `Package.swift`.
- Use `swift build` and `swift test` as the default first-pass validation commands.
- Use `xcodebuild` when validating Apple platform integration details that `swift package` does not cover well (schemes, destinations, SDK-specific behavior, and configuration-specific builds/tests).
- Keep `xcodebuild` invocations explicit and reproducible (always pass scheme, destination or SDK, and configuration when relevant).
- Prefer deterministic non-interactive CLI usage in automation/CI for both `swift package` and `xcodebuild`.

## Swift Package Workflow

- Use `swift build` and `swift test` as the default first-pass validation commands for this package.
- Use `bootstrap-swift-package` when a new Swift package repo still needs to be created from scratch.
- Use `sync-swift-package-guidance` when the repo guidance for this package drifts and needs to be refreshed or merged forward.
- Re-run `sync-swift-package-guidance` after substantial package-workflow or plugin updates so local guidance stays aligned.
- Use `swift-package-build-run-workflow` for manifest, dependency, plugin, resource, Metal-distribution, build, and run work when `Package.swift` is the source of truth.
- Use `swift-package-testing-workflow` for Swift Testing, XCTest holdouts, `.xctestplan`, fixtures, and package test diagnosis.
- Use `scripts/repo-maintenance/validate-all.sh` for local maintainer validation and `scripts/repo-maintenance/sync-shared.sh` for repo-local sync steps.
- Use `scripts/repo-maintenance/release.sh --mode standard --version vX.Y.Z` from a feature branch or worktree only when the task is actually a protected-main release, publish, merge, tag, or release-PR preparation.
- Do not run the standard release workflow from `main`; when a protected-main release is explicitly requested, let it validate, bump versions, tag, push the branch and tag, open the release PR, watch CI, address valid PR comments or record out-of-scope concerns in `ROADMAP.md`, merge to protected `main`, fast-forward local `main`, and clean up stale branches.
- Treat `scripts/repo-maintenance/config/profile.env` as the installed `maintain-project-repo` profile marker, and keep it on the `swift-package` profile for plain package repos.
- Read relevant SwiftPM, Swift, and Apple documentation before proposing package-structure, dependency, manifest, concurrency, or architecture changes.
- Prefer Xcode MCP DocumentationSearch or local Swift docs first for Apple-owned Swift and SDK behavior; use Dash MCP or Dash HTTP next for installed Swift package, SwiftPM, and non-Apple docs; then use official Swift or Apple docs when local docs are insufficient.
- When SwiftPM behavior, manifest syntax, package plugins, resources, products, targets, or dependency rules matter, prefer the Dash.app docset workflow with the `swiftlang/swift-package-manager` docset first; fall back to the canonical `swiftlang/swift-package-manager` GitHub repository only when the local docset is unavailable or insufficient.
- Prefer the simplest correct Swift that is easiest to read and reason about.
- Prefer synthesized and framework-provided behavior over extra wrappers and boilerplate.
- For public Swift APIs, treat streamlined, compact, ergonomic call sites as the only acceptable default; prefer optional parameters with explicit default values over additional methods or overloads when the difference is optional behavior on the same operation.
- When a public function, initializer, or method reaches four or more arguments or parameters, strongly prefer a named typed `struct` request, options, or configuration value so call sites stay readable and future additions do not multiply overloads.
- Prefer enums, enum cases with associated values, and narrow typed values over strings, booleans, sentinel values, or parallel parameters whenever the domain has a closed or meaningful set of choices.
- Keep data flow straight and dependency direction unidirectional.
- Treat `Package.swift` as the source of truth for package structure, targets, products, and dependencies.
- Prefer `swift package` subcommands for structural package edits before manually editing `Package.swift`.
- Edit `Package.swift` intentionally and keep it readable; agents may modify it when package structure, targets, products, or dependencies need to change, and should try to keep package graph updates consolidated in one change when possible.
- Keep `Package.swift` explicit about its package-wide Swift language mode. On current Swift 6-era manifests, prefer `swiftLanguageModes: [.v6]` as the default declaration, treat `swiftLanguageVersions` as a legacy alias used only when an older manifest surface requires it, and keep the supported Swift toolchain window focused on the latest stable minor and previous stable minor. Treat Swift `6.2` as the current minimum floor for trait-enabled manifests, not as a ceiling; use newer stable Swift toolchains when available and validated, and refresh this guidance when the maintained floor or window changes. Do not lower `// swift-tools-version:` below `6.2` without an explicit repo policy and a matching guidance update.
- Keep `swift-configuration` as the default configuration dependency for Swift packages unless the package has a concrete reason to remove it. The preferred manifest shape depends on `https://github.com/apple/swift-configuration` from `1.2.0`, enables the `.defaults`, `Reloading`, `YAML`, and `CommandLineArguments` package traits, and adds the `Configuration` product to the primary target. Add the `PropertyList` trait when the package should parse property-list configuration, and add the `Logging` trait when configuration access should integrate with `SwiftLog.Logger`.
- Keep dependency provenance concise but explicit enough for another contributor to fetch the same package: use package-manager, package-registry, GitHub URL, or other real remote repository requirements, and do not commit machine-local dependency paths such as `/Users/...`, `~/...`, `../...`, local worktrees, or private checkout paths. Avoid branch- or revision-based requirements unless the user explicitly asks for that level of control.
- Treat `Package.resolved` and similar package-manager outputs as generated files; do not hand-edit them.
- Prefer Swift Testing by default unless an external constraint requires XCTest.
- Use `apple-ui-accessibility-workflow` when the package work crosses into SwiftUI accessibility semantics, Apple UI accessibility review, or UIKit/AppKit accessibility bridge behavior.
- Keep package resources under the owning target tree, declare them intentionally with `Resource.process(...)`, `Resource.copy(...)`, `Resource.embedInCode(...)`, and load them through `Bundle.module`.
- Keep test fixtures as test-target resources instead of relying on the working directory.
- Bundle precompiled Metal artifacts such as `.metallib` files as explicit resources when they ship with the package, and prefer `xcode-build-run-workflow` when shader compilation or Apple-managed Metal toolchain behavior matters.
- Prefer normal SwiftPM parallel test execution for ordinary Swift Testing and XCTest runs. Do not serialize regular package tests just because they use Swift, XCTest, async tests, fixtures, or test plans.
- Treat tests that load large local AI or ML models, especially models over 500 million parameters, as heavy system-resource tests. Run those tests sequentially, one at a time, and call `unload_models` on Gale's live TTS service before the heavy run and `reload_models` after it ends, even when the run fails or is interrupted.
- Validate both Debug and Release paths when optimization or packaging differences matter, and treat tagged releases as a cue to verify the Release artifact path before publishing.
- Prefer `xcode-build-run-workflow` or `xcode-testing-workflow` only when package work needs Xcode-managed SDK, toolchain, or test behavior.
- Keep runtime UI accessibility verification and XCUITest follow-through in `xcode-testing-workflow` rather than treating package-side testing as a substitute for live UI verification.
