---
title: "EPIC-001 Skills Ecosystem Zero-Effort Distribution"
artifact: EPIC-001
status: Proposed
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
parent-vision: VISION-001
success-criteria:
  - "`npx skills add cristoslc/LLM-personal-agent-patterns` (targeting the `L3-agents` branch) installs all active skills into any supported agent"
  - "Skills appear on skills.sh with correct names and descriptions"
  - "Users on Gemini CLI, Cursor, Codex, and other Agent Skills-compatible tools can install and use the skills without modification"
  - "A non-npx-skills installation path remains documented and functional (direct clone / symlink)"
---

# EPIC-001 Skills Ecosystem Zero-Effort Distribution

## Goal / Objective

Make the skills in this repo installable via `npx skills add` and discoverable on skills.sh — the Agent Skills open standard ecosystem — with zero or minimal changes to existing skill content. This is the "Tier 1" distribution path: broad agent compatibility (40+ tools) with no registry submission or manifest files required.

## Scope Boundaries

**In scope:**
- Validating that `npx skills add` discovers and installs skills from the `L3-agents` branch correctly
- Resolving branch strategy: `L3-agents` (subtree split per ADR-001) is the consumer-facing branch, not `main`
- Ensuring SKILL.md frontmatter meets Agent Skills spec requirements (name, description)
- Determining the relationship between `npx skills` and the existing `remote-skill-manager` skill (see SPIKE-002)
- Documenting the installation path for consumers
- Preserving a first-class non-npx-skills path (direct clone, symlink, or fetch script) for users who don't use npx

**Out of scope:**
- Claude Code plugin marketplace (that's EPIC-002)
- Changes to skill content or behavior
- Publishing to any curated/official registry
- npm packaging

## Key Constraints

- **Branch:** The `L3-agents` branch (subtree split per ADR-001) is the distribution branch. On this branch, `.agents/skills/` is at the repo root — a standard discovery path for `npx skills`. The `main` branch has a `L3-agents-standalone/` prefix that would break discovery.
- **No lock-in:** The npx skills path is additive. Users who don't want Node.js tooling must still have a viable installation path.

## Child Specs

_None yet. To be created after SPIKE-002 findings._

## Key Dependencies

- **SPIKE-002** (npx Skills vs Remote Skill Manager): Must resolve whether `remote-skill-manager` wraps, coexists with, or is replaced by `npx skills` before implementation begins.
- **ADR-001** (Subtree Split Distribution Model): The `L3-agents` branch structure is the foundation for this Epic.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-01 | b7245e8 | Initial creation |
