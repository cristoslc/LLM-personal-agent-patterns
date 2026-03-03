---
title: "Specwatch Log Strategy"
artifact: SPIKE-007
status: Planned
author: cristos
created: 2026-03-03
last-updated: 2026-03-03
question: "Should specwatch be warn-only (log stale refs for spec-management to check), or should it also attempt resolution and log the resolution?"
gate: Pre-implementation
risks-addressed:
  - "Stale path references accumulate silently during lifecycle transitions"
  - "Agent resolution attempts could introduce incorrect fixes without human review"
depends-on: []
---

# Specwatch Log Strategy

## Question

When specwatch detects a stale path reference, what should it do with that information?

Three candidate strategies:

1. **Warn-only**: Log the stale reference (file, line, broken path). Spec-management checks the log at the start of each operation and surfaces warnings to the agent. No automatic resolution.

2. **Warn + suggest**: Log the stale reference AND a suggested resolution (e.g., "file moved to docs/adr/Adopted/(ADR-005)-Foo.md"). Agent or user decides whether to apply.

3. **Warn + resolve + log resolution**: Attempt to find where the file moved (by artifact ID or filename pattern), apply the fix, and log what was changed. Resolution is logged separately so it can be reviewed or reverted.

## Go / No-Go Criteria

- **GO for a strategy** if it satisfies ALL of:
  1. Stale references are surfaced before they get committed (not just detected post-hoc)
  2. The agent has enough context to act on the warning without manual investigation
  3. No silent mutations to artifact content (every change is visible in git diff)
  4. The log format is parseable by both humans and spec-management skill logic
- **NO-GO for auto-resolution** if ANY of:
  1. Resolution heuristics produce >10% false positives on a representative sample of path references in this repo
  2. The resolution step takes >2s per reference (blocking the watcher event loop)
  3. Auto-applied fixes cannot be trivially reverted (single `git checkout -- <file>`)

## Pivot Recommendation

If auto-resolution fails the gate: fall back to Strategy 2 (warn + suggest). The suggestion is logged but never applied automatically. Spec-management presents suggestions and the agent applies them explicitly, giving full git-diff visibility.

## Findings

_To be populated during Active phase._

### Analysis dimensions

1. **What path patterns actually appear in this repo?** — Audit `docs/` for all path-like references; classify by type (relative link, frontmatter field, prose mention, Mermaid node)
2. **How reliably can we resolve a moved file?** — Given a stale path, how often can we find the new location by artifact ID, filename, or git log?
3. **What's the UX for each strategy?** — Mock up the log output and the spec-management integration for each candidate
4. **What's the blast radius of a bad resolution?** — If a heuristic guesses wrong, how bad is the damage and how easy is the revert?

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-03 | _pending_ | Initial creation |
