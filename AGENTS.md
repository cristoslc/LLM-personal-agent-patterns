# AGENTS.md

## Documentation lifecycle workflow

Use the following structure and lifecycle tracking conventions for new and moved documentation. Each doc-type directory must include at least a `README.md` with the lifecycle explained.

- Research artifacts live under `docs/research/` with phase directories:
  - `Planned/`
  - `Active/`
  - `Complete/`
- Every research artifact must be a folder (not a single markdown file).
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
- Every PRD artifact must be a folder containing at minimum a `README.md` with the specification and any supporting documents (wireframes, data models, API contracts, etc.).
- PRD `README.md` must include a front-matter block with: title, status, author, created date, last updated date, and a list of linked research artifacts and/or ADRs.
- Each phase directory must keep a markdown file at the top containing a lifecycle table with commit hash stamps for state transitions so repository state is auditable at decision time.
