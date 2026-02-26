---
title: ADR-001 Remote Skills Reference Pattern
status: Draft
author: Claude
created_date: 2026-02-26
last_updated_date: 2026-02-26
linked_epics: []
linked_prds: []
---

# ADR-001 Remote Skills Reference Pattern

## Context

The `.agents/skills/` directory holds locally-authored skills that agents discover at session start. As the skill ecosystem grows, teams will want to **import skills from remote repositories** — shared libraries, community contributions, or cross-team standards.

Today there is no convention for:

1. Tracking **where** a skill came from (repository, ref, path within repo).
2. Detecting **drift** between the local copy and its upstream source.
3. **Updating** a fetched skill while preserving provenance metadata.
4. Distinguishing **local-only** skills from **remotely-sourced** ones.

Without a standard, teams will invent ad-hoc approaches (git submodules, manual copy-paste, undocumented wrapper scripts) that create maintenance burden and lose traceability.

## Decision

Introduce a **`.source.yml`** manifest file that lives alongside any skill fetched from a remote repository. The manifest records provenance, pinned version, and an integrity digest. A companion **fetch script** automates the clone-extract-stamp workflow. A **Jinja template** provides the canonical `.source.yml` shape for both the script and manual creation.

### Conventions

- `.source.yml` is **OPTIONAL**. Its absence signals a locally-authored skill (no remote origin).
- `.source.yml` is **GENERATED**, not hand-written. The fetch script or a skill-management agent writes it.
- `.source.yml` is **COMMITTED** to the repo alongside the fetched skill files. It is source-controlled, not ephemeral.
- The fetch script is **idempotent**. Re-running it for the same skill updates the local copy and stamps a new `.source.yml` with the current upstream state.

## Schema definition

### `.source.yml` structure

```yaml
# .source.yml — Remote skill provenance manifest
# Machine-generated. Do not edit manually.

source:
  repository: <string>       # Git remote URL (HTTPS or SSH)
  ref: <string>              # Branch, tag, or commit ref used at fetch time
  commit: <string>           # Full SHA of the pinned commit
  path: <string>             # Path to the skill directory within the source repo

skill:
  name: <string>             # Skill directory name (must match containing directory)

fetched:
  at: <string>               # ISO 8601 timestamp of the fetch operation
  by: <string>               # Identifier of the tool/agent that performed the fetch

integrity:
  algorithm: sha256           # Hash algorithm (always sha256 for v1)
  digest: <string>           # Hex-encoded hash of the tar archive of fetched skill files
```

### Field reference

| Field | Required | Description |
|---|---|---|
| `source.repository` | Yes | Git remote URL. HTTPS preferred for portability. |
| `source.ref` | Yes | The branch, tag, or commit ref requested at fetch time. |
| `source.commit` | Yes | Full 40-character SHA of the resolved commit. Enables exact replay. |
| `source.path` | Yes | Relative path from repo root to the skill directory (e.g., `.agents/skills/my-skill`). |
| `skill.name` | Yes | Must match the skill's directory name. Used for validation. |
| `fetched.at` | Yes | ISO 8601 UTC timestamp. Records when the fetch occurred. |
| `fetched.by` | Yes | Freeform identifier — e.g., `fetch-remote-skill.sh`, `claude-code`, `codex`. |
| `integrity.algorithm` | Yes | Always `sha256` in v1. Future versions may add alternatives. |
| `integrity.digest` | Yes | Hex digest of the deterministic tar of the skill directory (excluding `.source.yml` itself). |

### Example

```yaml
source:
  repository: https://github.com/acme/shared-skills
  ref: v2.1.0
  commit: 9f86d081884c7d659a2feaa0c55ad015a3bf4f1b
  path: .agents/skills/code-review

skill:
  name: code-review

fetched:
  at: "2026-02-26T14:30:00Z"
  by: fetch-remote-skill.sh

integrity:
  algorithm: sha256
  digest: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

### Drift detection

A skill is **in sync** when:

```
sha256(tar of local skill files, excluding .source.yml) == .source.yml integrity.digest
```

A mismatch indicates either:
- **Upstream changed**: re-fetch to update.
- **Local modification**: intentional customization — document in a `CUSTOMIZATIONS.md` alongside `.source.yml`, or fork the skill into a local-only copy (remove `.source.yml`).

## Consequences

### Benefits

- **Traceability**: Every fetched skill carries its full provenance. `git log` + `.source.yml` gives a complete audit trail.
- **Reproducibility**: Pinned commit + integrity digest enables exact reconstruction of any historical skill state.
- **Drift visibility**: Comparing the integrity digest to a fresh hash of local files surfaces unauthorized or forgotten modifications.
- **CLI-agnostic**: The pattern is a file convention, not tied to any specific agent CLI. Claude Code, Codex, and Gemini can all consume it.
- **Opt-in**: Local skills remain untouched. Only fetched skills carry the manifest.

### Costs

- **One extra file per fetched skill**: `.source.yml` adds a small file to each imported skill directory.
- **Fetch script dependency**: The script requires `git` and standard POSIX tools (`tar`, `sha256sum`/`shasum`, `date`).
- **Schema evolution**: Future field additions require versioning strategy (addressed by keeping `integrity.algorithm` explicit and future-proofing with a potential `schema_version` field).

### Risks

- Teams may hand-edit `.source.yml`, breaking integrity guarantees. Mitigated by the "machine-generated, do not edit" header comment.
- Hash algorithm changes require coordinated migration. Mitigated by pinning `sha256` in v1 and making algorithm explicit.

## Acceptance criteria

These criteria define what "done" means for the initial implementation. The smoke-test script (`scripts/smoke-test.sh` in the `remote-skill-manager` skill) automates verification of criteria AC-1 through AC-5.

| ID | Criterion | Verification |
|---|---|---|
| AC-1 | `fetch-remote-skill.sh` clones a public repo, extracts a skill directory, and writes it to the target skills path. | Smoke test: fetch a known skill from this repo into a temp directory. |
| AC-2 | A valid `.source.yml` is generated alongside the fetched skill files. | Smoke test: assert `.source.yml` exists and is valid YAML. |
| AC-3 | All required fields in the schema are populated and non-empty. | Smoke test: check each required field is present and non-blank. |
| AC-4 | `integrity.digest` matches a fresh `sha256` computation of the fetched files (excluding `.source.yml`). | Smoke test: recompute hash and compare to manifest value. |
| AC-5 | Re-running the fetch script updates `fetched.at` and `source.commit` to current values. | Smoke test: fetch twice, assert timestamps differ and commit field is valid. |
| AC-6 | `.source.yml` absence for locally-authored skills causes no errors in agent discovery. | Manual: verify existing skills (e.g., `spec-management`) load normally. |
| AC-7 | The JSON Schema validates conforming `.source.yml` files and rejects malformed ones. | Manual or CI: run schema validator against example and counter-example. |

### Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-02-26 | 6953762 | Initial creation, schema v1 defined |
