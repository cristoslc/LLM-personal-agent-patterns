---
title: "VISION-001 Agents Standalone Framework"
artifact: VISION-001
status: Active
author: cristos
created: 2026-03-01
last-updated: 2026-03-01
target-audience: "Solo developers and small teams using AI coding agents for spec-driven development"
value-proposition: "A portable, vendor-agnostic framework for structuring agent workflows — specifications, lifecycle management, execution tracking, and reusable skills — that works across any AI coding tool"
success-metrics:
  - "Skills are installable from the ecosystem in under 60 seconds across any major agent tool"
  - "A new project can adopt the framework scaffolding and be productive within one session"
  - "Artifact lifecycle management works the same regardless of which agent tool drives the session"
non-goals:
  - "Building a competing package manager or skill registry"
  - "Enterprise-scale multi-team coordination"
  - "Tight coupling to any single agent vendor (Claude Code, Gemini CLI, Cursor, etc.)"
  - "Runtime infrastructure or hosted services"
depends-on: []
---

# VISION-001 Agents Standalone Framework

Every developer using AI coding agents should have a structured, portable framework for managing what they're building — from vision to implementation — regardless of which agent tool they happen to use today.

AI coding agents are powerful but unstructured. They can write code, run tests, and explore codebases, but they have no shared vocabulary for *what to build* or *how to track progress*. Each session starts from scratch. Specifications live in the developer's head or in ad hoc documents. Skills and patterns are locked inside specific tool ecosystems.

This framework exists to fill that gap: a lightweight, file-based system of **specification artifacts** (Visions, Epics, Stories, Agent Specs, ADRs) with clear lifecycle phases, **reusable skills** that encode operational knowledge portably across tools, and **execution tracking** that bridges specs to implementation.

The framework serves developers who think in systems but work alone or in small teams — people who want the rigor of structured development without the overhead of enterprise tooling. It meets them where they are: in a Git repository, with markdown files, using whatever AI coding agent they prefer.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-01 | d4ed11a | Initial creation — skipped Draft, framework already in use |
