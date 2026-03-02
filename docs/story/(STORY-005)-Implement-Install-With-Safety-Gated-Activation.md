---
title: "Implement Install With Safety-Gated Activation"
artifact: STORY-005
status: Implemented
author: cristos
created: 2026-03-02
last-updated: 2026-03-02
parent-epic: EPIC-003
related:
  - JOURNEY-001
---

# Implement Install With Safety-Gated Activation

**As a** skill consumer, **I want** a single install command with security audit and rollback, **so that** I can install skills safely.

## Acceptance Criteria

1. `install.sh` wraps `npx skills add` when available, falls back to `fetch-remote-skill.sh`.
2. Stamps `.source.yml` after install.
3. Runs `audit.sh` post-install.
4. Rolls back on critical findings (exit 2).
5. `audit.sh` checks: exfiltration, env-harvesting, credential-access, obfuscation, reverse-shells, curl-pipe-shell, prompt-injection, known-malicious.
6. Smoke test covers both paths + rollback.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Draft | 2026-03-02 | 21421b0 | Initial creation |
| Implemented | 2026-03-02 | ee5ec0c | install.sh + audit.sh + smoke tests AC-6..AC-9 |
