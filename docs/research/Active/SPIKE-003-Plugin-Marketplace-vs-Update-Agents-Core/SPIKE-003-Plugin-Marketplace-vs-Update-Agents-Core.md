---
title: "SPIKE-003 Plugin Marketplace vs Update Agents Core"
artifact: SPIKE-003
status: Active
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
question: "Does the Claude Code plugin marketplace mechanism supersede `update-agents-core` and/or `remote-skill-manager`, should those skills be refactored to use `/plugin` as their underlying mechanism, or should they coexist?"
gate: Pre-implementation (EPIC-002)
risks-addressed:
  - "Plugin auto-updates may conflict with the manual git-merge approach in update-agents-core"
  - "Two update mechanisms for the same files creates confusion about which is authoritative"
  - "Dropping update-agents-core removes support for non-Claude-Code agents that adopt this framework"
dependencies:
  - "SPIKE-002 npx Skills vs Remote Skill Manager (Planned) — the skill-level decision informs the scaffolding-level decision"
  - "ADR-001 Subtree Split Distribution Model (Adopted)"
  - "ADR-002 Remote Skills Reference Pattern (Adopted)"
  - "EPIC-002 Claude Code Plugin Marketplace (Proposed)"
blocks:
  - "EPIC-002 implementation — cannot finalize plugin structure without this decision"
  - "Potential refactor or deprecation of update-agents-core skill"
---

# SPIKE-003 Plugin Marketplace vs Update Agents Core

## Question

Does the Claude Code plugin marketplace mechanism supersede `update-agents-core` and/or `remote-skill-manager`, should those skills be refactored to use `/plugin` as their underlying mechanism, or should they coexist?

### Context

The current update path uses two custom skills:

**`update-agents-core`** handles scaffolding updates:
- Fetches from `agents-upstream` git remote (shallow fetch of `l3-standalone` branch)
- Squash-merges with `--allow-unrelated-histories`
- Resolves conflicts: `.agents/` files accept upstream; `AGENTS.md` reconciles
- Manual trigger only — user invokes the skill explicitly

**`remote-skill-manager`** handles individual skill installation:
- Fetches specific skill directories from remote repos via bash script
- Stamps `.source.yml` provenance manifests
- Supports drift detection via integrity hashes

The **Claude Code plugin marketplace** provides:
- `/plugin marketplace add owner/repo` — registers a marketplace source
- `/plugin install plugin@marketplace` — installs a plugin (which bundles skills)
- Auto-updates on Claude Code startup (configurable per marketplace)
- Semantic versioning with release channels (ref/SHA pinning)
- `.claude-plugin/marketplace.json` + `plugin.json` manifests
- Scoped installation: User, Project, Local, or Managed

Key tensions:
- `update-agents-core` updates **scaffolding** (AGENTS.md, .agents/ structure, skill templates) — not just skills. Plugin marketplace updates **plugins** (skill bundles). These are overlapping but not identical scopes.
- Plugin auto-updates replace pull-based merging but don't handle conflict resolution on files the consumer may have customized (like AGENTS.md).
- Plugin marketplace is Claude Code-specific; `update-agents-core` works in any git environment.

### Scenarios to evaluate

