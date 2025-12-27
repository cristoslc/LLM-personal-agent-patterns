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

### 8. Abbreviation Strategy

**Quick Decision Rule:** Use abbreviations for terms that appear **5+ times** in the prompt. For terms appearing 1-2 times, keep full form to avoid confusion.

**Abbreviation Glossary (Maintain Consistency):**
- `briefing_window` → `bw` (appears 15+ times)
- `actionability_test` → `act_test` (appears 8+ times)
- `service_disruption` → `svc_disrupt` (appears 6+ times)
- `equity_consideration` → `equity` (appears 5+ times)
- `system_reveal` → `sys_reveal` (appears 4+ times)
- `thematic_sweeps` → `thematic` (appears 3+ times)
- `internal_contradiction` → `contradiction` (appears 3+ times)
- `developing_story` → `dev_story` (appears 10+ times)
- `shared_actors_and_timeline` → `shared_actors` (appears 2+ times)

**Note:** Always use the same abbreviation throughout the prompt once introduced. Use find/replace to ensure consistency.

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

## Recommended Implementation Order

### Step 1: Quick Wins (Highest ROI, ~15 minutes)
1. Source lists (Section 1) - ~400 token savings, low risk
2. Output formats (Section 2) - ~400 token savings, low risk
3. Templates (Section 3) - ~300 token savings, low risk
**Total: ~1,100 tokens**

### Step 2: Medium Effort (~30 minutes)
4. Category lists (Section 4) - ~200 tokens
5. Process steps (Section 5) - ~200 tokens
6. New sections 11-18 (see below) - ~1,050 tokens
**Total: ~1,450 tokens**

### Step 3: Final Polish (~20 minutes)
7. Definitions (Section 6) - ~150 tokens
8. Reminders (Section 7) - ~100 tokens
9. Turn flow (Section 10) - ~100 tokens
10. Abbreviations (Section 8) - variable
**Total: ~350+ tokens**

**Grand total: ~2,900 tokens saved, ~65 minutes work**
**Final count: ~3,600 tokens (from 6.5k = 45% reduction)**

## Compression Patterns (Reusable Templates)

### Pattern 1: List → Pattern Description
**Before:** `[item1, item2, item3, item4, item5, ...]`  
**After:** `"Category description. Examples: item1, item2, item3"`  
**Savings:** ~50-60% tokens

### Pattern 2: Structured YAML → Inline String
**Before:** 
```yaml
section:
  field1: "value1"
  field2: "value2"
```
**After:** `section: "field1: value1 | field2: value2"`  
**Savings:** ~40-50% tokens

### Pattern 3: Verbose Definition → Concise Criteria
**Before:** `"Long explanation with multiple clauses and examples"`  
**After:** `"Key terms (brief context). Examples: X, Y"`  
**Savings:** ~40-50% tokens

### Pattern 4: Multiple Reminders → Single Line
**Before:** List of bullet points  
**After:** `"Rule1. Rule2. Rule3. Exception: X"`  
**Savings:** ~60-70% tokens

## Symbol Notation Reference

When compressing, these symbols help save tokens:
- `→` = "leads to" or "means" (saves ~3 tokens vs "means that")
- `|` = "or" separator (saves ~2 tokens vs "OR")
- `+` = "and" (saves ~2 tokens vs "and")
- `>` = "greater than" (saves ~1 token)
- `<` = "less than" (saves ~1 token)
- `/` = "or" in abbreviations (saves ~1 token)

**Example:** `T3→T1-2 corr` saves ~8 tokens vs "Tier 3 requires Tier 1-2 corroboration"

## What to Preserve (Don't Remove)

When compressing, always keep:
- [ ] Weak/strong example comparisons (compress format, not content)
- [ ] Edge case exceptions (Local stories, developing stories)
- [ ] Critical definitions (compress phrasing, not meaning)
- [ ] Process dependencies (Temporal → Source → Slot test order)
- [ ] Quality standards (cost/loser/assumption/horizon framework)

**Rule of thumb:** If it helps the model understand quality or handle edge cases, compress the format but preserve the information.

## Common Pitfalls to Avoid

1. **Inconsistent abbreviations:** Using `bw` in one place and `briefing_window` in another
   - **Fix:** Use find/replace to ensure consistency

2. **Over-compressing examples:** Removing weak/strong examples entirely
   - **Fix:** Compress format but keep the comparison (e.g., "Weak: X. Strong: Y")

3. **Losing edge cases:** Removing exceptions like "Local stories may use local sources"
   - **Fix:** Compress to "Local: local sources ok" but keep the exception

4. **Breaking YAML structure:** Making YAML invalid with compression
   - **Fix:** Test YAML syntax after each change (use online YAML validator)

5. **Removing critical context:** Cutting explanations that clarify ambiguous terms
   - **Fix:** If a term could be misunderstood, keep a brief explanation

## Model Considerations

### Quick Tips by Model
- **Claude:** Handles compressed formats well, can be more aggressive with abbreviations
- **GPT-4:** Benefits from examples, compress format but keep structure
- **Gemini:** Good with patterns, pattern descriptions work well

