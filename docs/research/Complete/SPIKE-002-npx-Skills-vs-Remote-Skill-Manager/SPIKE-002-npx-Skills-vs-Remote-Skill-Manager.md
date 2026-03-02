---
title: "SPIKE-002 npx Skills vs Remote Skill Manager"
artifact: SPIKE-002
status: Complete
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
question: "Does `npx skills` replace the remote-skill-manager skill, should remote-skill-manager wrap npx skills as its underlying mechanism, or should they coexist as independent paths?"
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

Does `npx skills` replace the `remote-skill-manager` skill, should `remote-skill-manager` wrap `npx skills` as its underlying mechanism, or should they coexist as independent installation paths?

### Context

The primary problem is **skill installation** — making it easy for consumers to install skills into their projects using ecosystem tooling rather than maintaining competing infrastructure. Per-project skills (not just global) must be supported. Provenance and drift detection are secondary concerns to layer on as the ecosystem matures.

The `remote-skill-manager` skill (per ADR-002) currently provides:
- Fetch skills from remote Git repos via a custom bash script
- `.source.yml` provenance manifests with integrity hashes for drift detection
- Explicit ref pinning (branch, tag, commit SHA)
- POSIX-only dependencies (git, tar, sha256sum)

The `npx skills` ecosystem (Vercel skills.sh) provides:
- `npx skills add owner/repo@ref` — installs skills from GitHub
- Multi-agent routing: installs to correct directories for 40+ agent platforms
- Ecosystem discoverability on skills.sh via install telemetry
- Active development: 69k+ skills, 2M+ CLI installs, backed by Vercel
- Fully scriptable: `--skill`, `--agent`, `--yes` flags suppress all interactive prompts

### Scenarios

1. **Replace:** Deprecate `remote-skill-manager`. Use `npx skills` directly. Document clone/symlink as the no-Node fallback.
2. **Wrap:** Refactor `remote-skill-manager` to call `npx skills` when Node.js is available, falling back to the current bash fetch script when it's not. Layer provenance, drift detection, and multi-project sync on top.
3. **Coexist:** Keep both paths independent. `npx skills` for ecosystem users, `remote-skill-manager` for provenance-conscious or Node-free environments.

## Go / No-Go Criteria

1. **Feature gap analysis:** Document what each tool provides and where the gaps are.
2. **Wrap feasibility:** Determine whether `npx skills` can be called programmatically from a wrapper with predictable behavior.
3. **Non-Node path verified:** Confirm that a viable installation path exists for users without Node.js.
4. **Clear recommendation:** One of the three scenarios is recommended with rationale.

## Pivot Recommendation

If wrapping proves fragile (unstable CLI interface, unparseable output), fall back to **Scenario 3 (Coexist)** — it preserves all existing functionality while adding the ecosystem path. Revisit consolidation when the Agent Skills spec adds provenance/integrity features.

## Findings

### Feature comparison

