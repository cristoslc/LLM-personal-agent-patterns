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

The `remote-skill-manager` skill (per ADR-002) provides:
- Fetch skills from remote Git repos via a custom bash script
- `.source.yml` provenance manifests with integrity hashes for drift detection
- Explicit ref pinning (branch, tag, commit SHA)

The `npx skills` ecosystem (Vercel skills.sh) provides:
- `npx skills add owner/repo` — installs skills from GitHub into agent-specific directories
- `npx skills update` — pulls latest from upstream
- `npx skills check` — detects available updates
- Auto-discovery on skills.sh via install telemetry
- Support for 40+ agents
- No provenance manifests or integrity hashing

Key differences:
- `remote-skill-manager` tracks provenance (`.source.yml`) and supports drift detection; `npx skills` does not
- `npx skills` handles multi-agent routing (installs to the right location per agent); `remote-skill-manager` targets `.agents/skills/` only
- `remote-skill-manager` requires only POSIX tools (git, tar, sha256sum); `npx skills` requires Node.js
- `npx skills` has ecosystem discoverability (skills.sh); `remote-skill-manager` is repo-to-repo only

### Scenarios to evaluate

1. **Replace:** Deprecate `remote-skill-manager`, adopt `npx skills` as the canonical install path. Document direct clone/symlink as the non-Node fallback.
2. **Wrap:** Refactor `remote-skill-manager` to call `npx skills` when available, falling back to the current bash fetch script when Node.js is absent. Preserve `.source.yml` as an overlay.
3. **Coexist:** Keep both paths independent. `npx skills` for ecosystem users, `remote-skill-manager` for provenance-sensitive or Node-free environments. Document when to use which.

## Go / No-Go Criteria

1. **Feature gap analysis complete:** Document what `remote-skill-manager` provides that `npx skills` does not (provenance, integrity, drift detection) and assess whether those gaps matter for the target user base.
2. **Non-Node path verified:** Confirm that a viable installation path exists for users without Node.js, regardless of the chosen scenario.
3. **Clear recommendation:** One of the three scenarios is recommended with rationale, not "it depends."

## Pivot Recommendation

If no scenario cleanly resolves the trade-offs, adopt **Scenario 3 (Coexist)** as the default — it preserves all existing functionality while adding the ecosystem path. Revisit consolidation when the Agent Skills spec adds provenance/integrity features (which may make `.source.yml` redundant).

## Findings

### Feature gap analysis

| Capability | `npx skills` | `remote-skill-manager` |
|---|---|---|
| Install from GitHub | `npx skills add owner/repo@ref` | `fetch-remote-skill.sh <url> <path> [ref]` |
| Branch/tag/SHA pinning | `@ref` syntax; tracked in lock file | Positional `ref` argument; tracked in `.source.yml` |
| Provenance manifest | Centralized `skills-lock.json` with source, ref, `skillFolderHash` | Per-skill `.source.yml` with full 40-char commit SHA, integrity digest |
| Drift detection | Compares `skillFolderHash` against GitHub tree SHA | `sha256(tar excluding .source.yml) == .source.yml digest` |
| Integrity hash | GitHub tree SHA (content-addressable but opaque) | sha256 of deterministic tar archive (auditable) |
| Update mechanism | `npx skills update` (global only; project-scoped pending [#337](https://github.com/vercel-labs/skills/issues/337)) | Re-run fetch script (idempotent, any scope) |
| Multi-agent routing | Installs to correct location per agent (40+ agents) | Targets `.agents/skills/` only |
| Selective install | `--skill` flag for specific skills | Targets specific `<skill-path>` by design |
| Ecosystem discoverability | Automatic via skills.sh install telemetry | None (repo-to-repo only) |
| Runtime dependency | Node.js (npx) | POSIX only (git, tar, sha256sum) |
| Lock file location | `~/.agents/.skill-lock.json` (global) / `skills-lock.json` (project) | `.source.yml` alongside each skill |

### Key observations

1. **They solve different problems.** `npx skills` is a consumer-facing distribution tool (install, discover, update across agents). `remote-skill-manager` is an operator-facing provenance tool (track where skills came from, detect unauthorized modifications, audit integrity).

2. **Provenance gap is real but narrowing.** `npx skills` tracks source + ref + hash in a centralized lock file, which covers 80% of what `.source.yml` provides. The remaining 20% — per-skill manifest, full commit SHA (not just ref), deterministic tar-based integrity, and explicit drift detection workflow — matters for auditable environments but not for most consumers.

3. **The Node.js requirement is a real constraint.** The agents-standalone framework targets environments that may not have Node.js. POSIX-only operation is a design principle worth preserving as a fallback.

4. **Project-scoped updates are broken in `npx skills`.** Issue #337 is open — `npx skills update` only works for globally installed skills. This is a significant gap since project-scoped installation is the natural fit for team repos.

5. **Wrapping is fragile.** `npx skills` is a young CLI (v1.x). Its flags and behavior are still evolving. Building a wrapper that shells out to `npx skills` creates coupling to an unstable interface.

### Recommendation: Scenario 3 (Coexist) with role clarity

**Do not replace or wrap. Keep both paths independent with clear guidance on when to use which.**

| Audience | Recommended path | Why |
|---|---|---|
| **Consumers** installing skills into their projects | `npx skills add owner/repo@L3-agents` | Broadest agent support (40+), ecosystem discoverability, familiar CLI |
| **Operators / auditors** in provenance-sensitive environments | `remote-skill-manager` fetch script | Per-skill `.source.yml`, deterministic integrity hashing, POSIX-only, no external CLI dependency |
| **Users without Node.js** | `remote-skill-manager` fetch script or manual clone + symlink | Only viable automated path without Node |

**What changes:**
- `npx skills` becomes the **documented default** install path for EPIC-001 (Tier 1)
- `remote-skill-manager` is repositioned from "the skill installer" to "the provenance/audit tool" — its description and docs should reflect this
- Document the manual clone + symlink path as the minimal fallback for no-tooling environments
- No code changes to either tool needed right now

**Future consolidation trigger:** If the Agent Skills spec or `npx skills` adds per-skill provenance manifests and integrity verification, `remote-skill-manager` becomes redundant for its provenance role and can be deprecated. Monitor skills.sh roadmap.

### Gate evaluation

1. **Feature gap analysis:** Complete (table above). Provenance and POSIX-only operation are the meaningful gaps.
2. **Non-Node path:** Verified — `remote-skill-manager` and manual clone/symlink both work without Node.js.
3. **Clear recommendation:** Scenario 3 (Coexist) with role clarity. Not "it depends."

**Gate: PASS**

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-01 | b7245e8 | Initial creation |
| Active | 2026-03-01 | b7245e8 | Investigation with findings |
