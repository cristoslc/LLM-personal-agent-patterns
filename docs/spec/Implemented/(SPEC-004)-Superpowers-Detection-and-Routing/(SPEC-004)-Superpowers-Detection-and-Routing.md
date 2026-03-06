---
title: "Superpowers Detection and Routing"
artifact: SPEC-004
status: Implemented
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
parent-epic: EPIC-009
linked-research:
  - SPIKE-008
linked-adrs:
  - ADR-004
depends-on:
  - SPEC-003
addresses: []
execution-tracking: required
---

# Superpowers Detection and Routing

## Problem Statement

When a spec comes up for implementation, spec-management currently hands off directly to execution-tracking, which creates an ad-hoc task breakdown. ADR-004 specifies that when superpowers is installed, spec-management should route through superpowers' brainstorming → writing-plans pipeline first, producing a higher-quality plan file that execution-tracking then ingests via SPEC-003. Spec-management needs to detect superpowers' presence and adapt the implementation flow accordingly.

## External Behavior

**Detection:**
- Spec-management checks whether superpowers skills are available (e.g., `brainstorming` and `writing-plans` directories exist in the skill search path)
- Detection happens when an implementation-tier artifact (SPEC, STORY, BUG) comes up for implementation

**Routing when superpowers IS present:**
1. Spec-management invokes superpowers `brainstorming` skill with the artifact's context (problem statement, acceptance criteria, scope)
2. Brainstorming produces a design, then invokes `writing-plans`
3. Writing-plans saves a plan file to `docs/plans/`
4. Spec-management invokes execution-tracking with the plan file path and origin-ref (SPEC-003's ingestion flow)

**Routing when superpowers is NOT present:**
- Current behavior unchanged — spec-management hands off to execution-tracking for ad-hoc task breakdown

**Preconditions:**
- An implementation-tier artifact exists and is ready for implementation
- Spec-management skill is invoked with implementation intent

**Postconditions:**
- If superpowers present: plan file exists in `docs/plans/`, bd tasks created via ingestion
- If superpowers absent: bd tasks created via current ad-hoc flow
- Either path produces a tracked implementation plan linked to the source artifact

## Acceptance Criteria

1. Given superpowers is installed, when a SPEC comes up for implementation, then spec-management routes through brainstorming → writing-plans before execution-tracking.
2. Given superpowers is NOT installed, when a SPEC comes up for implementation, then the current direct-to-execution-tracking flow works unchanged.
3. Given superpowers is installed but brainstorming produces a design the user rejects, then the flow stops cleanly without creating orphaned plans or bd tasks.
4. Given a superpowers plan file is produced, when spec-management hands off to execution-tracking, then it passes both the plan file path and the origin-ref artifact ID.

## Scope & Constraints

- Detection is a simple filesystem check, not a runtime probe.
- Superpowers skills are invoked via the Skill tool — no custom integration code.
- The routing logic lives in the spec-management SKILL.md as conditional instructions, not as a script.
- Out of scope: modifying superpowers skills, handling superpowers version differences, installing superpowers automatically.

## Implementation Approach

Add a "Superpowers integration" section to the spec-management SKILL.md's execution tracking handoff area. The section:
1. Defines the detection check (look for superpowers skills in `.claude/skills/`)
2. Describes the conditional routing: if present → brainstorm → write-plan → ingest; if absent → current flow
3. Specifies what context to pass to brainstorming (artifact frontmatter, problem statement, acceptance criteria)
4. Specifies how to hand the plan file to execution-tracking for ingestion

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-06 | _pending_ | Initial creation |
| Implemented | 2026-03-06 | 3f44cb1 | Detection and routing logic added to spec-management SKILL.md |
