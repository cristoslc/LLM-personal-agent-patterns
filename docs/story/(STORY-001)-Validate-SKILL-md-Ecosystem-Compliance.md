---
title: "Validate SKILL.md Ecosystem Compliance"
artifact: STORY-001
status: Ready
author: cristos
created: 2026-03-02
last-updated: 2026-03-02
parent-epic: EPIC-001
related:
  - JOURNEY-001
---

# Validate SKILL.md Ecosystem Compliance

**As a** skill publisher, **I want** all SKILL.md files on the distribution branch to comply with the Agent Skills spec, **so that** consumers can install them via ecosystem tooling without errors.

## Acceptance Criteria

1. All 4 SKILL.md files have valid `name` (lowercase, hyphens, matches dir, ≤64 chars) and `description` (non-empty, ≤1024 chars).
2. No `name` contains consecutive hyphens or leading/trailing hyphens.
3. `l3-standalone` branch includes all 4 skill directories with their supporting files (`references/`, `scripts/`).

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Ready | 2026-03-02 | 7729fab | Initial creation — skipped Draft, ACs fully defined |
