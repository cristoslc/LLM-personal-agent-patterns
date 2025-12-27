# Token Reduction Strategies for News-compact.yaml

## Current Token Count: ~6.5k (after v9.3 enhancements)
## Previous Token Count: ~5k
## Target: <3k tokens (40% reduction from original, 54% from current)

## Note on Recent Enhancements (v9.3)
The prompt has been enhanced with structural analysis improvements that add ~1.5k tokens:
- Enhanced slot_test with system_reveal, improvement_test, and examples
- Expanded "Why It Matters" with quality standards and examples
- New Pattern Recognition section
- Enhanced Phase 2 search strategy (minimum searches, thematic sweeps)
- New Story Consolidation guidance
- Enhanced Tone & Voice with forbidden phrases and examples
- Phase 3 Quality Gate (self-review checkpoint)
- Enhanced local_sig with system_reveal and reframing prompts

These additions are intentional quality improvements. Future compaction should preserve the examples and guidance while finding more compact ways to express them.

## Biggest Token Sinks (in order)

### 1. Source Lists (~800 tokens)
**Problem:** Full lists of sources with names, qualifiers, examples
**Solution:** Use category references instead of exhaustive lists

**Before:**
```yaml
tier2:
  nationals: [NYT, WSJ, Washington Post, Financial Times, The Economist, Bloomberg (analysis), Reuters (analysis), Politico, The Guardian, BBC, NPR, PBS NewsHour, The Atlantic, New Yorker, ProPublica, The Intercept, Axios, Semafor]
  international: [Le Monde, Der Spiegel, El País, South China Morning Post, Nikkei Asia, The Hindu, Al Jazeera English, ABC Australia, Globe and Mail, Toronto Star]
  business: [CNBC, MarketWatch, Barron's, Fortune, Forbes (news only), Business Insider (original reporting)]
  tech: [Ars Technica, The Verge, Wired, MIT Technology Review, TechCrunch (funding), Protocol, 404 Media, Heatmap News]
```

**After:**
```yaml
tier2:
  types: [nationals, international, business, tech]
  rule: Major outlets with editorial standards. Examples: NYT, WSJ, FT, BBC, NPR, The Guardian, Le Monde, Der Spiegel, CNBC, Wired, Ars Technica. If uncertain, treat as Tier 3
```

**Savings: ~400 tokens**

### 2. Output Format Examples (~600 tokens)
**Problem:** Full markdown examples with placeholders in every phase
**Solution:** Minimal format specs, remove example URLs/timestamps

**Before:**
```yaml
output_format: |
  ## Phase 2: Story Candidates (Search Tool Results)
  **[Tier] Source | Headline | Timestamp | URL**
  - [T1] Reuters | "..." | 2025-12-24T08:00Z | [URL from search]
  ...
  **Sources with no results:** [list]
  **Total candidates:** [N]
  **Duplicates:** [list]
```

**After:**
```yaml
output_format: "## Phase 2: Story Candidates | Format: [Tier] Source | Headline | Timestamp | URL | Include: no-results list, total count, duplicates"
```

**Savings: ~400 tokens**

### 3. Template Examples (~500 tokens)
**Problem:** Full template examples with verbose placeholders
**Solution:** Minimal structure, reference definitions

**Before:**
```yaml
standard: |
  **[Compelling Headline]**
  [Context: 2-3 sentences with inline citations]
  *Actor context:* [Key actors: who, role/power, why they matter]
  *Why it matters:* [Analysis: cost, loser, broken assumption, or time horizon]
  *Next:* [Concrete forward indicator: scheduled decision, deadline, pivot condition]
```

**After:**
```yaml
standard: "Headline | Context (2-3 sentences, inline cites) | Actor context (who/role/why) | Why it matters (cost/loser/assumption/horizon) | Next (forward indicator)"
```

**Savings: ~300 tokens**

### 4. Category Include/Exclude Lists (~400 tokens)
**Problem:** Long arrays of examples
**Solution:** Use pattern descriptions instead of exhaustive lists

