# Swain Repository Structure Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create the `cristoslc/swain` repo locally, structure it for `npx skills` discovery, copy the three existing skills plus a governance placeholder, and verify end-to-end installation.

**Architecture:** Standalone Git repo at `~/Documents/code/swain/` with a `skills/` directory containing four skill subdirectories. Each skill has a SKILL.md plus optional `references/` and `scripts/` subdirectories. Dev-only content (docs, AGENTS.md) lives at repo root with no SKILL.md, so `npx skills` ignores it.

**Tech Stack:** Git, `npx skills` CLI, bash, Python 3 (for existing scripts)

---

### Task 1: Create the swain repo and push to GitHub

**Step 1: Create the GitHub repo**

Run:
```bash
gh repo create cristoslc/swain --public --description "Agent governance, spec management, and execution tracking skills" --clone --gitignore='' ~/Documents/code/swain
```
Expected: Repo created on GitHub and cloned locally.

If `gh` auth fails or the repo already exists, handle accordingly.

**Step 2: Verify the local clone**

Run:
```bash
ls -la ~/Documents/code/swain/.git
```
Expected: `.git` directory exists.

**Step 3: Commit**

```bash
cd ~/Documents/code/swain && git commit --allow-empty -m "chore: initialize swain repo"
git push -u origin main
```

---

### Task 2: Create the directory structure and repo scaffolding

Working directory: `~/Documents/code/swain/`

**Step 1: Create the skills directory tree**

```bash
cd ~/Documents/code/swain
mkdir -p skills/spec-management/references skills/spec-management/scripts
mkdir -p skills/execution-tracking/references skills/execution-tracking/scripts
mkdir -p skills/release
mkdir -p skills/governance
mkdir -p docs
```

**Step 2: Create .gitignore**

Write `~/Documents/code/swain/.gitignore`:
```
# Runtime artifacts
specwatch.log
*.log

# OS files
.DS_Store
Thumbs.db

# Node
node_modules/

# Skill installation artifacts (consumer-side)
skills-lock.json
```

**Step 3: Create LICENSE**

Write `~/Documents/code/swain/LICENSE` with MIT license text. Use `cristos` as the copyright holder and `2026` as the year.

**Step 4: Create CLAUDE.md**

Write `~/Documents/code/swain/CLAUDE.md`:
```
@AGENTS.md
```

**Step 5: Create AGENTS.md**

Write `~/Documents/code/swain/AGENTS.md` — adapted from `L3-agents-core/AGENTS.md` for swain's own development:

```markdown
# AGENTS.md

## Skill routing

When the user wants to create, plan, write, update, transition, or review any documentation artifact (Vision, Journey, Epic, Story, Agent Spec, Spike, ADR, Persona, Runbook, Bug) or their supporting docs, **always invoke the spec-management skill**.

**For all task tracking and execution progress**, use the **execution-tracking** skill instead of any built-in todo or task system.

## Pre-implementation protocol (MANDATORY)

Implementation of any SPEC artifact (Epic, Story, Agent Spec, Spike) requires an execution-tracking plan **before** writing code. Invoke the spec-management skill — it enforces the full workflow.

## Issue Tracking

This project uses **bd (beads)** for all issue tracking. Do NOT use markdown TODOs or task lists. Invoke the **execution-tracking** skill for all bd operations.
```

**Step 6: Create README.md**

Write `~/Documents/code/swain/README.md`:

```markdown
# swain

Agent governance, spec management, and execution tracking skills for AI coding agents.

Named for the boatswain's mate — the officer who maintains rigging and enforces standards.

## Install

```bash
npx skills add cristoslc/swain
```

This installs all skills into your project's `.claude/skills/` directory:

- **governance** — Always-on routing rules, protocols, and conventions
- **spec-management** — Artifact lifecycle (Vision, Epic, Spec, Story, ADR, Spike, Bug, etc.)
- **execution-tracking** — External task management integration (bd/beads)
- **release** — Version bump, changelog, and git tagging

## Requirements

- Node.js (for `npx skills`)
- Python 3 (for spec-management and execution-tracking scripts)
- Git

## Companion

[obra/superpowers](https://github.com/obra/superpowers) is a recommended companion install for plan authoring (brainstorming, writing-plans). Not a dependency — swain works without it.

## License

MIT
```

**Step 7: Commit scaffolding**

```bash
cd ~/Documents/code/swain
git add -A
git commit -m "chore: add repo scaffolding (dirs, README, LICENSE, AGENTS.md, .gitignore)"
```

---

### Task 3: Copy spec-management skill

Working directory: `~/Documents/code/swain/`

**Step 1: Copy all spec-management files**

```bash
cp -R /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/spec-management/SKILL.md ~/Documents/code/swain/skills/spec-management/
cp -R /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/spec-management/references/* ~/Documents/code/swain/skills/spec-management/references/
cp -R /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/spec-management/scripts/* ~/Documents/code/swain/skills/spec-management/scripts/
```

**Step 2: Verify file count matches**

```bash
find /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/spec-management -type f | wc -l
find ~/Documents/code/swain/skills/spec-management -type f | wc -l
```
Expected: Same count (26 files).

**Step 3: Verify scripts are executable**

