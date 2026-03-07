---
title: "Single-Command Framework Install"
artifact: STORY-009
status: Draft
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
parent-epic: EPIC-006
depends-on:
  - SPEC-005
addresses: []
execution-tracking: required
---

# STORY-009 Single-Command Framework Install

**As a** developer adopting the agents framework, **I want** to install it with a single `npx skills add cristos/swain` command, **so that** I get all skills and governance without git remote setup, merge ceremonies, or manual file copying.

## Acceptance Criteria

1. Running `npx skills add cristos/swain` in a clean project installs all framework skills into `.claude/skills/`.
2. After installation, `npx skills list` shows spec-management, execution-tracking, and governance as installed skills.
3. The first agent session after install triggers governance setup, injecting routing rules into the project's context file.
4. The entire install-to-working flow completes in under 60 seconds.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-06 | d7c0701 | Initial creation |
