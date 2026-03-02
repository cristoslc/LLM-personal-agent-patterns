---
title: "SPIKE-002 npx Skills vs Remote Skill Manager"
artifact: SPIKE-002
status: Active
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
question: "Does `npx skills` replace the remote-skill-manager skill, should remote-skill-manager be refactored to use npx skills as its underlying mechanism, or should they coexist as independent paths?"
gate: Pre-implementation (EPIC-001)
risks-addressed:
  - "Maintaining two parallel skill-installation mechanisms creates confusion and drift"
  - "Dropping the custom path locks out users without Node.js / npx"
  - "Wrapping npx skills may add fragile coupling to an external tool's CLI interface"
dependencies:
  - "ADR-002 Remote Skills Reference Pattern (Adopted)"
  - "EPIC-001 Skills Ecosystem Zero-Effort Distribution (Proposed)"
blocks:
  - "EPIC-001 implementation — cannot finalize installation path without this decision"
  - "Potential refactor or deprecation of remote-skill-manager skill"
---

# SPIKE-002 npx Skills vs Remote Skill Manager

## Question

Does `npx skills` replace the `remote-skill-manager` skill, should `remote-skill-manager` be refactored to use `npx skills` as its underlying mechanism, or should they coexist as independent installation paths?

### Context

The primary problem is **skill installation** — making it easy for consumers to install skills into their projects using ecosystem tooling with committed resources behind it. Per-project skills (not just global) must be an option. Provenance and drift detection are secondary concerns that can be layered on later as scanning tools mature.

The `remote-skill-manager` skill (per ADR-002) provides:
- Fetch skills from remote Git repos via a custom bash script
- `.source.yml` provenance manifests with integrity hashes for drift detection
- Explicit ref pinning (branch, tag, commit SHA)
- POSIX-only (git, tar, sha256sum)

The `npx skills` ecosystem (Vercel skills.sh) provides:
- `npx skills add owner/repo@ref` — installs skills from GitHub into agent-specific directories
- `npx skills update` — pulls latest from upstream
- `npx skills check` — detects available updates
- Auto-discovery on skills.sh via install telemetry
- Support for 40+ agents
- Backed by Vercel with active development, 69k+ skills, 2M+ CLI installs

### Scenarios to evaluate

1. **Replace:** Deprecate `remote-skill-manager`, adopt `npx skills` as the canonical install path. Document direct clone/symlink as the non-Node fallback.
2. **Wrap:** Refactor `remote-skill-manager` to call `npx skills` when available, falling back to the current bash fetch script when Node.js is absent. Preserve `.source.yml` as an overlay.
3. **Coexist:** Keep both paths independent. `npx skills` for ecosystem users, `remote-skill-manager` for provenance-sensitive or Node-free environments. Document when to use which.

## Go / No-Go Criteria

1. **Feature gap analysis complete:** Document what `remote-skill-manager` provides that `npx skills` does not and assess whether those gaps matter for the target user base.
2. **Non-Node path verified:** Confirm that a viable installation path exists for users without Node.js, regardless of the chosen scenario.
3. **Clear recommendation:** One of the three scenarios is recommended with rationale, not "it depends."

## Pivot Recommendation

If no scenario cleanly resolves the trade-offs, adopt **Scenario 3 (Coexist)** as the default — it preserves all existing functionality while adding the ecosystem path. Revisit consolidation when the Agent Skills spec adds provenance/integrity features (which may make `.source.yml` redundant).

## Findings

### Feature comparison

