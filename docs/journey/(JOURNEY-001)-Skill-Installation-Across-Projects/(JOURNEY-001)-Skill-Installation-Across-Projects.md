---
title: "JOURNEY-001 Skill Installation Across Projects"
artifact: JOURNEY-001
status: Draft
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
parent-vision: VISION-001
personas:
  - "PERSONA-001 Solo Framework Developer"
related:
  - "SPIKE-002 npx Skills vs Remote Skill Manager"
  - "EPIC-001 Skills Ecosystem Zero-Effort Distribution"
---

# JOURNEY-001 Skill Installation Across Projects

## Persona

**[PERSONA-001 Solo Framework Developer](../../persona/(PERSONA-001)-Solo-Framework-Developer/(PERSONA-001)-Solo-Framework-Developer.md)** — the Pragmatic Tinkerer. Maintains an agents-standalone framework with shared skills. Publishes skills from a monorepo (subtree-split to a `L3-agents` distribution branch). Consumes third-party skills into multiple personal projects. Uses Claude Code primarily, sometimes Gemini CLI or Cursor. Has Node.js available. Not building infrastructure — wants to ride ecosystem tooling and fill gaps.

## Goal

Install shared skills into projects, keep them current, and understand what's installed — using ecosystem tools (`npx skills`) rather than maintaining custom installation infrastructure.

## Steps / Stages

### Discovery

The developer hears about a skill or searches for one to solve a problem.

- **Browse skills.sh directory:** The skills.sh site surfaces skills by install count and category. Works for popular skills but long-tail discovery is limited — no semantic search, just name matching and keyword tags. Adequate for now.
- **Read skill docs before installing:** Most skills are a single SKILL.md with no README or usage examples on GitHub. You commit to installing before you can really evaluate — the full instructions only make sense in-context with an agent.

### First Install

The developer installs a skill into a project for the first time.

- **Run `npx skills add owner/repo@L3-agents`:** Clean one-liner. Branch specification via `@ref` works. The CLI discovers SKILL.md files in standard locations (`.agents/skills/`, `skills/`, `.claude/skills/`). Installs to the correct agent-specific directory. This is the happy path.
- **Choose project scope:** The interactive prompt asks project vs global. Project-scoped installation puts skills in `.claude/skills/` (for Claude Code) and creates a `skills-lock.json` at the project root. This is the right default for per-project skills.
- **Verify skill is active:** After install, the skill appears in Claude Code's skill list and can be invoked. No manual configuration needed.

### Day-to-Day Use

The developer uses installed skills in their agent workflow.

- **Invoke skill in Claude Code:** Skills auto-discovered on session start. Invocation is seamless — Claude matches the skill's description to the task context. No friction here.
- **Invoke skill in other agents:** `npx skills` installs to agent-specific directories. Gemini CLI, Cursor, Codex all pick up skills from their expected paths. Cross-agent portability works.

### Updates

The developer wants to pull the latest version of an installed skill.