**General rule:** If unsure, preserve examples but compress their format rather than removing them.

## Quick Token Counting

### Online Tools (No Setup)
- **OpenAI Tokenizer:** https://platform.openai.com/tokenizer (paste YAML, get count)
- **tiktoken online:** Various web-based tokenizers available

### Quick Check Method
After each major compression:
1. Copy compressed section
2. Paste into tokenizer
3. Compare to original count
4. Document savings

**Target:** Each high-impact section should save 40-60% tokens.

## YAML Syntax Check

After compressing, always validate YAML syntax:
- Use online YAML validator (e.g., yamlchecker.com)
- Or use: `python -c "import yaml; yaml.safe_load(open('file.yaml'))"`

**Common syntax errors from compression:**
- Missing quotes around strings with special characters
- Incorrect indentation
- Invalid list formatting

## Trade-offs to Consider
- **Readability:** More compact = harder for humans to read
- **Clarity:** Abbreviations may reduce LLM understanding
- **Maintainability:** Denser format harder to update
- **LLM Performance:** Some models benefit from explicit examples

## New Sections Added (v9.3) - Specific Compaction Strategies

### 11. Enhanced slot_test (~200 tokens)
**Current structure:**
```yaml
slot_test:
  valid_answers: [...]
  improvement_test: [...]
  examples:
    weak: "..."
    strong: "..."
```

**Compaction strategy:**
```yaml
slot_test: "Articulate ONE worldview change (system/mechanism/assumption OR actor/power/constraint). Weak: 'affects many people'. Strong: 'reveals system operates by X not Y'"
```
**Savings:** ~150 tokens (75% reduction)

### 12. Enhanced "Why It Matters" (~250 tokens)
**Compaction strategy:**
```yaml
why_it_matters: "Cost/loser/assumption/horizon. Weak: 'affects economy'. Strong: '$2B shift→rural hospitals 15-20% cuts→closures'"
```
**Savings:** ~180 tokens (72% reduction)

### 13. Pattern Recognition Section (~200 tokens)
**Compaction strategy:**
```yaml
patterns_newsworthy: "contradiction/power_shift/precedent. Reframe: system? power? precedent?"
```
**Savings:** ~140 tokens (70% reduction)

### 14. Enhanced Phase 2 Search Strategy (~150 tokens)
**Compaction strategy:**
```yaml
search_strategy: "Within bw, prioritize recent. Group by theme. Min 3/category. Cross-reference sources"
```
**Savings:** ~100 tokens (67% reduction)

### 15. Story Consolidation Section (~200 tokens)
**Compaction strategy:**
```yaml
consolidation: "Combine: shared actors+timeline OR same event. Separate: different time/geography"
```
**Savings:** ~140 tokens (70% reduction)

### 16. Enhanced Tone & Voice (~250 tokens)
**Compaction strategy:**
```yaml
tone_voice: "Forbidden: breaking/developing/stay tuned/we're following/more to come. Required: specific, quantified, forward-looking"
```
**Savings:** ~180 tokens (72% reduction)

### 17. Phase 3 Quality Gate (~150 tokens)
**Compaction strategy:**
```yaml
quality_gate: "Check: slot_test clear? why_it_matters specific? actors clear? If no: reframe/gather/reconsider"
```
**Savings:** ~100 tokens (67% reduction)

### 18. Enhanced local_sig (~100 tokens)
**Compaction strategy:**
```yaml
local_sig: "Existing criteria + sys_reveal. Reframe prompts: system? power? precedent?"
```
**Savings:** ~60 tokens (60% reduction)

**Total potential savings from sections 11-18: ~1,050 tokens**
**Combined with sections 1-10: ~2,800 tokens total savings**
**Final estimated total: ~3,700 tokens (from 6.5k = 43% reduction)**

## Updated Recommendation

1. **Preserve quality:** Keep examples and guidance that improve structural analysis
2. **Compress format:** Use more compact YAML structures without losing meaning
3. **Follow implementation order:** Start with quick wins (sections 1-3), then medium effort (sections 4-6, 11-18), then polish (sections 7, 10, 8)
4. **Validate YAML:** Check syntax after each major change
5. **Use patterns:** Apply compression patterns consistently
6. **Maintain consistency:** Use abbreviation glossary and symbol notation reference

## Quick Reference Checklist

Before starting compaction:
- [ ] Create backup of current News-compact.yaml
- [ ] Review abbreviation glossary
- [ ] Review compression patterns
- [ ] Review symbol notation reference
- [ ] Review what to preserve checklist

During compaction:
- [ ] Follow implementation order (Step 1 → Step 2 → Step 3)
- [ ] Validate YAML syntax after each section
- [ ] Use find/replace for abbreviations to ensure consistency
- [ ] Check token count after each major section
- [ ] Preserve examples and edge cases (compress format, not content)

After compaction:
- [ ] Final YAML syntax validation
- [ ] Final token count check (target: <3.7k tokens)
- [ ] Verify all abbreviations used consistently
- [ ] Document any deviations from standard patterns

