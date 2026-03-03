---
title: "EPIC-006 Promote Agents Core to Standalone Repo"
artifact: EPIC-006
status: Proposed
author: cristos
created: 2026-03-03
last-updated: 2026-03-03
parent-vision: VISION-001
success-criteria:
  - "L3-agents-core content lives in its own Git repo with skills publishable to SkillKit"
  - "Governance rules (routing, protocols, artifact hierarchy) distribute via Rulesync or direct CLAUDE.md injection with graceful fallback"
  - "Skills and governance install from a single entry point — consumers do not need to know about two distribution channels"
  - "The framework's own development docs (docs/) never leak to consumers regardless of distribution channel"
  - "Existing projects using update-agents-core can migrate to the new distribution model"
depends-on: []
---

# EPIC-006 Promote Agents Core to Standalone Repo

## Goal / Objective

Extract L3-agents-core from the LLM-personal-agent-patterns snippets collection into a standalone repository, adopting SkillKit for cross-platform skill distribution and Rulesync for governance rule delivery. The framework becomes installable via standard ecosystem tools rather than a custom rsync pipeline, while preserving the coherence of skills + governance as a single logical unit.

## Scope Boundaries

**In scope:**
- New standalone repo creation and naming (nautical theme; candidates include agent-halyard, agent-fairlead, agent-mainsheet, agent-bowline)
- Adopting SkillKit as the distribution channel for skills (spec-management, execution-tracking)
- Adopting Rulesync (Option B) as the delivery mechanism for governance rules, bundled within a SkillKit-distributed package with graceful fallback to direct CLAUDE.md/AGENTS.md injection
- Retiring the custom `update-agents-core` skill and `.distignore`-based rsync pipeline
- Retiring the custom `skill-manager` skill in favor of SkillKit
- Restructuring AGENTS.md content into governance rules (always-on context via Rulesync) vs. skill capabilities (on-demand via SkillKit)
- Migration path for existing consumers of update-agents-core

**Out of scope:**
- Replacing the spec-management skill with GitHub Spec Kit or OpenSpec (evaluated and rejected — custom artifact hierarchy and lifecycle model are sufficiently differentiated)
- Replacing the execution-tracking skill (no equivalent exists in the ecosystem)
- Cross-agent format translation for skills beyond what SkillKit provides natively
- Enterprise multi-team distribution or hosted registry
- Modifying the artifact types, lifecycle phases, or hierarchy defined in AGENTS.md (content stays the same; only the delivery mechanism changes)

## Context

### Why now

L3-agents-core has outgrown its role as a snippet in the patterns collection. It includes a full AGENTS.md governance layer, four skills with templates/scripts/references, and a documentation lifecycle framework. It touches the host project's AGENTS.md — making it more of an opinionated plugin than a code sample.

### Ecosystem landscape (as of 2026-03)

The spec-driven development and agent tooling space has matured rapidly:

| Tool | Stars | Relevance |
|------|-------|-----------|
| GitHub Spec Kit | 73k | SDD templates + extension system. Feature-scoped, no vision/ADR/persona. |
| OpenSpec | 27k | Artifact DAG + custom schemas. Change-scoped, not product-scoped. |
| BMAD-METHOD | 39k | Full lifecycle with agent personas. Opinionated, modular. |
| SkillKit | 461 | Cross-platform skill distribution to 44 agents. Marketplace search. |
| Rulesync | 839 | Write-once governance rules, generate for 8+ agent formats. |
| agnix | 69 | LSP linter for CLAUDE.md/AGENTS.md/SKILL.md validation. |

**Strategic positioning:** This framework is not an SDD tool (competing with Spec Kit/OpenSpec) or a skill marketplace (competing with SkillKit). It is a **governance and coordination layer** — routing, protocols, convention enforcement, and execution tracking — that composes with ecosystem tools for commodity functions. Adopt SkillKit and Rulesync for distribution; keep the governance core and specialized skills (spec-management, execution-tracking) as the differentiated value.

### Distribution architecture (Option B)

SkillKit serves as the single consumer-facing entry point. Governance rules are bundled inside the SkillKit package as `.rulesync/` source files. On install:

1. Skills land in the consumer's agent-specific skill directories (`.claude/skills/`, `.cursor/skills/`, etc.) via SkillKit's native translation.
2. If Rulesync is available, `rulesync generate` produces CLAUDE.md/AGENTS.md/.cursor/rules/ from the bundled `.rulesync/` sources.
3. If Rulesync is not available, the bootstrap skill writes governance content directly to CLAUDE.md (or the agent's equivalent).

This preserves coherence (one install, one repo) while leveraging established distribution channels.

### Two layers of content

| Layer | Content | Delivery | Lifecycle |
|-------|---------|----------|-----------|
| **Governance rules** (always-on) | Skill routing table, pre-implementation protocol, artifact hierarchy, session workflow, issue tracking conventions | Rulesync (with direct-write fallback) | Loaded at session start; governs all agent behavior |
| **Skills** (on-demand) | spec-management, execution-tracking | SkillKit | Loaded when invoked; provide operational capabilities |

## Child Specs

_To be created as this epic is broken down into stories/specs._

Anticipated children:
- Repo creation and initial structure (naming, branching, CI)
- SkillKit integration (packaging skills for SkillKit distribution, marketplace registration)
- Rulesync integration (governance rule authoring in `.rulesync/` format, bootstrap fallback)
- AGENTS.md decomposition (split current monolith into governance rules vs. skill content)
- Migration guide (update-agents-core consumers to SkillKit + Rulesync)
- Retirement of update-agents-core and skill-manager skills

## Key Dependencies

- **SkillKit** — external tool; must support the distribution model (post-install hooks or bootstrap skill pattern). Needs evaluation of SkillKit vs. Vercel's `npx skills` to confirm SkillKit is the right choice.
- **Rulesync** — external tool; must support bundled `.rulesync/` sources within a SkillKit package, or the fallback path must be robust.
- **Repo naming decision** — blocks repo creation. Candidates: agent-halyard, agent-fairlead, agent-mainsheet, agent-bowline.

## Risks

- **SkillKit may not support post-install hooks** — the "Option B" bootstrap pattern requires some mechanism to trigger Rulesync generation on install. If SkillKit doesn't support this, the fallback is a manual setup step or a bootstrap skill the user invokes once.
- **Rulesync format may not accommodate complex governance content** — the current AGENTS.md includes structured tables, Mermaid diagrams, and multi-level hierarchy definitions. Rulesync may expect simpler rule sets. Needs validation.
- **Two-tool dependency for consumers** — even with graceful fallback, the full experience requires both SkillKit and Rulesync. If either project becomes unmaintained, the distribution layer needs replacement. Mitigated by the direct-write fallback path.
- **SkillKit vs. Vercel `npx skills` uncertainty** — SkillKit was identified as the leading option but Vercel's alternative needs evaluation before committing. This is a gating research item.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-03 | 19c8f96 | Initial creation from design discussion |
