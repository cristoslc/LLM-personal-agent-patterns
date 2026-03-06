---
title: "Superpowers Execution Model Evaluation"
artifact: SPIKE-008
status: Complete
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
question: "What is superpowers' actual execution model, and what is the right relationship — if any — between superpowers and our execution-tracking/bd stack?"
gate: Pre-implementation
risks-addressed:
  - "ADR-004 assumed a three-layer architecture without hands-on evaluation of superpowers' actual behavior"
  - "Superpowers may solve problems bd solves, making the stack redundant rather than complementary"
  - "Superpowers may be fundamentally incompatible with our spec-management workflow, making integration a dead end"
  - "The 'plan ingestion' framing may be wrong — superpowers may not produce discrete ingestible artifacts"
depends-on: []
execution-tracking: required
---

# Superpowers Execution Model Evaluation

## Question

What is superpowers' actual execution model, and what is the right relationship — if any — between superpowers and our execution-tracking/bd stack?

ADR-004 decided on a three-layer architecture (spec-management → superpowers → execution-tracking) based on reading superpowers' docs and repo. But we've never actually run it. The decision assumed:

1. Superpowers produces discrete plan files that can be parsed and ingested
2. Superpowers' TodoWrite-based tracking is insufficient for our workflow
3. The two systems are complementary (plan authoring vs. plan tracking)
4. bd adds value on top of what superpowers provides

Any or all of these assumptions may be wrong. This spike investigates from first principles.

## Go / No-Go Criteria

- **GO for integration** if: Superpowers and bd genuinely serve different purposes, superpowers produces artifacts that can bridge into bd, and the combined value exceeds either tool alone for a short-burst, context-switching workflow.
- **GO for replacement** if: Superpowers alone handles plan authoring AND cross-session tracking well enough that bd adds no meaningful value. In this case, ADR-004 is superseded and execution-tracking should wrap superpowers instead of bd.
- **NO-GO** if: Superpowers' execution model is too tightly coupled to its own methodology to integrate with our spec-management workflow, or the overhead of integration exceeds the quality improvement in plans.

## Pivot Recommendation

If NO-GO: Keep the current execution-tracking/bd stack as-is. Document what we learned about superpowers' model in the findings. Consider cherry-picking specific techniques (e.g., structured task decomposition patterns) without adopting the framework.

If GO for replacement: Create a new ADR superseding ADR-004, transition execution-tracking to wrap superpowers, and evaluate whether bd should be retained as a secondary backend or dropped entirely.

## Findings

### Gate: GO for integration

All four ADR-004 assumptions validated by examining superpowers source (obra/superpowers repo, 14 skills, 3 sample plans).

### Assumption 1: Discrete parseable plan files
**CONFIRMED.** Plans are markdown files at `docs/plans/YYYY-MM-DD-<name>.md`. Consistent structure: header (title/goal/architecture/tech-stack), then `### Task N: [Title]` blocks with `Files:` (Create/Modify/Test with exact paths), numbered steps with complete code blocks and verification commands. Format is documented in `writing-plans/SKILL.md` and consistent across all sample plans.

### Assumption 2: TodoWrite tracking insufficient for our workflow
**CONFIRMED.** TodoWrite is session-scoped — ephemeral, no persistence to disk. Plan files persist but have no completion tracking (no checkboxes, no status). If a session ends mid-execution, all progress state is lost.

### Assumption 3: Complementary, not redundant
**CONFIRMED.** Superpowers excels at plan **authoring** (Socratic brainstorming, exact paths, complete code, verification commands, 2-5 min bite-sized steps) and execution **process** (subagent dispatch, 2-stage review). bd excels at plan **tracking** (persistence, dependency graph, observability, lineage). Neither covers the other's strengths.

### Assumption 4: bd adds value on top of superpowers
**CONFIRMED.** bd provides cross-session persistence, dependency-aware scheduling (`bd ready`), external observability (`bd status`/`bd list`), and spec lineage (`--external-ref`, `--labels spec:SPEC-NNN`). Superpowers provides none of these.

### Integration seam
Each superpowers `### Task N` block maps to a bd task. Steps within a task map to bd task description/notes. File paths can be captured in labels or notes. The plan file format is stable enough for reliable extraction.

### What we did NOT validate
- Actual runtime behavior (we examined source, not execution)
- Format stability across superpowers versions (only 3 sample plans examined)
- Whether superpowers' execution skills can be modified to use bd instead of TodoWrite

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-06 | _pending_ | Initial creation |
| Complete | 2026-03-06 | _pending_ | Gate PASS — GO for integration; ADR-004 validated |
