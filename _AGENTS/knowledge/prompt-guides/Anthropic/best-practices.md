# Anthropic Claude Prompt Engineering Best Practices

Based on official Anthropic documentation and "Building Effective Agents" guide (December 2024)

## Core Principles

### 1. Be Clear and Direct
- Provide explicit instructions to guide Claude's responses
- Think of Claude as a new employee who needs clear guidance
- Specificity enhances the quality of outputs

**Example:**
```
Summarize the following article in three bullet points highlighting the main arguments.
```

### 2. Use Examples (Multishot Prompting)
- Incorporate examples to demonstrate desired output format
- Guide Claude's responses through example patterns
- Ensure examples align with desired behaviors

**Example:**
```
Translate the following English sentences to French.
English: "Hello, how are you?"
French: "Bonjour, comment ça va?"
English: "What is your name?"
French:
```

### 3. Let Claude Think (Chain of Thought)
- Encourage Claude to think through problems systematically
- Break down complex tasks into smaller steps
- Guide reasoning processes for better results

**Example:**
```
Let's break down the problem step by step:
1. Identify the variables involved.
2. Determine the relationships between variables.
3. Apply the appropriate formulas to find the solution.
```

### 4. Use XML Tags for Structure
- Organize content using XML tags for clear structure and context
- Helps Claude understand document organization
- Improves parsing and response quality

**Example:**
```
<document>
  <title>Anthropic's AI Research</title>
  <author>Jane Doe</author>
  <content>
    Claude is an AI assistant developed by Anthropic to be helpful, harmless, and honest.
  </content>
</document>
```

### 5. Give Claude a Role (System Prompts)
- Define Claude's role to set expectations for responses
- Use system prompts to establish context and behavior
- Helps maintain consistent persona throughout conversation

**Example:**
```
As a customer support agent, assist the user with their inquiries in a friendly and professional manner.
```

### 6. Prefill Claude's Responses
- Provide partial responses to guide Claude's completions
- Useful for maintaining format or style consistency
- Helps Claude understand desired output structure

**Example:**
```
User: What are the benefits of using AI in healthcare?
Claude: AI in healthcare offers several benefits, including:
1.
```

### 7. Chain Complex Prompts
- Break down complex tasks into a sequence of simpler prompts
- Improves performance by focusing on specific aspects
- Allows for iterative refinement

**Example:**
```
Step 1: Summarize the following research paper.
Step 2: Identify the key findings from the summary.
Step 3: Suggest potential applications of these findings in real-world scenarios.
```

### 8. Utilize Long Context Effectively
- Place long documents at the beginning of the prompt
- Use structured tags to organize information
- Leverage Claude's long context window capabilities

**Example:**
```
<document>
  <content>
    [Long document text here]
  </content>
</document>
Please summarize the above document.
```

## Building Effective Agents

### When (and When Not) to Use Agents

**Use agents when:**
- Workflows involve complex decision-making with nuanced judgment
- Systems have difficult-to-maintain rules that are unwieldy
- Scenarios rely heavily on unstructured data interpretation
- Tasks require flexibility and model-driven decision-making at scale

**Don't use agents when:**
- Simple, single LLM calls with retrieval and in-context examples suffice
- Tasks can be easily handled with deterministic solutions
- Latency and cost tradeoffs don't make sense

### Agent Design Foundations

Three core components:

1. **Model**: The LLM powering reasoning and decision-making
2. **Tools**: External functions or APIs the agent can use
3. **Instructions**: Explicit guidelines and guardrails

### Building Blocks: The Augmented LLM

- Enhance LLMs with retrieval, tools, and memory
- Tailor capabilities to your specific use case
- Ensure easy, well-documented interface for your LLM
- Consider Model Context Protocol for third-party tool integration

### Workflow Patterns

#### Prompt Chaining
- Decompose tasks into a sequence of steps
- Each LLM call processes output of the previous one
- Add programmatic checks (gates) on intermediate steps
- Trade latency for higher accuracy

