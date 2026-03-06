---
title: "Superpowers Plan Ingestion"
artifact: SPEC-003
status: Implemented
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
parent-epic: EPIC-009
linked-research:
  - SPIKE-008
linked-adrs:
  - ADR-004
depends-on: []
addresses: []
execution-tracking: required
---

# Superpowers Plan Ingestion

## Problem Statement

The execution-tracking skill creates task breakdowns ad-hoc — the agent reads a spec and manually decomposes it into bd tasks. Superpowers' writing-plans skill produces higher-quality plans (exact file paths, complete code blocks, verification commands, bite-sized steps), but those plans exist only as markdown files with no connection to bd. Execution-tracking needs a way to ingest a superpowers plan file and register its tasks in bd with full spec lineage.

## External Behavior

**Input:** A superpowers plan file path (e.g., `docs/plans/2026-03-06-auth-system.md`) and an origin-ref artifact ID (e.g., `SPEC-003`).

**Output:** A bd epic with child tasks mirroring the plan's `### Task N` blocks, each with:
- Title from the task heading
- Description from the task body (files, steps, code blocks)
- `--external-ref` on the epic pointing to the origin artifact
- `--labels spec:<ID>` on each child task
- Dependencies between tasks reflecting their sequential ordering

**Preconditions:**
- bd is initialized (`.beads/` exists)
- The plan file exists and follows superpowers' `writing-plans` format
- The origin-ref artifact exists in `docs/`

**Postconditions:**
- bd epic created with all tasks
- Each task's description contains enough context for an agent to execute it without re-reading the plan file
- `bd ready` returns the first unblocked task(s)

## Acceptance Criteria

1. Given a superpowers plan file with 5 tasks, when ingestion runs, then bd contains 1 epic + 5 child tasks with correct titles and descriptions.
2. Given a plan file, when ingestion runs, then each bd task's description includes the task's file paths, steps, and code blocks from the plan.
3. Given sequential tasks in a plan, when ingestion runs, then bd dependencies enforce Task N+1 depends on Task N.
4. Given an origin-ref of `SPEC-003`, when ingestion runs, then the bd epic has `--external-ref SPEC-003` and all child tasks have `--labels spec:SPEC-003`.
5. Given a plan file that doesn't match the expected format, when ingestion runs, then it fails with a clear error message rather than producing garbage tasks.

## Scope & Constraints

- Ingestion is one-way: plan file → bd. No bd → plan file sync.
- The parser handles the format documented in superpowers' `writing-plans/SKILL.md`. It does not need to handle arbitrary markdown.
- Ingestion can be implemented as a shell script, Python script, or additions to the execution-tracking SKILL.md instructions — whatever is simplest.
- Out of scope: modifying superpowers itself, bidirectional sync, automatic re-ingestion on plan file changes.

## Implementation Approach

Add a "plan ingestion" section to the execution-tracking SKILL.md that teaches the agent how to parse a superpowers plan file. The parsing logic:
1. Read the plan file
2. Extract the header (title, goal, architecture)
3. Split on `### Task N:` boundaries
4. For each task block, extract title, Files section, and Steps
5. Create bd epic with `--external-ref`
6. Create bd child tasks with descriptions and labels
7. Wire sequential dependencies

This could be agent instructions (the agent parses the plan inline) or a helper script. Start with agent instructions — a script can be extracted later if the parsing proves complex.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-06 | _pending_ | Initial creation |
| Implemented | 2026-03-06 | 034183a | Plan ingestion script and SKILL.md docs complete |
