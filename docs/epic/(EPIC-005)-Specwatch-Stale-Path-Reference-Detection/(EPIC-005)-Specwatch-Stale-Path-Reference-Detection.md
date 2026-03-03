---
title: "Specwatch — Stale Path Reference Detection"
artifact: EPIC-005
status: Complete
author: cristos
created: 2026-03-03
last-updated: 2026-03-03
parent-vision: VISION-001
success-criteria:
  - "A background filesystem watcher detects file moves, renames, and deletes in docs/ and flags stale path references in other artifacts"
  - "The watcher self-terminates after a configurable inactivity timeout (default 1 hour) with keepalive refresh on spec-management invocations"
  - "Stale reference warnings are surfaced to the agent so they can be addressed before committing"
  - "The watcher integrates cleanly with Claude Code sessions — startable on demand or via session hook, with no orphan processes"
depends-on:
  - SPIKE-007
---

# Specwatch — Stale Path Reference Detection

## Goal / Objective

Agents implementing spec-management frequently incorporate file paths into artifact content (cross-references, ADR phase-directory paths, supporting doc links). When lifecycle transitions move or rename files — especially ADR phase-directory moves — these path references go stale silently. Build a lightweight filesystem watcher (`specwatch`) that monitors `docs/` for structural changes and flags stale path references in real time.

## Scope Boundaries

**In scope:**
- Background watcher script using `fswatch` (macOS FSEvents) to monitor `docs/` for moves, renames, and deletes of `.md` files
- Stale path reference scanner: grep `docs/**/*.md` for path-like strings pointing to files that no longer exist
- Inactivity timeout with sentinel-file keepalive pattern (spec-management touches sentinel; watcher exits when sentinel age exceeds threshold)
- Integration with spec-management skill: touch sentinel on every artifact operation (create, transition, edit, audit)
- Start/stop mechanism compatible with Claude Code background tasks
- Log output strategy (determined by SPIKE-007)

**Out of scope:**
- Automatic rewriting of stale references (watcher detects and reports only — resolution is a manual or agent-assisted step)
- Watching files outside `docs/` (SKILL.md, AGENTS.md, etc. are lower-frequency and handled by audit)
- Cross-platform support beyond macOS (fswatch supports Linux/Windows but initial implementation targets macOS FSEvents)
- IDE integration (VS Code link updating is a separate concern)

## Child Specs

_To be created after SPIKE-007 completes and log strategy is decided._

## Key Dependencies

- **SPIKE-007** (Specwatch Log Strategy) — determines whether the watcher is warn-only or logs resolutions too
- **SPIKE-006** (Spec Dependency Graph Tracking) — **Complete**: specgraph.sh provides the frontmatter-based reference model that specwatch complements with path-level monitoring
- **fswatch** — must be installed (`brew install fswatch`); script should fail gracefully with install instructions if missing

## Risks

- False positives from path-like strings that aren't actual file references (e.g., example paths in prose) — mitigate with heuristic filtering
- fswatch event batching may miss rapid rename chains — mitigate with debounce and periodic full-scan fallback
- Orphan watcher processes if Claude Code session crashes — mitigate with PID file and sentinel timeout

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-03 | dc83645 | Initial creation; gated on SPIKE-007 |
| Active | 2026-03-03 | 60bc5c3 | SPIKE-007 gate passed; Strategy 2 selected |
| Testing | 2026-03-03 | 8240c89 | Implementation complete; 6/6 tasks closed; E2E validated |
