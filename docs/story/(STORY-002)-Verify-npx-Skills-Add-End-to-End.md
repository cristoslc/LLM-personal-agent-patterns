---
title: "Verify npx Skills Add End-to-End"
artifact: STORY-002
status: Implemented
author: cristos
created: 2026-03-02
last-updated: 2026-03-02
parent-epic: EPIC-001
related:
  - JOURNEY-001
---

# Verify npx Skills Add End-to-End

**As a** skill consumer, **I want** to install skills via `npx skills add cristoslc/LLM-personal-agent-patterns@l3-standalone`, **so that** I can use ecosystem tooling without manual setup.

## Acceptance Criteria

1. CLI discovers all 4 skills from `.agents/skills/`.
2. Installing one skill creates correct files in consumer `.agents/skills/` or `.claude/skills/`.
3. `skills-lock.json` written with correct source.
4. `@l3-standalone` ref pins to distribution branch.
5. After install, skill appears on skills.sh.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-02 | 7729fab | Initial creation |
| Implemented | 2026-03-02 | a29dc73 | ACs 1-4 pass; AC-5 (skills.sh) deferred — indexing requires default branch |
