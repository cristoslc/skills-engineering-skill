---
date: 2026-05-01
topic: skill-design
---

# AGENTS.md as Navigational Map

**Core insight:** OpenAI, Anthropic, and swain independently converged on the same conclusion: the agent instruction file should be a table of contents, not an encyclopedia.

## Why "one big AGENTS.md" fails

OpenAI's harness engineering team (`openai-harness-engineering`) identifies four failure modes:

1. **Context is scarce** — a giant file crowds out the actual task
2. **Too much guidance becomes non-guidance** — when everything is "important," nothing is
3. **It rots instantly** — large monolithic instruction files are impossible to keep current
4. **Hard to verify mechanically** — linters and CI can check structure, not content quality

## What it should be instead

A ~100-line entry point that teaches the agent *where* to look, not *what* to know.

**Anthropic's test:** "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it."

**What to include:**
- Repository conventions the agent can't infer from code
- Pointers to structured documentation (`docs/design-docs/`, `docs/exec-plans/`)
- Import directives (`@path/to/import`)
- Project-specific commands or tools

**What to exclude:**
- Standard conventions the agent already knows
- Detailed API docs (link instead)
- Self-evident practices
- Anything that can be mechanically verified by CI

## Relevance to skill design

A SKILL.md follows the same principle at a smaller scale:
- The description field teaches the agent *when* to use the skill
- The body teaches *how* — but should route to references for detail, not embed everything
- References handle the encyclopedic knowledge (schemas, detailed procedures, examples)
