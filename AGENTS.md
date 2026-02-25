# AGENTS.md

## Documentation lifecycle workflow

### General rules

- Each top-level directory within `docs/` must include a `README.md` with an explanation and index.
- All artifacts MUST be titled AND numbered.
  - Good: `(ADR-192)-Multitenant-Gateway-Architecture.md`
  - Bad: `{ADR} Multitenant Gateway Architectre (#192).md`
- **Every artifact is the authoritative record of its own lifecycle.** Each must embed a lifecycle table in its frontmatter tracking every phase transition with date, commit hash, and notes. Index files (`list-<type>.md`) mirror this data as a project-wide dashboard but are not the source of truth — the artifact is.
- Each doc-type directory keeps a single lifecycle index (`list-<type>.md`, e.g., `list-prds.md`) with one table per phase and commit hash stamps for auditability.

### Lifecycle table format (embedded in every artifact)

```markdown
### Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Planned | 2026-02-24 | abc1234 | Initial creation |
| Active  | 2026-02-25 | def5678 | Dependency X satisfied |
```

Commit hashes reference the repo state at the time of the transition, not the commit that writes the hash stamp itself. Commit first, then stamp the hash and amend — the pre-amend hash is the correct value.

When moving an artifact between phase directories: update the artifact's status field, append a row to its lifecycle table, then update the index file to match.

### Artifact types

| Type | Path | Format | Phases |
|------|------|--------|--------|
| Research / Spikes | `docs/research/` | Folder containing titled `.md` (not `README.md`) | Planned → Active → Complete |
| ADRs | `docs/adr/` | Markdown file directly in phase directory | Proposed → Adopted → Retired · Superseded |
| PRDs | `docs/prd/` | Folder containing titled `.md` + supporting docs | Draft → Review → Approved → Implemented → Deprecated |

### Research spikes (SPIKE-NNN)

- Number in intended execution order — sequence communicates priority.
- Frontmatter must state: question, gate (e.g., Pre-MVP), PRD risks addressed, dependencies, and what it blocks.
- Gating spikes must define go/no-go criteria with measurable thresholds (not just "investigate X").
- Gating spikes must recommend a specific pivot if the gate fails (not just "reconsider approach").
- Spikes belong to the PRD that created them. The PRD owns all spike tables: questions, risks, gate criteria, dependency graph, execution order, phase mappings, and risk coverage. There is no separate research roadmap document.

### PRDs (PRD-NNN)

- Spec file frontmatter must include: title, status, author, created date, last updated date, and linked research artifacts and/or ADRs.
