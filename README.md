# LLM-personal-agent-patterns
NotesHub Notebook

## L3 — Agents Standalone

Cross-CLI agent scaffolding (`.agents/` directory, skills, setup verification) that you can import into any project repo. Works with Claude Code, Codex CLI, and Gemini CLI.

### Install

**Option A — npx skills** (recommended if you have Node.js):

```bash
npx skills add https://github.com/cristoslc/LLM-personal-agent-patterns
```

**Option B — git clone:**

```bash
git clone --depth 1 https://github.com/cristoslc/LLM-personal-agent-patterns.git /tmp/agents-scaffold
cp -r /tmp/agents-scaffold/L3-agents-standalone/.agents .agents
cp /tmp/agents-scaffold/L3-agents-standalone/AGENTS.md AGENTS.md
cp /tmp/agents-scaffold/L3-agents-standalone/CLAUDE.md CLAUDE.md
rm -rf /tmp/agents-scaffold
```

Review the copied files and commit.

### Update

Use the `update-agents-core` skill, or manually:

```bash
git remote add agents-upstream https://github.com/cristoslc/LLM-personal-agent-patterns.git  # first time only
git fetch --depth=1 agents-upstream l3-standalone
git merge agents-upstream/l3-standalone --allow-unrelated-histories --squash
```
