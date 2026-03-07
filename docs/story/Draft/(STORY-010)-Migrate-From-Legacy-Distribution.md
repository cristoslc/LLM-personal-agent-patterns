---
title: "Migrate from Legacy Distribution"
artifact: STORY-010
status: Draft
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
parent-epic: EPIC-006
depends-on:
  - SPEC-005
  - SPEC-006
addresses: []
execution-tracking: required
---

# STORY-010 Migrate from Legacy Distribution

**As an** existing consumer of the subtree-split distribution (L3-agents-core branch), **I want** a clear migration path to `npx skills add cristoslc/swain`, **so that** I can switch to the new distribution model without losing my customizations or breaking my workflow.

## Acceptance Criteria

1. A migration guide documents the step-by-step process to switch from subtree-split to `npx skills add`.
2. The migration preserves any project-specific customizations in AGENTS.md/CLAUDE.md (governance rules are additive, not destructive).
3. After migration, the `agents-upstream` git remote and `l3-agents-core` merge history can be safely removed.
4. The migration guide is included in the swain repo README or as a dedicated doc.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-06 | d7c0701 | Initial creation |
