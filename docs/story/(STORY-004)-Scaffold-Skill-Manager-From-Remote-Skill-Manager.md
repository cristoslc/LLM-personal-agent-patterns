---
title: "Scaffold Skill Manager From Remote Skill Manager"
artifact: STORY-004
status: Ready
author: cristos
created: 2026-03-02
last-updated: 2026-03-02
parent-epic: EPIC-003
related:
  - JOURNEY-001
---

# Scaffold Skill Manager From Remote Skill Manager

**As a** framework developer, **I want** `remote-skill-manager` renamed to `skill-manager`, **so that** subsequent stories build on a clean foundation.

## Acceptance Criteria

1. `skill-manager/` exists with all migrated files.
2. `remote-skill-manager/` deleted.
3. Frontmatter updated (name, description, ADR refs).
4. Existing smoke-test passes from new location.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Ready | 2026-03-02 | 21421b0 | Initial creation — skipped Draft, ACs fully defined |
