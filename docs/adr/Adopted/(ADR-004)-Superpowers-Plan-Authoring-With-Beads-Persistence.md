---
title: "Superpowers as Plan Authoring Engine with Beads Persistence"
artifact: ADR-004
status: Adopted
author: cristos
created: 2026-03-03
last-updated: 2026-03-03
linked-epics:
  - EPIC-006
  - EPIC-004
linked-specs: []
depends-on: []
---

# Superpowers as Plan Authoring Engine with Beads Persistence

## Context

Swain's execution-tracking skill uses bd (beads) as a persistent task backend for implementation plans. Plans are created ad hoc — the agent breaks a spec into tasks and registers them in bd. This works but produces lower-quality task breakdowns compared to a structured authoring process.

obra/superpowers (69K stars) is a development methodology framework distributed as agent skills. Its `brainstorming` → `writing-plans` pipeline produces high-quality implementation plans: each task has exact file paths, complete code blocks, verification commands with expected output, and commit steps. However, superpowers tracks execution state via `TodoWrite` (Claude Code's built-in ephemeral task system), which does not persist across sessions.

The user's workflow involves short bursts with heavy context switching — cross-session persistence and dependency tracking are critical. TodoWrite's ephemeral state is insufficient.

The question: how should plan authoring (superpowers) and plan tracking (bd) relate to each other, and which skill orchestrates the flow?

## Decision

Adopt a three-layer architecture where each tool stays in its lane:

1. **spec-management** is the orchestrator. When a spec reaches the implementation stage, spec-management calls superpowers to author the plan, then hands the resulting plan to execution-tracking for registration in bd.

2. **superpowers** (brainstorming + writing-plans) is a pure capability for plan authoring. It produces a markdown plan file with structured tasks. It does not track state or know about specs.

3. **execution-tracking** bridges superpowers plans into bd. It reads a superpowers plan file, extracts tasks, registers them in bd with origin-ref linking back to the source spec, and manages dependencies. bd provides cross-session persistence, dependency-aware scheduling, and external observability.

The flow:

```
spec-management          "SPEC-003 is Approved, time to implement"
  → superpowers          "brainstorm the design, write the plan"
    → spec-management    "plan file produced, hand to execution-tracking"
      → execution-tracking   "register tasks in bd with origin-ref: SPEC-003"
```

Superpowers is a recommended companion install, not a hard dependency. When superpowers is not present, spec-management falls back to manual plan authoring (the current behavior). When superpowers is present, spec-management leverages it for higher-quality plans.

## Alternatives Considered

**Replace bd with superpowers entirely.** Superpowers' plan files are persistent (markdown in `docs/plans/`) and use checkboxes to track completion. However, this provides no dependency graph, no computed "what's next?" across sessions, no external observability, and no spec lineage tagging. The user's short-burst, context-switching workflow requires cross-session continuity that checkbox markdown cannot provide.

**Have execution-tracking call superpowers directly.** This would skip spec-management as the orchestrator. Rejected because execution-tracking should not know about spec artifacts — it is a task backend integration, not a lifecycle manager. Spec-management owns the "what to implement" context (success criteria, parent epic, dependencies) and should control when and how plans are authored.

**Adopt superpowers wholesale, replacing swain.** Superpowers has no spec management (no artifact types, lifecycle phases, numbering, dependency graphs, specwatch, specgraph), no persistent execution tracking, and no governance routing. It is a development methodology framework, not a project management framework. The two are complementary, not competing.

**Use superpowers' executing-plans/subagent-driven-development for execution.** These skills provide valuable execution *process* (batched tasks, subagent dispatch, two-stage review) and can be used alongside bd tracking. They are orthogonal to this ADR's scope — this decision is about plan *authoring* and *persistence*, not execution process.

## Consequences

**Positive:**
- Plan quality improves via superpowers' structured brainstorming → writing pipeline
- Each tool stays in its lane: superpowers authors plans, bd tracks them, spec-management orchestrates
- Superpowers is optional — no hard dependency added to swain
- The plan markdown file serves as a human-readable reference alongside the bd task database
- Execution-tracking gains a "ingest superpowers plan" capability, making it more useful to superpowers users outside the swain ecosystem

**Negative:**
- Three-tool chain (spec-management → superpowers → execution-tracking) adds coordination complexity
- Superpowers plan format may evolve independently — the ingestion step needs to handle format changes
- Users must install superpowers separately (`npx skills add obra/superpowers`) to get the full experience
- The plan file and bd tasks are dual representations of the same work — they can drift if one is updated without the other

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Adopted | 2026-03-03 | 002e7de | Decision made through design discussion; skipped Draft/Proposed |
