---
title: "Spec Dependency Graph Tracking"
artifact: SPIKE-006
status: Planned
author: cristos
created: 2026-03-02
last-updated: 2026-03-02
question: "What is the best approach to track and query the dependency graph between spec artifacts in a way that is LLM-friendly without requiring full-document reads?"
gate: Pre-Epic (dependency graph epic TBD)
risks-addressed:
  - Agent reads all docs to discover blocking relationships
  - Stale cross-references when artifacts transition phases
  - No automated way to answer "what does EPIC-003 block?"
dependencies:
  - SPIKE-001 (bd CLI selection — confirms bd as the task backend)
blocks: []
---

# Spec Dependency Graph Tracking

## Question

Certain spec artifacts block other artifacts (e.g., a Spike gates an Epic; an Epic's completion gates downstream Specs). Today, these relationships are encoded only in YAML frontmatter (`blocks:`, `dependencies:`, `parent-epic:`, `parent-vision:`) scattered across individual files. An LLM must read every artifact to reconstruct the graph — expensive, slow, and error-prone when the corpus grows.

What is the best approach to track and query these inter-artifact dependencies in a structured, automated, LLM-friendly way?

### Sub-questions

1. **Beads as graph backend:** Could bd beads model spec artifacts (one bead per artifact, `--spec-id SPEC-003`, `--external-ref` for doc paths) with `bd dep add` edges? This gives `bd graph`, `bd ready`, `bd blocked`, `bd dep tree` for free.
2. **Artifacts inside beads:** Should the markdown documents themselves live in `.beads/`? Or does that make them hard to browse in `docs/`?
3. **Symlinks for dual access:** If artifacts live in beads, could symlinks from `docs/<type>/Phase/` point into `.beads/` so humans still browse the familiar folder tree? What breaks (git, editors, CI)?
4. **Multiple document keys:** Does bd support linking more than one document to a bead? (Answer from `bd create --help`: `--spec-id` is a single string, `--external-ref` is a single string, but `--metadata` accepts arbitrary JSON — so multiple refs are possible via metadata.)
5. **Alternatives to beads:** Would a simpler approach — frontmatter extraction, a master index, or a lightweight script — achieve the same goal with less machinery?

## Candidates

### Candidate A: Beads as a shadow dependency graph

Create one bd bead per spec artifact. Use `--spec-id` for the artifact ID (e.g., `SPEC-003`), `--external-ref` for the doc path, `--labels` for artifact type and phase. Model all blocking relationships with `bd dep add`. Artifacts stay in `docs/` as markdown — beads are a parallel index, not the storage layer.

**Strengths:**
- `bd graph --all --html` gives interactive dependency visualization for free
- `bd ready` / `bd blocked` answer "what can I work on next?" instantly
- `bd query "spec=EPIC-*"` finds all epic beads; `bd dep tree` shows their children
- `bd dep cycles` catches circular dependencies automatically
- `--metadata` can store arbitrary cross-refs (multiple doc paths, related artifacts)
- Already installed (v0.57.0); execution-tracking skill already knows bd

**Weaknesses:**
- Two sources of truth: frontmatter in docs AND beads graph — sync can drift
- Requires a sync mechanism (hook? script? skill procedure?) to keep beads in sync with doc changes
- Beads database (`.beads/dolt/`) adds repo weight
- Beads' status model (`open`/`in_progress`/`blocked`/`closed`) doesn't map 1:1 to artifact phases (Draft/Active/Complete/Abandoned etc.) — would need labels or metadata for phase tracking

### Candidate B: Artifacts live in beads (with symlinks)

Move the canonical markdown files into `.beads/` storage. Create symlinks from `docs/<type>/Phase/` pointing into `.beads/` so the familiar folder structure persists for human browsing.

**Strengths:**
- Single source of truth — the bead IS the artifact
- No sync problem

**Weaknesses:**
- bd has no document storage subsystem — `.beads/` contains a Dolt database, not a file tree. There is nowhere to put markdown files "inside" beads
- Symlinks into a database directory are nonsensical — Dolt stores data as SQL tables, not individual files
- **This candidate is not viable** given bd's architecture. bd tracks issues (rows in a database), not files on disk. Moving artifacts into beads would require either: (a) storing the full markdown in the `description` field (breaks editor workflows, git diffs, file-based tooling), or (b) a custom document storage layer that doesn't exist
- Git handles symlinks inconsistently across platforms (Windows compat issues)

**Verdict: Eliminated.** bd is an issue tracker, not a document store. Symlinks into `.beads/` don't make architectural sense.

### Candidate C: Frontmatter extraction + master index

Write a script (or skill procedure) that:
1. Globs all `docs/**/*.md` files
2. Parses YAML frontmatter (artifact ID, status, parent refs, blocks, dependencies)
3. Emits a single `docs/dependency-graph.md` (or `.json`) with the full adjacency list
4. Optionally generates a Mermaid diagram

**Strengths:**
- Zero new dependencies — works with existing files and frontmatter conventions
- Single-file output is trivially LLM-readable (one `Read` call)
- Markdown + Mermaid output is human-readable too
- Git-friendly: the index file is a plain text diff
- Already have all the frontmatter fields (`blocks:`, `dependencies:`, `parent-epic:`, etc.)

**Weaknesses:**
- Must be regenerated on every artifact change (could be a pre-commit hook or skill step)
- No interactive querying (`bd ready` equivalent requires parsing the index)
- No cycle detection without additional logic
- Script maintenance burden (parsing YAML frontmatter, handling edge cases)

### Candidate D: Hybrid — frontmatter is source of truth, bd is the query layer

Keep artifacts in `docs/` with frontmatter as the canonical dependency data. A sync script reads frontmatter and upserts bd beads to mirror the graph. bd provides the query/visualization layer only.

**Strengths:**
- Frontmatter remains the single source of truth (no dual-write problem)
- bd provides `graph`, `ready`, `blocked`, `dep tree`, `dep cycles` as a read-only query layer
- Sync is one-directional: docs → beads (simpler than bidirectional)
- If sync breaks, the docs are still complete and correct
- Can layer on incrementally — start with the master index (Candidate C), add bd sync later

**Weaknesses:**
- Still requires a sync mechanism, though one-directional is simpler
- Beads status/phase mismatch still needs a mapping convention
- Two representations of the same data, even if one is authoritative

### Candidate E: Enhanced list indexes (status quo++)

Extend the existing `list-<type>.md` index files to include dependency columns. Add a single `docs/dependencies.md` cross-index showing all blocking relationships. No new tooling.

**Strengths:**
- Lowest effort — extends what already exists
- Pure markdown, LLM-readable, no tooling dependencies
- Maintained by the existing index refresh step in spec-management

**Weaknesses:**
- Manual maintenance (even with skill procedures, the refresh is file-based)
- No graph visualization or automated querying
- Doesn't scale well past ~50 artifacts (tables get unwieldy)
- No cycle detection

## Go / No-Go Criteria

| Criterion | Threshold | Measurement |
|-----------|-----------|-------------|
| Query cost | An LLM can determine "what blocks artifact X?" in ≤2 tool calls (Read/Bash) | Test with 3 sample queries against a prototype |
| Sync reliability | Dependency graph stays consistent with frontmatter after 10 artifact operations | Run the sync mechanism 10 times, verify no drift |
| Setup cost | Can bootstrap the graph from existing ~25 artifacts in <5 minutes | Time the initial sync |
| Visualization | Can produce a visual dependency graph (Mermaid, HTML, or DOT) on demand | Generate one graph from the prototype |

**Go threshold:** At least one candidate meets all four criteria.

## Pivot Recommendation

If no candidate meets the go threshold, fall back to **Candidate E** (enhanced list indexes) as a zero-dependency baseline, and revisit when the artifact count exceeds ~30 and the manual approach becomes painful.

## Recommendation

Based on the analysis above, **Candidate D (hybrid)** is recommended if the sync mechanism can be made reliable and low-friction. It preserves frontmatter as the source of truth while gaining bd's powerful query and visualization capabilities.

If the sync mechanism proves too fragile or complex during prototyping, **Candidate C (frontmatter extraction + master index)** is the pragmatic fallback — it provides the core value (LLM-readable dependency graph in one file) with zero new dependencies.

Candidate B is eliminated. Candidate A has the dual-write risk that Candidate D avoids. Candidate E is the minimal baseline but doesn't achieve the "automated, queryable graph" goal.

## Findings

_To be populated during Active phase._

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-02 | 779a93c | Initial creation |
