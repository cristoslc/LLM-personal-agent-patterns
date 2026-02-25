# AGENTS.md

## Documentation lifecycle workflow

Use the following structure and lifecycle tracking conventions for new and moved documentation. 
- Each top-level directory within `docs/` must include at least a `README.md` explaining it and keeping an index list.
- All artifacts MUST be titled (`multitenant-gateway-architecture`) AND numbered (e.g., `SPIKE-001`, `ADR-192`, etc.)
  - Good: `(ADR-192)-Multitenant-Gateway-Architecture.md`
  - BAD: `{ADR} Multitenant Gateway Architectre (#192).md`

- Research artifacts live under `docs/research/` with phase directories:
  - `Planned/`
  - `Active/`
  - `Complete/`
- Every research artifact must be a folder (not a single markdown file). The main document must be a titled markdown file (e.g., `Flock-Phone-Detector.md`), not `README.md`.
- Research spikes (SPIKE-NNN) follow additional conventions:
  - Number spikes in intended execution order, not by theme or discovery order. The sequence communicates priority: SPIKE-002 should be worked before SPIKE-003.
  - Each spike document must state: the question it answers, the gate it belongs to (e.g., Pre-MVP, Pre-v1), which PRD risks it addresses, what it depends on, and what it blocks.
  - Spikes that gate implementation phases must define concrete go/no-go criteria with measurable thresholds (not just "investigate X").
  - Spikes belong to the PRD that created them. The PRD owns all spike tables: questions, risks, gate criteria, dependency graph, execution order, phase mappings, and risk coverage. There is no separate research roadmap document.
  - Spikes that produce a go/no-go verdict should recommend a specific pivot if the gate fails (e.g., "pivot to companion app model"), not just "reconsider approach."
- ADR artifacts live under `docs/adr/` with phase directories:
  - `Proposed/`
  - `Adopted/`
  - `Retired/`
  - `Superseded/`
- ADR artifacts are markdown files directly in their phase directories.
- PRD artifacts live under `docs/prd/` with phase directories:
  - `Draft/`
  - `Review/`
  - `Approved/`
  - `Implemented/`
  - `Deprecated/`
- Every PRD artifact must be a folder containing at minimum a titled markdown file (e.g., `Flock-Detector-App.md`) with the specification and any supporting documents (wireframes, data models, API contracts, etc.).
- The PRD spec file must include a front-matter block with: title, status, author, created date, last updated date, and a list of linked research artifacts and/or ADRs.
- Each doc-type directory must keep a single lifecycle index file (`list-<type>.md`, e.g., `list-prds.md`) containing one table per phase with commit hash stamps for state transitions so repository state is auditable at decision time.
