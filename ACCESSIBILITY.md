# Accessibility

SwiftMonocle is currently a Swift package with a bootstrap macOS app shell. Accessibility requirements matter because graph visualization, Xcode-facing workflows, and future voice/status surfaces should be designed from the start as accessible interfaces.

## Table of Contents

- [Overview](#overview)
- [Standards Baseline](#standards-baseline)
- [Accessibility Architecture](#accessibility-architecture)
- [Engineering Workflow](#engineering-workflow)
- [Known Gaps](#known-gaps)
- [User Support and Reporting](#user-support-and-reporting)
- [Verification and Evidence](#verification-and-evidence)

## Overview

### Status

No app UI has shipped yet. Accessibility guidance is therefore a planning and design baseline, not evidence of a verified product surface.

### Scope

This file applies to SwiftUI, AppKit, Xcode extension, graph visualization, command, status, and voice-adjacent UI surfaces added to this repository.

### Accessibility Goals

Future UI should make code context, dependency/API graphs, diagnostics, agent status, and actions usable with keyboard navigation, VoiceOver, sufficient contrast, reduced motion, and clear text alternatives.

## Standards Baseline

### Target Standard

Use current Apple accessibility guidance for macOS apps and SwiftUI/AppKit controls, with WCAG 2.2 AA as the general product baseline when web-style criteria apply.

### Conformance Language Rules

Only claim verified support after testing a concrete UI. Use "planned", "targeted", or "not yet verified" for surfaces that do not exist yet.

### Supported Platforms and Surfaces

The first expected UI platform is macOS. Xcode Source Editor Extension behavior should be tested separately from the companion macOS app because it runs inside a different host surface.

## Accessibility Architecture

### Semantic Structure

Graph views should expose meaningful nodes, edges, selection state, and summaries instead of relying only on visual layout.

### Input and Keyboard Model

Every primary command should be reachable by keyboard. Graph navigation should support predictable movement between nodes, filters, search results, and detail panes.

### Focus Management

Opening detail panes, search results, errors, or approval prompts should move focus intentionally and restore focus when dismissed.

### Naming and Announcements

Controls, graph nodes, API symbols, dependency groups, and status changes should have concise accessible names and useful announcements.

### Color, Contrast, and Motion

Use color as emphasis, not as the only signal. Any animated graph layout, pulse, or status motion should respect reduced-motion preferences.

### Zoom, Reflow, and Responsive Behavior

Visualization surfaces should remain readable when text size or window size changes. Dense graph views need list, outline, or table alternatives for inspection.

### Media, Captions, and Alternatives

No media surface exists yet. Future demos or voice/status playback should include text equivalents where practical.

## Engineering Workflow

### Design and Implementation Rules

Keep accessibility semantics close to the component that owns the interaction. Do not hide essential state inside decorative drawing layers.

### Automated Testing

Add automated checks when UI targets exist and the checks can verify real labels, roles, focus behavior, or state.

### Manual Testing

Manual validation should include keyboard-only use, VoiceOver inspection, contrast review, and reduced-motion review for the macOS app.

### Assistive Technology Coverage

VoiceOver is the primary assistive technology target for macOS. Additional tooling can be added when the UI surface becomes concrete.

### Definition of Done

UI work is not complete until interaction, focus, labels, state, and non-visual alternatives are considered and any remaining gaps are documented.

## Known Gaps

### Current Exceptions

- No macOS app target exists yet.
- No Xcode extension target exists yet.
- No graph visualization surface exists yet.
- No accessibility evidence exists for runtime UI.

### Planned Remediation

Add concrete accessibility acceptance criteria when the first app or extension target is introduced.

### Ownership

UI owners are responsible for keeping this file, implementation, and validation evidence aligned as the app surface becomes real.

## User Support and Reporting

### Feedback Path

Use the repository issue tracker or maintainer discussion path once the repository is ready for outside feedback.

### Triage Expectations

Treat accessibility bugs as product bugs. Record reproduction steps, affected surface, assistive technology involved, expected behavior, and observed behavior.

## Verification and Evidence

### CI Signals

There are no UI accessibility CI checks yet.

### Audit Cadence

Run an accessibility review when the first macOS app target lands, when graph interactions change materially, and before any public release.

### Review History

- 2026-06-28: Added accessibility baseline for the planned macOS app and visualization surfaces. No runtime UI was available to test.
