# Design: Swain Repository Structure and Skill Packaging

**Spec:** SPEC-005
**Date:** 2026-03-06

## Repository layout

```
~/Documents/code/swain/
  skills/
    spec-management/
      SKILL.md
      references/
      scripts/
    execution-tracking/
      SKILL.md
      references/
      scripts/
    release/
      SKILL.md
    governance/
      SKILL.md             # placeholder — content defined by SPEC-006
  docs/                    # dev-only (invisible to npx skills)
  AGENTS.md                # dev-only governance for swain repo development
  CLAUDE.md                # @AGENTS.md reference
  README.md
  LICENSE
  .gitignore
```

## What goes where

| Content | Source in LLM-personal-agent-patterns | Destination in swain |
|---------|--------------------------------------|---------------------|
| spec-management skill | `.claude/skills/spec-management/` | `skills/spec-management/` |
| execution-tracking skill | `.claude/skills/execution-tracking/` | `skills/execution-tracking/` |
| release skill | `.claude/skills/release/` | `skills/release/` |
| governance skill | New (SPEC-006) | `skills/governance/SKILL.md` (placeholder) |
| Dev governance | `L3-agents-core/AGENTS.md` | `AGENTS.md` (adapted for swain's own dev) |
| Dev docs | N/A initially | `docs/` |

## Key decisions

- **`skills/` directory layout** — matches `vercel-labs/agent-skills` convention and is a known `npx skills` scan path
- **No root SKILL.md** — avoids `--full-depth` issue; CLI recurses into `skills/` naturally
- **Separate dev AGENTS.md** — swain's own development governance is distinct from what the governance skill injects into consumers
- **Governance skill is a placeholder** — SPEC-006 defines the content; this spec just creates the directory and a minimal SKILL.md stub
- **Dev-only content invisible** — `docs/`, `AGENTS.md`, `README.md`, `LICENSE` have no SKILL.md so `npx skills` ignores them

## Validation plan

1. Run `npx skills add ~/Documents/code/swain --list` to verify all 4 skills are discovered
2. Run `npx skills add ~/Documents/code/swain --all --yes` in a test project to verify installation
3. Confirm no dev-only content leaks into the installed skills

## Out of scope

- Governance skill content (SPEC-006)
- Migration guide (STORY-010)
- Legacy infrastructure retirement (STORY-011)
- skills.sh registration (STORY-012)
