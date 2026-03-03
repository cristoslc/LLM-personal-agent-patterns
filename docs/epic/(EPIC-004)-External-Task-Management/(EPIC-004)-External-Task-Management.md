---
title: "EPIC-004 External Task Management"
artifact: EPIC-004
status: Complete
author: cristos
created: 2026-03-02
last-updated: 2026-03-03
parent-vision: VISION-001
success-criteria:
  - "An external CLI-based task store replaces built-in agent todos as the source of truth for execution tracking"
  - "Task history persists when switching between agent backends"
  - "An external observer can monitor task progress without access to the active agent runtime"
  - "The execution-tracking skill defaults to the selected CLI with a documented fallback path"
depends-on:
  - SPIKE-001
---

# EPIC-004 External Task Management

## Goal / Objective

Replace built-in agent todo systems with a durable, external CLI-based task store. Agents should track work in a tool that survives backend switches, supports external supervision, and provides a portable data model. The chosen tool becomes the default backend for the execution-tracking skill.

## Scope Boundaries

**In scope:**
- Evaluating and selecting an external task CLI (SPIKE-001)
- Defining canonical status transitions (`todo` -> `in_progress` -> `blocked` | `done`)
- Install/bootstrap instructions and recovery behavior when the CLI is unavailable
- Observer-friendly task summaries for handoff and supervision
- Integration guidance for the execution-tracking skill

**Out of scope:**
- Replacing project-level issue trackers (GitHub Issues, Jira) for roadmap planning
- Full bi-directional sync with enterprise PM tools
- Spec dependency graph tracking (that's SPIKE-006 territory, downstream of this Epic)

## Target Users

- Operator running a local/remote agent loop
- Supervisor observing progress from outside the active agent runtime

## Child Specs

No child Agent Specs were created. The execution-tracking skill (v2.0.0) was implemented directly as an operational skill rather than through formal spec decomposition. The skill provides the full scope of this Epic: `bd`-backed task management with bootstrap, observer patterns, spec lineage tagging, parallel coordination, and a documented fallback path.

## Key Dependencies

- **SPIKE-001** (External Task CLI Evaluation) — **Complete**: Gate PASS. `bd` (Beads) selected as default backend.
- **SPIKE-006** (Spec Dependency Graph Tracking) — **Planned**: Downstream. Depends on SPIKE-001's CLI selection but is not a child of this Epic.

## Risks

- Chosen CLI may become unmaintained — mitigated by tool comparison and neutral fallback model
- Tool-specific metadata may hinder migration — mitigated by external durable store requirement
- Installation friction could reduce adoption — mitigated by observer-centric CLI evaluation criteria

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-02 | fc73aa0 | Migrated from PRD-001; gated on SPIKE-001 |
| Active | 2026-03-02 | 3e2bbdb | SPIKE-001 gate passed; bd selected |
| Complete | 2026-03-03 | fe8272b | All success criteria met; execution-tracking skill v2.0.0 operational |
