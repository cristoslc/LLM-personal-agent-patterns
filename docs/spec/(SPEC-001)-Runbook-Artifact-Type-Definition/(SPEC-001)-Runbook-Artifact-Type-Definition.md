---
title: "SPEC-001 Runbook Artifact Type Definition and Tooling"
artifact: SPEC-001
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

# SPEC-001 Runbook Artifact Type Definition and Tooling

## Problem Statement

The Runbook artifact type (RUNBOOK-NNN) is defined in AGENTS.md with lifecycle phases, path conventions, and relationship rules, but the spec-management skill lacks the reference files (definition and template) needed for agents to create and transition Runbook artifacts. Without these files, agents cannot follow the standard creation workflow that reads the definition for conventions and uses the template for document structure.

## External Behavior

- When an agent invokes the spec-management skill to create a Runbook, the skill reads `references/runbook-definition.md` for lifecycle phases, folder structure conventions, and type-specific rules.
- The skill uses `references/runbook-template.md.j2` for the document skeleton, including frontmatter fields (`mode`, `trigger`, `audience`, `validates`, `parent-epic`, `related`) and content sections (Purpose, Prerequisites, Procedure, Expected Results, Failure Handling).
- The SKILL.md artifact type definitions table links to both files so agents can locate them.

## Acceptance Criteria

- `runbook-definition.md` exists in `references/` with lifecycle phases matching AGENTS.md (Draft → Active → Archived · Abandoned), folder structure conventions, and cross-cutting relationship rules.
- `runbook-template.md.j2` exists in `references/` with all required frontmatter fields and content sections.
- The SKILL.md artifact type definitions table includes a Runbook row pointing to both files.

## Scope & Constraints

- Only creates reference files. Does not modify AGENTS.md (Runbook is already defined there).
- Does not create any Runbook artifacts — only the tooling to enable their creation.

## Implementation Approach

1. Create `runbook-definition.md` following the pattern of existing definitions (state diagram, description, folder structure, conventions).
2. Create `runbook-template.md.j2` following the pattern of existing templates (Jinja2 frontmatter, content sections, lifecycle table).
3. Verify SKILL.md already links to both files (it does — added in a prior session).

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Implemented | 2026-03-04 | 2af3ec2 | Created directly as Implemented — definition and template files already existed |
