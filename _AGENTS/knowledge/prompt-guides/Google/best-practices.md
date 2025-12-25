# Google Gemini Prompt Engineering Best Practices

Based on official Google documentation: "Gemini for Google Workspace Prompting Guide 101" (October 2024)

## Core Framework: The Four Pillars

When writing effective prompts for Gemini, consider these four main areas:

1. **Persona** - Define the role the AI should assume
2. **Task** - Specify what you need the AI to do (always include a verb/command)
3. **Context** - Provide relevant background information
4. **Format** - Specify the desired output structure

### Example Structure

```
You are a [persona] in [industry]. [Task] based on [context]. [Format specification].
```

**Example:**
```
You are a program manager in [industry]. Draft an executive summary email to [persona] based on [details about relevant program docs]. Limit to bullet points.
```

## Fundamental Best Practices

### 1. Use Natural Language
- Write as if speaking to another person
- Express complete thoughts in full sentences
- Avoid overly technical jargon unless necessary

### 2. Be Specific and Iterate
- Tell Gemini what you need it to do (summarize, write, change tone, create)
- Provide as much context as possible
- Use follow-up prompts to refine results
- Most fruitful prompts average around 21 words with relevant context

### 3. Be Concise and Avoid Complexity
- State your request in brief — but specific — language
- Avoid jargon
- Keep prompts clear and straightforward

### 4. Make It a Conversation
- Fine-tune prompts if results don't meet expectations
- Use follow-up prompts and iterative refinement
- Build on previous responses to improve outcomes

### 5. Use Your Documents
- Personalize Gemini's output with information from your Google Drive files
- Reference documents using `@file name` syntax
- Leverage your personal knowledge base in Drive, Docs, Gmail, and more

### 6. Make Gemini Your Prompt Editor
When using Gemini Advanced, start prompts with:
```
Make this a power prompt: [original prompt text here]
```
Gemini will suggest improvements, which you can then paste back for better results.

## Prompt Iteration Strategy

1. **Start Simple**: Begin with a basic prompt using the four pillars
2. **Refine Incrementally**: Add details based on initial output
3. **Use Follow-ups**: Build on previous responses rather than starting over
4. **Iterate Based on Results**: Adjust wording, add context, or simplify as needed

## Common Use Case Patterns

### Content Creation
- Use persona + task + context + format structure
- Reference existing documents for style consistency
- Iterate to refine tone and messaging

### Data Analysis
- Specify the type of analysis needed
- Reference source documents or spreadsheets
- Request specific output formats (tables, bullet points, summaries)

### Communication
- Define the audience and purpose
- Reference relevant documents for context
- Specify tone and format requirements

## Important Considerations

### Review Before Use
- Always review Gemini outputs for clarity, relevance, and accuracy
- Generative AI is meant to help humans, but the final output is yours
- Verify information, especially for critical business decisions

### Context Integration
- Gemini has access to your Workspace environment
- Use `@file name` to reference specific documents
- Leverage Drive, Docs, Gmail, and other Workspace apps for context

### Privacy and Security
- Your data stays in your Workspace environment
- Content is never used for targeting ads or training models
- Enterprise-grade security is maintained

## Advanced Techniques

### Breaking Down Complex Tasks
- Divide multi-step tasks into separate prompts
- Build on each step's output sequentially
- Use intermediate outputs as context for next steps

### Formatting Specifications
- Request specific formats: tables, bullet points, numbered lists
- Specify length constraints when needed
- Define style preferences (formal, casual, technical)

### Role-Based Prompting
- Assign specific roles to guide behavior
- Examples: "You are a customer service representative", "You are a technical writer"
- Combine roles with task specifications for better results

## Resources

- Official Guide: [Gemini for Google Workspace Prompting Guide 101](https://services.google.com/fh/files/misc/gemini-for-google-workspace-prompting-guide-101.pdf)
- Features Documentation: Visit g.co/gemini/features
- Workspace Blog: workspace.google.com/blog

---

*Last updated: December 2024*
*Source: Google's official "Gemini for Google Workspace Prompting Guide 101"*

