# AGENTS.md

## Documentation lifecycle workflow

Use the following structure and lifecycle tracking conventions for new and moved documentation:

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
- Each phase directory must keep a markdown file at the top containing a lifecycle table with commit hash stamps for state transitions so repository state is auditable at decision time.
