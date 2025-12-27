# Prompt Compression Techniques

Prompt compression focuses on reducing the token count of prompts and instructions while maintaining their effectiveness and clarity.

## Core Strategies

### 1. Remove Redundant Information

**Identify and eliminate:**
- Repeated explanations of the same concept
- Verbose descriptions that don't add value
- Unnecessary context that doesn't affect output
- Redundant reminders already covered elsewhere

**Example:**
```yaml
# Before
reminders:
  - NO WEB SEARCH TOOLS = DO NOT PROCEED. Tell user immediately
  - URLs from search tools ONLY. Constructed URLs = fabrication = failure
  - PHASE SEQUENCING MANDATORY: "continue" after Phase 1 = Phase 2 ONLY, then stop
  - After Phase 2: MUST wait. Do NOT output Phase 3 or 4
  - After Phase 3: MUST wait. Do NOT output Phase 4

# After
reminders: "Web search required. URLs from search only. One phase per turn. Temporal gate absolute. T3 alone=exclude. One dev=one story. Local needs local sources."
```

**Savings:** ~100-200 tokens

### 2. Compress Examples

**Replace full examples with minimal specifications:**

**Before:**
```yaml
slot_test:
  valid_answers:
    - "This reveals that [system] operates by [mechanism], not [assumption]"
    - "This shows [actor] has [power/constraint] that wasn't visible before"
  examples:
    weak: "This is important because it affects many people"
    strong: "This reveals that municipal budgeting operates through political negotiation, not technical optimization, meaning future budget decisions will prioritize visible projects over systemic needs"
```

**After:**
```yaml
slot_test: "Articulate ONE worldview change (system/mechanism/assumption OR actor/power/constraint). Weak: 'affects many people'. Strong: 'reveals system operates by X not Y'"
```

**Savings:** ~150-300 tokens per example set

### 3. Consolidate Similar Rules

**Merge related instructions:**

**Before:**
```yaml
temporal_gate:
  rule: "Reject stories outside briefing_window"
  exception: "Flag for developing_story if material update exists"
source_gate:
  rule: "Reject Tier 3 sources lacking Tier 1-2 corroboration"
  exception: "Local stories may use local sources only"
```

**After:**
```yaml
gates: "Temporal: reject outside bw (dev_story exception) | Source: T3 alone=exclude (Local: local sources ok)"
```

**Savings:** ~100-150 tokens

### 4. Use Pattern Descriptions Instead of Lists

**Replace exhaustive lists with pattern descriptions:**

**Before:**
```yaml
forbidden_phrases:
  - "breaking news"
  - "developing story"
  - "we're following"
  - "stay tuned"
  - "more to come"
  - "this is a developing story"
  - "we'll update as more information becomes available"
```

**After:**
```yaml
forbidden_phrases: "Breaking/developing/stay tuned/we're following/more to come/update as info available"
```

**Savings:** ~50-100 tokens per list

### 5. Compress Structured Sections

**Convert verbose YAML structures to compact formats:**

**Before:**
```yaml
why_it_matters:
  quality_standards:
    - cost: "Quantify financial impact (dollars, percentages, scale)"
    - loser: "Identify who is harmed and how"
    - broken_assumption: "Challenge conventional wisdom"
    - time_horizon: "Explain when effects manifest"
  examples:
    weak: "This matters because it affects the economy"
    strong: "This shifts $2B in federal funding from rural to urban areas, meaning rural hospitals will face 15-20% budget cuts over 3 years, forcing closures in communities already struggling with healthcare access"
```

**After:**
```yaml
why_it_matters: "Cost/loser/assumption/horizon. Weak: 'affects economy'. Strong: '$2B shift→rural hospitals 15-20% cuts→closures'"
```

**Savings:** ~200-300 tokens per section

## Advanced Compression Techniques

### 6. Turn Flow Compression

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

**Savings:** ~150-200 tokens

### 7. Search Strategy Compression

**Before:**
```yaml
search_strategy:
  temporal: "Search within briefing_window, prioritize recent"
  thematic_sweeps: "Group related searches by theme"
  minimum_searches: "At least 3 searches per category"
  validation: "Cross-reference multiple sources"
```

