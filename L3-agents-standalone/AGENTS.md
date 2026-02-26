# AGENTS.md

## Documentation lifecycle workflow

### General rules

- Each top-level directory within `docs/` must include a `README.md` with an explanation and index.
- All artifacts MUST be titled AND numbered.
  - Good: `(ADR-192)-Multitenant-Gateway-Architecture.md`
  - Bad: `{ADR} Multitenant Gateway Architectre (#192).md`
- **Every artifact is the authoritative record of its own lifecycle.** Each must embed a lifecycle table in its frontmatter tracking every phase transition with date, commit hash, and notes. Index files (`list-<type>.md`) mirror this data as a project-wide dashboard but are not the source of truth — the artifact is.
- Each doc-type directory keeps a single lifecycle index (`list-<type>.md`, e.g., `list-prds.md`) with one table per phase and commit hash stamps for auditability.

### Artifact types

| Type | Path | Format | Phases |
|------|------|--------|--------|
| Product Vision | `docs/vision/` | Single markdown file per product/area | Draft → Active → Sunset |
| Epics | `docs/epic/` | Folder containing titled `.md` + supporting docs | Proposed → Active → Complete → Archived |
| PRDs | `docs/prd/` | Folder containing titled `.md` + supporting docs | Draft → Review → Approved → Implemented → Deprecated |
| Research / Spikes | `docs/research/` | Folder containing titled `.md` (not `README.md`) | Planned → Active → Complete |
| ADRs | `docs/adr/` | Markdown file directly in phase directory | Draft → Proposed → Adopted → Retired · Superseded |

### Artifact hierarchy

```
Product Vision (VISION-NNN) — one per product or product area
  ├── Epic (EPIC-NNN) — strategic initiative / major capability
  │     ├── PRD (PRD-NNN) — feature specification
  │     │     └── Implementation Plan (bd epic + swarm)
  │     └── ADR (ADR-NNN) — architectural decision (cross-cutting)
  └── Research Spike (SPIKE-NNN) — can attach to any artifact ↑
```

**Relationship rules:**
- Every Epic MUST reference a parent Vision in its frontmatter.
- Every PRD MUST reference a parent Epic.
- Spikes can belong to any artifact type (Vision, Epic, PRD, ADR). The owning artifact controls all spike tables.
- ADRs are cross-cutting: they link to all affected Epics/PRDs but are not owned by any single one.
- An artifact may only have one parent in the hierarchy but may reference siblings or cousins via `related` links.

For artifact creation, lifecycle transitions, and implementation plan workflows, use the **spec-management** skill.
