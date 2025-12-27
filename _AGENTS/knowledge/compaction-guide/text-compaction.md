# Text Compaction Strategies

Text compaction focuses on condensing text content and context while preserving essential meaning and information.

## Core Principles

### 1. Remove Redundancy
Eliminate repeated information, verbose explanations, and unnecessary words.

### 2. Preserve Semantics
Maintain the core meaning, relationships, and critical details.

### 3. Optimize Structure
Use efficient formats, abbreviations, and patterns to convey information.

### 4. Balance Compression
Find the optimal balance between token reduction and information retention.

## Text-Level Techniques

### 1. Sentence Compression

**Before:**
```
This story reveals that municipal budgeting operates through political negotiation processes, not through technical optimization methods, which means that future budget decisions will prioritize visible projects over systemic needs that may be more important but less visible to the public.
```

**After:**
```
Municipal budgeting operates through political negotiation, not technical optimization, meaning future budgets prioritize visible projects over systemic needs.
```

**Savings:** ~30-40% tokens, maintains meaning

### 2. List Compression

**Before:**
```
The sources include: The New York Times, The Wall Street Journal, The Washington Post, Financial Times, The Economist, Bloomberg for analysis pieces, Reuters for analysis pieces, Politico, The Guardian, BBC, NPR, PBS NewsHour, The Atlantic, The New Yorker, ProPublica, The Intercept, Axios, and Semafor.
```

**After:**
```
Sources: Major national outlets (NYT, WSJ, WP, FT, Economist, Bloomberg/Reuters analysis, Politico, Guardian, BBC, NPR, PBS, Atlantic, New Yorker, ProPublica, Intercept, Axios, Semafor).
```

**Savings:** ~50-60% tokens

### 3. Definition Compression

**Before:**
```
Service disruption refers to the loss or suspension of essential services such as healthcare, safety, education, housing, and social services that affect community subgroups, particularly vulnerable populations. This includes provider closures, payment suspensions, and capacity reductions that materially reduce access to these services.
```

**After:**
```
Service disruption: Loss/suspension of essential services (healthcare, safety, education, housing, social services) affecting vulnerable populations. Includes closures, payment suspensions, capacity reductions materially reducing access.
```

**Savings:** ~40-50% tokens

### 4. Process Description Compression

**Before:**
```
First, apply the temporal gate: reject any stories that fall outside the briefing window, unless there is a material update that would qualify it as a developing story. Second, apply the source gate: reject any Tier 3 sources that lack corroboration from Tier 1 or Tier 2 sources, except for local stories which may use local sources only. Third, apply the slot test: the story must articulate one worldview change, or it should be rejected, except for local stories which may use the actionability test instead.
```

**After:**
```
Process: 1.Temporal gate (reject outside bw, dev_story exception) 2.Source gate (T3 alone=exclude, Local: local sources ok) 3.Slot test (one worldview change, Local: actionability ok)
```

**Savings:** ~60-70% tokens

## Format-Level Techniques

### 5. YAML Structure Compression

**Before:**
```yaml
output_format:
  phase_2:
    title: "Phase 2: Story Candidates (Search Tool Results)"
    format: "[Tier] Source | Headline | Timestamp | URL"
    required_fields:
      - tier
      - source
      - headline
      - timestamp
      - url
    additional_sections:
      - sources_with_no_results
      - total_candidates
      - duplicates
```

**After:**
```yaml
output_format: "## Phase 2: Story Candidates | [Tier] Source | Headline | Timestamp | URL | Include: no-results, total, duplicates"
```

**Savings:** ~70-80% tokens

### 6. Template Compression

**Before:**
```yaml
template:
  standard:
    headline: "[Compelling Headline]"
    context: "[Context: 2-3 sentences with inline citations]"
    actor_context: "[Key actors: who, role/power, why they matter]"
    why_it_matters: "[Analysis: cost, loser, broken assumption, or time horizon]"
    next: "[Concrete forward indicator: scheduled decision, deadline, pivot condition]"
```

**After:**
```yaml
template: "Headline | Context (2-3 sentences, inline cites) | Actor context (who/role/why) | Why it matters (cost/loser/assumption/horizon) | Next (forward indicator)"
```

**Savings:** ~60-70% tokens

## Content-Level Techniques

### 7. Category Description Compression

**Before:**
```
Include stories about: zoning and housing policy changes, budget decisions with service impact, local and state elections and ballot measures, transit and utility and climate infrastructure, school board decisions, state legislation with local implementation, regional economic shifts, environmental and health rulings with enforcement, tribal and port and regional compacts, public health advisories, major weather events, significant incidents, healthcare and social service provider suspensions and closures, essential service disruptions, and stories that disproportionately affect vulnerable populations.
```

**After:**
```
Include: Governance/infrastructure/livability changes (municipal/state/regional) OR essential service disruptions. Examples: zoning/housing, budgets, elections, transit/utilities, school boards, health advisories, weather events, service provider closures, vulnerable population impacts.
```

**Savings:** ~50-60% tokens

### 8. Rule Consolidation

