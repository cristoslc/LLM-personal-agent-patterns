# LLM-personal-agent-patterns
NotesHub Notebook

## L3 — Agents Standalone

Cross-CLI agent scaffolding (`.agents/` directory, skills, setup verification) that you can import into any project repo. Works with Claude Code, Codex CLI, and Gemini CLI.

### Install

From your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/cristoslc/LLM-personal-agent-patterns/main/L3-agents-standalone/import-agents-standalone.sh | bash
```

This adds an `agents-upstream` remote, squash-merges the scaffolding, and stages the files. Review with `git diff --cached --stat`, then commit.

### Update

```bash
git fetch agents-upstream l3-standalone
git merge agents-upstream/l3-standalone --squash
```
