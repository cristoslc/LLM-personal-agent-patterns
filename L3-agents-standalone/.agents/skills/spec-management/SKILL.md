---
name: spec-management
description: Create, validate, and transition documentation artifacts (Vision, Epic, PRD, Spike, ADR) through their lifecycle phases. Use when creating new spec artifacts, moving artifacts between phases, seeding implementation plans in bd, or validating cross-references between artifacts.
license: UNLICENSED
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
metadata:
  short-description: Manage spec artifact creation and lifecycle
---

# Spec Management

Create, transition, and validate documentation artifacts defined in AGENTS.md. The authoritative list of artifact types, phases, and hierarchy lives in AGENTS.md — this skill provides the operational procedures.

## Lifecycle table format

Every artifact embeds a lifecycle table tracking phase transitions:

```markdown
### Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-02-24 | abc1234 | Initial creation |
| Active  | 2026-02-25 | def5678 | Dependency X satisfied |
```

Commit hashes reference the repo state at the time of the transition, not the commit that writes the hash stamp itself. Commit first, then stamp the hash and amend — the pre-amend hash is the correct value.

## Creating artifacts

### Workflow

1. Scan `docs/<type>/` to determine the next available number for the prefix.
2. Create the artifact using the appropriate format (see AGENTS.md artifact types table).
3. Populate frontmatter with the required fields for the type (see sections below).
4. Initialize the lifecycle table with the first phase and current date.
5. Update or create the `list-<type>.md` index in the type's directory.
6. Validate parent references exist (e.g., the Epic referenced by a new PRD must already exist).

### Product Vision (VISION-NNN)

The highest-level specification artifact. Defines *what the product is* and *why it exists*. Typically one per product or major product area.

- Frontmatter must include: title, status, author, created date, last updated date.
- Must define: target audience, value proposition, success metrics, non-goals.
- Should be stable — update infrequently. If a Vision needs frequent revision, it is likely scoped too narrowly (should be an Epic) or too early (needs a Spike first).
- Vision documents do NOT contain implementation details, timelines, or task breakdowns.

### Epics (EPIC-NNN)

A strategic initiative that decomposes into multiple PRDs, Spikes, and ADRs. The **coordination layer** between product vision and feature-level work.

- Frontmatter must include: title, status, author, created date, last updated date, parent Vision, success criteria.
- Must define: goal/objective, scope boundaries, child PRD list (updated as PRDs are created), and key dependencies on other Epics.
- An Epic is "Complete" when all child PRDs reach "Implemented" and success criteria are met.
- An Epic is "Archived" after completion, when it no longer requires active reference.

### PRDs (PRD-NNN)

- Frontmatter must include: title, status, author, created date, last updated date, parent Epic, and linked research artifacts and/or ADRs.
- Should be scoped to something a team (or agent) can ship and validate independently.

### Research Spikes (SPIKE-NNN)

- Number in intended execution order — sequence communicates priority.
- Frontmatter must state: question, gate (e.g., Pre-MVP), risks addressed, dependencies, and what it blocks.
- Gating spikes must define go/no-go criteria with measurable thresholds (not just "investigate X").
- Gating spikes must recommend a specific pivot if the gate fails (not just "reconsider approach").
- Spikes can belong to any artifact type (Vision, Epic, PRD, ADR). The owning artifact controls all spike tables: questions, risks, gate criteria, dependency graph, execution order, phase mappings, and risk coverage. There is no separate research roadmap document.

### ADRs (ADR-NNN)

- Frontmatter must include: title, status, author, created date, last updated date, and links to all affected Epics/PRDs.
- ADRs are cross-cutting: they link to all affected artifacts but are not owned by any single one.
- Use the Draft phase while investigation (Spikes) is still in progress. Move to Proposed when the recommendation is formed and ready for review.

## Phase transitions

### Workflow

1. Validate the transition is legal for the artifact type (see AGENTS.md phases column).
2. Update the artifact's status field in frontmatter.
3. Commit the change.
4. Append a row to the artifact's lifecycle table with the commit hash from step 3.
5. Amend the commit to include the hash stamp.
6. Update `list-<type>.md` to reflect the new phase.

### Completion rules

- An Epic is "Complete" only when all child PRDs are "Implemented" and success criteria are met.
- A PRD is "Implemented" only when its bd implementation plan epic is closed (or all tasks are done in fallback mode).
- An ADR is "Superseded" only when the superseding ADR is "Adopted" and links back.

## Implementation plans (bd execution bridge)

Implementation Plans are not a doc-type artifact. They bridge declarative specs (`docs/`) and execution tracking (`bd`). Plans are materialized as live `bd` epics with dependency-ordered child tasks.

### Seeding a plan from a spec

1. A PRD (or Epic) may include an "Implementation Approach" section sketching the high-level plan. This seeds the `bd` plan but is not the plan of record.
2. When work begins, create a `bd` epic from that outline:
   ```
   bd create "Implement PRD-003 CSV Export" --type=epic --external-ref PRD-003
   ```
3. Create child tasks under the epic with dependencies:
   ```
   bd create "Add export endpoint" --parent <epic-id> --labels spec:PRD-003
   bd create "Write serializer" --parent <epic-id> --deps <endpoint-id> --labels spec:PRD-003
   ```

### Lineage and cross-spec impact

- **`--external-ref`** records which spec *seeded* the plan (immutable origin).
- **`spec:<ID>` labels** record which specs a task *currently affects* (mutable, may grow).
- When a task impacts additional specs:
  ```
  bd label add <task-id> spec:PRD-007
  bd dep relate <task-id> <other-spec-task-id>
  ```
- Use `bd dep add --type=discovered-from` for provenance when tasks spawn from existing ones.
- Query all work for a spec: `bd list --label spec:PRD-003`.

### Parallel coordination

- `bd swarm create <epic-id>` sets up a swarm — agents use `bd ready` to pick up unblocked work.
- For repeatable workflows, define a formula in `.beads/formulas/` and instantiate with `bd mol pour`.

### Closing the loop

- Progress is tracked in `bd`, not in the spec doc. The PRD's lifecycle table records the transition to "Implemented" once the `bd` epic completes.
- Cross-spec tasks should be noted in each affected artifact's lifecycle table entry (e.g., "Implemented — shared serializer also covers PRD-007").

### Fallback

If `bd` is unavailable, use the agent's built-in todo system with canonical states (`todo`, `in_progress`, `blocked`, `done`) per the external-task-management skill. The plan structure (ordered steps, dependencies, completion tracking) remains the same — only the backend changes. Lineage is maintained by including artifact IDs in task titles or notes (e.g., `[PRD-003] Add export endpoint`).
