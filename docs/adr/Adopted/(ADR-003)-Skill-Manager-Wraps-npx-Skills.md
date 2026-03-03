---
title: "Skill Manager Wraps npx Skills with Provenance Overlay"
artifact: ADR-003
status: Adopted
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
linked-epics:
  - EPIC-001
  - EPIC-003
linked-specs: []
depends-on:
  - SPIKE-002
  - SPIKE-005
---

# ADR-003: Skill Manager Wraps npx Skills with Provenance Overlay

## Context

The project needs a single entry point for skill lifecycle management — discovery, safety review, installation, updates, and drift detection. Two tools exist:

- **`npx skills`** (Vercel, v1.4.3): The ecosystem standard. Installs skills from GitHub, routes to 40+ agent platforms, provides ecosystem discoverability and install-time security scanning (Gen, Socket, Snyk). 69k+ skills, 2M+ CLI installs. However, it has gaps: `skills-lock.json` does not persist `@ref` pinning, `check`/`update` ignore project-scoped installs, `experimental_install` loses ref and agent fidelity, and there are no post-install hooks or extension points.

- **`remote-skill-manager`** (this project, per ADR-002): Fetches skills via a POSIX bash script, stamps `.source.yml` provenance manifests with integrity hashes and ref pinning. Supports drift detection. No ecosystem integration, no multi-agent routing, no discoverability.

Neither tool covers the full lifecycle alone. SPIKE-002 evaluated three scenarios: Replace (drop custom tooling), Wrap (compose both), Coexist (keep independent). SPIKE-005 surveyed existing ecosystem skills and found no full-lifecycle manager — but identified composable patterns worth borrowing.

## Decision

**Evolve `remote-skill-manager` into `skill-manager` — a wrapper that delegates to `npx skills` as its primary backend and falls back to the existing POSIX fetch script when Node.js is unavailable.**

The wrapper adds a value layer the ecosystem doesn't provide:

1. **Provenance stamping:** After every install or update via `npx skills add`, generate `.source.yml` (per ADR-002) from `skills-lock.json` data plus git metadata. This fills the ecosystem's ref-persistence gap — `.source.yml` stores `source.ref` and `source.commit` that `skills-lock.json` loses.

2. **Safety-gated installation:** Adopt the install-audit-rollback pattern (from oakencore/skillvet, per SPIKE-005): install via `npx skills add`, run safety checks, auto-rollback on critical findings.

3. **Rules-based security scanning:** Adopt pattern-based checks (from oakencore/skillvet: exfiltration endpoints, env harvesting, credential theft, obfuscation, path traversal, reverse shells, prompt injection) rather than relying solely on LLM-prompted review.

4. **Diff-scan on update:** Only audit changed files between versions, not the full skill (pattern from oakencore/skillvet).

5. **Project-scoped updates:** Work around `npx skills` issue [#337](https://github.com/vercel-labs/skills/issues/337) by re-running `npx skills add` with the ref from `.source.yml`.

6. **Drift detection:** Compare `.source.yml` integrity hashes to on-disk state; report cross-project drift (pattern from kkkkhazix/skill-manager, already present in `remote-skill-manager`).

7. **POSIX fallback:** When Node.js is unavailable, the existing `fetch-remote-skill.sh` provides the same install + provenance workflow without ecosystem integration.

### Wrapping is feasible because:

- `npx skills add` is fully scriptable (`--skill`, `--agent`, `--yes` flags suppress all prompts)
- No CLI output parsing needed — read `skills-lock.json` directly after install
- The wrapper adds post-install steps, not mid-install hooks
- `skills-lock.json` schema is simple and stable (version 1 for project scope)
- If `npx skills` changes or breaks, the POSIX fallback still works

## Alternatives Considered

**Scenario 1 — Replace (drop custom tooling):** Deprecate `remote-skill-manager` entirely. Use `npx skills add` directly. Simplest to maintain, but abandons provenance (`.source.yml`, ADR-002), leaves JOURNEY-001 pain points unaddressed (scores 1-2), and provides no path for non-Node environments. Rejected because it solves installation but abandons the value layer.

**Scenario 3 — Coexist (independent paths):** Keep both tools independent. Least effort but also least value — consumers get ecosystem OR provenance, not both. Creates "which do I use?" confusion and doesn't address JOURNEY-001 pain points. Rejected because the tools don't compose.

**Adopt an existing ecosystem skill:** SPIKE-005 evaluated four candidates (kkkkhazix/skill-manager, dwsy/skill-management, useai-pro/skill-auditor, oakencore/skillvet). None covers all five lifecycle phases. Each is vendor-locked to a specific ecosystem. Rejected as a wholesale adoption, but patterns are borrowed (see Decision above).

## Consequences

### Benefits

- **Single entry point:** Consumers use `skill-manager` regardless of environment — it picks the right backend.
- **Ecosystem + provenance compose:** `npx skills` provides discoverability, multi-agent routing, and security scanning; `.source.yml` provides ref persistence, drift detection, and integrity guarantees.
- **ADR-002 preserved:** The `.source.yml` provenance pattern remains the provenance layer on top of any install backend.
- **JOURNEY-001 pain points addressed:** The wrapper fills the specific gaps (project updates, ref-aware restore, drift visibility) that score 1-2 in the journey.
- **Graceful degradation:** POSIX fallback ensures the tool works in non-Node environments with reduced but functional capabilities.

### Costs

- **Two code paths:** The wrapper must maintain both the `npx skills` path and the POSIX fallback. Mitigated by keeping the interface identical — same `.source.yml` output regardless of backend.
- **Coupling to `npx skills` CLI:** Changes to the CLI interface could break the wrapper. Mitigated by treating `npx skills add` as a black box (no output parsing) and reading `skills-lock.json` directly. The POSIX fallback provides a safety net.
- **Borrowed patterns need porting:** The install-audit-rollback and rules-based scanning patterns from oakencore/skillvet must be adapted, not just copied. They use a different ecosystem ("ClawHub") with different conventions.

### Risks

- `npx skills` lock file schema could change. Mitigated: the wrapper only reads `skills-lock.json` (schema v1), which is intentionally minimal and stable.
- The `experimental_install` command could be removed or changed. Mitigated: the wrapper does not depend on it — it implements its own restore logic from `.source.yml` refs.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Adopted | 2026-03-01 | e48dbba | Skipped Draft/Proposed — decision fully developed in SPIKE-002, SPIKE-005 |
