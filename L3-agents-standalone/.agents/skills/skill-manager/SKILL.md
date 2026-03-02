---
name: skill-manager
description: Full-lifecycle skill management — discover, install, audit, update, and detect drift for agent skills. Wraps `npx skills` when available, falls back to POSIX tooling. Use when installing shared skills, checking for upstream changes, auditing skill safety, or managing skills across projects.
license: UNLICENSED
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
metadata:
  short-description: Discover, install, audit, update, and drift-detect agent skills
  related-adr: ADR-002-Remote-Skills-Reference-Pattern, ADR-003-Skill-Manager-Wraps-npx-Skills
  version: 2.0.0
  author: cristos
---

# Skill Manager

Full-lifecycle skill management for agent skills per ADR-002 and ADR-003. Wraps `npx skills` when available, falls back to POSIX tooling.

## Quick reference

| Operation | Command |
|---|---|
| Install a skill | `scripts/install.sh <repo-url> <skill-path> [ref] [target-dir]` |
| Audit a skill | `scripts/audit.sh <skill-dir>` |
| Fetch (low-level) | `scripts/fetch-remote-skill.sh <repo-url> <skill-path> [ref] [target-dir]` |
| Check drift | Compare `integrity.digest` in `.source.yml` to a fresh hash of local files |
| Update a skill | Re-run the fetch script — it overwrites and re-stamps |
| Verify setup | `scripts/smoke-test.sh` |

## Concepts

### `.source.yml` provenance manifest

Every skill fetched from a remote repo gets a `.source.yml` file written alongside its `SKILL.md`. This manifest records:

- **Where** the skill came from (repository, ref, path, pinned commit)
- **When** it was fetched and by whom
- **Integrity** hash for drift detection

The schema is defined in ADR-002 and formalized as:
- JSON Schema: `references/source-yml-schema.json`
- Jinja template: `references/source-yml.template.j2`

Local-only skills (authored in this repo) do NOT have `.source.yml`. Its absence is the signal that a skill is locally maintained.

### Drift detection

A fetched skill is **in sync** when:

```
sha256(tar of skill files, excluding .source.yml) == .source.yml → integrity.digest
```

Drift means either upstream changed (re-fetch to update) or the local copy was modified (document customizations or fork to local-only by removing `.source.yml`).

## Installation

### Install with safety gate

Use `install.sh` for all skill installations. It wraps the fetch-and-stamp workflow with a post-install safety audit and automatic rollback on critical findings.

```bash
bash scripts/install.sh \
  https://github.com/acme/shared-skills \
  .agents/skills/code-review \
  v2.1.0 \
  ../../.agents/skills
```

**Backend selection:** When `npx` is available, `install.sh` attempts `npx skills add` first. If `npx` is unavailable or the command fails, it falls back to `fetch-remote-skill.sh` (POSIX path).

**After install:**
1. Stamps `.source.yml` provenance manifest
2. Runs `audit.sh` on the installed skill
3. If audit finds **critical** issues (exit 2): rolls back the installation
4. If audit finds **warnings** (exit 1): skill installed, review recommended
5. If audit is **clean** (exit 0): skill installed and ready

**Exit codes:**
- `0` — installed, audit clean
- `1` — installed, audit warnings
- `2` — rolled back due to critical audit findings

### Optional: `--agent` flag

When using the npx backend, pass `--agent <name>` to scope the installation:

```bash
bash scripts/install.sh \
  https://github.com/acme/shared-skills \
  .agents/skills/code-review \
  v2.1.0 \
  .agents/skills \
  --agent claude
```

## Safety review

### Automated audit

Run `audit.sh` on any skill directory to scan for security patterns:

```bash
bash scripts/audit.sh .agents/skills/code-review
```

The audit checks for:

