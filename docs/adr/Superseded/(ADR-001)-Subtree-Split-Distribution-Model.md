---
title: "Subtree Split Distribution Model"
artifact: ADR-001
status: Superseded
superseded-by: ADR-005
author: cristoslc
created: 2026-02-26
last-updated: 2026-03-06
depends-on: []
---

# ADR-001: Subtree Split Distribution Model

## Context

The `L3-agents-core` scaffolding (AGENTS.md, `.agents/` skills directory) is maintained in a monorepo (`LLM-personal-agent-patterns`) but needs to be consumable by independent project repos. Projects need to:

1. Pull the scaffolding into their **project root** (not a subdirectory) — `AGENTS.md` must be the project's `AGENTS.md`.
2. Receive updates from upstream when the scaffolding evolves.
3. Customize freely after import (fork-and-diverge is acceptable; pushing back upstream is not required).

## Decision

Use `git subtree split` to publish a `l3-agents-core` branch containing the L3 folder's contents at root level. Consumer projects add this as a git remote and merge into their root.

**Source side:**
- A GitHub Action runs `git subtree split --prefix=L3-agents-core -b l3-agents-core` on every push to main that touches the L3 directory, force-pushing the result.
- A self-deleting `import-agents-standalone.sh` script is included on the branch for first-time setup.

**Consumer side:**
- First import: `git remote add agents-upstream <url>` → `git fetch` → `git merge --allow-unrelated-histories --squash`.
- Updates: `git fetch` → `git merge --squash`, resolving conflicts where the project has diverged.

## Alternatives Considered

### Git submodules
- Files land in a subdirectory, not at root — breaks the requirement that `AGENTS.md` is the project's top-level context file.
- Submodule ceremony (detached HEAD, `--recurse-submodules` in CI, forgotten `--init`) adds friction for a config-file use case.

### Git subtree add with prefix
- `git subtree add --prefix=<dir>` nests files under a directory. There is no `--prefix=.` option.
- Even with a subdirectory, we'd need symlinks to surface `AGENTS.md` at root — fragile and platform-dependent.

### Sparse-checkout submodule
- Submodule pointing at the monorepo with sparse-checkout filtering to only materialize the L3 folder.
- Still clones full history. Sparse-checkout config doesn't propagate to other cloners without additional setup.
- Results in a nested path (`.agents-upstream/L3-agents-core/`).

### Separate standalone repository
- Fork L3 into its own repo. Consumer adds as submodule or subtree.
- Cleanest consumer experience, but doubles maintenance burden — changes must be authored or mirrored in two repos.
- The GitHub Action approach achieves the same result (standalone branch with root-level files) without a separate repo.

### Package manager distribution (npm, pip, Homebrew)
- Overkill for configuration files and Markdown. No build step, no runtime dependency.

## Consequences

- **Positive:** Projects get a clean one-command import. Updates are standard git merges. No submodule friction. No separate repo to maintain.
- **Positive:** The self-deleting import script reduces consumer-side setup to a single curl/bash invocation.
- **Negative:** Force-pushing the split branch means consumer refs go stale — they must always fetch before merging.
- **Negative:** Projects that heavily customize AGENTS.md will face merge conflicts on updates. This is accepted as the right tradeoff (fork-and-diverge model).
- **Negative:** The GitHub Action adds CI minutes on every L3-touching push. This is negligible for the current push frequency.

### Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Adopted | 2026-02-26 | de5f1a3 | Branch and Action already shipped; writing ADR retroactively |
| Superseded | 2026-03-06 | fbfc4ee | Superseded by ADR-005 (npx Skills Distribution Model) |
