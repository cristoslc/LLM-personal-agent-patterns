---
title: "SPEC-006 Governance Skill"
artifact: SPEC-006
status: Draft
author: cristos
created: 2026-03-06
last-updated: 2026-03-06
parent-epic: EPIC-006
linked-research: []
linked-adrs:
  - ADR-005
depends-on:
  - SPEC-005
addresses: []
execution-tracking: required
---

# SPEC-006 Governance Skill

## Problem Statement

The framework's governance layer (skill routing rules, pre-implementation protocol, issue tracking conventions) currently lives in AGENTS.md and is distributed via the subtree split pipeline. This content needs to become a SKILL.md-based skill that delivers always-on context to the agent, with first-use setup that injects governance rules into the host project's agent configuration.

## External Behavior

**Inputs:**
- Installed via `npx skills add cristos/swain` (bundled with other skills)
- First invocation triggers setup: detects agent platform and existing config

**Outputs:**
- Governance routing rules appended to the host project's context file (CLAUDE.md, .cursor/rules/, etc.)
- Subsequent sessions find rules already in place and skip setup

**Preconditions:**
- Swain skills installed via `npx skills add`
- Agent session active with access to filesystem

**Postconditions:**
- Agent context file contains: skill routing table, pre-implementation protocol, issue tracking conventions
- Other swain skills (spec-management, execution-tracking) are routable via the injected routing rules

## Acceptance Criteria

1. Given a fresh project with swain skills installed but no governance config, when the agent starts a session and loads the governance skill, then it detects the missing config and proposes appending governance rules
2. Given a project where governance rules are already in the agent context file, when the governance skill loads, then it skips setup silently
3. Given a Cursor IDE project (`.cursor/rules/`), when the governance skill runs first-use setup, then it writes rules in the appropriate format for Cursor
4. Given the governance skill's SKILL.md, when loaded by Claude Code, then the skill description triggers loading at session start (high-priority routing)
5. Given the governance content, when injected, then it includes: skill routing table, pre-implementation protocol, and issue tracking conventions — matching the current AGENTS.md content

## Scope & Constraints

**In scope:**
- SKILL.md for the governance skill with always-on trigger language
- First-use setup logic (platform detection, config injection)
- Content extraction from current AGENTS.md into governance SKILL.md
- Idempotent setup (safe to run multiple times)

**Out of scope:**
- Modifying the governance content itself (routing rules, protocols) — content stays the same
- Supporting agents beyond Claude Code and Cursor in the initial version
- Automatic updates to governance rules after initial injection

## Implementation Approach

1. Extract governance content from `L3-agents-core/AGENTS.md` into `skills/governance/SKILL.md`
2. Write the SKILL.md description to trigger at session start ("always invoke this skill at the start of every session")
3. Add first-use detection: check for routing rules in CLAUDE.md / .cursor/rules/
4. Add platform-adaptive injection: detect Claude Code vs Cursor and write appropriate format
5. Test idempotency: multiple runs should not duplicate content

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-06 | d7c0701 | Initial creation |
