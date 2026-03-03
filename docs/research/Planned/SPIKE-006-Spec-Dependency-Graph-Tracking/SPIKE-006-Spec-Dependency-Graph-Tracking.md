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
  - SPIKE-001 (bd CLI selection — confirms bd as the task backend, gates EPIC-004)
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

### Candidate F: On-the-fly frontmatter grep (no persistent index)

Don't build an index at all. When an LLM needs the dependency graph, it runs a targeted `grep` for frontmatter fields (`blocks:`, `dependencies:`, `parent-epic:`) across `docs/`, parses the matches inline, and answers the question. The "index" is the query itself.

**Strengths:**
- Zero maintenance — no index to drift, no sync to break
- Always fresh — reads live frontmatter every time
- No new files, tools, or dependencies
- Works today with existing Grep + Read tools

**Weaknesses:**
- Cost scales linearly with artifact count (one grep per query, then reads for context)
- Cannot answer transitive questions ("what transitively blocks X?") without multiple rounds
- No visualization unless the LLM builds it ad hoc
- No cycle detection
- Answers the question "is this actually a problem at ~25 artifacts?" — maybe not yet

### Candidate G: SQLite index built from frontmatter

A build step (script or pre-commit hook) parses all frontmatter into a local SQLite database (`docs/.deps.sqlite`). Agents query with `sqlite3` — standard SQL for graph traversal (recursive CTEs for transitive dependencies), cycle detection, filtering by phase/type.

**Strengths:**
- SQL is a universal query language — any agent or script can query it
- Recursive CTEs handle transitive dependency queries natively
- Single-file database, git-friendly (or gitignored and rebuilt on demand)
- Can answer complex queries: "all Draft artifacts that transitively block an Active Epic"
- Lightweight — no server, no Dolt, just `sqlite3` (pre-installed on macOS)

**Weaknesses:**
- Build step required (same as Candidate C)
- Binary file if git-tracked; rebuild-on-demand if gitignored
- No built-in visualization (would need a script to emit Mermaid/DOT from query results)
- Yet another tool in the chain (though sqlite3 is ubiquitous)

### Candidate H: Single YAML/JSON graph file as source of truth

Invert the current model: instead of each artifact owning its own dependency frontmatter, maintain a single `docs/graph.yaml` (or `.json`) that declares all artifacts and their edges. Artifacts still have frontmatter for their own metadata (title, status, author) but dependency relationships live only in the graph file.

**Strengths:**
- Single source of truth for all edges — no scatter, no sync
- One file to read for the full graph (LLM-optimal)
- Trivially parseable by any tool (YAML/JSON)
- Easy to validate (schema check, cycle detection) with a simple script
- Diff-friendly — all relationship changes show up in one file

**Weaknesses:**
- Breaks the current convention where each artifact declares its own relationships
- Merge conflicts if two people edit the graph file simultaneously (less relevant for solo dev)
- Artifacts lose self-contained context — reading a single artifact no longer tells you what it blocks/depends on without also reading the graph file
- Migration effort to extract existing frontmatter relationships into the graph file

### Candidate I: bd kv store as a lightweight edge index

Use bd's built-in `bd kv` key-value store to cache dependency edges without creating full beads for each artifact. Keys are artifact IDs, values are JSON adjacency lists. A skill procedure reads/writes the kv store as part of the index refresh step.

**Strengths:**
- Uses existing bd infrastructure — no new tool
- Lighter than full beads (no issue lifecycle, no status mapping needed)
- `bd kv get EPIC-003` returns its edges instantly
- `bd kv list` dumps the full graph in one call

**Weaknesses:**
- kv store has no graph operations (`dep tree`, `graph`, `ready`, `blocked`, `cycles`) — just flat key lookups
- Loses all the query/visualization power that makes bd attractive in the first place
- Still a second source of truth alongside frontmatter
- Effectively a worse version of Candidate C (master index) but stored in `.beads/` instead of a plain file

### Candidate J: Skill procedure as the query layer (no persistent state)

The spec-management skill itself becomes the "graph engine." Add procedures like `query-blockers <artifact-id>` and `render-dependency-graph` that glob, parse frontmatter, build an in-memory graph, and answer the query — all within a single skill invocation. No persistent index file. The graph is ephemeral, computed on demand.

**Strengths:**
- No persistent state to drift — always computed fresh
- Encapsulated in the skill — no external tools, no files to maintain
- Can include cycle detection, transitive queries, Mermaid output as procedure logic
- The skill already reads/writes artifacts — adding graph traversal is a natural extension

**Weaknesses:**
- Computed every time — cost grows with artifact count (though ~25 is trivial)
- Can't be queried outside the skill (e.g., from a shell script or another tool)
- Logic lives in skill instructions (natural language) — harder to test/debug than a script
- If the skill context is large, the graph computation competes for context window space

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

_To be determined during Active phase after prototyping._

## Findings

_To be populated during Active phase._

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-03-02 | 779a93c | Initial creation |
