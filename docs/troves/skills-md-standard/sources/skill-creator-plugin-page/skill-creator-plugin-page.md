---
source: https://claude.com/plugins/skill-creator
title: Skill Creator Plugin — Claude.com
type: web-page
fetched: 2026-05-01
---

# Skill Creator Plugin (Anthropic Verified)

Available at: https://claude.com/plugins/skill-creator

## Overview

Skill Creator is a comprehensive toolkit for developing, testing, and iterating on Claude Code skills. It provides four operating modes — Create, Eval, Improve, and Benchmark — that guide you through the full skill development lifecycle, from initial concept to optimized, production-ready skills.

**Made by:** Anthropic (Verified)
**Installs:** 176,097 (as of May 2026)
**Install method:** `/plugin install skill-creator@anthropic-agent-skills` (via the official plugin marketplace)

## Four composable agents

Under the hood, four composable agents handle specialized tasks:

1. **Executor** — Runs skills against eval prompts
2. **Grader** — Evaluates outputs against defined expectations
3. **Comparator** — Performs blind A/B comparisons between skill versions
4. **Analyzer** — Suggests targeted improvements based on results

Together, these agents enable rigorous, data-driven skill refinement.

## Utility scripts

The plugin includes utility scripts for:
- Initializing skills
- Validating configurations
- Preparing evaluations
- Aggregating benchmark results with variance analysis (statistical confidence)

## How to invoke

Invoke with `/skill-creator` and choose a mode. Example prompts:
- "Create a new skill that reviews PRs for security issues"
- "Run evals on my code-review skill"
- "Improve my deploy skill based on these test cases"
- "Benchmark my skill across 10 runs and show variance"

The interactive workflow guides through requirements gathering, test case creation, and iterative optimization.

## Related official plugins

- **Frontend Design** (564,908 installs) — Production-grade frontends, polished code avoiding generic AI aesthetics
- **Superpowers** (476,245 installs) — Brainstorming, subagent development, code review, debugging, TDD, skill authoring
- **Code Review** (255,208 installs) — AI code review with specialized agents and confidence-based filtering for PRs
- **Context7** (268,967 installs) — Live docs lookup, pulls version-specific docs and code examples from source repos

## Source repos

The skill-creator plugin source lives at:
- https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator
- The skill's SKILL.md itself is at: https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md

A community fork with additional guardrails exists at https://github.com/daymade/claude-code-skills.