| Capability | `npx skills` | `remote-skill-manager` |
|---|---|---|
| Install from GitHub | `npx skills add owner/repo@ref` | `fetch-remote-skill.sh <url> <path> [ref]` |
| Branch/tag/SHA pinning | `@ref` syntax; tracked in lock file | Positional `ref` argument; tracked in `.source.yml` |
| Multi-agent routing | Installs to correct location per agent (40+ agents) | Targets `.agents/skills/` only |
| Selective install | `--skill` flag for specific skills | Targets specific `<skill-path>` by design |
| Ecosystem discoverability | Automatic via skills.sh install telemetry | None (repo-to-repo only) |
| Project-scoped install | Yes (`.claude/skills/`, `skills-lock.json`) | Yes (`.agents/skills/`, `.source.yml`) |
| Project-scoped update | **Broken** — [#337](https://github.com/vercel-labs/skills/issues/337) open | Re-run fetch script (idempotent) |
| Lockfile-based install | **Missing** — no `npx skills install` from lockfile | N/A |
| Provenance manifest | Centralized `skills-lock.json` (source, ref, hash) | Per-skill `.source.yml` (full SHA, integrity digest) |
| Security scanning | **None** | **None** |
| Runtime dependency | Node.js (npx) | POSIX only (git, tar, sha256sum) |

### `npx skills` gaps (see JOURNEY-001 for full experience map)

1. **Project-scoped updates broken** (JOURNEY-001 score: 1) — `npx skills update` only works for global installs. Workaround: re-run `npx skills add`. [Issue #337](https://github.com/vercel-labs/skills/issues/337) is the single highest-impact fix to track.
2. **No declarative skill manifest** (score: 2) — `skills-lock.json` exists but can't be used as input. No `npx skills install --from-lock` equivalent to `npm install`.
3. **Skills drift silently across projects** (score: 2) — no cross-project awareness or sync command.
4. **No security scanning** (score: 1) — industry-wide gap, not specific to `npx skills`.

### Scope boundary: skills vs scaffolding

`npx skills` installs SKILL.md files into agent-specific directories. It does **not** touch AGENTS.md or any project-level scaffolding. Agents auto-discover installed skills without AGENTS.md routing entries.

Two concerns remain separate:
- **Skill installation** → `npx skills` (this spike)
- **Framework scaffolding** (AGENTS.md, `.agents/` structure, artifact types, lifecycle rules) → `update-agents-core` git-merge workflow (SPIKE-003 scope)

### Recommendation: Scenario 1 (Replace) — adopt `npx skills`, deprecate `remote-skill-manager` as installer

**Adopt `npx skills` as the primary skill installation mechanism. Ride the ecosystem; fill the gaps with thin scripts.**

| What | Action |
|---|---|
| **Skill installation** | `npx skills add owner/repo@L3-agents` — ecosystem path, 40+ agents |
| **`remote-skill-manager` fetch function** | **Deprecate.** `npx skills` does this better with multi-agent routing and ecosystem discoverability. |
| **`.source.yml` provenance stamping** | **Retain as lightweight post-install script.** Runs after any install method. Feeds future security scanners when they arrive. |
| **No-Node fallback** | Document manual `git clone` + symlink. Lightweight docs, not custom tooling. |
| **Gap-filling** | Track [#337](https://github.com/vercel-labs/skills/issues/337). Consider contributing a `--from-lock` feature upstream. Use thin scripts (Makefile targets, post-install hooks) for multi-project sync. |

**What changes in the repo:**
- `remote-skill-manager` skill moves to `skills-drafts/` (deprecated as installer)
- `fetch-remote-skill.sh` refactored into a standalone provenance-stamping script (strips the fetch/clone logic, keeps the `.source.yml` generation)
- ADR-002 remains Adopted — `.source.yml` pattern is still valid as a provenance overlay, just no longer coupled to installation
- EPIC-001 implementation uses `npx skills` as the documented install path
- Document the manual clone + symlink path as the no-Node alternative

### Gate evaluation

1. **Feature gap analysis:** Complete. `npx skills` covers installation well. Gaps are in lifecycle management (project updates, sync, scanning) — addressable with thin scripts and upstream contributions, not custom infrastructure.
2. **Non-Node path:** Verified — manual clone + symlink works. Documented, not automated with custom tooling.
3. **Clear recommendation:** Scenario 1 (Replace). Adopt ecosystem tooling, fill gaps with lightweight scripts, don't maintain a competing installer.

**Gate: PASS**

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-01 | b7245e8 | Initial creation |
| Active | 2026-03-01 | b7245e8 | Investigation |