| Category | Severity | What it detects |
|---|---|---|
| Exfiltration | Critical | `curl --data`, `wget --post`, outbound POST |
| Env harvesting | Critical/Warning | `printenv`, references to KEY/TOKEN/SECRET vars |
| Credential access | Critical | SSH keys, AWS creds, `.env`, service accounts |
| Obfuscation | Critical/Warning | `base64 -d`, `eval $var` |
| Reverse shells | Critical | `/dev/tcp`, netcat listeners, bash reverse shells |
| Curl-pipe-shell | Critical | `curl ... \| bash`, `wget ... \| sh` |
| Prompt injection | Warning | "ignore previous instructions", role hijacking |
| Known malicious | Critical | `rm -rf /`, `chmod 777`, fifo+netcat |

**Interpreting results:**
- **Exit 0 (clean):** No findings. Skill is safe to activate.
- **Exit 1 (warnings):** Review the flagged patterns. Most are false positives in legitimate skills. Check context before activating.
- **Exit 2 (critical):** Do not activate. Review the findings file:line references. If using `install.sh`, the skill was already rolled back.

## Fetching a skill (low-level)

### Prerequisites

- `git` available on PATH
- POSIX tools: `tar`, `sha256sum` or `shasum`, `date`

### Workflow

1. Run the fetch script:
   ```bash
   bash scripts/fetch-remote-skill.sh \
     https://github.com/acme/shared-skills \
     .agents/skills/code-review \
     v2.1.0 \
     ../../.agents/skills
   ```

2. The script will:
   - Shallow-clone the repository at the specified ref
   - Extract the skill directory from the clone
   - Copy it to the target skills directory
   - Compute an integrity hash of the fetched files
   - Generate `.source.yml` from the Jinja template
   - Clean up the temporary clone

3. Verify the result:
   ```bash
   cat .agents/skills/code-review/.source.yml
   ```

### Arguments

| Position | Name | Required | Default | Description |
|---|---|---|---|---|
| 1 | `repo-url` | Yes | — | Git remote URL (HTTPS or SSH) |
| 2 | `skill-path` | Yes | — | Path to skill directory within the source repo |
| 3 | `ref` | No | `HEAD` | Branch, tag, or commit to fetch |
| 4 | `target-dir` | No | `.agents/skills` | Local directory to install the skill into |

## Updating a skill

Re-run the fetch script with the same arguments. The script is idempotent:

- Overwrites local skill files with the latest upstream version
- Generates a fresh `.source.yml` with updated `fetched.at`, `source.commit`, and `integrity.digest`

To update to a new version:

```bash
bash scripts/fetch-remote-skill.sh \
  https://github.com/acme/shared-skills \
  .agents/skills/code-review \
  v3.0.0
```

## Checking drift

To manually check if a fetched skill has drifted from its recorded state:

```bash
# Compute current hash (excluding .source.yml)
CURRENT=$(tar cf - --exclude='.source.yml' -C .agents/skills code-review | sha256sum | cut -d' ' -f1)

# Compare to recorded hash
RECORDED=$(grep 'digest:' .agents/skills/code-review/.source.yml | awk '{print $2}')

[ "$CURRENT" = "$RECORDED" ] && echo "In sync" || echo "Drift detected"
```

## Removing a fetched skill

Delete the skill directory (including `.source.yml`). No other cleanup is required:

```bash
rm -rf .agents/skills/code-review
```

## Converting a fetched skill to local-only

If you have customized a fetched skill and want to take ownership of it locally:

```bash
rm .agents/skills/code-review/.source.yml
```

The skill is now treated as locally-authored. Drift detection no longer applies.

## Verification

Run the smoke test to validate the fetch-and-stamp workflow end-to-end:

```bash
bash scripts/smoke-test.sh
```

The smoke test exercises acceptance criteria AC-1 through AC-5 from ADR-002. See `scripts/smoke-test.sh` for details.

## Skill references

| File | Purpose |
|---|---|
| `references/source-yml-schema.json` | JSON Schema for `.source.yml` validation |
| `references/source-yml.template.j2` | Jinja2 template for `.source.yml` generation |
| `scripts/install.sh` | Install with safety-gated activation |
| `scripts/audit.sh` | Security pattern scanner |
| `scripts/fetch-remote-skill.sh` | Low-level fetch-and-stamp (POSIX fallback) |
| `scripts/smoke-test.sh` | End-to-end verification |
