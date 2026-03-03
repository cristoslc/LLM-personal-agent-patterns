---
title: "Specwatch Log Strategy"
artifact: SPIKE-007
status: Complete
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

### Dimension 1: What path patterns actually appear in this repo?

Audited all 43 markdown files in `docs/`. **~350 path-like references total**, broken into four categories:

| Category | Count | Reference type | Staleness risk |
|----------|-------|---------------|----------------|
| Markdown links `[text](path)` | 49 | Relative file paths (`./`, `../../`) | **HIGH** — break on file move |
| Frontmatter fields | 51 | Bare artifact IDs (`EPIC-003`) | **NONE** — IDs are stable |
| Prose mentions | 195+ | Bare artifact IDs | **NONE** — semantic labels |
| Code block paths | ~25 | Repo-root-relative paths | **LOW** — illustrative, rarely navigated |

**Key insight:** Only **49 markdown links** (14% of all references) use actual file paths. The rest use bare artifact IDs which are inherently immune to file moves. The specwatch scanner only needs to check markdown link targets and optionally code block paths — not the full ~350 references.

**Markdown link distribution:**
- Index files (`list-*.md`) linking to artifacts: 29 links
- Epic files linking to child stories: 14 links (cross-directory `../../`)
- Journey/persona cross-references: 5 links
- External repo link: 1 link

### Dimension 2: How reliably can we resolve a moved file?

Three-tier resolution tested against actual repo history (9 historical renames):

| Tier | Method | Success rate | Speed |
|------|--------|-------------|-------|
| 1. Artifact ID extraction | Extract `(TYPE-NNN)` from path, `find docs -name "*TYPE-NNN*"` | **100%** (all artifact files have globally unique IDs) | <50ms |
| 2. Git rename tracking | `git log --all --follow --diff-filter=R -- <stale-path>` | **100%** (git tracks all renames) | ~200ms |
| 3. Filename search | `find docs -name "<basename>"` for non-artifact files | **100%** (non-artifact files like `list-*.md` never move) | <50ms |

**False positive rate: 0%.** Artifact IDs are globally unique across the entire `docs/` tree. No two files share an artifact ID. The `(TYPE-NNN)` parenthetical pattern is unambiguous.

**Move patterns observed:**
- ADR phase moves: filename unchanged, only directory changes (`Draft/` → `Adopted/`)
- Spike phase moves: directory changes (`Planned/` → `Complete/` or `Abandoned/`)
- Non-artifact files: **zero moves in entire git history**

### Dimension 3: UX for each strategy

**Strategy 1 — Warn-only log:**
```
[specwatch] STALE docs/epic/(EPIC-001)-Skills-Ecosystem-Zero-Effort-Distribution/(EPIC-001)-Skills-Ecosystem-Zero-Effort-Distribution.md:18
  broken: ../../adr/Draft/(ADR-001)-Subtree-Split-Distribution-Model.md
```
Agent must investigate manually. For 49 total links, this means potentially re-scanning on every warning.

**Strategy 2 — Warn + suggest:**
```
[specwatch] STALE docs/epic/(EPIC-001)-Skills-Ecosystem-Zero-Effort-Distribution/(EPIC-001)-Skills-Ecosystem-Zero-Effort-Distribution.md:18
  broken:  ../../adr/Draft/(ADR-001)-Subtree-Split-Distribution-Model.md
  found:   ../../adr/Adopted/(ADR-001)-Subtree-Split-Distribution-Model.md
  action:  review and apply
```
Agent has full context to act. Apply is a single `Edit` tool call. Visible in `git diff`.

**Strategy 3 — Warn + resolve + log:**
```
[specwatch] FIXED docs/epic/(EPIC-001)-Skills-Ecosystem-Zero-Effort-Distribution/(EPIC-001)-Skills-Ecosystem-Zero-Effort-Distribution.md:18
  was:     ../../adr/Draft/(ADR-001)-Subtree-Split-Distribution-Model.md
  now:     ../../adr/Adopted/(ADR-001)-Subtree-Split-Distribution-Model.md
  reverted with: git checkout -- "docs/epic/(EPIC-001)-Skills-Ecosystem-Zero-Effort-Distribution/(EPIC-001)-Skills-Ecosystem-Zero-Effort-Distribution.md"
```
Changes applied silently. Revert is single command, but mutations happen outside agent/user control.

### Dimension 4: Blast radius of a bad resolution

With **0% false positive rate** on artifact ID extraction, a bad resolution would require:
- A file to match the ID pattern but not be the correct target (impossible given global uniqueness), OR
- A non-artifact path to match the wrong file (only ~25 code block paths, and non-artifact files never move)

**Worst case:** A code block example path like `docs/dependency-graph.md` (hypothetical, from SPIKE-006 prose) gets "resolved" to a similarly-named file. This is harmless since it's inside a code fence — but it would be a misleading edit.

**Revert cost:** Always a single `git checkout -- <file>` since specwatch edits one line at a time.

## Gate Decision

**Strategy 2 (Warn + suggest) — GO.**

Rationale against the gate criteria:
1. Stale references surfaced before commit: **YES** — watcher runs in background, spec-management checks log before operations
2. Agent has enough context to act: **YES** — suggestion includes old path, new path, and source location
3. No silent mutations: **YES** — agent applies fixes explicitly via `Edit`, visible in `git diff`
4. Log format parseable: **YES** — structured `broken:`/`found:`/`action:` fields

**Strategy 3 (auto-resolve) — technical GO but unnecessary.** Resolution heuristics pass all thresholds (0% false positives, <50ms per reference, trivially revertible). However, with only 49 markdown links at risk, the complexity cost of auto-resolution isn't justified. Strategy 2 gives the agent identical information with full control.

**Strategy 1 (warn-only) — NO-GO.** Fails criterion 2: the agent doesn't have enough context to act without re-scanning. Since resolution is trivially cheap and 100% reliable, omitting the suggestion is a needless tax on every warning.

## Recommendation

Implement **Strategy 2 (Warn + suggest)** with two scan modes:

1. **Event-driven scan** (on fswatch event): Check only the moved/renamed file's artifact ID against all markdown links in `docs/`. Fast because artifact ID extraction + grep is <200ms.
2. **Full scan** (on spec-management invocation or `specwatch scan`): Check all 49 markdown link targets for existence. Runs in <1s for the current repo size.

The log file should use a structured format parseable by spec-management:
```
# Specwatch log — repo: LLM-personal-agent-patterns
# Scanned: 2026-03-03T14:22:00Z

STALE <source-file>:<line>
  broken: <relative-path-as-written>
  found: <suggested-new-path>
  artifact: <TYPE-NNN>

STALE <source-file>:<line>
  broken: <relative-path-as-written>
  found: NONE
  artifact: UNKNOWN
```

Spec-management reads this log at the start of every operation. If entries exist, it surfaces them as warnings before proceeding.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-03 | dc83645 | Initial creation |
