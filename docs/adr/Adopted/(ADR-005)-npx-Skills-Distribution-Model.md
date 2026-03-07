---
title: "npx Skills Distribution Model"
artifact: ADR-005
status: Adopted
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
linked-epics:
  - EPIC-006
depends-on: []
supersedes: ADR-001
---

# ADR-005: npx Skills Distribution Model

## Context

ADR-001 established a `git subtree split` pipeline to distribute L3-agents-core: a GitHub Action splits the `L3-agents-core/` directory into a standalone branch, and consumers merge it into their project root. This works but has friction:

- Consumers must add a git remote, fetch, and merge with `--allow-unrelated-histories` — unfamiliar ceremony for a config-file use case.
- Updates require `git merge --squash` with manual conflict resolution.
- The subtree split Action force-pushes, making consumer refs stale.
- A custom `.distignore` file and rsync pipeline filter dev-only content — bespoke tooling that must be maintained.
- The `skill-manager` skill (ADR-003) wraps `npx skills` but adds a provenance overlay layer that duplicates what the ecosystem now handles natively.

Meanwhile, Vercel's `npx skills` CLI has become the de facto standard for agent skill distribution (~318k weekly npm downloads, 40+ agent support). The Anthropic Agent Skills spec defines the SKILL.md format as an open standard. Distribution through this channel is zero-friction for consumers and eliminates all custom infrastructure.

## Decision

Replace the subtree split pipeline with direct distribution via `npx skills` from a standalone `cristos/swain` repository.

**What changes:**
- L3-agents-core content moves to the `cristos/swain` repo, structured as SKILL.md directories under `skills/`
- Consumers install with `npx skills add cristos/swain` — one command, no git ceremony
- A `governance` skill delivers always-on routing rules, protocols, and conventions via first-use agent-driven setup
- The GitHub Action (`split-l3-agents-core.yml`), `.distignore`, `update-agents-core` skill, and `skill-manager` skill are retired
- The `L3-agents-core/` directory is removed from this repo after migration

**What stays the same:**
- All skills and governance distribute from a single repo (single install command)
- Content (artifact types, lifecycle phases, routing rules) is unchanged — only the delivery mechanism changes
- The framework's dev docs (`docs/`) remain invisible to consumers (`npx skills` only discovers SKILL.md directories)

## Alternatives Considered

### Keep subtree split with improved tooling
- Could add a CLI wrapper to simplify the consumer-side merge ceremony.
- Still requires git remote management, conflict resolution on updates, and maintaining the GitHub Action.
- Rejected: invests in proprietary infrastructure when the ecosystem has standardized on a better solution.

### Git submodules pointing to swain repo
- Clean separation, explicit version pinning.
- But: files land in a subdirectory, not at root. AGENTS.md must be the project's top-level context file. Symlinks are fragile and platform-dependent.
- Rejected: same fundamental problem as in ADR-001's evaluation.

### Publish as npm package
- Familiar to JS developers, good versioning story.
- But: these are configuration files and Markdown, not runtime dependencies. `npm install` puts them in `node_modules/`, not at project root. Post-install scripts could copy files, but that's fragile.
- Rejected: `npx skills` is purpose-built for this exact use case.

### Maintain both channels (subtree split + npx skills)
- Provides a migration period where both work.
- But: doubles maintenance burden indefinitely. Consumers won't migrate until the old channel is removed.
- Rejected: clean cut with a migration guide is simpler.

## Consequences

- **Positive:** Consumer installation drops from 4 commands (remote add, fetch, merge, cleanup) to 1 (`npx skills add cristos/swain`).
- **Positive:** Updates via `npx skills update` — no merge conflicts, no stale refs.
- **Positive:** Eliminates all custom distribution infrastructure: GitHub Action, `.distignore`, `update-agents-core` skill, `skill-manager` skill.
- **Positive:** Framework becomes discoverable in the skills.sh ecosystem directory.
- **Negative:** Depends on Vercel maintaining `npx skills`. Mitigated by the Agent Skills spec being an open standard — alternative CLIs can emerge.
- **Negative:** Existing consumers of the subtree split must migrate. Mitigated by a migration guide (one-time, ~5 minutes).
- **Negative:** Governance delivery relies on the AI agent itself injecting rules on first use, since `npx skills` has no post-install hooks. This is a novel pattern that needs validation.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Adopted | 2026-03-06 | fbfc4ee | Supersedes ADR-001; decision captured in EPIC-006 |
