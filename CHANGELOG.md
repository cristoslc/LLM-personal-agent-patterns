# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-03-06

Initial release of the Personal Agent Patterns framework — a spec-driven development system for AI agents with lifecycle management, execution tracking, and skill distribution.

### Capabilities

**Spec Management** — Full artifact lifecycle system with 10 artifact types (Vision, Epic, Spec, Story, Spike, ADR, Persona, Journey, Runbook, Bug), phase transitions with hash-stamped audit trails, dependency graph tracking, and stale reference detection.

**Execution Tracking** — External task management via `bd` (beads) CLI with spec lineage tagging, dependency-aware scheduling, and escalation protocols. Supports plan ingestion from superpowers plan files.

**Skill Ecosystem** — 20 bundled skills covering the full development lifecycle:
- Core workflow: `push`, `release`, `finishing-a-development-branch`
- Planning: `brainstorming`, `writing-plans`, `executing-plans`
- Quality: `test-driven-development`, `systematic-debugging`, `verification-before-completion`
- Code review: `requesting-code-review`, `receiving-code-review`
- Orchestration: `dispatching-parallel-agents`, `subagent-driven-development`
- Infrastructure: `skill-manager`, `update-agents-core`, `using-git-worktrees`, `using-superpowers`
- Domain: `spec-management`, `execution-tracking`, `writing-skills`

**Specwatch** — Filesystem-level stale reference detection with ignore list support, background watcher mode, and post-operation scanning.

**Specgraph** — Artifact dependency graph with `overview`, `next`, `ready`, `blocks`, `blocked-by`, `tree`, and `mermaid` commands.

**Superpowers Integration** — Detection and routing through obra/superpowers brainstorming and writing-plans pipeline when installed, with plan file ingestion into bd tasks.

### Architecture Decisions

- ADR-001: Subtree split distribution model for agents-core
- ADR-002: Remote skills reference pattern
- ADR-003: Skill manager wraps `npx skills` with provenance overlay
- ADR-004: Superpowers as plan authoring engine with beads persistence

### Completed Epics

- EPIC-001: Skills Ecosystem Zero-Effort Distribution
- EPIC-003: Skill Lifecycle Manager
- EPIC-004: External Task Management
- EPIC-005: Specwatch — Stale Path Reference Detection
- EPIC-007: New Artifact Types — Runbook and Bug
- EPIC-009: Superpowers Execution Tracking Integration

### Known Issues

- EPIC-008 (Specwatch Ignore List) is in progress — basic support merged, refinements ongoing
- EPIC-006 (Promote Agents Core to Standalone Repo) is proposed but not yet started
- JOURNEY-001 (Skill Installation Across Projects) remains in draft
- Skill version fields in SKILL.md frontmatter are tracked independently and not bumped by this release
