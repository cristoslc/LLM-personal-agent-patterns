# Agent Skills: Cross-CLI Compatibility Analysis

Analysis of the Agent Skills open standard across Claude Code, OpenAI Codex CLI, and Google Gemini CLI — with a universal single-source-of-truth setup.

*Last updated: February 2026*

---

## Background

Anthropic introduced Agent Skills in Claude Code (October 2025), then published the format as an open standard (December 18, 2025). OpenAI adopted it in Codex CLI within weeks; Google added experimental support in Gemini CLI v0.23.0 (January 2026). The spec is governed by the Agentic AI Foundation (AAIF) under the Linux Foundation, alongside MCP.

A skill is a directory containing a `SKILL.md` file (YAML frontmatter + Markdown instructions) plus optional `scripts/`, `references/`, and `assets/` subdirectories. All three CLIs implement progressive disclosure: only metadata is loaded at session start; full instructions load on demand.

---

## Universal Setup: One Repo, Three CLIs

### Goal

Define skills and project context once, in a single canonical location, and have all three CLIs discover them — using redirects and one symlink where needed.

### Context Files

Use `AGENTS.md` as the source of truth. Redirect tool-specific files to it.

| File | Contents | Why |
|------|----------|-----|
| `AGENTS.md` | Full project instructions | Codex reads natively; canonical source |
| `CLAUDE.md` | `@AGENTS.md` | Claude Code's `@file` import loads AGENTS.md into context |
| `GEMINI.md` | `@AGENTS.md` | Gemini CLI's `@file.md` import loads AGENTS.md into context |

**Alternative for Gemini CLI**: Instead of a redirect file, configure `settings.json` to read `AGENTS.md` directly:

```json
{
  "context": {
    "fileName": ["AGENTS.md", "GEMINI.md"]
  }
}
```

This makes Gemini CLI discover `AGENTS.md` files throughout the directory hierarchy, same as it would `GEMINI.md` — no redirect file needed.

### Skill Discovery

Use `.agents/skills/` as the canonical skill directory.

| CLI | Native skill path | Scans `.agents/skills/`? | Action needed |
|-----|-------------------|--------------------------|---------------|
| Codex CLI | `.agents/skills/` | **Yes** — primary path | None |
| Gemini CLI | `.gemini/skills/` | **Yes** — alias, takes precedence over `.gemini/skills/` | None |
| Claude Code | `.claude/skills/` | **No** | Symlink |

Claude Code requires one symlink:

```bash
# From the repo root
ln -sfn ../.agents/skills .claude/skills
```

### Resulting Repo Structure

```
your-repo/
├── AGENTS.md                          # Source of truth (Codex native)
├── CLAUDE.md                          # Contains: @AGENTS.md
├── GEMINI.md                          # Contains: @AGENTS.md
│
├── .agents/
│   ├── AGENTS-SETUP.md               # First-run verification (see below)
│   └── skills/
│       ├── my-skill/
│       │   ├── SKILL.md              # Write once, works everywhere
│       │   ├── scripts/
│       │   └── references/
│       └── another-skill/
│           └── SKILL.md
│
├── .claude/
│   └── skills -> ../.agents/skills   # Symlink (git-portable on macOS/Linux)
│
└── .gitignore
```

### First-Run Bootstrap: AGENTS-SETUP.md

Symlinks are stored natively in git and survive clone on macOS/Linux. But they break silently on Windows (unless Developer Mode or `core.symlinks=true`), and new contributors may not realize the infrastructure needs verification.

The bootstrap pattern solves this: `AGENTS.md` includes a reference to `.agents/AGENTS-SETUP.md` that any agent will follow on first session, then remove.

**In `AGENTS.md`:**

```markdown
# Project instructions
...your normal project context...

@.agents/AGENTS-SETUP.md
```

**In `.agents/AGENTS-SETUP.md`:** Verification steps that the agent runs once:

1. `.agents/skills/` directory exists
2. `.claude/skills` symlink exists and resolves
3. `CLAUDE.md` contains `@AGENTS.md`
4. `GEMINI.md` contains `@AGENTS.md` (if using Gemini CLI)

After all checks pass, the agent removes the `@.agents/AGENTS-SETUP.md` line from `AGENTS.md` — but only locally, not committed. The reference stays in the committed version so fresh clones always get verified.

This keeps the setup self-documenting, agent-executable, and zero-friction for new contributors. The context cost is one line in `AGENTS.md` on first session, zero thereafter.

### User-Level (Global) Skills

The same pattern applies for personal skills that span all repos:

| CLI | User skill path | Scans `~/.agents/skills/`? |
|-----|-----------------|----------------------------|
| Codex CLI | `~/.codex/skills/` | **Yes** — via `~/.agents/skills/` |
| Gemini CLI | `~/.gemini/skills/` | **Yes** — via `~/.agents/skills/` |
| Claude Code | `~/.claude/skills/` | **No** |

