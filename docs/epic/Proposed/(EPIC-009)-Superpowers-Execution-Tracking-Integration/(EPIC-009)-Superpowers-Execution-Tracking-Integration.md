---
title: "Superpowers Execution Tracking Integration"
artifact: EPIC-009
status: Proposed
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
parent-vision: VISION-001
success-criteria:
  - "SPIKE-008 completes with a clear integrate/replace/reject decision backed by hands-on evidence"
  - "If integrate or replace: execution-tracking skill is updated to work with superpowers (either as plan author or as primary backend)"
  - "If replace: new ADR supersedes ADR-004 with documented rationale"
  - "If reject: current stack is validated and this epic is abandoned cleanly"
depends-on:
  - SPIKE-008
addresses: []
---

# Superpowers Execution Tracking Integration

## Goal / Objective

Evaluate whether and how obra/superpowers should relate to our execution-tracking stack. ADR-004 proposed a three-layer architecture (spec-management → superpowers → execution-tracking/bd), but that decision was made from documentation, not hands-on use. This epic gates on SPIKE-008 to determine the right path before any implementation work.

Three possible outcomes:
1. **Integrate** — superpowers authors plans, bd tracks execution (ADR-004 validated)
2. **Replace** — superpowers replaces bd as the execution backend (ADR-004 superseded)
3. **Reject** — keep current stack, superpowers doesn't fit our workflow (epic abandoned)

## Scope Boundaries

**In scope:**
- SPIKE-008 hands-on evaluation of superpowers' execution model
- Challenging ADR-004 assumptions with empirical evidence
- Whatever implementation path SPIKE-008's findings dictate

**Out of scope:**
- Modifying superpowers itself — we consume it as-is
- Committing to a specific integration approach before SPIKE-008 completes

## Child Specs

- SPIKE-008: Superpowers Execution Model Evaluation (gating spike — must complete before any implementation decisions)
- Implementation specs TBD based on SPIKE-008 outcome

## Key Dependencies

- SPIKE-008 (Planned) — gating research, blocks all implementation work
- ADR-004 (Adopted) — may be validated, superseded, or abandoned based on findings
- EPIC-004 (Complete) — established execution-tracking with bd
- superpowers (external) — obra/superpowers

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-06 | _pending_ | Initial creation |
