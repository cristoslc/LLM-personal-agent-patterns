---
title: "EPIC-006 Promote Agents Core to Standalone Repo"
artifact: EPIC-006
status: Proposed
author: cristos
created: 2026-03-03
last-updated: 2026-03-03
parent-vision: VISION-001
success-criteria:
  - "L3-agents-core content lives in its own Git repo with skills installable via npx skills add"
  - "Governance rules (routing, protocols, artifact hierarchy) distribute as a governance skill within the same repo — no separate distribution channel"
  - "All skills and governance install from a single command: npx skills add <owner>/<repo>"
  - "The framework's own development docs (docs/) never leak to consumers — npx skills only discovers SKILL.md directories"
  - "Existing projects using update-agents-core can migrate to the new distribution model"
depends-on: []
---

# EPIC-006 Promote Agents Core to Standalone Repo

## Goal / Objective

Extract L3-agents-core from the LLM-personal-agent-patterns snippets collection into a standalone repository, adopting Vercel's `npx skills` as the distribution channel. The framework becomes installable via the de facto ecosystem standard rather than a custom rsync pipeline, while preserving the coherence of skills + governance as a single logical unit distributed from a single repo.

## Scope Boundaries

**In scope:**
- New standalone repo creation and naming (nautical theme; candidates include agent-halyard, agent-fairlead, agent-mainsheet, agent-bowline)
- Adopting Vercel's `npx skills` as the distribution channel for all content (skills and governance)
- Structuring skills for the Agent Skills spec (SKILL.md + references/ + scripts/ per skill)
- Creating a `governance` skill that delivers always-on routing, protocols, and conventions — with first-invocation setup to inject governance rules into the agent's context (CLAUDE.md or equivalent)
- Retiring the custom `update-agents-core` skill and `.distignore`-based rsync pipeline
- Retiring the custom `skill-manager` skill in favor of `npx skills`
- Migration path for existing consumers of update-agents-core

**Out of scope:**
- Replacing the spec-management skill with GitHub Spec Kit or OpenSpec (evaluated and rejected — custom artifact hierarchy and lifecycle model are sufficiently differentiated)
- Replacing the execution-tracking skill (no equivalent exists in the ecosystem)
- Cross-agent format translation beyond what `npx skills` provides natively
- Enterprise multi-team distribution or hosted registry
- Modifying the artifact types, lifecycle phases, or hierarchy defined in AGENTS.md (content stays the same; only the delivery mechanism changes)
- Adopting Rulesync (evaluated — unnecessary given the governance-as-skill approach)

## Context

### Why now

L3-agents-core has outgrown its role as a snippet in the patterns collection. It includes a full AGENTS.md governance layer, four skills with templates/scripts/references, and a documentation lifecycle framework. It touches the host project's AGENTS.md — making it more of an opinionated plugin than a code sample.

### Ecosystem landscape (as of 2026-03)

The spec-driven development and agent tooling space has matured rapidly:

| Tool | Stars | Weekly npm downloads | Relevance |
|------|-------|---------------------|-----------|
| GitHub Spec Kit | 73k | — | SDD templates + extension system. Feature-scoped, no vision/ADR/persona. |
| OpenSpec | 27k | — | Artifact DAG + custom schemas. Change-scoped, not product-scoped. |
| BMAD-METHOD | 39k | — | Full lifecycle with agent personas. Opinionated, modular. |
| Vercel `npx skills` | 8k | ~318,000 | De facto standard skill distribution CLI. 40+ agents. skills.sh directory. |
| Anthropic Agent Skills spec | 12k | — | Open standard for SKILL.md format. Reference skills at anthropics/skills (82k stars). |
| SkillKit | 462 | ~460 | Solo-dev alternative to Vercel CLI. Inflated claims, negligible adoption. Rejected. |
| Rulesync | 839 | — | Write-once governance rules, 8+ agent formats. Unnecessary with governance-as-skill approach. |

**Strategic positioning:** This framework is not an SDD tool (competing with Spec Kit/OpenSpec) or a skill marketplace (competing with skills.sh). It is a **governance and coordination layer** — routing, protocols, convention enforcement, and execution tracking — that composes with ecosystem tools for commodity functions. Adopt `npx skills` for distribution; keep the governance core and specialized skills (spec-management, execution-tracking) as the differentiated value.

