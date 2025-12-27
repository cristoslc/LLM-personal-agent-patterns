# Token Optimization Strategies

Token optimization involves refining how input data is represented and processed as tokens by AI models to enhance performance, efficiency, and interpretability.

## Core Principles

### 1. Reduce Token Count
Concise inputs reduce computation cost and inference time. Techniques include:
- Removing redundant information
- Using abbreviations for common terms
- Eliminating verbose explanations
- Consolidating similar content

### 2. Improve Tokenization Schemes
Choose appropriate tokenization strategies:
- **Byte Pair Encoding (BPE)** - Common in GPT models
- **WordPiece** - Used in BERT models
- **SentencePiece** - Used in multilingual models
- Understanding tokenization helps optimize input structure

### 3. Context Preservation
Optimize token sequence length while retaining contextual integrity:
- Preserve critical contextual information
- Maintain semantic relationships
- Keep essential metadata
- Retain structural information

### 4. Task-Specific Adjustments
Tailor tokenization to specific applications:
- Optimize for specific model architectures
- Adjust for domain-specific terminology
- Consider fine-tuning requirements
- Balance between compression and clarity

## High-Impact Optimization Techniques

### Source List Compression

**Before:**
```yaml
tier2:
  nationals: [NYT, WSJ, Washington Post, Financial Times, The Economist, Bloomberg (analysis), Reuters (analysis), Politico, The Guardian, BBC, NPR, PBS NewsHour, The Atlantic, New Yorker, ProPublica, The Intercept, Axios, Semafor]
  international: [Le Monde, Der Spiegel, El País, South China Morning Post, Nikkei Asia, The Hindu, Al Jazeera English, ABC Australia, Globe and Mail, Toronto Star]
```

**After:**
```yaml
tier2:
  types: [nationals, international, business, tech]
  rule: Major outlets with editorial standards. Examples: NYT, WSJ, FT, BBC, NPR, The Guardian, Le Monde, Der Spiegel. If uncertain, treat as Tier 3
```

**Savings:** ~400 tokens per list

### Output Format Compression

**Before:**
```yaml
output_format: |
  ## Phase 2: Story Candidates (Search Tool Results)
  **[Tier] Source | Headline | Timestamp | URL**
  - [T1] Reuters | "..." | 2025-12-24T08:00Z | [URL from search]
  - [T2] NYT | "..." | 2025-12-24T07:30Z | [URL from search]
  **Sources with no results:** [list]
  **Total candidates:** [N]
  **Duplicates:** [list]
```

**After:**
```yaml
output_format: "## Phase 2: Story Candidates | Format: [Tier] Source | Headline | Timestamp | URL | Include: no-results list, total count, duplicates"
```

**Savings:** ~400 tokens per format specification

### Template Compression

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

**Savings:** ~300 tokens per template

### Category List Compression

**Before:**
```yaml
include: [Zoning/housing policy, budget decisions w/ service impact, local/state elections/ballot measures, transit/utility/climate infra, school board decisions, state legislation w/ local implementation, regional economic shifts, environmental/health rulings w/ enforcement, tribal/port/regional compacts, public health advisories, major weather events, significant incidents, healthcare/social service provider suspensions/closures, essential service disruptions, stories disproportionately affecting vulnerable populations]
```

**After:**
```yaml
include: "Governance/infrastructure/livability changes (municipal/state/regional) OR essential service disruptions. Examples: zoning/housing, budgets, elections, transit/utilities, school boards, health advisories, weather events, service provider closures, vulnerable population impacts"
```

**Savings:** ~200 tokens per list

## Advanced Techniques

### Process Step Compression

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

**Savings:** ~200 tokens

### Definition Compression

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

**Savings:** ~150 tokens

## Abbreviation Strategies

### Common Abbreviations
- `briefing_window` → `bw`
- `actionability_test` → `act_test`
- `service_disruption` → `svc_disrupt`
- `equity_consideration` → `equity`
- `system_reveal` → `sys_reveal`
- `thematic_sweeps` → `thematic`
- `internal_contradiction` → `contradiction`

### When to Use Abbreviations
- **Use:** When term appears frequently (5+ times)
- **Use:** For technical terms with clear mappings
- **Avoid:** For terms that appear only once or twice
- **Avoid:** When abbreviation might cause confusion
- **Test:** Verify model understanding after abbreviation

## Research-Based Techniques

### CORE (Compact Object-centric REpresentations)
For vision-language models, uses object masks to guide token merging:
- Generates object-centric representations
- Significantly reduces token count
- Maintains high accuracy
- Particularly effective for visual inputs

### TokenCarve
Training-free, two-stage token compression:
1. **Pruning:** Removes low-information tokens
2. **Merging:** Combines similar tokens
- Achieves substantial token reduction
- Minimal accuracy loss
- No retraining required

### Compactor
Uses approximate leverage scores to determine token importance:
- Efficient compression of key-value caches
- No retraining needed
- Preserves important information
- Reduces computational overhead

## Implementation Priority

1. **High Impact (40-60% savings):**
   - Source lists compression
   - Output format compression
   - Template compression

2. **Medium Impact (20-30% savings):**
   - Category list compression
   - Process step compression
   - Definition compression

3. **Low Impact (10-15% savings):**
   - Abbreviation usage
   - Redundant explanation removal
   - Example URL/timestamp removal

## Trade-offs to Consider

### Readability
- **More compact = harder for humans to read**
- Consider maintaining a human-readable version
- Document abbreviations and shorthand

### Clarity
- **Abbreviations may reduce LLM understanding**
- Test with target models
- Some models benefit from explicit examples

### Maintainability
- **Denser format harder to update**
- Balance between compression and maintainability
- Use version control to track changes

### LLM Performance
- **Some models benefit from explicit examples**
- Test performance after compaction
- Monitor output quality metrics
- Adjust compression level based on results

## Best Practices

1. **Preserve Quality:** Keep examples and guidance that improve model performance
2. **Compress Format:** Use more compact structures without losing meaning
3. **Test Impact:** Verify LLM performance after compaction
4. **Iterate:** Start with high-impact changes, then refine
5. **Document:** Maintain clear documentation of abbreviations and patterns
6. **Monitor:** Track token counts and performance metrics over time

## References

- TokenCrush: Prompt optimization services (up to 85% token reduction)
- CORE: Compact Object-centric REpresentations for LVLMs
- TokenCarve: Training-free token compression framework
- Compactor: Leverage score-based token compression
- Apache Druid: Data compaction strategies
- Apache Cassandra: Unified Compaction Strategy (UCS)

