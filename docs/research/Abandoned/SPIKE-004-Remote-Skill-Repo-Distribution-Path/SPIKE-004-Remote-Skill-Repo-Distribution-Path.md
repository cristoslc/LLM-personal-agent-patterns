---
title: "SPIKE-004 Remote Skill Repo Distribution Path"
artifact: SPIKE-004
status: Abandoned
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
question: "Should standalone remote skill repos (like architecture-reference-repo) be distributed as npx skills, Claude Code plugins, or both — and does this change the role of remote-skill-manager for consuming third-party skills?"
gate: Pre-implementation (EPIC-001, EPIC-002)
risks-addressed:
  - "Remote skill repos without a standard distribution path create friction for consumers"
  - "Different distribution mechanisms for first-party vs third-party skills creates inconsistency"
  - "Skill repos that lack SKILL.md files (like architecture-reference-repo today) are invisible to ecosystem tools"
dependencies:
  - "SPIKE-002 npx Skills vs Remote Skill Manager (Planned)"
  - "SPIKE-003 Plugin Marketplace vs Update Agents Core (Planned)"
  - "EPIC-001 Skills Ecosystem Zero-Effort Distribution (Proposed)"
  - "EPIC-002 Claude Code Plugin Marketplace (Proposed)"
blocks:
  - "Distribution guidance for third-party skill repos"
  - "Potential architecture-reference-repo refactor to add SKILL.md and/or plugin manifests"
---

# SPIKE-004 Remote Skill Repo Distribution Path

## Question

Should standalone remote skill repos (like `cristoslc/architecture-reference-repo`) be distributed as npx skills, Claude Code plugins, or both — and does this change the role of `remote-skill-manager` for consuming third-party skills?

### Context

The `architecture-reference-repo` is an example of a skill that lives in its own repository:
- Contains a `skills/architecture-advisor/` directory (no SKILL.md yet — planned)
- Has its own `AGENTS.md` and `.agents/` structure
- Is a standalone knowledge base, not part of the agents-standalone scaffolding
- Currently has no standard installation path — consumers would clone or use `remote-skill-manager` to fetch

This pattern will recur: skill authors (including this project) will create repos that contain one or more skills meant to be consumed by others. The question is what distribution path to recommend.

### Scenarios to evaluate

1. **npx skills only:** Remote skill repos add SKILL.md files and consumers install via `npx skills add owner/repo`. Simplest path, broadest agent compatibility. No provenance tracking unless `remote-skill-manager` is layered on top.
2. **Claude Code plugin only:** Remote skill repos add `.claude-plugin/` manifests. Consumers install via `/plugin marketplace add`. Rich experience (auto-updates, versioning) but Claude Code-specific.
3. **Both (recommended default):** Remote skill repos include both SKILL.md and `.claude-plugin/` manifests. `npx skills` provides the broad path; plugin marketplace provides the rich path. Same content, two install mechanisms.
4. **remote-skill-manager as the consumer-side tool:** Regardless of how repos are published, consumers use `remote-skill-manager` to fetch and track provenance. The ecosystem tools (npx, /plugin) are alternative install mechanisms that bypass provenance.

### Sub-questions

- For the `architecture-reference-repo` specifically: should it add a SKILL.md to `skills/architecture-advisor/`? What about a `.claude-plugin/` manifest?
- If a remote skill repo has its own `AGENTS.md` and scaffolding, does that conflict with the consuming project's `AGENTS.md`? How do plugin boundaries prevent this?
- Should `remote-skill-manager` evolve into a "provenance overlay" that works on top of any install mechanism (npx, /plugin, or direct clone)?

## Go / No-Go Criteria

1. **Reference implementation defined:** A concrete example (using `architecture-reference-repo`) showing the recommended file structure for a distributable skill repo.
2. **Consumer install path documented:** Step-by-step instructions for installing a remote skill via each supported mechanism.
3. **Provenance decision made:** Whether `.source.yml` provenance tracking applies to ecosystem-installed skills or only to direct-fetch installs.
4. **Clear recommendation:** One of the four scenarios is recommended with rationale.

## Pivot Recommendation

If ecosystem tools mature to include provenance/integrity features, adopt **Scenario 3 (Both)** without the `remote-skill-manager` overlay. If provenance remains important and ecosystem tools don't add it, keep `remote-skill-manager` as a provenance layer per **Scenario 4**.

## Findings

_To be populated during Active phase._

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-01 | b7245e8 | Initial creation |
| Abandoned | 2026-03-01 | e48dbba | Questions answered by SPIKE-002, SPIKE-003, SPIKE-005. Remaining question (architecture-reference-repo SKILL.md) belongs in EPIC-001 scope. |