```bash
# Store personal skills in ~/.agents/skills/, symlink for Claude Code
mkdir -p ~/.agents/skills
ln -sfn ~/.agents/skills ~/.claude/skills
```

---

## SKILL.md Format (Universal)

The core format is identical across all three CLIs:

```yaml
---
name: my-skill
description: >
  Brief description for discovery. Include what the skill does
  AND specific contexts for when to use it.
---

# Instructions

Step-by-step instructions in Markdown.
Claude/Codex/Gemini all read this body when the skill is activated.
```

### Progressive Disclosure (All Three CLIs)

| Tier | What loads | When |
|------|-----------|------|
| 1. Metadata | `name` + `description` from frontmatter | Session start (always) |
| 2. Instructions | Full SKILL.md body | When the agent activates the skill |
| 3. Resources | `scripts/`, `references/`, `assets/` | On demand during execution |

### Directory Structure

```
my-skill/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable scripts
├── references/       # Optional: documentation loaded into context
└── assets/           # Optional: templates, config files
```

---

## What's Universal vs. Platform-Specific

### Universal (write once, works everywhere)

- `SKILL.md` file with `name` and `description` frontmatter
- Markdown instruction body
- Progressive disclosure architecture
- Explicit invocation via slash commands / skill mentions
- Implicit invocation via description matching
- Supporting `scripts/`, `references/`, `assets/` directories

### Platform-Specific Frontmatter

| Frontmatter field | Claude Code | Codex CLI | Gemini CLI |
|-------------------|:-----------:|:---------:|:----------:|
| `name` | Yes | Yes | Yes |
| `description` | Yes | Yes | Yes |
| `disable-model-invocation` | Yes | Ignored | Ignored |
| `user-invocable` | Yes | Ignored | Ignored |
| `allowed-tools` | Yes | Ignored | Ignored |
| `compatibility` | Yes | Yes | Yes |
| `agents/openai.yaml` sidecar | Ignored | Yes | Ignored |

**Guidance**: Always include `name` and `description`. Add Claude-specific frontmatter fields for skills where invocation control matters — they're harmless on other platforms (ignored, not errors). Use the `compatibility` field to document platform-specific behavior.

### Invocation Differences

| Mechanism | Claude Code | Codex CLI | Gemini CLI |
|-----------|:-----------:|:---------:|:----------:|
| Slash command | `/skill-name` | `/skills` menu | Via extensions |
| Inline mention | N/A | `$skill-name` | N/A |
| Auto-invocation | Description match | Description match | `activate_skill` tool + consent prompt |

---

## Relationship to MCP

MCP and Agent Skills are complementary layers:

- **MCP** = connectivity (tools, data sources, APIs)
- **Skills** = procedural knowledge (how to use those tools effectively)

A skill can reference MCP servers in its instructions without depending on them structurally. This keeps skills portable — the MCP configuration is separate from the skill itself.

---

## Known Limitations

1. **Claude Code doesn't scan `.agents/skills/` natively.** Requires a symlink. This is the only structural shim needed for the universal setup.

2. **Gemini CLI `@file` imports only support `.md` files.** If your `AGENTS.md` imports non-Markdown files, those imports won't resolve in Gemini CLI. Keep redirect files to Markdown-only imports.

3. **Codex CLI's `AGENTS.md` has no `@file` import syntax.** It concatenates files hierarchically instead. If you need modular context, split into directory-level `AGENTS.md` files rather than using imports.

4. **User-level skill paths diverge.** No single `~/.agents/skills/` is natively supported by all three; Claude Code needs a symlink.

5. **Platform-specific frontmatter is silently ignored**, not rejected. This is good for portability but means you can't rely on `disable-model-invocation` behavior when the same skill runs on Codex or Gemini.

6. **Context budgets differ.** Claude Code reserves 2% of context window for skill descriptions (fallback: 16,000 chars). Codex and Gemini have their own limits. If you have many skills, test discovery on each platform.

---

## Automation

The [`agents`](https://github.com/amtiYo/agents) CLI tool automates the symlink setup:

```bash
# Generates .claude/skills/ → .agents/skills/, .gemini/skills/ → .agents/skills/, etc.
agents sync
```

For manual setup, the symlinks are trivial — see the repo structure above.

---

## References

- [Agent Skills Specification](https://agentskills.io/specification) — the open standard
- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
- [Codex CLI Skills Docs](https://developers.openai.com/codex/skills)
- [Gemini CLI Skills Docs](https://geminicli.com/docs/cli/skills/)
- [Simon Willison: OpenAI quietly adopting skills](https://simonwillison.net/2025/Dec/12/openai-skills/)
- [amtiYo/agents: One .agents source of truth](https://github.com/amtiYo/agents)
- [awesome-agent-skills](https://github.com/skillmatic-ai/awesome-agent-skills) — community skill catalog
