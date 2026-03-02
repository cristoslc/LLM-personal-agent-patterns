---
title: "EPIC-002 Claude Code Plugin Marketplace"
artifact: EPIC-002
status: Abandoned
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
parent-vision: VISION-001
success-criteria:
  - "`/plugin marketplace add cristoslc/LLM-personal-agent-patterns` (targeting the `L3-agents` branch) registers the marketplace in Claude Code"
  - "All active skills are installable via `/plugin install` with correct namespacing"
  - "Auto-updates pull new skill versions when the `L3-agents` branch is updated"
  - "Semantic versioning in plugin.json enables users to track breaking changes"
  - "A non-plugin installation path remains documented and functional"
---

# EPIC-002 Claude Code Plugin Marketplace

## Goal / Objective

Add Claude Code plugin manifests (`marketplace.json` + `plugin.json`) so the skills in this repo are installable via `/plugin marketplace add` with auto-updates, version tracking, and the Discover tab UI. This is the "Tier 2" distribution path: richer install experience with semantic versioning and auto-updates, but Claude Code-specific.

## Scope Boundaries

**In scope:**
- Creating `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json` on the `L3-agents` branch
- Defining versioning strategy (semver in plugin.json, git tags for release channels)
- Determining the relationship between the plugin marketplace and the existing `update-agents-core` and `remote-skill-manager` skills (see SPIKE-003)
- Evaluating whether skills should be bundled as one plugin or split into multiple plugins
- Documenting the marketplace installation path for consumers

**Out of scope:**
- Submission to the official Anthropic marketplace (future consideration)
- npm packaging
- Changes to skill content or behavior
- npx skills compatibility (that's EPIC-001)

## Key Constraints

- **Branch:** Same as EPIC-001 — the `L3-agents` branch is the distribution target. `.claude-plugin/` must be at the repo root on that branch.
- **Coexistence:** The plugin path must coexist with the npx skills path (EPIC-001) and the direct clone/symlink path. One repo, multiple install mechanisms.
- **Versioning:** Plugin marketplace supports semver and release channels (stable vs latest via different refs). This is a capability `npx skills` lacks — it's a key differentiator for the Claude Code path.

## Child Specs

_None yet. To be created after SPIKE-003 findings._

## Key Dependencies

- **SPIKE-003** (Plugin Marketplace vs Update Agents Core): Must resolve whether `update-agents-core` wraps, coexists with, or is replaced by the plugin update mechanism before implementation begins.
- **EPIC-001**: The branch strategy and SKILL.md frontmatter validation done in EPIC-001 are prerequisites — the plugin wraps the same skills.
- **ADR-001** (Subtree Split Distribution Model): The `L3-agents` branch structure is the foundation.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-01 | b7245e8 | Initial creation |
| Abandoned | 2026-03-01 | d4ed11a | Rejected per SPIKE-003 — vendor lock-in to Claude Code violates vendor-agnosticism principle |
