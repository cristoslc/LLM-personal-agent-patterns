---
title: "SPIKE-005 Existing Skill Lifecycle Tools"
artifact: SPIKE-005
status: Complete
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
question: "Does an existing skill already cover full skill lifecycle management (discovery, safety, install, updates, drift) that we could adopt or compose instead of building skill-manager from scratch?"
gate: Pre-implementation (EPIC-003)
risks-addressed:
  - "Building a skill-manager that duplicates an existing solution"
  - "Missing composable primitives that could accelerate development"
dependencies:
  - "EPIC-003 Skill Lifecycle Manager (Proposed)"
  - "SPIKE-002 npx Skills vs Remote Skill Manager (Active)"
blocks:
  - "EPIC-003 build-vs-compose decision"
---

# SPIKE-005 Existing Skill Lifecycle Tools

## Question

Does an existing skill on skills.sh already cover full skill lifecycle management (discovery → safety review → installation → updates → drift detection), or are we building something new?

### Context

Before building `skill-manager` (EPIC-003), check whether the ecosystem already has a solution we could adopt, fork, or compose from. Searched `npx skills find` for skill managers, auditors, and lifecycle tools.

## Go / No-Go Criteria

1. **Landscape mapped:** Identify existing skills that cover any of the five lifecycle phases.
2. **Full-lifecycle candidate identified (or not):** Determine if any single skill covers all five phases.
3. **Composable primitives identified:** Note reusable patterns or techniques worth adopting even if no full solution exists.

## Findings

### Candidates evaluated

| Skill | Repo | Installs | Focus |
|---|---|---|---|
| `skill-manager` | kkkkhazix/khazix-skills | 169 | Drift detection via git hash |
| `skill-management` | dwsy/agent | 14 | Discovery + install + updates via `npx skills` |
| `skill-auditor` | useai-pro/openclaw-skills-security | 17 | Deep security audit (LLM-prompted, 6-step protocol) |
| `skillvet` | oakencore/skillvet | 7 | Rules-based security scanning (48 checks in bash) |

### Coverage matrix

| Phase | kkkkhazix | dwsy | useai-pro | oakencore |
|---|---|---|---|---|
| **Discovery** | — | Yes (3 sources: GitHub API, skills.sh, `npx skills find`) | — | — |
| **Safety review** | — | Shallow (LLM-prompted) | Deep (LLM-prompted, 6-step) | Deepest (bash scripts, 48 pattern checks, IOC blocklists) |
| **Installation** | — | Yes (wraps `npx skills add`) | — | Partial (`safe-install.sh`: install + audit + auto-rollback) |
| **Updates** | Partial (detect only) | Yes (wraps `npx skills check/update`) | — | Partial (`diff-scan.sh` audits deltas) |
| **Drift detection** | Yes (hash comparison) | — | — | — |
| **Wraps `npx skills`** | No | Yes | No | No |
| **Runtime deps** | Python | TypeScript/Bun | None (prompt-only) | Bash (POSIX) |
| **Vendor lock-in** | Claude Code (`~/.claude/skills`) | Mostly Claude Code | "OpenClaw" ecosystem | "ClawHub" ecosystem |

### Key finding: no full-lifecycle skill exists

Each candidate covers 1–2 phases well. None covers all five. None is composable with the others — they use different ecosystems (`npx skills` vs `clawdhub` vs raw `git ls-remote`), different languages, and different metadata conventions.

### Composable patterns worth adopting

Despite no adoptable solution, several patterns are worth stealing:

1. **Install-audit-rollback** (oakencore/skillvet `safe-install.sh`): Install a skill, run safety checks, auto-remove if critical findings. This is the right primitive for "safety-gated installation."

2. **Rules-based security scanning** (oakencore/skillvet): 48 real pattern checks in bash — exfiltration endpoints, env harvesting, credential theft, obfuscation, path traversal, reverse shells, prompt injection, typosquats. POSIX-portable. Far more trustworthy than LLM-prompted "does this look safe?"

3. **Three-source discovery** (dwsy/skill-management): Searches GitHub API, skills.sh scraping, and `npx skills find` in parallel. Broader than any single source.

4. **Diff-scan on update** (oakencore/skillvet `diff-scan.sh`): Only audits what changed between versions, not the full skill. Efficient for update safety review.

5. **Hash-based drift detection** (kkkkhazix/skill-manager): Compares local file hash to remote HEAD via `git ls-remote`. Lightweight, no clone needed. Compatible with `.source.yml` integrity model.

### Recommendation

**Build `skill-manager`, borrow patterns.** No existing skill is adoptable as-is, but the ecosystem has validated the primitives we need. Specific borrowings:

| Pattern | Source | How to adopt |
|---|---|---|
| Install-audit-rollback | oakencore | Adapt the `safe-install.sh` flow: install via `npx skills add`, scan, rollback on failure |
| Rules-based scanning | oakencore | Port the bash pattern checks (or reference them) rather than relying on LLM-prompted safety review |
| Diff-scan on update | oakencore | Scan only changed files when updating, not the full skill |
| `npx skills` wrapping | dwsy | Already planned per SPIKE-002 Scenario 2 |
| Hash drift detection | kkkkhazix | Already exists in `remote-skill-manager` via `.source.yml` integrity digests |

### Gate evaluation

1. **Landscape mapped:** Complete. Four candidates evaluated across five lifecycle phases.
2. **Full-lifecycle candidate:** None found. Each covers 1–2 phases.
3. **Composable primitives:** Five patterns identified worth adopting.

**Gate: PASS — build, don't adopt. Borrow patterns.**

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Complete | 2026-03-01 | 5810a56 | Skipped Planned/Active — investigated and resolved in one session |
