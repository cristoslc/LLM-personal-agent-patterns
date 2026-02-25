---
title: PRD-001 External Task Management Tooling
status: Draft
author: Codex
created_date: 2026-02-25
last_updated_date: 2026-02-25
linked_research:
  - SPIKE-001-External-Task-CLI-Evaluation
linked_adrs: []
---

# PRD-001 External Task Management Tooling

## Problem statement
Built-in agent todo systems are backend-specific and do not provide consistent portability or external supervision. Teams need durable task continuity across agent providers and an observer-friendly workflow.

## Goals
1. Use an external CLI-based task store as the source of truth for agent work tracking.
2. Preserve task history when switching between agent backends.
3. Enable an external observer pattern for supervision, intervention, and auditability.

## Non-goals (draft)
- Replacing project-level issue trackers (GitHub/Jira) for roadmap planning.
- Full bi-directional sync with all enterprise PM tools in v1.

## Target users
- Operator running a local/remote agent loop.
- Supervisor observing progress from outside the active agent runtime.

## Functional requirements (draft)
1. The skill must instruct agents to prefer external task CLI commands over built-in todos.
2. The workflow must define canonical status transitions (`todo` → `in_progress` → `blocked|done`).
3. The workflow must include install/bootstrap instructions if the preferred CLI is unavailable.
4. The workflow must include recovery behavior when the CLI is missing or fails.
5. The workflow must expose observer-friendly task summaries for handoff.

## Open questions (owned by SPIKE-001)
1. Which CLI should be default (`bd` vs alternatives)?
2. What data model is portable enough for cross-tool fallback?
3. Which observer access pattern is most reliable (watch vs poll)?

## Risks
- Chosen CLI may become unmaintained.
- Tool-specific metadata may hinder migration.
- Installation friction could reduce adoption.

## Dependency graph (draft)
- PRD-001
  - blocks skill default finalization
  - depends on SPIKE-001 gate outcome

## Execution order
1. Execute SPIKE-001.
2. Update PRD defaults based on findings.
3. Promote PRD from Draft to Review.

## Phase mappings
- Draft: current state, awaiting comparative analysis.
- Review: after recommendation + implementation detail update.
- Approved: after stakeholder sign-off.

## Risk coverage mapping
- Lock-in risk → mitigated by tool comparison + neutral fallback model.
- Continuity risk → mitigated by external durable store requirement.
- Observability risk → mitigated by observer-centric CLI evaluation criteria.

### Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-02-25 | 2630c39 | Initial draft, pending SPIKE-001 |
