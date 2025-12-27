# News Briefing Prompt

A structured prompt system for generating daily news briefings with Quartz-style structural analysis. This prompt guides LLMs through a four-phase process to curate, collect, select, and compose news stories that update your worldview about power, money, and capability.

## Overview

The news briefing prompt is designed to produce concise, analytical briefings that go beyond surface-level reporting. Instead of simply describing events, it focuses on:
- **Structural analysis**: What does this story reveal about how systems actually work?
- **Systemic insights**: What worldview changes would removing this story eliminate?
- **Why it matters**: Who bears the cost? What assumption just broke? What's the mechanism?

## Files

### `News-compact.md`
The main prompt file (v9.3-structural-analysis). This is a comprehensive YAML-structured prompt that defines:
- **Identity & Role**: Quartz journalist approach with national and local north stars
- **Source Tiers**: Three-tier system (Primary, Institutional, Other) with strict validation rules
- **Four-Phase Process**: 
  1. Source Curation
  2. Story Collection
  3. Selection
  4. Composition
- **Categories**: Politics, Tech, Business, Local, Uplifting
- **Templates**: Standard, Developing, Actionable, and Terse Recap formats
- **Quality Gates**: Slot tests, pattern proofs, durability checks, and systemic insight requirements

### `COMPACTION-ADVICE.md`
A technical document outlining strategies for reducing the prompt's token count while preserving quality. Includes:
- Current token analysis (~6.5k tokens)
- Identification of token sinks
- Compression strategies with before/after examples
- Trade-offs between compactness and clarity
- Recommendations for future optimization

## Key Features

### Source Validation
- **Tier 1**: Wires, government domains, court systems, legislatures, major regulators
- **Tier 2**: Major outlets with editorial standards (nationals, international, business, tech)
- **Tier 3**: Other sources (must be corroborated with Tier 1-2 or excluded)
- **Local Sources**: Discovered and validated for reader location

### Selection Criteria
- **Slot Test**: "Which ONE worldview change would deleting this story remove?"
- **Pattern Proof**: Either >$5B/top-10 gatekeeper OR 2+ similar events with new parameters
- **Durability**: Progress survives next election/budget/leadership change
- **Local Significance**: Lock-in, resource shifts, precedents, infrastructure, personal impact, service disruptions, equity considerations

### Quality Standards
- **Systemic Insight**: Every story must reveal something about how systems work
- **Mechanisms over Outcomes**: Explain HOW power shifts, not just WHO
- **Precision over Hedging**: Name the loser, the cost, the timeline, the broken assumption
- **Structural over Descriptive**: "X reveals Y about Z" not "X happened and affected Y"

## Usage

### Required Parameters
- `date`: Briefing date (ISO 8601 format)
- `reader_location`: City/town, state, region (e.g., "Brookline, Massachusetts, New England")
- `special_instructions`: Optional editorial guidance

### Phase Execution
The prompt operates in strict phases:
1. **Turn 1**: Provide parameters → Phase 1 (Source Curation) → STOP
2. **Turn 2**: Say "continue" → Phase 2 (Story Collection) → STOP
3. **Turn 3**: Say "continue" → Phase 3 (Selection) → STOP
4. **Turn 4**: Say "continue" → Phase 4 (Composition) → Final Briefing

**Critical**: The prompt requires web search tools. If unavailable, it will stop and request them.

## Output Format

Final briefings are organized by category:
1. **Politics**: Power via states, international bodies, political movements
2. **Tech**: Technical capability, platform power, innovation infrastructure
3. **Business & Finance**: Capital movements, market structure, corporate power
4. **Local**: Structural changes at municipal/state/regional scale
5. **Uplifting**: Durable structural progress representing net gain for humanity
6. **Sources**: Bibliography grouped by category with full URLs and ISO 8601 dates

Each story includes:
- Compelling headline
- Context with inline citations
- Actor context (who, role, why they matter)
- Why it matters (systemic analysis)
- Next (concrete forward indicator)

## Version History

- **v9.3-structural-analysis**: Current version with enhanced structural analysis
  - Enhanced slot_test with system_reveal
  - Expanded "Why It Matters" quality standards
  - Pattern recognition section
  - Enhanced search strategy
  - Story consolidation guidance
  - Phase 3 quality gate
  - Enhanced local significance criteria

## Design Philosophy

This prompt is built on the principle that news briefings should update your worldview, not just inform you of events. It prioritizes:
- **Structural insights** over event descriptions
- **Systemic reveals** over surface-level facts
- **Mechanisms** over outcomes
- **Precision** over hedging
- **Durability** over ephemeral updates

The prompt explicitly rejects:
- Celebrity/entertainment news
- Sports (unless structural impact)
- Crime/violence (unless policy trigger)
- Social media controversy (unless institutional response)
- Rumors/leaks/unconfirmed reports
- Press-release journalism

## Token Optimization

See `COMPACTION-ADVICE.md` for detailed strategies on reducing token count while maintaining quality. Current focus areas include:
- Source list compression
- Output format simplification
- Template compaction
- Process step shorthand
- Definition consolidation

## Notes

- All URLs must come from search tool results (no constructed URLs)
- Tier 3 sources alone are insufficient; require Tier 1-2 corroboration
- Local stories require local sources; no extrapolation from national stories
- One source/development = ONE story (no recycling across categories)
- Briefing window is 36 hours; stories outside window use developing_story format or are excluded

