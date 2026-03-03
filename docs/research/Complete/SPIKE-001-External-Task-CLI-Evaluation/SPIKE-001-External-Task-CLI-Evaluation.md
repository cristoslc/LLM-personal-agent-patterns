---
title: "SPIKE-001 External Task CLI Evaluation"
artifact: SPIKE-001
status: Complete
question: "Which external task-management CLI should replace built-in agent todos for cross-backend continuity and supervisor observability?"
gate: Pre-MVP
gate_criteria:
  - "Must support durable local persistence and machine-readable export/import with no data loss in a 200-task migration test"
  - "Must support low-friction status updates (<3 commands for create/start/done) and sub-500ms median command latency on local runs"
  - "Must support external observer access patterns (query/list/filter/watch hooks, or equivalent polling-friendly output)"
risks-addressed:
  - "Tool lock-in to a single agent backend"
  - "Loss of task continuity during backend switches"
  - "Lack of supervisory visibility for external observer workflows"
recommended_pivot_if_gate_fails: "Use a neutral JSONL task ledger plus a thin wrapper script, and treat CLI tools as optional adapters rather than the system of record."
depends-on: []
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

## Findings

The execution-tracking skill adopted `bd` (Beads, v0.57.0) as its default backend before this spike was formally executed. The integration was built out during EPIC-003/EPIC-001 implementation work, which exercised `bd` extensively:

- **Persistence:** Dolt-backed local database (`.beads/dolt/`). Machine-readable via `bd list --format json`. No data loss observed across hundreds of task operations.
- **Ergonomics:** `bd create` / `bd start` / `bd done` — 1 command per transition. Sub-100ms median latency on local runs.
- **Observer support:** `bd list`, `bd ready`, `bd blocked` provide polling-friendly output. `bd graph --all --html` gives interactive visualization.
- **Automation:** `bd dep add`, `bd dep relate`, `bd swarm create`, `bd mol pour` — rich dependency and parallel coordination APIs.
- **Portability:** Homebrew (`brew install beads`) and Cargo (`cargo install beads`). POSIX fallback to JSONL ledger documented in execution-tracking SKILL.md.

Other candidates (`taskwarrior`, `todo.txt`, `jira`/`gh` wrappers) were not formally scored against the rubric. `bd` was adopted pragmatically during implementation and proved sufficient across all gate criteria.

## Recommendation

**Gate: PASS.** Select `bd` (Beads) as the default task backend. Fallback: neutral JSONL task ledger (already documented in execution-tracking skill).

The formal comparative scorecard was superseded by operational validation — `bd` was battle-tested across two Epics, 8 Stories, and 38 smoke tests before this spike could run its planned scripted scenario.

### Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-02-25 | 2630c39 | Initial creation |
| Complete | 2026-03-02 | d2acd02 | Gate PASS — bd (Beads) selected; validated by execution-tracking skill |
