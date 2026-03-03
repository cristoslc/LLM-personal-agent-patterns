# Roadmap

Supporting document for [VISION-001 Agents Standalone Framework](./\(VISION-001\)-Agents-Standalone-Framework.md).

## Epic Sequence

```mermaid
graph LR
    E1["EPIC-001<br/>Skills Ecosystem<br/>Distribution<br/><b>Complete</b>"]
    E2["EPIC-002<br/>Plugin Marketplace<br/><b>Abandoned</b>"]
    E3["EPIC-003<br/>Skill Lifecycle<br/>Manager<br/><b>Complete</b>"]
    E4["EPIC-004<br/>External Task<br/>Management<br/><b>Active</b>"]

    S1["SPIKE-001<br/>Task CLI<br/>Evaluation<br/><b>Complete</b>"]
    S6["SPIKE-006<br/>Dependency Graph<br/>Tracking<br/><i>Planned</i>"]

    E1 -->|complementary| E3
    S1 -->|gates| E4
    S1 -->|prerequisite| S6

    style E1 fill:#2d6a2d,color:#fff
    style E2 fill:#6a2d2d,color:#fff
    style E3 fill:#2d6a2d,color:#fff
    style E4 fill:#4a4a2d,color:#fff
    style S1 fill:#2d6a2d,color:#fff
    style S6 fill:#2d4a6a,color:#fff
```

## Status Table

| Epic | Goal | Phase | Dependencies | Notes |
|------|------|-------|--------------|-------|
| EPIC-001 | Ride the Agent Skills ecosystem for zero-effort skill distribution | **Complete** | ADR-001, SPIKE-003 | 3/3 stories done |
| EPIC-002 | Claude Code plugin marketplace | **Abandoned** | SPIKE-003 (gate) | Rejected for vendor lock-in |
| EPIC-003 | Full-lifecycle skill management (discovery through drift detection) | **Complete** | SPIKE-002, SPIKE-005, ADR-003 | 5/5 stories done; 38/38 smoke tests |
| EPIC-004 | External CLI-based task store for cross-backend execution tracking | **Active** | SPIKE-001 (Complete) | bd (Beads) selected; child stories needed |

## Open Research

| Spike | Question | Blocks |
|-------|----------|--------|
| SPIKE-006 | How to track spec dependency graphs in an LLM-friendly way? | Future epic TBD |

## What's Next

1. **Create child stories for EPIC-004** — define the work to formalize bd integration, observer patterns, and fallback behavior in execution-tracking
2. **Execute SPIKE-006** — investigate dependency graph approaches (SPIKE-001 prerequisite now satisfied)
