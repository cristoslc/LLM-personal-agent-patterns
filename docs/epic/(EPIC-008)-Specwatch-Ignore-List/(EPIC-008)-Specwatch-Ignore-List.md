---
title: "Specwatch Ignore List"
artifact: EPIC-008
status: Active
author: cristos
created: 2026-03-05
last-updated: 2026-03-05
parent-vision: VISION-001
success-criteria:
  - "Specwatch reads a per-repo ignore file (e.g., .agents/specwatch-ignore) that lists path patterns to suppress from stale-reference reports"
  - "Ignored entries are excluded from both scan and watch modes — they do not appear in specwatch.log or agent warnings"
  - "The ignore file supports glob patterns and inline comments, following .gitignore-style conventions"
  - "The spec-management skill's before/after bookends respect the ignore list without any workflow changes"
depends-on: []
addresses: []
---

# Specwatch Ignore List

## Goal / Objective

Specwatch's stale-reference scanner currently flags every broken path it finds, with no way to suppress known false positives or intentionally broken references. This creates noise during the before/after bookend scans — agents must manually acknowledge the same false positives every session. Add a per-repo ignore list so that known-benign stale references can be suppressed without weakening the scanner's coverage for real issues.

## Scope Boundaries

**In scope:**
- A `.agents/specwatch-ignore` file (or similar) that specwatch reads at scan time
- Glob-pattern matching against source file paths, broken link paths, or artifact IDs
- Inline comments (`#`) and blank-line handling
- Integration with both `scan` and `watch` subcommands
- Documentation in the spec-management skill references

**Out of scope:**
- GUI or interactive ignore-list management
- Per-line suppression comments inside markdown files (too invasive)
- Automatic ignore-list population — entries are manually curated

## Child Specs

Updated as Agent Specs are created under this epic.

## Key Dependencies

Builds on the existing specwatch infrastructure delivered by EPIC-005. No blocking external dependencies.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Proposed | 2026-03-05 | 47b3287 | Initial creation |
| Active | 2026-03-05 | 1c0fe84 | Scope clear, no spikes needed |
