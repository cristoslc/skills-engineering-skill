---
date: 2026-05-01
topic: skill-design
---

# Subagent Dispatch Topologies

**Core insight:** There are at least three distinct dispatch topologies, each trading off a different resource. The choice is about *what kind of freshness* you need, not just CPU vs. I/O.

## Topology 1: Specialist (per-lens)
- One subagent per review lens (security, style, logic, docs)
- Each reviews all code segments
- Reads each file N times (4× overhead)
- **Gives**: domain depth — each lens has undivided attention
- **Costs**: I/O duplication
- **Source:** code-review-skill

## Topology 2: Segment (per-file)
- One subagent per code segment
- Each applies all lenses sequentially within that segment
- Reads each file once
- **Gives**: single-read efficiency
- **Costs**: context switching within each subagent (all lenses loaded)
- **Source:** code-review-skill

## Topology 3: Writer/Reviewer (per-role)
- Two parallel subagents — one writes, one reviews
- The reviewer has fresh context, no bias from having written
- **Gives**: unbiased second eyes — catches blind spots the writer can't see
- **Costs**: no overlap with writing agent's reasoning
- **Source:** anthropic-claude-code-best-practices

## Choosing a topology

| You need... | Use... |
|-------------|--------|
| Deep coverage from multiple angles | Specialist |
| Minimal I/O, simple work | Segment |
| Unbiased quality gate | Writer/Reviewer |
| Investigation without polluting main context | Any — subagents always isolate context |

**Convergence point:** All topologies express the same principle from humanlayer-12-factor-agents Factor 10 — small, focused agents are more reliable than large general-purpose ones.
