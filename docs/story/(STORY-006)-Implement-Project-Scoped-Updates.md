---
title: "Implement Project-Scoped Updates"
artifact: STORY-006
status: Draft
author: cristos
created: 2026-03-02
last-updated: 2026-03-02
parent-epic: EPIC-003
related:
  - JOURNEY-001
---

# Implement Project-Scoped Updates

**As a** skill consumer, **I want** to update skills using `.source.yml` coordinates, **so that** I have a workaround for npx skills #337.

## Acceptance Criteria

1. `update.sh` reads `.source.yml` for repo/ref.
2. Re-runs `install.sh` with pinned ref.
3. Reports whether anything changed (digest comparison).
4. Smoke test covers update with changes and no-op.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-02 | 21421b0 | Initial creation |
