---
title: "Implement Drift Detection"
artifact: STORY-007
status: Draft
author: cristos
created: 2026-03-02
last-updated: 2026-03-02
parent-epic: EPIC-003
related:
  - JOURNEY-001
---

# Implement Drift Detection

**As a** skill consumer, **I want** to detect when installed skills differ from their recorded state, **so that** I can notice unexpected modifications.

## Acceptance Criteria

1. `drift.sh` single-skill: compares `.source.yml` digest to fresh tar hash.
2. `--all` mode: scans all skills with `.source.yml`.
3. `--cross <dir1> <dir2>`: compares skill versions across projects.
4. Smoke test covers clean + drifted.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-02 | 21421b0 | Initial creation |