**After:**
```yaml
search_strategy: "Within bw, prioritize recent. Group by theme. Min 3/category. Cross-reference sources"
```

**Savings:** ~100-150 tokens

### 8. Story Consolidation Compression

**Before:**
```yaml
consolidation:
  combine_when:
    - shared_actors_and_timeline: "Same actors, same time period"
    - same_underlying_event: "Different angles on same event"
  keep_separate_when:
    - different_time_periods: "Even if same actors"
    - different_geographic_scope: "Even if related"
```

**After:**
```yaml
consolidation: "Combine: shared actors+timeline OR same event. Separate: different time/geography"
```

**Savings:** ~100-150 tokens

### 9. Quality Gate Compression

**Before:**
```yaml
quality_gate:
  before_composition:
    - "Is slot_test clearly articulated?"
    - "Is why_it_matters specific and quantified?"
    - "Are actors and their roles clear?"
  if_answers_are_no:
    - "Reframe the story"
    - "Gather more information"
    - "Reconsider story selection"
```

**After:**
```yaml
quality_gate: "Check: slot_test clear? why_it_matters specific? actors clear? If no: reframe/gather/reconsider"
```

**Savings:** ~100-150 tokens

## Pattern Recognition Compression

### 10. Established Patterns Section

**Before:**
```yaml
established_patterns_ARE_newsworthy_when:
  - internal_contradiction: "Reveals system operates differently than stated"
  - power_shift: "Changes who has decision-making authority"
  - precedent_break: "Establishes new pattern for future decisions"
reframe_prompts:
  - "What system does this reveal?"
  - "Who gains/loses power here?"
  - "What precedent does this set?"
```

**After:**
```yaml
patterns_newsworthy: "contradiction/power_shift/precedent. Reframe: system? power? precedent?"
```

**Savings:** ~150-200 tokens

## Context Compaction for Conversational AI

### 11. Conversation History Compression

For conversational AI, compress context while maintaining relevance:

**Strategies:**
- **Summarization:** Use models to summarize conversation history
- **Selective Retention:** Keep only relevant recent context
- **Threshold-Based:** Compact when context exceeds threshold
- **Retention Windows:** Define what gets compacted and when

**Best Practices:**
- Choose summarization models that balance speed and quality
- Configure retention and eviction windows appropriately
- Select thresholds based on model's context window
- Monitor quality after compaction

### 12. Context Window Management

**Techniques:**
- **Sliding Window:** Keep only most recent N tokens
- **Hierarchical Summarization:** Summarize older context, keep recent detailed
- **Key Information Extraction:** Extract and preserve critical facts
- **Topic-Based Segmentation:** Group related context for compression

## Implementation Checklist

### Pre-Compression
- [ ] Identify token count baseline
- [ ] Document current structure
- [ ] Identify high-impact compression targets
- [ ] Set target token reduction goal

### During Compression
- [ ] Start with high-impact sections
- [ ] Preserve critical examples
- [ ] Test after each major change
- [ ] Document abbreviations and patterns

### Post-Compression
- [ ] Verify token count reduction
- [ ] Test model performance
- [ ] Monitor output quality
- [ ] Update documentation
- [ ] Create human-readable version if needed

## Quality Preservation Strategies

### Maintain Critical Information
- Keep examples that demonstrate quality standards
- Preserve edge case handling
- Retain important exceptions
- Maintain structural clarity

### Test and Validate
- Compare outputs before/after compression
- Monitor for quality degradation
- Adjust compression level based on results
- Iterate based on feedback

## Common Pitfalls

1. **Over-compression:** Removing too much detail, hurting model performance
2. **Inconsistent abbreviations:** Using different abbreviations for same term
3. **Lost context:** Removing critical contextual information
4. **Unclear patterns:** Pattern descriptions too vague for model understanding
5. **No testing:** Compressing without verifying impact on output quality

## References

- TokenCrush: Up to 85% token reduction while maintaining meaning
- Context Compaction: forgecode.dev/docs/context-compaction/
- Prompt Engineering Best Practices: See prompt-guides/ directory

