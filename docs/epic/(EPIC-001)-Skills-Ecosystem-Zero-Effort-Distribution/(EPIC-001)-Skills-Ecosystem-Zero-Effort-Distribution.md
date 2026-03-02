---
title: "EPIC-001 Skills Ecosystem Zero-Effort Distribution"
artifact: EPIC-001
status: Complete
author: cristos
created: 2026-03-01
last-updated: 2026-03-02
parent-vision: VISION-001
success-criteria:
  - "Framework skills are installable by any consumer using ecosystem tooling across 40+ agent platforms"
  - "Skills are discoverable on skills.sh without manual registry submission"
  - "A non-Node.js installation path remains viable for consumers without npx"
  - "The installation experience addresses the pain points surfaced in JOURNEY-001"
---

# EPIC-001 Skills Ecosystem Zero-Effort Distribution

## Goal / Objective

Ride the Agent Skills ecosystem for skill distribution rather than maintaining custom installation infrastructure. Consumers should be able to install framework skills using the same tooling they use for any other skill, across any agent platform. Fill ecosystem gaps with thin wrappers and scripts — don't build competing tools.

## Scope Boundaries

**In scope:**
- Ecosystem-based skill distribution using the Agent Skills open standard
- Ensuring this repo's skills are discoverable and installable via `npx skills add` from the `l3-standalone` branch
- Maintaining a viable non-Node.js installation path (clone/symlink)
- Validating that SKILL.md files meet Agent Skills spec requirements

**Out of scope:**
- Vendor-specific distribution channels (rejected per SPIKE-003)
- Building a competing package manager or skill registry
- Changes to skill content or behavior — this is about distribution, not authoring
- Framework scaffolding updates (that's `update-agents-core` territory)

## Child Specs

- [STORY-001](../../story/(STORY-001)-Validate-SKILL-md-Ecosystem-Compliance.md) — Validate SKILL.md Ecosystem Compliance
- [STORY-002](../../story/(STORY-002)-Verify-npx-Skills-Add-End-to-End.md) — Verify npx Skills Add End-to-End
- [STORY-003](../../story/(STORY-003)-Verify-Non-Node-Installation-Path.md) — Verify Non-Node.js Installation Path

## Key Dependencies

- **ADR-001** (Subtree Split Distribution Model): The `l3-standalone` branch is the distribution branch.
- **SPIKE-003** (Complete): Plugins rejected. Vendor-agnostic path only.
- **EPIC-003** (Skill Lifecycle Manager): Complementary — EPIC-001 is publisher-side, EPIC-003 is consumer-side (`skill-manager` wrapping `npx skills`).

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-01 | b7245e8 | Initial creation |
| Active | 2026-03-02 | 89c2fec | All prerequisite spikes complete; child stories ready to create |
| Complete | 2026-03-02 | f7226c2 | All 3 stories Implemented; all 4 success criteria met |
