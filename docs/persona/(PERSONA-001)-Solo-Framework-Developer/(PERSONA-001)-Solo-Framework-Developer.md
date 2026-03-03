---
title: "PERSONA-001 Solo Framework Developer"
artifact: PERSONA-001
status: Draft
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
linked-journeys:
  - JOURNEY-001
depends-on: []
---

# PERSONA-001 Solo Framework Developer

## Archetype: The Pragmatic Tinkerer

A developer who builds personal projects and side ventures with AI coding agents. Maintains multiple repositories, each with its own agent configuration. Thinks in systems — enjoys framework design and process structure — but doesn't have a team to justify enterprise tooling. Ships alone, iterates fast, and values tools that get out of the way.

## Goals and Motivations

- **Portable skills:** Encode hard-won operational knowledge (spec workflows, code review patterns, architecture guidance) as reusable skills that work across projects and agent tools.
- **Structured development:** Use specification artifacts and lifecycle tracking to stay organized across sessions — combat the "every session starts from scratch" problem.
- **Ecosystem leverage:** Ride existing tooling (npx skills, Agent Skills standard) rather than building custom infrastructure. Fill gaps with thin scripts, not competing projects.
- **Vendor agnosticism:** Use Claude Code today, Gemini CLI tomorrow, Cursor next week. Skills and specs should be portable, not locked to a single tool.

## Frustrations and Pain Points

- **Project-scoped skill management is immature.** Ecosystem tools optimize for global skill installation; per-project skills lack update tracking and declarative manifests.
- **Scaffolding updates require manual merging.** Keeping framework scaffolding (AGENTS.md, `.agents/` structure) current across projects is a git-merge chore with no automation beyond a custom skill.
- **No cross-project dashboard.** When the same skills are installed in multiple projects, there's no view of which version is where. Drift is silent.
- **Security scanning doesn't exist yet.** Skills are executable prompts with tool access. The ecosystem has no vulnerability scanning.

## Behavioral Patterns

- Works in focused sessions (1-3 hours), typically one project per session.
- Switches between 2-4 active projects weekly.
- Uses Git as the single source of truth — everything is file-based, committed, and auditable.
- Prefers convention over configuration. Will adopt a community standard if it has traction; won't build a custom alternative unless the gap is critical.
- Comfortable with Node.js but also values POSIX-portable tooling.
- Uses Claude Code as the primary agent but tests skills in Gemini CLI and Cursor for portability.

## Context of Use

- Personal laptop (macOS), single developer.
- Multiple Git repositories, each potentially adopting the agents-core framework.
- GitHub for hosting and distribution.
- Sessions driven by Claude Code CLI, occasionally Gemini CLI or Cursor.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-01 | d4ed11a | Initial creation from SPIKE-002/JOURNEY-001 context |