**Before:**
```yaml
include: [Zoning/housing policy, budget decisions w/ service impact, local/state elections/ballot measures, transit/utility/climate infra, school board decisions, state legislation w/ local implementation, regional economic shifts, environmental/health rulings w/ enforcement, tribal/port/regional compacts, public health advisories, major weather events, significant incidents, healthcare/social service provider suspensions/closures, essential service disruptions, stories disproportionately affecting vulnerable populations]
```

**After:**
```yaml
include: "Governance/infrastructure/livability changes (municipal/state/regional) OR essential service disruptions. Examples: zoning/housing, budgets, elections, transit/utilities, school boards, health advisories, weather events, service provider closures, vulnerable population impacts"
```

**Savings: ~200 tokens**

### 5. Process Steps (~300 tokens)
**Problem:** Verbose step-by-step descriptions
**Solution:** Use numbered shorthand

**Before:**
```yaml
process:
  - TEMPORAL GATE: Reject outside briefing_window OR flag for developing_story if material update exists
  - SOURCE GATE: Reject Tier 3 lacking Tier 1-2 corroboration
  - SLOT TEST: Articulate ONE worldview change; reject if none (EXCEPT: Local may use actionability_test)
```

**After:**
```yaml
process: "1.Temporal gate 2.Source gate (T3→T1-2 corr) 3.Slot test (Local→actionability ok) 4.Category assign 5.Dedup 6.Category tests 7.Recycling check 8.Cross-link ID 9.Political controversy check 10.Local rejection review"
```

**Savings: ~200 tokens**

### 6. Definitions (~300 tokens)
**Problem:** Some definitions are verbose
**Solution:** More concise phrasing

**Before:**
```yaml
local_sig:
  criteria:
    - service_disruption: loss/suspension of essential services (healthcare, safety, education, housing, social services) affecting community subgroups, particularly vulnerable populations. Provider closures/payment suspensions/capacity reductions materially reducing access
    - equity_consideration: stories disproportionately affecting vulnerable/marginalized populations (immigrants, refugees, low-income, disabled, unhoused, racial/ethnic minorities, LGBTQ+) receive heightened consideration. Concentrated harm can meet threshold even if <5% total population
```

**After:**
```yaml
local_sig:
  criteria: "lock_in | resource_shift(>1% budget/>5% pop) | precedent | infrastructure | personal_impact | actionable | service_disruption(essential services→vulnerable pop) | equity_consideration(vulnerable pop, <5% ok if concentrated harm)"
```

**Savings: ~150 tokens**

### 7. Reminders Section (~200 tokens)
**Problem:** Long list of reminders
**Solution:** Consolidate into single compact list

**Before:**
```yaml
reminders:
  - NO WEB SEARCH TOOLS = DO NOT PROCEED. Tell user immediately
  - URLs from search tools ONLY. Constructed URLs = fabrication = failure
  - PHASE SEQUENCING MANDATORY: "continue" after Phase 1 = Phase 2 ONLY, then stop...
```

**After:**
```yaml
reminders: "Web search required. URLs from search only. One phase per turn. Temporal gate absolute. T3 alone=exclude. One dev=one story. Local needs local sources. Local special: service disruption/equity consideration priority"
```

**Savings: ~100 tokens**

## Additional Strategies

### 8. Use Abbreviations
- `briefing_window` → `bw`
- `actionability_test` → `act_test`
- `service_disruption` → `svc_disrupt`
- `equity_consideration` → `equity`

### 9. Remove Redundant Explanations
- Remove "Do not proceed until instructed" (already in contract rules)
- Remove example timestamps/URLs from output formats
- Consolidate similar rules

