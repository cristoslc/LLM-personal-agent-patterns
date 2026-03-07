---
title: "Retire Legacy Distribution Infrastructure"
artifact: STORY-011
status: Draft
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
parent-epic: EPIC-006
depends-on:
  - STORY-009
  - STORY-010
addresses: []
execution-tracking: required
---

# STORY-011 Retire Legacy Distribution Infrastructure

**As a** framework maintainer, **I want** to remove the subtree-split GitHub Action, `.distignore`, `update-agents-core` skill, and `skill-manager` skill, **so that** there is a single canonical distribution channel and no dead code to maintain.

## Acceptance Criteria

1. The GitHub Action `split-l3-agents-core.yml` is deleted.
2. The `L3-agents-core/` directory is removed from this repo.
3. The `update-agents-core` skill is removed from `.claude/skills/` (or `.agents/skills/`).
4. The `skill-manager` skill is removed from `.claude/skills/` (or `.agents/skills/`).
5. The `.distignore` file is removed.
6. All references to the retired components are updated or removed from docs and AGENTS.md.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-06 | _pending_ | Initial creation |
