# Architecture Overview

Supporting document for [VISION-001 Agents Standalone Framework](./\(VISION-001\)-Agents-Standalone-Framework.md).

## System Shape

The framework is a file-based, vendor-agnostic system organized into four layers. Everything lives in a Git repository — no hosted services, no runtime infrastructure.

```
+---------------------------------------------------------+
|                    Git Repository                        |
|                                                         |
|  AGENTS.md              (entry point / agent context)   |
|                                                         |
|  +---------------------------------------------------+  |
|  |  Specification Layer (docs/)                       |  |
|  |  Vision > Epic > Story > Agent Spec                |  |
|  |  + ADRs, Spikes, Personas, Journeys                |  |
|  +---------------------------------------------------+  |
|                                                         |
|  +---------------------------------------------------+  |
|  |  Skills Layer (.claude/skills/, .agents/skills/)   |  |
|  |  Reusable operational knowledge as markdown        |  |
|  |  procedures + shell scripts                        |  |
|  +---------------------------------------------------+  |
|                                                         |
|  +---------------------------------------------------+  |
|  |  Distribution Layer                                |  |
|  |  Subtree split (ADR-001) + npx skills ecosystem    |  |
|  |  + skill-manager wrapper (ADR-003)                 |  |
|  +---------------------------------------------------+  |
|                                                         |
|  +---------------------------------------------------+  |
|  |  Execution Layer                                   |  |
|  |  Implementation plans + task backend               |  |
|  |  (external CLI TBD per EPIC-004)                   |  |
|  +---------------------------------------------------+  |
+---------------------------------------------------------+
```

## Specification Layer

Artifacts in `docs/` follow a hierarchy: **Vision** (aspirational narrative) decomposes into **Epics** (strategic initiatives), which decompose into **Stories** (atomic user-facing requirements) and **Agent Specs** (behavior contracts). Cross-cutting artifacts — **ADRs** (architectural decisions), **Spikes** (time-boxed research), **Personas** (user archetypes), and **Journeys** (end-to-end experience maps) — inform and constrain the hierarchy without belonging to a single branch.

Every artifact has:
- **YAML frontmatter** with status, parent refs, and dependency links
- **A lifecycle table** tracking phase transitions with commit hashes
- **An entry in its type's index** (`list-<type>.md`) refreshed on every change

Artifacts are organized by type directories under `docs/`. ADRs use phase subdirectories (`Draft/`, `Proposed/`, `Adopted/`, etc.); Spikes similarly (`Planned/`, `Active/`, `Complete/`). Other types use flat or folder-per-artifact structures.

## Skills Layer

Skills are reusable units of operational knowledge. Each skill is a directory containing:
- `SKILL.md` — the skill definition (description, procedures, configuration) conforming to the Agent Skills open standard
- Supporting files — shell scripts, templates, reference material

Skills are vendor-agnostic: they describe *what to do* in markdown, not *how a specific agent tool works*. The same skill can be consumed by Claude Code, Gemini CLI, Cursor, or any agent that reads markdown instructions.

Current skills include `spec-management` (this skill's domain), `skill-manager` (lifecycle management of installed skills), `update-agents-core` (framework scaffolding updates), and `execution-tracking` (bridging specs to task backends).

## Distribution Layer

Two mechanisms deliver the framework to consumer projects:

1. **Subtree split** (ADR-001): A GitHub Action publishes the `l3-agents-core` branch — a root-level projection of the framework directory. Consumer projects merge this branch to import scaffolding (`AGENTS.md`, `.agents/`, `docs/`). Updates are standard `git fetch && git merge --squash`.

2. **Skill ecosystem** (ADR-003): Individual skills are distributed via the Agent Skills ecosystem (`npx skills add`). The `skill-manager` skill wraps `npx skills` with a provenance overlay (`.source.yml` per ADR-002), adding safety-gated installation, drift detection, and a POSIX fallback for non-Node environments. This addresses the consumer journey pain points identified in JOURNEY-001.

## Execution Layer

Implementation plans bridge specs to work. A plan originates from an Agent Spec or Epic, creates tasks with dependencies and spec tags, and tracks progress to completion.

The task backend is currently the agent's built-in todo system (fallback mode). EPIC-004 and SPIKE-001 are evaluating external CLI tools (`bd` and alternatives) to provide durable persistence, cross-backend portability, and external observer access.

## Key Design Decisions

| Decision | Record | Status |
|----------|--------|--------|
| Subtree split for framework distribution | ADR-001 | Adopted |
| `.source.yml` provenance pattern for installed skills | ADR-002 | Adopted |
| Skill-manager wraps `npx skills` with provenance overlay | ADR-003 | Adopted |
| External task CLI selection | SPIKE-001 | Planned |