**Before:**
```
Rule 1: Do not proceed without web search tools. If web search tools are not available, tell the user immediately.
Rule 2: Only use URLs that come from search tools. Do not construct URLs yourself, as this constitutes fabrication and will result in failure.
Rule 3: Phase sequencing is mandatory. When the user says "continue" after Phase 1, output Phase 2 only, then stop.
Rule 4: After Phase 2, you must wait. Do not output Phase 3 or Phase 4.
Rule 5: After Phase 3, you must wait. Do not output Phase 4.
```

**After:**
```
Rules: Web search required. URLs from search only. One phase per turn. Temporal gate absolute. T3 alone=exclude. One dev=one story. Local needs local sources.
```

**Savings:** ~70-80% tokens

## Advanced Techniques

### 9. Hierarchical Compression

**Structure information hierarchically:**
- Main concept first
- Details as nested elements
- Use indentation and structure to convey relationships

**Example:**
```
Compaction strategies:
  High-impact: Source lists, output formats, templates (saves ~1,100 tokens)
  Medium-impact: Category lists, process steps (saves ~400 tokens)
  Low-impact: Definitions, reminders (saves ~250 tokens)
```

### 10. Pattern-Based Compression

**Replace specific instances with patterns:**

**Before:**
```
Examples of weak slot_test answers: "This is important because it affects many people", "This matters for the community", "This is significant news"
Examples of strong slot_test answers: "This reveals that municipal budgeting operates through political negotiation, not technical optimization", "This shows that the city council has budgetary authority that wasn't visible before"
```

**After:**
```
Slot_test: Weak: "affects many people"/"matters for community". Strong: "reveals system operates by X not Y"/"shows actor has power/constraint"
```

**Savings:** ~60-70% tokens

### 11. Abbreviation Strategy

**Use abbreviations for frequently repeated terms:**

**Common Abbreviations:**
- `briefing_window` → `bw`
- `actionability_test` → `act_test`
- `service_disruption` → `svc_disrupt`
- `equity_consideration` → `equity`
- `system_reveal` → `sys_reveal`
- `thematic_sweeps` → `thematic`
- `internal_contradiction` → `contradiction`
- `developing_story` → `dev_story`

**Guidelines:**
- Use for terms appearing 5+ times
- Maintain consistency
- Document abbreviations
- Test model understanding

### 12. Symbol and Notation Compression

**Use symbols and notation to convey relationships:**

**Examples:**
- `T3→T1-2 corr` (Tier 3 requires Tier 1-2 corroboration)
- `>1% budget/>5% pop` (greater than 1% budget or 5% population)
- `Local→actionability ok` (Local stories can use actionability test)
- `T3 alone=exclude` (Tier 3 alone should be excluded)

**Benefits:**
- Significant token savings
- Clear relationships
- Compact representation
- Maintains meaning

## Domain-Specific Techniques

### 13. News/Journalism Compaction

**Techniques:**
- Use headline-style compression
- Eliminate redundant qualifiers
- Compress attribution
- Use standard abbreviations (NYT, WSJ, etc.)

### 14. Technical Documentation Compaction

**Techniques:**
- Use code-style notation
- Compress API descriptions
- Use standard technical abbreviations
- Eliminate verbose explanations

### 15. Conversational Context Compaction

**Techniques:**
- Summarize conversation history
- Extract key facts
- Preserve recent context
- Compress older context

## Quality Preservation

### Maintain Critical Information
- Preserve examples that demonstrate quality
- Keep edge case handling
- Retain important exceptions
- Maintain structural relationships

### Test and Validate
- Compare outputs before/after
- Monitor quality metrics
- Adjust compression level
- Iterate based on results

## Implementation Strategy

### Phase 1: High-Impact Changes
1. Compress source lists
2. Compress output formats
3. Compress templates
4. **Expected savings:** 40-60% of total tokens

### Phase 2: Medium-Impact Changes
1. Compress category lists
2. Compress process steps
3. Compress definitions
4. **Expected savings:** 20-30% of remaining tokens

### Phase 3: Low-Impact Refinements
1. Apply abbreviations
2. Remove redundant explanations
3. Compress examples
4. **Expected savings:** 10-15% of remaining tokens

## Tools and Resources

### Automated Tools
- **TokenCrush:** Prompt optimization service (up to 85% reduction)
- **Text summarization models:** For context compression
- **Token counters:** To measure reduction

### Manual Techniques
- Pattern identification
- Abbreviation mapping
- Structure optimization
- Quality testing

## Best Practices

1. **Start High-Impact:** Focus on largest token consumers first
2. **Preserve Quality:** Maintain examples and critical guidance
3. **Test Incrementally:** Verify after each major change
4. **Document Changes:** Keep track of abbreviations and patterns
5. **Monitor Performance:** Track token counts and quality metrics
6. **Iterate:** Refine based on results and feedback

## Common Mistakes

1. **Over-compression:** Removing too much detail
2. **Inconsistent abbreviations:** Using different forms
3. **Lost context:** Removing critical information
4. **Unclear patterns:** Patterns too vague
5. **No testing:** Compressing without validation

## References

- Token optimization research papers
- Prompt engineering best practices
- Text summarization techniques
- Context compression strategies