- **Check for updates:** `npx skills check` works for globally installed skills. It posts skill hashes to the update API and compares against GitHub tree SHAs.
- **Update a globally installed skill:** `npx skills update` pulls latest. Works as expected.
- **Update a project-scoped skill:** **Broken.** `npx skills update` does not track project-scoped installations. [Issue #337](https://github.com/vercel-labs/skills/issues/337) is open but unresolved. The workaround is to re-run `npx skills add` (idempotent) — but you have to know to do this, and there's no notification that an update is available.

  > **Pain point:** This is the biggest gap. Per-project skills are the natural model for team repos and framework adopters, but the update story is missing. You're stuck manually re-adding skills or writing a wrapper script.

- **Pin to a specific version:** Lock file tracks the `ref` used at install time. You can install at a tag (`@v1.0.0`) and it stays pinned. But there's no `npx skills pin` command — you have to remember the ref syntax.

### Multi-Project Sync

The developer uses the same skills across multiple projects and wants them consistent.

- **Install in a new project:** Repeat `npx skills add` in each project. No friction on first install. `skills-lock.json` is committed to version control, and `npx skills experimental_install` can restore from it — but it restores to the default branch (loses `@ref` pinning) and installs to all agents (ignores original agent selection).

  > **Pain point:** Lockfile restore exists but is experimental and lossy. `@ref` pinning — critical for framework skills on a non-default branch like `L3-agents` — is not persisted in `skills-lock.json`. A fresh clone restoring via `experimental_install` would get the wrong branch.

- **Keep skills in sync:** No cross-project view. You update one project and forget the others. Drift is silent.

  > **Pain point:** Skills drift across projects with no notification. A simple `npx skills sync` or even a lockfile-based install would solve this, but neither exists today.

### Provenance & Security

The developer wants to understand what's installed, where it came from, and whether it's safe.

- **Verify skill source:** `skills-lock.json` records `source` (owner/repo) and `ref`. Adequate for basic "where did this come from" questions.
- **Detect local modifications:** The lock file stores a `skillFolderHash` (GitHub tree SHA). In principle you could compare, but there's no CLI command to check drift on project-scoped skills.

  > **Pain point:** No `npx skills audit` or drift-check command. The data is in the lock file but there's no user-facing workflow to surface it.

- **Scan for vulnerabilities:** As of v1.4.3, `npx skills add` shows install-time risk assessments from three providers (Gen, Socket, Snyk). This is a significant improvement — security visibility exists at install time. However, there's no post-install `npx skills audit` command for ongoing monitoring.

  > **Pain point (partially addressed):** Install-time scanning now exists, reducing the "flying blind" problem. The remaining gap is ongoing monitoring — no way to re-scan installed skills without re-installing them.

```mermaid
journey
    title Skill Installation Across Projects
    section Discovery
      Browse skills.sh directory: 4: Solo Developer
      Read skill docs before installing: 3: Solo Developer
    section First Install
      Run npx skills add: 5: Solo Developer
      Choose project scope: 4: Solo Developer
      Verify skill is active: 5: Solo Developer
    section Day-to-Day Use
      Invoke skill in Claude Code: 5: Solo Developer
      Invoke skill in other agents: 4: Solo Developer
    section Updates
      Check for available updates: 3: Solo Developer
      Update globally installed skill: 4: Solo Developer
      Update project-scoped skill: 1: Solo Developer
      Pin to specific version: 3: Solo Developer
    section Multi-Project Sync
      Install in a new project: 4: Solo Developer
      Keep skills in sync across projects: 2: Solo Developer
      Know which project has which version: 2: Solo Developer
    section Provenance and Security
      Verify skill source: 3: Solo Developer
      Detect local modifications: 2: Solo Developer
      Scan for vulnerabilities: 2: Solo Developer
```

## Pain Points Summary

| Pain Point | Score | Stage | Root Cause | Opportunity |
|---|---|---|---|---|
| Project-scoped skill updates broken | 1 | Updates | `npx skills update` only tracks global installs ([#337](https://github.com/vercel-labs/skills/issues/337)) | Track upstream issue; workaround: re-run `npx skills add` |
| No post-install vulnerability scanning | 2 | Provenance | Install-time scanning exists (Gen, Socket, Snyk) but no `npx skills audit` for ongoing monitoring | `.source.yml` provenance could feed future post-install scanners |
| Lockfile restore is experimental and lossy | 2 | Multi-Project | `experimental_install` exists but loses `@ref` pinning and agent selection | Wrapper can restore from `.source.yml` refs for full fidelity |
| Skills drift across projects silently | 2 | Multi-Project | No cross-project awareness | Script or Makefile pattern: loop over projects, run `npx skills add` |
| No drift detection CLI | 2 | Provenance | Hash data in lock file but no user command | Could layer `.source.yml` stamping as post-install hook; or contribute `npx skills check --project` |

## Opportunities

1. **Project-scoped update workaround.** Re-running `npx skills add` is idempotent and can serve as a manual update path until [#337](https://github.com/vercel-labs/skills/issues/337) is resolved. A thin wrapper could automate this.

2. **Ref-aware lockfile restore.** `experimental_install` exists but loses `@ref` pinning. A wrapper that restores from `.source.yml` refs (which do store the pinned branch/tag/SHA) would provide full-fidelity restore for clones and new projects.

3. **Cross-project drift visibility.** A lightweight CLI or script that compares `skills-lock.json` across sibling projects would surface version differences without requiring centralized infrastructure.

4. **Provenance as post-install overlay.** `.source.yml` stamping could run after any install method, positioning installed skills for future security scanning tools as they emerge.

5. **Ecosystem contribution.** The highest-impact upstream fix is [#337](https://github.com/vercel-labs/skills/issues/337) (project-scoped updates). If resolved, two of the five pain points disappear.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-01 | 5a4251f | Initial creation from SPIKE-002 investigation |
