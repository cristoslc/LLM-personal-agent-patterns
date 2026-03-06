---
title: "EPIC-007 New Artifact Types — Runbook and Bug"
artifact: EPIC-007
status: Complete
author: cristos
created: 2026-03-03
last-updated: 2026-03-04
parent-vision: VISION-001
success-criteria:
  - "Runbook and Bug artifact types are defined in AGENTS.md with lifecycle phases, path conventions, and relationship rules"
  - "Both types have definition files and templates in the spec-management skill references"
  - "The spec-management skill handles creation, transition, and indexing for both types"
  - "Bug artifacts integrate with execution-tracking for handoff to the task backend"
  - "Runbook artifacts are reconcilable — stale-reference detection and dependency graph support them"
depends-on: []
---

# EPIC-007 New Artifact Types — Runbook and Bug

## Goal / Objective

Extend the artifact type system with two new types that fill gaps in the current framework:

1. **Runbook (RUNBOOK-NNN)** — A human-readable operational document intended for the user (not the agent). Runbooks capture procedures, checklists, and decision trees for recurring operations. Unlike Agent Specs (which describe what an agent should do), Runbooks describe what a _person_ should do, often informed by the output of agent work. They participate in the full lifecycle: versioning, phase transitions, stale-reference detection, and dependency graph reconciliation.

2. **Bug (BUG-NNN)** — A structured defect or issue report that exists outside the Epic hierarchy. Bugs capture problems discovered during any phase of work — testing, user feedback, agent observation — that don't naturally fit as children of an existing Epic. They serve as the bridge between spec-management (where the problem is described) and execution-tracking (where the fix is tracked). Triage happens at creation time via frontmatter fields (severity, affected artifacts). When work begins, the Bug hands off to the task backend via an implementation plan, just like any other spec artifact.

## Scope Boundaries

**In scope:**
- Lifecycle phase definitions for both Runbook and Bug
- AGENTS.md updates: artifact types table, hierarchy diagram, relationship rules
- Spec-management skill updates: definition files, templates, skill routing for new types
- Frontmatter schema for each type (required/optional fields)
- Index files (`list-runbooks.md`, `list-bugs.md`) and directory scaffolding
- Specwatch and specgraph support for new types
- Bug-to-execution-tracking handoff workflow

**Out of scope:**
- Migrating existing ad-hoc runbooks or bug notes into the new format
- Automated bug detection or triage by agents
- Runbook execution engines or interactive checklists
- Changes to the execution-tracking skill itself (it already handles arbitrary spec origins)

## Design Notes

### Runbook (RUNBOOK-NNN)

**Path:** `docs/runbook/`
**Format:** Folder containing titled `.md` + supporting docs (diagrams, reference tables)

**Proposed lifecycle phases:**
- Draft → Published → Revised → Retired · Abandoned

**Key characteristics:**
- Audience is the human user, not the agent
- May reference other artifacts (Epics, Specs, ADRs) as context but is not owned by them
- Cross-cutting like ADRs and Personas — links to relevant artifacts without being a child
- "Revised" phase supports iterative updates without losing the publication record
- Content should be actionable: numbered steps, decision points, success/failure criteria

**Frontmatter fields:**
- `title`, `artifact`, `status`, `author`, `created`, `last-updated` (standard)
- `audience` — who this runbook is for (e.g., "operator", "contributor", "end-user")
- `trigger` — when to use this runbook (e.g., "new release", "incident response", "onboarding")
- `related` — list of related artifact IDs (informational, non-blocking)
- `depends-on` — blocking dependencies (if any)

### Bug (BUG-NNN)

**Path:** `docs/bug/`
**Format:** Markdown file per bug (lightweight, like User Stories)

**Proposed lifecycle phases:**
- Reported → In-Progress → Fixed → Verified · Won't-Fix · Abandoned

**Key characteristics:**
- Lives outside the Epic hierarchy — Bugs are not children of Epics
- Captures the problem description, reproduction steps, severity, and affected artifacts
- Triage happens at creation time — severity, affected artifacts, and priority are frontmatter fields, not a separate phase
- Handoff to execution-tracking happens at the Reported → In-Progress transition
- "Verified" is the success end-state (fix confirmed); "Won't-Fix" for intentional non-action
- May reference any artifact via `affected-artifacts` field

**Frontmatter fields:**
- `title`, `artifact`, `status`, `author`, `created`, `last-updated` (standard)
- `severity` — critical / high / medium / low
- `affected-artifacts` — list of artifact IDs impacted by this bug
- `discovered-in` — artifact or context where the bug was found (e.g., "SPEC-003 testing", "user report")
- `fix-ref` — once work begins, the execution-tracking plan ID or task ID
- `depends-on` — blocking dependencies (if any)

### Relationship to existing hierarchy

```
Product Vision (VISION-NNN)
  ├── User Journey (JOURNEY-NNN)
  ├── Epic (EPIC-NNN)
  │     ├── User Story (STORY-NNN)
  │     ├── Agent Spec (SPEC-NNN)
  │     │     └── Implementation Plan (via execution-tracking)
  │     └── ADR (ADR-NNN) — cross-cutting
  ├── Persona (PERSONA-NNN) — cross-cutting
  ├── Runbook (RUNBOOK-NNN) — cross-cutting, user-facing  ← NEW
  ├── Bug (BUG-NNN) — independent, hands off to execution-tracking  ← NEW
  └── Research Spike (SPIKE-NNN) — attaches to any artifact
```

- **Runbooks** are cross-cutting like Personas and ADRs: they link to relevant artifacts but aren't owned by any single one
- **Bugs** are independent: they reference affected artifacts but sit outside the hierarchy, bridging spec-management and execution-tracking

## Child Specs

- [SPEC-001 Runbook Artifact Type Definition and Tooling](../../spec/(SPEC-001)-Runbook-Artifact-Type-Definition/(SPEC-001)-Runbook-Artifact-Type-Definition.md) — Implemented
- [SPEC-002 Bug Artifact Type Definition and Tooling](../../spec/(SPEC-002)-Bug-Artifact-Type-Definition/(SPEC-002)-Bug-Artifact-Type-Definition.md) — Implemented
- Specwatch/specgraph extensions — not needed (scripts are generic, scan all `docs/*.md`)

## Key Dependencies

None. This Epic extends the artifact system using established patterns. The execution-tracking skill already supports arbitrary spec origins via `origin ref`, so Bug handoff requires no changes there.

## Risks

- **Scope creep into workflow automation** — Runbooks could expand into executable playbooks; mitigated by keeping them as static documents with clear "out of scope" boundary
- **Bug lifecycle overlap with execution-tracking** — The Bug artifact describes the problem; execution-tracking tracks the fix. The boundary must be clean: Bug transitions to In-Progress only when an execution-tracking plan exists, and transitions to Fixed/Verified based on plan completion
- **Naming collision** — `bug` is a common term that could conflict with the execution-tracking `bug` issue type in bd. Mitigated by scoping: BUG-NNN is the spec artifact (problem description); bd issues are execution tasks (fix tracking)

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-03 | 76a76c1 | Initial creation |
| Active | 2026-03-04 | 2af3ec2 | Child specs SPEC-001, SPEC-002 created and implemented |
