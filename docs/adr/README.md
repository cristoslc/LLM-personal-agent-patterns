# Architecture Decision Records (ADRs)

Architectural decisions that affect one or more Epics, PRDs, or cross-cutting concerns. ADRs are not owned by a single artifact — they link to all affected specs.

## Phases

| Phase | Meaning |
|---|---|
| Draft | Investigation in progress; recommendation not yet formed |
| Proposed | Recommendation ready for review |
| Adopted | Decision accepted and in effect |
| Retired | Decision no longer applies (superseded or obsoleted) |
| Superseded | Replaced by a newer ADR (must link to successor) |

## Directory layout

ADR markdown files live directly in their current phase directory:

```
docs/adr/
├── README.md
├── list-adrs.md
├── Draft/
│   └── ADR-001-Remote-Skills-Reference-Pattern.md
├── Proposed/
├── Adopted/
├── Retired/
└── Superseded/
```

## Index

See [list-adrs.md](./list-adrs.md) for the lifecycle index.
