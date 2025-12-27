# Token Optimization Best Practices

Comprehensive best practices for token optimization and compaction, including trade-offs, implementation strategies, and quality preservation techniques.

## Core Principles

### 1. Preserve Meaning
**Never sacrifice semantic integrity for token reduction.**

- Maintain core meaning and relationships
- Preserve critical contextual information
- Keep essential examples and guidance
- Retain structural information

### 2. Balance Trade-offs
**Consider all factors when optimizing:**

- **Readability:** More compact = harder for humans to read
- **Clarity:** Abbreviations may reduce LLM understanding
- **Maintainability:** Denser format harder to update
- **Performance:** Some models benefit from explicit examples

### 3. Test Impact
**Always verify that compaction doesn't degrade performance:**

- Compare outputs before/after compression
- Monitor quality metrics
- Test with target models
- Adjust compression level based on results

### 4. Iterate Incrementally
**Start with high-impact changes, then refine:**

- Phase 1: High-impact compression (40-60% savings)
- Phase 2: Medium-impact compression (20-30% savings)
- Phase 3: Low-impact refinements (10-15% savings)

## Implementation Strategy

### Phase 1: High-Impact Optimization

**Target Areas:**
1. Source lists (~800 tokens → ~400 tokens)
2. Output format examples (~600 tokens → ~200 tokens)
3. Template examples (~500 tokens → ~200 tokens)

**Techniques:**
- Replace exhaustive lists with pattern descriptions
- Compress format specifications
- Use minimal structure references

**Expected Savings:** ~1,100 tokens (40-60% of total)

### Phase 2: Medium-Impact Optimization

**Target Areas:**
1. Category include/exclude lists (~400 tokens → ~200 tokens)
2. Process steps (~300 tokens → ~100 tokens)
3. Definitions (~300 tokens → ~150 tokens)

**Techniques:**
- Use pattern descriptions
- Compress to numbered shorthand
- Consolidate similar definitions

**Expected Savings:** ~400 tokens (20-30% of remaining)

### Phase 3: Low-Impact Refinement

**Target Areas:**
1. Reminders section (~200 tokens → ~100 tokens)
2. Turn flow descriptions (~150 tokens → ~50 tokens)
3. Abbreviation usage (variable savings)

**Techniques:**
- Consolidate into single compact list
- Compress descriptions
- Apply abbreviations strategically

**Expected Savings:** ~250 tokens (10-15% of remaining)

## Quality Preservation Strategies

### Maintain Critical Examples

**Keep examples that:**
- Demonstrate quality standards
- Show edge case handling
- Illustrate important patterns
- Guide model behavior

**Compress format, not content:**
```yaml
# Before
examples:
  weak: "This is important because it affects many people"
  strong: "This reveals that municipal budgeting operates through political negotiation, not technical optimization, meaning future budget decisions will prioritize visible projects over systemic needs"

# After (compressed format, same examples)
examples: "Weak: 'affects many people'. Strong: 'reveals system operates by X not Y, meaning future decisions prioritize visible over systemic'"
```

### Preserve Edge Cases

**Maintain:**
- Important exceptions
- Special case handling
- Conditional logic
- Context-dependent rules

**Compress presentation:**
```yaml
# Before
exception: "Local stories may use local sources only, even if they lack Tier 1-2 corroboration"

# After
exception: "Local: local sources ok (T1-2 corr not required)"
```

### Retain Structural Information

**Keep:**
- Hierarchical relationships
- Process flow
- Dependencies
- Ordering requirements

**Use efficient notation:**
```yaml
# Before
process:
  step_1: "Apply temporal gate"
  step_2: "Apply source gate (depends on step 1)"
  step_3: "Apply slot test (depends on step 2)"

# After
process: "1.Temporal 2.Source (after 1) 3.Slot (after 2)"
```

## Abbreviation Guidelines

### When to Use Abbreviations

**Use abbreviations when:**
- Term appears 5+ times in document
- Abbreviation is clear and unambiguous
- Context makes meaning obvious
- Testing confirms model understanding

**Avoid abbreviations when:**
- Term appears only 1-2 times
- Abbreviation might cause confusion
- Term is critical for understanding
- No clear standard abbreviation exists

### Abbreviation Best Practices

1. **Consistency:** Use same abbreviation throughout
2. **Documentation:** Maintain abbreviation glossary
3. **Testing:** Verify model understanding
4. **Standards:** Use industry-standard abbreviations when available

**Common Abbreviations:**
```yaml
briefing_window: bw
actionability_test: act_test
service_disruption: svc_disrupt
equity_consideration: equity
system_reveal: sys_reveal
thematic_sweeps: thematic
internal_contradiction: contradiction
developing_story: dev_story
```

## Testing and Validation

### Pre-Compression Baseline

**Establish metrics:**
- Token count
- Output quality baseline
- Performance metrics
- Error rates

### Post-Compression Validation

**Compare:**
- Token count reduction
- Output quality (should maintain or improve)
- Performance metrics
- Error rates

