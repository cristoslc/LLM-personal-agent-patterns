---
title: "SPEC-005 Swain Repository Structure and Skill Packaging"
artifact: SPEC-005
status: Draft
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
parent-epic: EPIC-006
linked-research: []
linked-adrs:
  - ADR-005
depends-on: []
addresses: []
execution-tracking: required
---

# SPEC-005 Swain Repository Structure and Skill Packaging

## Problem Statement

The framework's skills currently live inside `L3-agents-core/.agents/` within a monorepo, structured for the custom subtree-split distribution pipeline. They need to be restructured into a standalone `cristos/swain` repository that `npx skills` can discover and install.

## External Behavior

**Inputs:**
- `npx skills add cristos/swain` from any project directory

**Outputs:**
- All skills (spec-management, execution-tracking, governance) symlinked into the consumer's `.claude/skills/` directory
- No dev-only content (docs/, tests, CI config) visible to consumers

**Preconditions:**
- Node.js and npm available (for `npx skills`)
- Git available (for repo cloning)

**Postconditions:**
- Each skill directory contains a valid SKILL.md, plus optional `references/` and `scripts/` subdirectories
- `npx skills list` shows all installed skills from swain

## Acceptance Criteria

1. Given the swain repo exists on GitHub, when a user runs `npx skills add cristos/swain`, then all skills are installed into `.claude/skills/`
2. Given the repo contains `docs/`, `AGENTS.md`, and other dev-only files, when `npx skills` scans the repo, then only SKILL.md directories are discovered
3. Given the existing spec-management skill with its `references/` and `scripts/` subdirectories, when packaged for swain, then all supporting files are included and paths resolve correctly
4. Given the existing execution-tracking skill, when packaged for swain, then all scripts (including `ingest-plan.py`) are included and functional

## Scope & Constraints

**In scope:**
- Repository creation and initial structure
- Skill directory layout (`skills/<name>/SKILL.md`)
- CI configuration (linting, specwatch)
- README and contributor docs for the swain repo itself

**Out of scope:**
- Governance skill content (see SPEC-006)
- Migration from legacy distribution (see STORY-010)
- skills.sh directory registration (see STORY-012)

## Implementation Approach

1. Create `cristos/swain` repo on GitHub
2. Set up directory structure: `skills/spec-management/`, `skills/execution-tracking/`, `skills/governance/`
3. Copy existing skill content from `L3-agents-core/.claude/skills/` (this repo's `.agents/skills/` equivalent)
4. Copy skill content from this repo's `.claude/skills/` where the canonical versions live
5. Verify `npx skills add` discovers all SKILL.md files
6. Add repo-level README, LICENSE, and CI

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-06 | _pending_ | Initial creation |
