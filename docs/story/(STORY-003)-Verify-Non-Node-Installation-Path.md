---
title: "Verify Non-Node.js Installation Path"
artifact: STORY-003
status: Implemented
author: cristos
created: 2026-03-02
last-updated: 2026-03-02
parent-epic: EPIC-001
related:
  - JOURNEY-001
depends-on: []
---

# Verify Non-Node.js Installation Path

**As a** skill consumer without Node.js, **I want** to install skills via git clone and symlink, **so that** I have a viable path without npx.

## Acceptance Criteria

1. `git clone --depth=1 -b l3-agents-core` produces `.agents/skills/` with all 4 skills.
2. Symlinking a skill dir into a consumer project makes it functional.
3. `import-agents-standalone.sh` bootstraps full scaffolding into a clean repo.
4. No step requires Node.js.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-02 | 7729fab | Initial creation |
| Implemented | 2026-03-02 | d8c1766 | All 4 ACs pass — clone, symlink, import script all work without Node.js |