| Capability | `npx skills` (v1.4.3) | `remote-skill-manager` |
|---|---|---|
| Install from GitHub | `npx skills add owner/repo@ref` | `fetch-remote-skill.sh <url> <path> [ref]` |
| Branch/tag/SHA pinning | `@ref` at install time; **not persisted** in lock file | Positional `ref` argument; persisted in `.source.yml` |
| Multi-agent routing | Installs to correct location per agent (40+ agents) | Targets `.agents/skills/` only |
| Selective install | `--skill` flag for specific skills | Targets specific `<skill-path>` by design |
| Ecosystem discoverability | Automatic via skills.sh install telemetry | None (repo-to-repo only) |
| Project-scoped install | Yes (`.agents/skills/` canonical, symlinks to agent dirs) | Yes (`.agents/skills/`, `.source.yml`) |
| Project-scoped update | **Broken** — [#337](https://github.com/vercel-labs/skills/issues/337) | Re-run fetch script (idempotent) |
| Lockfile-based restore | `experimental_install` — reads `skills-lock.json`, restores via `add` | N/A |
| Security scanning | Yes — Gen, Socket, Snyk assessments shown at install time | **None** |
| Post-install hooks | **None** — no extension points in the CLI | N/A |
| Machine-readable output | **None** — no `--json` flag; must read lock files directly | Script output only |
| Runtime dependency | Node.js (npx) | POSIX only (git, tar, sha256sum) |

### Lock file architecture (hands-on verified, v1.4.3)

`npx skills` maintains **two separate lock files** with different schemas and purposes:

**Project lock (`skills-lock.json` in project root):**
- Written on `add`; **not** updated on `remove` (entry persists for restore)
- Schema v1 — intentionally minimal to reduce merge conflicts:
  ```json
  {
    "version": 1,
    "skills": {
      "skill-name": {
        "source": "owner/repo",
        "sourceType": "github",
        "computedHash": "<sha256 of on-disk files>"
      }
    }
  }
  ```
- **Does not record `@ref`** — branch/tag pinning is lost after install. `experimental_install` restores from the default branch, not the original ref.
- **Does not record agent list** — `experimental_install` restores to all agents (universal), not the original agent selection.
- `computedHash` is SHA-256 of actual file contents on disk, not a GitHub tree SHA.
- Skills are sorted alphabetically for deterministic output.
- Designed to be **committed to version control** — acts as a declarative manifest.

**Global lock (`~/.agents/.skill-lock.json`):**
- Written on `add -g`; used by `check` and `update`.
- Schema v3 — richer metadata:
  ```json
  {
    "version": 3,
    "skills": {
      "skill-name": {
        "source": "owner/repo",
        "sourceType": "github",
        "sourceUrl": "https://github.com/owner/repo.git",
        "skillPath": "skills/skill-name/SKILL.md",
        "skillFolderHash": "<github tree SHA>",
        "installedAt": "2026-03-01T...",
        "updatedAt": "2026-03-01T..."
      }
    }
  }
  ```
- `check` and `update` **only read this lock** — project-scoped skills are invisible to them.
- `skillFolderHash` is a GitHub Trees API SHA, compared remotely for update detection.

**Key gaps in lock file behavior:**
1. **Ref not persisted** — `@ref` is used at clone time but not stored. Both lock files lose the pinned ref.
2. **`remove` doesn't clean up** — project lock entry persists after removal. Semantically correct (manifest vs. state), but surprising.
3. **`check`/`update` ignore project lock** — only global installs can be checked for updates.
4. **`experimental_install` is coarse** — restores all skills from lock to all agents, with no ref or agent fidelity.

### `experimental_install` (lockfile restore)

`npx skills experimental_install` reads `skills-lock.json` and calls `add` for each entry:
- Restores skills to `.agents/skills/` with symlinks to all agent directories
- Clones from the `source` repo at its default branch (ref is not stored)
- Effectively `npm install` semantics for skills — clone, check out, and reproduce
- Works non-interactively (no prompts)

This is the "install from lockfile" feature listed as missing in JOURNEY-001. It exists but is **experimental** and has fidelity gaps (no ref pinning, no agent selection).

### Security scanning

As of v1.4.3, `npx skills add` shows **security risk assessments** at install time from three providers:
- **Gen** (generative analysis)
- **Socket** (supply chain alerts)
- **Snyk** (vulnerability risk level)

This is install-time only — no `npx skills audit` or post-install scanning command. But it addresses the "no scanning exists" gap identified in JOURNEY-001.

### `npx skills` CLI scriptability (source code verified)

The CLI is fully non-interactive when flags are provided:

```bash
# Project-scoped, non-interactive, specific skill and agent
npx skills add owner/repo@ref --skill skill-name --agent claude-code --yes

# All skills, all agents, project-scoped
npx skills add owner/repo@ref --all
```

Key behaviors:
- `--yes` without `--global` defaults to **project scope**
- Canonical install target: `.agents/skills/<name>/` with symlinks to agent-specific directories
- `skills-lock.json` is written to project root for project-scoped installs (source, sourceType, computedHash)
- No post-install hooks, no callbacks, no extension points — wrapping must happen externally (call `npx skills add`, then run post-install steps)
- No `--json` output — read `skills-lock.json` directly for programmatic access

### Scope boundary: skills vs scaffolding

`npx skills` installs SKILL.md files into agent-specific directories. It does **not** touch AGENTS.md or any project-level scaffolding. These are separate concerns:

- **Skill installation** → `npx skills` / `remote-skill-manager` (this spike)
- **Framework scaffolding** (AGENTS.md, `.agents/` structure) → `update-agents-core` git-merge (confirmed by SPIKE-003)

### Scenario evaluation

#### Scenario 1: Replace

Deprecate `remote-skill-manager` entirely. Use `npx skills add` directly. Document clone/symlink as the no-Node fallback.

| Pros | Cons |
|---|---|
| Simplest to maintain — no custom code | JOURNEY-001 pain points remain unaddressed (project updates, manifest, drift, sync) |
| Full ecosystem benefits (discoverability, multi-agent) | No provenance overlay — `.source.yml` pattern (ADR-002) abandoned |
| No coupling risk | No-Node path is undocumented manual work |
| | Consumer must know workarounds for ecosystem gaps |

**Verdict:** Solves installation but abandons everything `remote-skill-manager` adds. The JOURNEY-001 pain points (scores 1-2) remain as raw gaps with no mitigation path.

#### Scenario 2: Wrap

Refactor `remote-skill-manager` to call `npx skills add ... --yes` when Node.js is available. Fall back to the current bash fetch script when it's not. Layer value-add operations on top of either backend.

**What the wrapped skill would do:**

| Operation | With npx | Without npx (fallback) |
|---|---|---|
| Install | `npx skills add owner/repo@ref --skill name --yes` | `fetch-remote-skill.sh <url> <path> [ref]` |
| Post-install stamp | Generate `.source.yml` from `skills-lock.json` data + git metadata | Generate `.source.yml` (current behavior) |
| Update | Re-run install (workaround for [#337](https://github.com/vercel-labs/skills/issues/337)) | Re-run fetch script |
| Drift check | Compare `.source.yml` digest to on-disk hash | Same (current behavior) |
| Multi-project sync | Read `.source.yml` manifests across sibling projects, report drift | Same |

**Wrapping is feasible because:**
- `npx skills add` is fully scriptable (no interactive prompts with `--yes`)
- Output doesn't need parsing — read `skills-lock.json` directly after install
- The wrapper adds a post-install step (`.source.yml` stamping), not a mid-install hook
- Fallback to the existing bash script is clean — same interface, different backend

**The wrapper fills specific lockfile gaps:**
- **Ref persistence:** `skills-lock.json` does not record `@ref`. The wrapper's `.source.yml` stores `source.ref` and `source.commit`, preserving pinning that the ecosystem lock loses.
- **Update for project skills:** `check`/`update` ignore project-scoped skills. The wrapper can re-run `npx skills add` with the ref from `.source.yml` as a project-scoped update workaround.
- **Restore with ref fidelity:** `experimental_install` restores from default branch (ref lost). The wrapper can restore from `.source.yml` refs instead, maintaining version pinning across clones.

**Coupling risk is low because:**
- The wrapper calls `npx skills add` as a black box — it doesn't parse CLI output or depend on internal behavior
- `skills-lock.json` schema is simple and stable (version 1 for project scope)
- If `npx skills` changes or breaks, the fallback path still works

| Pros | Cons |
|---|---|
| Ecosystem benefits when npx is available | Slightly more code than Scenario 1 |
| POSIX fallback when it's not | Two code paths to maintain (npx + bash) |
| Addresses JOURNEY-001 pain points with thin scripts | Coupling to `npx skills` CLI interface (mitigated by fallback) |
| `.source.yml` provenance preserved (ADR-002 intact) | |
| Foundation for manifest-based install and cross-project sync | |
| Single entry point for consumers regardless of environment | |

**Verdict:** Best alignment with "ride the ecosystem, fill the gaps." Gets ecosystem benefits for free, adds the value that's missing, falls back gracefully.

#### Scenario 3: Coexist

Keep both paths independent. Consumer chooses: `npx skills add` for ecosystem users, `remote-skill-manager` for provenance-conscious or Node-free environments.

| Pros | Cons |
|---|---|
| No coupling between tools | Two installation paths to document and support |
| Each tool does its thing well | Consumer confusion: "which do I use?" |
| No refactoring needed | No integration — ecosystem benefits and provenance don't compose |
| | Provenance only available if consumer deliberately uses `remote-skill-manager` |

**Verdict:** Least effort but also least value. The tools don't compose — you get ecosystem OR provenance, not both. Doesn't address JOURNEY-001 pain points.

### Recommendation: Scenario 2 (Wrap)

**Refactor `remote-skill-manager` to wrap `npx skills` as its primary backend, with the existing bash fetch as fallback.**

The wrapped skill becomes the single entry point for skill installation. It delegates to `npx skills` for the heavy lifting (discovery, multi-agent routing, ecosystem integration) and adds what's missing: `.source.yml` provenance, drift detection, and a foundation for declarative manifests and cross-project sync.

**What changes in the repo:**
- `remote-skill-manager` SKILL.md is rewritten to document the wrapped workflow
- `fetch-remote-skill.sh` is retained as the no-Node fallback
- New: a wrapper script (or SKILL.md procedure) that calls `npx skills add`, reads `skills-lock.json`, and stamps `.source.yml`
- ADR-002 remains Adopted — `.source.yml` pattern is the provenance layer on top of any install backend
- EPIC-001 implementation uses the wrapped skill as the documented install path

**What doesn't change:**
- Skill content and SKILL.md files — distribution, not authoring
- `update-agents-core` — scaffolding is a separate concern (SPIKE-003)
- The fallback install path for no-Node environments

### Gate evaluation

1. **Feature gap analysis:** Complete. See comparison table above.
2. **Wrap feasibility:** Verified. `npx skills add` is fully scriptable with `--yes` flag. No output parsing needed — read `skills-lock.json` directly. No post-install hooks in npx skills, but external post-install steps work cleanly.
3. **Non-Node path:** Verified — existing `fetch-remote-skill.sh` becomes the fallback. Same interface, same `.source.yml` output.
4. **Clear recommendation:** Scenario 2 (Wrap). Ride the ecosystem via `npx skills`, fill the gaps via `remote-skill-manager` as a thin wrapper with provenance overlay.

**Gate: PASS**

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-01 | b7245e8 | Initial creation |
| Active | 2026-03-01 | b7245e8 | Investigation |
| Complete | 2026-03-01 | e48dbba | Gate PASS — Scenario 2 (Wrap) recommended |