### Distribution architecture

Vercel's `npx skills` serves as the single distribution channel. All content — skills and governance — lives in one repo as SKILL.md directories. `npx skills` discovers them, symlinks them into the consumer's agent skill directories, and handles cross-agent placement.

```
<repo>/
  skills/
    governance/SKILL.md          -- always-on routing, protocols, hierarchy
    spec-management/SKILL.md     -- artifact lifecycle
    execution-tracking/SKILL.md  -- task backend integration
  docs/                          -- dev-only (invisible to npx skills)
  AGENTS.md                      -- dev-only governance for this repo
  ...
```

Consumer installs:
```bash
npx skills add <owner>/<repo>
```

This symlinks all three skills into `.claude/skills/` (or equivalent for other agents). No two-tier model, no `.devignore`/`.distignore`, no GitHub Action needed — `npx skills` only discovers directories containing SKILL.md files and ignores everything else.

### Governance delivery: agent-as-hook

Neither `npx skills` nor any major skill CLI supports post-install hooks. Instead, the `governance` skill uses the AI agent itself as the setup mechanism:

1. The governance skill's SKILL.md description triggers it to load at session start (via high-priority routing language).
2. On first activation, it checks whether the agent's context file (CLAUDE.md, .cursor/rules/, etc.) contains the governance routing rules.
3. If not, it instructs the agent to append the governance content.
4. Subsequent sessions find the rules already in place and skip setup.

This is more robust than a shell script hook — the agent can detect the platform, check existing config, and write the appropriate format adaptively.

### Two layers of content

| Layer | Content | Delivery | When loaded |
|-------|---------|----------|-------------|
| **Governance** (always-on) | Skill routing table, pre-implementation protocol, artifact hierarchy, session workflow, issue tracking conventions | `governance` skill — injects into agent context on first use | Session start |
| **Skills** (on-demand) | spec-management, execution-tracking | Standard SKILL.md via `npx skills` | When invoked |

## Child Specs

_To be created as this epic is broken down into stories/specs._

Anticipated children:
- Repo creation and initial structure (naming, CI)
- Skill packaging (restructure existing skills into Agent Skills spec format)
- Governance skill (extract AGENTS.md routing/protocol content into a governance SKILL.md with first-use setup)
- Migration guide (update-agents-core consumers to `npx skills add`)
- Retirement of update-agents-core and skill-manager skills
- skills.sh registration and discovery

## Key Dependencies

- **Vercel `npx skills` CLI** — external tool; must support the repo layout with skills in subdirectories. The CLI discovers SKILL.md files by scanning well-known paths (`.claude/skills/`, `skills/`, etc.). Need to confirm our `skills/` directory layout is discoverable.
- **Repo naming decision** — blocks repo creation. Candidates: agent-halyard, agent-fairlead, agent-mainsheet, agent-bowline. Must check skills.sh for naming collisions with existing skill packages.

## Risks

- **Governance-as-skill loading semantics** — the governance skill needs to be always-on context, but skills may be lazily loaded (name + description at startup, full body on invocation). If the governance routing rules aren't visible until the skill is explicitly invoked, the routing table can't influence which skills handle which requests. Needs validation of how Claude Code and other agents handle skill loading.
- **`npx skills` skill discovery paths** — the CLI scans specific directories for SKILL.md files. If our `skills/` layout isn't in the scan list, skills won't be discovered. Needs validation.
- **No skill dependency management** — `npx skills` has no mechanism for one skill to declare dependencies on another. The governance skill can't programmatically ensure spec-management and execution-tracking are also installed. Mitigated by distributing all skills from the same repo (single `npx skills add` installs all).
- **Single-vendor distribution dependency** — if Vercel discontinues `npx skills`, the distribution channel needs replacement. Mitigated by the Agent Skills spec being an open standard — alternative CLIs exist and the SKILL.md format is vendor-neutral.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-03 | 19c8f96 | Initial creation from design discussion |