**When to use:** Tasks that can be easily decomposed into fixed subtasks

#### Routing
- Classify input and direct to specialized followup task
- Allows separation of concerns and specialized prompts
- Use for distinct categories handled separately

**When to use:** Complex tasks with distinct categories, accurate classification possible

#### Parallelization
- **Sectioning**: Break task into independent subtasks run in parallel
- **Voting**: Run same task multiple times for diverse outputs
- Effective when subtasks can be parallelized or multiple perspectives needed

**When to use:** Tasks that can be divided for speed or need multiple perspectives

#### Orchestrator-Workers
- Central LLM dynamically breaks down tasks
- Delegates to worker LLMs
- Synthesizes their results
- Flexible - subtasks determined by orchestrator

**When to use:** Complex tasks where you can't predict subtasks needed

#### Evaluator-Optimizer
- One LLM generates response
- Another provides evaluation and feedback in a loop
- Effective when iterative refinement provides measurable value

**When to use:** Clear evaluation criteria, demonstrable improvement possible

### Autonomous Agents

**Characteristics:**
- LLMs using tools based on environmental feedback in a loop
- Plan and operate independently
- Gain "ground truth" from environment at each step
- Can pause for human feedback at checkpoints
- Handle sophisticated tasks with straightforward implementation

**When to use:**
- Open-ended problems where required steps are unpredictable
- Can't hardcode a fixed path
- Need flexibility and model-driven decision-making
- Have appropriate guardrails and testing

**Core principles:**
1. Maintain **simplicity** in agent design
2. Prioritize **transparency** by showing planning steps
3. Carefully craft **agent-computer interface (ACI)** through thorough tool documentation and testing

### Prompt Engineering Your Tools

**Key considerations:**
- Give model enough tokens to "think" before writing
- Keep format close to what model has seen naturally on internet
- Avoid formatting "overhead" (accurate line counts, string-escaping)
- Put yourself in model's shoes - is tool usage obvious?
- Include example usage, edge cases, input format requirements
- Test how model uses tools - run many examples
- Poka-yoke your tools - make mistakes harder to make

**Tool format decisions:**
- Prefer formats that are easier for LLMs to write
- Avoid requiring accurate counts of thousands of lines
- Minimize string-escaping requirements
- Think about agent-computer interface (ACI) like human-computer interface (HCI)

## Advanced Techniques

### Extended Thinking
- Leverage Claude's extended thinking capabilities for complex reasoning
- Guide thinking process for tasks involving reflection
- Particularly effective for multi-step problem solving

### Parallel Tool Execution
- Claude excels at parallel tool execution
- Encourage simultaneous invocation of relevant tools
- Improves efficiency in multi-step processes

### Long Context Tips
- Place content at beginning of prompt when dealing with long documents
- Use structured tags to organize information
- Leverage Claude's ability to process extensive context

### Prompt Templates
- Use flexible base prompts that accept policy variables
- Adapt easily to various contexts
- Simplify maintenance and evaluation
- Update variables rather than rewriting entire workflows

## Best Practices Summary

1. **Start Simple**: Begin with simple prompts, optimize with evaluation
2. **Add Complexity Only When Needed**: Don't build agentic systems unless simpler solutions fall short
3. **Measure Performance**: Use comprehensive evaluation to guide improvements
4. **Iterate Based on Results**: Refine implementations based on real-world performance
5. **Maintain Transparency**: Show agent planning steps explicitly
6. **Design Tools Thoughtfully**: Invest effort in agent-computer interface design
7. **Test Extensively**: Run many examples to understand tool usage patterns

## Resources

- [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Prompt Engineering Overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- [Be Clear, Direct, and Detailed](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/be-clear-and-direct)
- [Use Examples (Multishot Prompting)](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-examples)
- [Chain Complex Prompts](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/chain-prompts)
- [Long Context Tips](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips)
- [Extended Thinking Tips](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/extended-thinking-tips)

---

*Last updated: December 2024*
*Sources: Anthropic "Building Effective Agents" (December 2024) and official Claude documentation*

