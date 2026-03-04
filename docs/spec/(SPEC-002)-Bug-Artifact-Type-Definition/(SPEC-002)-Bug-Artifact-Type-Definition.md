---
title: "SPEC-002 Bug Artifact Type Definition and Tooling"
artifact: SPEC-002
status: Implemented
author: cristos
created: 2026-03-04
last-updated: 2026-03-04
parent-epic: EPIC-007
linked-research: []
linked-adrs: []
depends-on: []
addresses: []
---

# SPEC-002 Bug Artifact Type Definition and Tooling

## Problem Statement

The artifact type system has no Bug type. Defect reports discovered during testing, user feedback, or agent observation have no structured home in the spec hierarchy. Without a Bug artifact, problems are either tracked ad-hoc in the execution backend (losing the spec-level description) or shoehorned into Epics/Stories (polluting the feature hierarchy).

## External Behavior

- Agents can create Bug artifacts (`BUG-NNN`) via the spec-management skill using the standard creation workflow.
- Bugs are triaged at creation time via frontmatter fields: `severity` (critical/high/medium/low), `affected-artifacts` (list of impacted artifact IDs), `discovered-in` (context of discovery).
- At the Reported → Active transition, the Bug hands off to execution-tracking. The `fix-ref` frontmatter field records the plan or task ID.
- Bug lifecycle: Reported → Active → Fixed → Verified · Declined · Abandoned.
- Specgraph recognizes Bug terminal states (Verified, Declined) as resolved for dependency calculations.
- Specwatch and specgraph handle Bug artifacts generically (no script changes needed — they scan all `docs/*.md`).

## Acceptance Criteria

- Bug type added to AGENTS.md: artifact types table, hierarchy diagram, relationship rules, and skill routing.
- `bug-definition.md` exists in `references/` with lifecycle phases, format conventions, and triage-at-creation rules.
- `bug-template.md.j2` exists in `references/` with all required frontmatter fields and content sections.
- `docs/bug/` directory exists with `README.md` and `list-bugs.md` index.
- SKILL.md artifact type definitions table includes a Bug row pointing to both reference files.
- SKILL.md ER diagram includes Bug entity and relationships.
- Specgraph `RESOLVED_RE` includes `Verified` and `Declined`.

## Scope & Constraints

- Does not modify the execution-tracking skill — it already handles arbitrary spec origins via `origin ref`.
- Does not create any Bug artifacts — only the tooling and scaffolding.
- Bug phases avoid hyphens and apostrophes to match existing phase naming conventions (e.g., "Declined" instead of "Won't-Fix").

## Implementation Approach

1. Add Bug to AGENTS.md artifact types table, hierarchy, relationship rules, and skill routing.
2. Create `bug-definition.md` and `bug-template.md.j2` in `references/`.
3. Scaffold `docs/bug/` with `README.md` and `list-bugs.md`.
4. Add Bug row to SKILL.md artifact type definitions table.
5. Add Bug entity and relationships to SKILL.md ER diagram.
6. Add `Verified|Declined` to specgraph.sh `RESOLVED_RE`.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Implemented | 2026-03-04 | _pending_ | Created directly as Implemented — full type definition authored in-session |
