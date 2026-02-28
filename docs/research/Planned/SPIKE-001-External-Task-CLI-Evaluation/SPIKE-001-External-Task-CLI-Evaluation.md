---
title: SPIKE-001 External Task CLI Evaluation
status: Planned
question: Which external task-management CLI should replace built-in agent todos for cross-backend continuity and supervisor observability?
gate: Pre-MVP
gate_criteria:
  - "Must support durable local persistence and machine-readable export/import with no data loss in a 200-task migration test"
  - "Must support low-friction status updates (<3 commands for create/start/done) and sub-500ms median command latency on local runs"
  - "Must support external observer access patterns (query/list/filter/watch hooks, or equivalent polling-friendly output)"
prd_risks_addressed:
  - "Tool lock-in to a single agent backend"
  - "Loss of task continuity during backend switches"
  - "Lack of supervisory visibility for external observer workflows"
dependencies:
  - "PRD-001 External Task Management Tooling (Draft)"
what_it_blocks:
  - "Default task backend in the L3 execution-tracking skill"
  - "Runbook standardization for operator supervision"
recommended_pivot_if_gate_fails: "Use a neutral JSONL task ledger plus a thin wrapper script, and treat CLI tools as optional adapters rather than the system of record."
---

# SPIKE-001 External Task CLI Evaluation

## Objective
Evaluate modern external task CLI tools (including `bd`) and recommend a default integration target for L3 agent workflows.

## Candidate set (initial)
1. `bd` (Beads)
2. `taskwarrior`
3. `todo.txt` ecosystem (`todo.sh`)
4. `jira`/`gh` task wrappers where local mirror support exists

## Method
1. Define an evaluation rubric: persistence, ergonomics, observer support, automation APIs, portability.
2. Run a scripted scenario: create 20 tasks, update status transitions, add notes, export/import, and query filters.
3. Score each tool and produce recommendation + migration notes.

## Deliverables
- Comparative scorecard with weighted rubric.
- Recommended default CLI and one fallback option.
- Integration guidance update for `skills/execution-tracking/SKILL.md`.

### Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-02-25 | 2630c39 | Initial creation |
