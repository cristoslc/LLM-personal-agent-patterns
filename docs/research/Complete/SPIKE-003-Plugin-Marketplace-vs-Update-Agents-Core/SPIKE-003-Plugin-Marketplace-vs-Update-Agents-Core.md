---
title: "SPIKE-003 Plugin Marketplace vs Update Agents Core"
artifact: SPIKE-003
status: Complete
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

### Decisive constraint: vendor-agnosticism

The Claude Code plugin marketplace is Claude Code-specific. Skills distributed as plugins are only installable via `/plugin` in Claude Code — users on Gemini CLI, Cursor, Codex, or any other agent get nothing. This violates the framework's vendor-agnostic principle.

`npx skills` (SPIKE-002 recommendation) supports 40+ agents from a single installation mechanism. There is no benefit to maintaining a parallel Claude Code-only distribution channel.

**Plugins are rejected as a distribution pathway.**

### Prior investigation (retained for reference)

The plugin mechanism was investigated before the vendor-agnosticism constraint was applied. Key technical findings:

- Plugins **cannot modify files outside their cache** (`~/.claude/plugins/cache/`). AGENTS.md and `.agents/` are untouchable.
- Plugin auto-update is **full overwrite** with no merge conflict resolution.
- Branch specification via GitHub shorthand (`owner/repo`) is **not supported** ([#23551](https://github.com/anthropics/claude-code/issues/23551)).
- Plugin skills are namespaced (`/plugin:skill`) — different invocation model than standalone skills.

These technical limitations would have been additional blockers even without the vendor-agnosticism constraint.

### EPIC-002 disposition

**EPIC-002 (Claude Code Plugin Marketplace) should be Abandoned.** The vendor-agnostic path (`npx skills` via EPIC-001) covers skill distribution. A Claude Code-specific channel adds complexity without proportional value for a solo developer.

### Scope boundary: skills vs scaffolding (confirmed)

SPIKE-002 identified that `npx skills` handles skill installation but does not touch AGENTS.md or `.agents/` scaffolding. This spike confirms the boundary:

| Content | Mechanism | Why |
|---|---|---|
| **Skills** (SKILL.md + scripts + references) | `npx skills add` | Cross-agent, ecosystem, vendor-agnostic |
| **Scaffolding** (AGENTS.md, `.agents/` structure, templates, README) | `update-agents-core` git-merge | Requires merge conflict resolution on consumer-customized files |

**`update-agents-core` is not deprecated.** Skills and scaffolding have different update semantics:
- Skills: **overwrite** is fine (upstream version replaces local)
- Scaffolding: **merge** is required (upstream structure + local additions must coexist)

`npx skills` is an overwrite tool. `update-agents-core` is a merge tool. Different tools for different problems. Agents auto-discover installed skills without AGENTS.md routing entries, so these concerns are fully decoupled.

### Recommendation: Reject plugins. Retain `update-agents-core` for scaffolding.

**Distribution architecture:**

```
Skill installation (vendor-agnostic):
└── npx skills add owner/repo@L3-agents     → SKILL.md into agent-specific dirs

Framework scaffolding updates (git-native):
└── update-agents-core                       → AGENTS.md + .agents/ via git-merge

Provenance overlay (optional, future):
└── .source.yml stamping script              → post-install hook for audit trail
```

### Gate evaluation

1. **Scope boundary:** Defined. Skills → `npx skills`. Scaffolding → `update-agents-core` git-merge. Different update semantics (overwrite vs merge).
2. **AGENTS.md update path:** Stays with `update-agents-core`. `npx skills` does not touch it. Agents auto-discover skills without AGENTS.md routing.
3. **Non-Claude-Code path:** Preserved by rejecting the Claude Code-specific plugin pathway entirely.
4. **Clear recommendation:** Reject plugins. `npx skills` for skills (vendor-agnostic). `update-agents-core` for scaffolding (git-native).

**Gate: PASS**

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-01 | b7245e8 | Initial creation |
| Active | 2026-03-01 | b7245e8 | Investigation with findings |
| Complete | 2026-03-01 | d4ed11a | Gate PASS — reject plugins for vendor-agnosticism; retain update-agents-core for scaffolding |