```bash
ls -la ~/Documents/code/swain/skills/spec-management/scripts/
```
Expected: `specwatch.sh` and `specgraph.sh` have execute permission. If not:
```bash
chmod +x ~/Documents/code/swain/skills/spec-management/scripts/*.sh
```

**Step 4: Commit**

```bash
cd ~/Documents/code/swain
git add skills/spec-management/
git commit -m "feat: add spec-management skill"
```

---

### Task 4: Copy execution-tracking skill

Working directory: `~/Documents/code/swain/`

**Step 1: Copy all execution-tracking files**

```bash
cp /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/execution-tracking/SKILL.md ~/Documents/code/swain/skills/execution-tracking/
cp -R /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/execution-tracking/references/* ~/Documents/code/swain/skills/execution-tracking/references/
cp -R /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/execution-tracking/scripts/* ~/Documents/code/swain/skills/execution-tracking/scripts/
```

**Step 2: Verify file count matches**

```bash
find /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/execution-tracking -type f | wc -l
find ~/Documents/code/swain/skills/execution-tracking -type f | wc -l
```
Expected: Same count (3 files).

**Step 3: Verify ingest-plan.py is executable**

```bash
ls -la ~/Documents/code/swain/skills/execution-tracking/scripts/ingest-plan.py
```
If not executable:
```bash
chmod +x ~/Documents/code/swain/skills/execution-tracking/scripts/ingest-plan.py
```

**Step 4: Commit**

```bash
cd ~/Documents/code/swain
git add skills/execution-tracking/
git commit -m "feat: add execution-tracking skill"
```

---

### Task 5: Copy release skill

Working directory: `~/Documents/code/swain/`

**Step 1: Copy SKILL.md**

```bash
cp /Users/cristos/Documents/code/LLM-personal-agent-patterns/.claude/skills/release/SKILL.md ~/Documents/code/swain/skills/release/
```

**Step 2: Verify**

```bash
head -10 ~/Documents/code/swain/skills/release/SKILL.md
```
Expected: YAML frontmatter with `name: release`.

**Step 3: Commit**

```bash
cd ~/Documents/code/swain
git add skills/release/
git commit -m "feat: add release skill"
```

---

### Task 6: Create governance skill placeholder

Working directory: `~/Documents/code/swain/`

**Step 1: Write governance SKILL.md placeholder**

Write `~/Documents/code/swain/skills/governance/SKILL.md`:

```markdown
---
name: governance
description: Always-on agent governance — skill routing rules, pre-implementation protocol, and issue tracking conventions. This skill loads at session start and ensures the host project's agent context file contains the governance routing rules. On first use, it detects the agent platform and injects governance content into the appropriate config file.
license: MIT
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
metadata:
  short-description: Agent routing and governance rules
  version: 0.1.0
  author: cristos
---

# Governance

> **Placeholder** — Full governance skill content is defined by SPEC-006. This stub establishes the skill's presence for `npx skills` discovery.

This skill delivers always-on routing rules, pre-implementation protocols, and issue tracking conventions to consumer projects.
```

**Step 2: Commit**

```bash
cd ~/Documents/code/swain
git add skills/governance/
git commit -m "feat: add governance skill placeholder (SPEC-006 defines content)"
```

---

### Task 7: Validate npx skills discovery

**Step 1: List skills from local path**

```bash
npx skills add ~/Documents/code/swain --list
```
Expected: All 4 skills listed (spec-management, execution-tracking, release, governance). No dev-only content (docs, AGENTS.md, README) listed.

If discovery fails, check:
- Are SKILL.md files in `skills/<name>/SKILL.md`?
- Is there a root SKILL.md blocking recursion? (There should NOT be one.)
- Try with `--full-depth` flag to see if that changes results.

**Step 2: Test installation in a temp project**

```bash
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
git init
npx skills add ~/Documents/code/swain --all --yes
```
Expected: Skills installed into `.claude/skills/`.

**Step 3: Verify installed files**

```bash
ls "$TMPDIR/.claude/skills/"
```
Expected: Four directories: `spec-management`, `execution-tracking`, `release`, `governance`.

```bash
ls "$TMPDIR/.claude/skills/spec-management/references/" | head -5
ls "$TMPDIR/.claude/skills/execution-tracking/scripts/"
```
Expected: Reference files and scripts present.

**Step 4: Verify no dev-only content leaked**

```bash
ls "$TMPDIR/docs" 2>/dev/null && echo "LEAK: docs/" || echo "OK: no docs/"
ls "$TMPDIR/AGENTS.md" 2>/dev/null && echo "LEAK: AGENTS.md" || echo "OK: no AGENTS.md"
ls "$TMPDIR/README.md" 2>/dev/null && echo "LEAK: README.md" || echo "OK: no README.md"
```
Expected: All "OK" — no leaks.

**Step 5: Clean up**

```bash
rm -rf "$TMPDIR"
```

---

### Task 8: Push to GitHub and final verification

**Step 1: Push all commits**

```bash
cd ~/Documents/code/swain
git push origin main
```

**Step 2: Verify GitHub discovery**

```bash
npx skills add cristoslc/swain --list
```
Expected: All 4 skills listed from the GitHub repo (not local path).

**Step 3: Commit plan verification results**

Return to the LLM-personal-agent-patterns repo and note verification results. No code changes needed in this repo — the swain repo is standalone.
