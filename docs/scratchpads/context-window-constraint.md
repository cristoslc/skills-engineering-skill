---
date: 2026-05-01
topic: skill-design
---

# Context Window as the Fundamental Constraint

**Core insight:** The context window is the primary constraint driving all other skill design decisions. It's the root from which progressive disclosure, phase-script routing, and AGENTS.md-as-map all descend.

**Why it's fundamental:**
- Context is scarce — every token in the window competes with the actual task
- Polluted context has negative value — after two failed corrections, start fresh
- Subagents don't just parallelize — they isolate context (investigation doesn't poison the main thread)

**What it drives:**
- Progressive disclosure: metadata → body → references. Load only what's needed, when it's needed
- Phase-script routing: the LLM never loads eval criteria while authoring
- AGENTS.md-as-map: the entry point teaches *where* to look, not *what* to know

**Operational rules** (from anthropic-claude-code-best-practices):
- `/clear` between unrelated tasks
- After two failed corrections, `/clear` and start fresh
- Auto-compaction when approaching limits
- `/btw` for side questions (don't enter history)
- Subagents for investigation (clean context boundary)

**One-liner:** "The context window is the API."

**Sources:** anthropic-claude-code-best-practices, anthropic-agent-skills, humanlayer-12-factor-agents