1. **Replace both:** Plugin marketplace becomes the sole update mechanism for Claude Code users. `update-agents-core` and `remote-skill-manager` are deprecated. Non-Claude users use `npx skills` (EPIC-001) or direct clone.
2. **Plugin for skills, git-merge for scaffolding:** Plugin marketplace handles skill distribution and updates. `update-agents-core` continues to handle AGENTS.md and structural scaffolding updates (which require merge conflict resolution that plugins can't do). `remote-skill-manager` is deprecated in favor of the plugin path.
3. **Refactor to use /plugin internally:** `update-agents-core` is refactored to invoke `/plugin` commands for skill updates while keeping its git-merge workflow for scaffolding files. `remote-skill-manager` delegates to `/plugin install` when available, falls back to bash fetch otherwise.
4. **Coexist independently:** Plugin marketplace is an additive distribution channel. `update-agents-core` and `remote-skill-manager` continue to work as-is for users who prefer the git-native path.

### Sub-questions

- Does plugin auto-update handle the AGENTS.md merge problem, or is that inherently a git-merge task?
- If skills are distributed as a plugin, should AGENTS.md and `.agents/README.md` scaffolding also be part of the plugin, or do they remain git-merge territory?
- Can a plugin's `hooks.json` or `settings.json` replicate what `update-agents-core` does for conflict resolution?

## Go / No-Go Criteria

1. **Scope boundary defined:** Clear answer on which files are "plugin territory" (skills) vs "scaffolding territory" (AGENTS.md, .agents/ structure, templates).
2. **AGENTS.md update path resolved:** Concrete recommendation for how AGENTS.md updates flow to consumers — via plugin, via git merge, or via a hybrid.
3. **Non-Claude-Code path preserved:** Confirm that users on Gemini CLI, Cursor, etc. have a viable update path regardless of the plugin decision.
4. **Clear recommendation:** One of the four scenarios is recommended with rationale.

## Pivot Recommendation

If no scenario cleanly resolves the scope boundary between skills and scaffolding, adopt **Scenario 2 (Plugin for skills, git-merge for scaffolding)** — it separates the two concerns and avoids forcing the plugin mechanism to handle merge conflicts it wasn't designed for.

## Findings

### Plugin scope boundary (critical finding)

The Claude Code plugin mechanism **cannot modify files outside the plugin cache**. Specifically:

| File/directory | Plugin can manage? | Why |
|---|---|---|
| `skills/` (in plugin) | Yes | Core plugin content, auto-discovered and namespaced |
| `commands/`, `agents/`, `hooks/` (in plugin) | Yes | Standard plugin components |
| `AGENTS.md` (project root) | **No** | Plugins are cached in `~/.claude/plugins/cache/`, not merged into the project tree |
| `.agents/` directory (project) | **No** | Project-level scaffolding is outside plugin scope |
| `.claude/settings.json` | Partially — only `enabledPlugins` and `extraKnownMarketplaces` keys | Modified at install time, not by plugin content |

This is the decisive finding: **plugins distribute reusable components; they do not manage project configuration.** The AGENTS.md merge problem is inherently a git-merge task.

### Sub-question answers

**Does plugin auto-update handle the AGENTS.md merge problem?**
No. Plugin auto-update is a full overwrite of the cached plugin directory. It has no merge conflict resolution. AGENTS.md requires reconciliation (upstream structure + local additions), which is a git-merge workflow.

**Should AGENTS.md and scaffolding be part of the plugin?**
No. Even if included, they'd be cached in the plugin directory, not placed at the project root. Plugin components are namespaced (`/plugin-name:skill-name`) and isolated. Project-level configuration must live in the project tree.

**Can hooks.json or settings.json replicate update-agents-core?**
No. `hooks.json` defines event handlers (pre-tool-use, post-tool-use). `settings.json` currently only supports the `agent` key for default agent mode. Neither can perform git operations or file modifications outside the plugin directory.

### Plugin marketplace capabilities for skill distribution

| Capability | Plugin marketplace | Comparison to `remote-skill-manager` |
|---|---|---|
| Install skills | `/plugin install name@marketplace` | Equivalent; richer UI |
| Auto-update | On Claude Code startup (configurable) | Not available — manual re-fetch only |
| Versioning | Semantic versioning in `plugin.json` + release channels via ref/SHA | Git ref pinning only |
| Multi-skill bundles | Yes — `skills/` directory with multiple SKILL.md | Fetches one skill at a time |
| Branch specification | **Not supported** for GitHub shorthand (`owner/repo`); only via full Git URL + `#ref` ([feature request #23551](https://github.com/anthropics/claude-code/issues/23551)) | Full ref support |
| Provenance | None | `.source.yml` with integrity hash |
| Agent support | Claude Code only | Any environment with POSIX tools |
| Skill namespacing | `/plugin-name:skill-name` (avoids conflicts with project skills) | Installed directly as project skills (may conflict) |

### Branch constraint (significant for EPIC-002)

Claude Code's `/plugin marketplace add owner/repo` syntax **does not support branch specification**. It always uses the repo's default branch. Since the `L3-agents` branch is the distribution branch (not `main`), consumers would need to either:

1. Use full Git URL: `/plugin marketplace add https://github.com/cristoslc/LLM-personal-agent-patterns.git#L3-agents`
2. Wait for feature request #23551 to land (branch spec in GitHub shorthand)
3. Make `L3-agents` the default branch on GitHub (breaking change for monorepo users)
4. Create a separate marketplace repo that points to the `L3-agents` branch via source ref

Option 4 is the cleanest workaround: a lightweight `marketplace.json` in a separate repo (or on the `L3-agents` branch itself) with explicit ref pinning.

### Recommendation: Scenario 2 (Plugin for skills, git-merge for scaffolding)

**Skills and scaffolding have a hard scope boundary. Distribute each through its natural mechanism.**

| Content type | Distribution mechanism | Update mechanism |
|---|---|---|
| **Skills** (SKILL.md + scripts + references) | Claude Code plugin (EPIC-002) + `npx skills` (EPIC-001) | Plugin auto-update (Claude Code) / `npx skills update` (others) |
| **Scaffolding** (AGENTS.md, `.agents/README.md`, templates, skill-drafts structure) | `update-agents-core` git-merge workflow | Manual invocation of `update-agents-core` skill |
| **Individual third-party skills** | `remote-skill-manager` (provenance path) or `npx skills` (ecosystem path) per SPIKE-002 | Re-fetch (remote-skill-manager) / `npx skills update` |

**What changes:**
- `remote-skill-manager` is **not deprecated** — it retains its provenance/audit role (per SPIKE-002 finding)
- `update-agents-core` is **not deprecated** — it retains its scaffolding merge role (plugins cannot do this)
- Plugin marketplace is **additive** — a new distribution channel for skills specifically, coexisting with existing tools
- Scenario 1 (Replace both) is ruled out: plugins can't manage scaffolding
- Scenario 3 (Refactor to use /plugin internally) is ruled out: unnecessary coupling; different scopes don't benefit from sharing a mechanism
- Scenario 4 (Coexist independently) is close but less clear — Scenario 2 provides the explicit scope boundary that avoids confusion

**Architecture after implementation:**

```
Distribution channels (consumer-facing):
├── npx skills add owner/repo@L3-agents     → installs skills (40+ agents)
├── /plugin marketplace add ...              → installs skills (Claude Code, auto-updates)
└── update-agents-core                       → merges scaffolding (any git env)

Provenance layer (operator-facing, optional):
└── remote-skill-manager                     → .source.yml stamps on any installed skill
```

### Gate evaluation

1. **Scope boundary:** Defined. Skills → plugin/npx. Scaffolding (AGENTS.md, .agents/ structure) → git-merge.
2. **AGENTS.md update path:** Stays with `update-agents-core` git-merge workflow. Plugins cannot manage it.
3. **Non-Claude-Code path:** Preserved. `npx skills` (40+ agents) + `update-agents-core` (any git env) + manual clone/symlink.
4. **Clear recommendation:** Scenario 2 (Plugin for skills, git-merge for scaffolding).

**Gate: PASS**

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-01 | b7245e8 | Initial creation |
| Active | 2026-03-01 | b7245e8 | Investigation with findings |