### Quality Metrics

**Monitor:**
- Semantic accuracy
- Completeness of outputs
- Adherence to instructions
- Edge case handling

### Iterative Refinement

**Process:**
1. Compress high-impact areas
2. Test and validate
3. Adjust if needed
4. Move to next phase
5. Repeat

## Trade-off Analysis

### Readability vs. Compression

**More Compact:**
- ✅ Lower token count
- ✅ Lower costs
- ✅ Faster processing
- ❌ Harder for humans to read
- ❌ More difficult to maintain

**More Verbose:**
- ✅ Easier for humans to read
- ✅ Easier to maintain
- ✅ Better documentation
- ❌ Higher token count
- ❌ Higher costs

**Recommendation:** Maintain both versions if possible:
- Compact version for model use
- Human-readable version for maintenance

### Clarity vs. Compression

**More Explicit:**
- ✅ Better model understanding
- ✅ Fewer interpretation errors
- ✅ Clearer examples
- ❌ Higher token count

**More Compressed:**
- ✅ Lower token count
- ✅ More efficient
- ❌ Potential for misunderstanding
- ❌ May require testing

**Recommendation:** Test with target models to find optimal balance

### Maintainability vs. Compression

**More Structured:**
- ✅ Easier to update
- ✅ Clearer organization
- ✅ Better version control
- ❌ Higher token count

**More Compressed:**
- ✅ Lower token count
- ✅ More efficient
- ❌ Harder to update
- ❌ More error-prone

**Recommendation:** Use version control and documentation to mitigate

## Model-Specific Considerations

### GPT Models (OpenAI)
- Generally handle abbreviations well
- Benefit from explicit examples
- Can work with compressed formats
- Test with specific model version

### Claude Models (Anthropic)
- Strong at understanding context
- Handle compressed formats well
- Benefit from clear structure
- Good at inferring from patterns

### Gemini Models (Google)
- Good at pattern recognition
- Handle abbreviations well
- Benefit from examples
- Test with specific model version

### General Guidelines
- Test with your specific model
- Monitor output quality
- Adjust based on results
- Document model-specific optimizations

## Common Pitfalls

### 1. Over-Compression
**Problem:** Removing too much detail, hurting performance

**Solution:**
- Preserve critical examples
- Maintain edge case handling
- Test after each change
- Iterate incrementally

### 2. Inconsistent Abbreviations
**Problem:** Using different abbreviations for same term

**Solution:**
- Maintain abbreviation glossary
- Use consistent abbreviations
- Document all abbreviations
- Review before finalizing

### 3. Lost Context
**Problem:** Removing critical contextual information

**Solution:**
- Identify critical context
- Preserve essential relationships
- Maintain structural information
- Test context preservation

### 4. Unclear Patterns
**Problem:** Pattern descriptions too vague

**Solution:**
- Include examples in patterns
- Test pattern understanding
- Refine based on results
- Balance compression and clarity

### 5. No Testing
**Problem:** Compressing without verifying impact

**Solution:**
- Establish baseline metrics
- Test after each change
- Monitor quality metrics
- Iterate based on results

## Tools and Resources

### Token Counting Tools
- OpenAI Tokenizer
- Anthropic Token Counter
- Custom token counting scripts
- API response metadata

### Quality Testing
- Output comparison tools
- Quality metrics tracking
- A/B testing frameworks
- Performance monitoring

### Documentation
- Abbreviation glossaries
- Pattern descriptions
- Change logs
- Version control

## Implementation Checklist

### Pre-Compression
- [ ] Establish token count baseline
- [ ] Document current structure
- [ ] Identify high-impact targets
- [ ] Set reduction goals
- [ ] Create backup

### During Compression
- [ ] Start with high-impact areas
- [ ] Preserve critical examples
- [ ] Test after each major change
- [ ] Document abbreviations
- [ ] Track token reduction

### Post-Compression
- [ ] Verify token count reduction
- [ ] Test model performance
- [ ] Monitor output quality
- [ ] Update documentation
- [ ] Create human-readable version
- [ ] Document trade-offs

## Success Metrics

### Token Reduction
- **Target:** 40-60% reduction
- **High-impact areas:** 50-70% reduction
- **Overall:** Maintain quality while reducing tokens

### Quality Maintenance
- **Output quality:** Should maintain or improve
- **Error rates:** Should not increase
- **Edge cases:** Should still be handled correctly

### Performance
- **Processing speed:** Should improve
- **Cost:** Should decrease
- **Efficiency:** Should increase

## References

- TokenCrush: Up to 85% token reduction
- Research papers: CORE, TokenCarve, Compactor
- Prompt engineering guides: See prompt-guides/ directory
- Context compaction: forgecode.dev/docs/context-compaction/

## Conclusion

Token optimization is a balance between compression and quality. The key is to:
1. Start with high-impact changes
2. Preserve critical information
3. Test incrementally
4. Iterate based on results
5. Document everything

By following these best practices, you can achieve significant token reduction while maintaining or improving output quality.