### 10. Compress Turn Flow
**Before:**
```yaml
turn_flow:
  summary:
    - Turn 1: User provides params → Phase 1 ONLY → STOP
    - Turn 2: User says "continue" → Phase 2 ONLY → STOP
    - Turn 3: User says "continue" → Phase 3 ONLY → STOP
    - Turn 4: User says "continue" → Phase 4 ONLY → END
  continue_means: "continue" = output NEXT phase and STOP. NOT "complete all remaining phases"
  strict_sequencing:
    - After Phase 1: MUST wait. Do NOT output Phase 2, 3, or 4
    - After Phase 2: MUST wait. Do NOT output Phase 3 or 4
    - After Phase 3: MUST wait. Do NOT output Phase 4
```

**After:**
```yaml
turn_flow: "Turn N: params/continue → Phase N ONLY → STOP. Continue = next phase only, not all remaining. Never skip ahead"
```

## Estimated Total Savings: ~1,750 tokens
## New Estimated Total: ~3,250 tokens (35% reduction)

## Implementation Priority
1. **High Impact:** Source lists, output formats, templates (saves ~1,100 tokens)
2. **Medium Impact:** Category lists, process steps (saves ~400 tokens)
3. **Low Impact:** Definitions, reminders (saves ~250 tokens)

## Trade-offs to Consider
- **Readability:** More compact = harder for humans to read
- **Clarity:** Abbreviations may reduce LLM understanding
- **Maintainability:** Denser format harder to update
- **LLM Performance:** Some models benefit from explicit examples

## New Sections Added (v9.3) - Compaction Considerations

### 11. Enhanced slot_test (~200 tokens)
**Current:** Structured with valid_answers, improvement_test, examples
**Compaction options:**
- Keep examples but compress format
- Use abbreviations: `system_reveal` → `sys_reveal`
- Consolidate weak/strong examples into single line

### 12. Enhanced "Why It Matters" (~250 tokens)
**Current:** Quality standards, examples (weak/strong)
**Compaction options:**
- Keep examples but use more compact format
- Consolidate quality_standards into single list
- Use abbreviations for standard names

### 13. Pattern Recognition Section (~200 tokens)
**New section:** established_patterns_ARE_newsworthy_when, reframe_prompts, examples
**Compaction options:**
- Compress examples to single-line format
- Use abbreviations: `internal_contradiction` → `contradiction`
- Consolidate reframe_prompts into comma-separated list

### 14. Enhanced Phase 2 Search Strategy (~150 tokens)
**Current:** search_strategy with temporal, thematic_sweeps, minimum_searches, validation
**Compaction options:**
- Consolidate into single process line with inline notes
- Use abbreviations: `thematic_sweeps` → `thematic`
- Compress validation into single sentence

### 15. Story Consolidation Section (~200 tokens)
**New section:** combine_when, keep_separate_when, developing_story_consolidation
**Compaction options:**
- Use bullet format instead of structured YAML
- Compress examples to single-line format
- Use abbreviations: `shared_actors_and_timeline` → `shared_actors`

### 16. Enhanced Tone & Voice (~250 tokens)
**Current:** voice_principles, forbidden_phrases, required_specificity, examples
**Compaction options:**
- Consolidate forbidden_phrases into comma-separated list
- Compress examples to single-line format
- Use abbreviations where possible

### 17. Phase 3 Quality Gate (~150 tokens)
**New section:** before_composition checklist, if_answers_are_no actions
**Compaction options:**
- Convert to single-line checklist format
- Use abbreviations: `reframe_the_story` → `reframe`
- Consolidate actions into comma-separated list

### 18. Enhanced local_sig (~100 tokens)
**Added:** system_reveal criteria, reframing_prompts
**Compaction options:**
- Integrate system_reveal into existing criteria list
- Compress reframing_prompts to single line

**Total new tokens: ~1,500**
**Potential compaction savings: ~600-800 tokens (40-50% of new content)**

## Updated Recommendation
1. **Preserve quality:** Keep examples and guidance that improve structural analysis
2. **Compress format:** Use more compact YAML structures without losing meaning
3. **Test impact:** Verify LLM performance after compaction
4. **Priority order:**
   - First: Compress existing sections (1-10) as originally planned
   - Second: Compress new sections (11-18) using format optimization
   - Third: Consider abbreviations only if performance maintained

