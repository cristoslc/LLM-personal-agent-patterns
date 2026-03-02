---
title: "EPIC-003 Skill Lifecycle Manager"
artifact: EPIC-003
status: Complete
author: cristos
created: 2026-03-01
last-updated: 2026-03-02
child-stories:
  - STORY-004
  - STORY-005
  - STORY-006
  - STORY-007
  - STORY-008
parent-vision: VISION-001
success-criteria:
  - "A single `skill-manager` skill covers discovery, safety review, installation, updates, and drift detection"
  - "Discovery surfaces relevant skills from the ecosystem and recommends skills based on project context"
  - "Every install and update includes a safety review step before skill activation"
  - "The skill wraps `npx skills` when available and falls back to POSIX tooling when it's not"
  - "JOURNEY-001 pain points at score <= 2 are addressed or have documented workarounds"
---

# EPIC-003 Skill Lifecycle Manager

## Goal / Objective

Evolve `remote-skill-manager` into `skill-manager` — a full-lifecycle skill management skill covering the entire consumer journey from JOURNEY-001: discovery, safety review, installation, updates with re-review, and cross-project drift detection. Wrap `npx skills` as the ecosystem backend (per SPIKE-002) while adding the value layer the ecosystem doesn't provide.

## Scope Boundaries

**In scope:**
- Renaming `remote-skill-manager` to `skill-manager` to reflect expanded scope
- Discovery: help find relevant skills via `npx skills find` and project-context recommendations
- Safety review: surface security assessments (Gen, Socket, Snyk) at install and update time; gate activation on review
- Installation: wrap `npx skills add` with `.source.yml` provenance stamping (per SPIKE-002 Scenario 2)
- Updates: project-scoped update workflow (workaround for [#337](https://github.com/vercel-labs/skills/issues/337)); re-run safety review on update
- Drift detection: compare `.source.yml` integrity hashes to on-disk state; cross-project drift reporting
- POSIX fallback for all operations when Node.js is unavailable

**Out of scope:**
- Making *this repo's* skills distributable (that's EPIC-001 — the publisher side)
- Framework scaffolding updates (that's `update-agents-core`)
- Building a skill registry or marketplace
- Skill authoring or content changes

## Child Stories

- [STORY-004](../../story/(STORY-004)-Scaffold-Skill-Manager-From-Remote-Skill-Manager.md) — Scaffold skill-manager from remote-skill-manager
- [STORY-005](../../story/(STORY-005)-Implement-Install-With-Safety-Gated-Activation.md) — Implement install with safety-gated activation
- [STORY-006](../../story/(STORY-006)-Implement-Project-Scoped-Updates.md) — Implement project-scoped updates
- [STORY-007](../../story/(STORY-007)-Implement-Drift-Detection.md) — Implement drift detection
- [STORY-008](../../story/(STORY-008)-Add-Discovery-Procedures.md) — Add discovery procedures

## Key Dependencies

- **SPIKE-002** (npx Skills vs Remote Skill Manager) — **Complete**: Wrap recommendation provides the architecture — `skill-manager` wraps `npx skills` with provenance overlay and POSIX fallback.
- **SPIKE-005** (Existing Skill Lifecycle Tools) — **Complete**: No full-lifecycle skill exists in the ecosystem. Build `skill-manager`, borrowing composable patterns (install-audit-rollback, rules-based scanning, diff-scan on update).
- **ADR-003** (Skill Manager Wraps npx Skills with Provenance Overlay) — **Adopted**: Records the wrap + borrow-patterns decision.
- **JOURNEY-001** (Skill Installation Across Projects): Pain points at scores 1-2 define the gaps this Epic must address.
- **ADR-002** (Remote Skills Reference Pattern): `.source.yml` provenance pattern remains the provenance layer.
- **EPIC-001** (Skills Ecosystem Zero-Effort Distribution): Complementary — EPIC-001 is publisher-side (make skills installable), EPIC-003 is consumer-side (manage installed skills).

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-01 | e2769af | Initial creation |
| Active | 2026-03-02 | 21421b0 | 5 child stories created (STORY-004 through STORY-008) |
| Complete | 2026-03-02 | ad5d66e | All 5 stories implemented; 38/38 smoke tests pass |
