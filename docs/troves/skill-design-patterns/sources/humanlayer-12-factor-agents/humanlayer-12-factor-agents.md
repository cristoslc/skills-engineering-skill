---
title: "12-Factor Agents — Principles for Building Reliable LLM Applications"
source: https://github.com/humanlayer/12-factor-agents
author: Dex Horthy (HumanLayer)
type: web
fetched: 2026-05-01
tags: [agent-architecture, production-agents, reliability, control-flow, context-management, 12-factor]
---

# 12-Factor Agents

Dex Horthy's principles for building LLM-powered software reliable enough for production customers. Inspired by [12 Factor Apps](https://12factor.net/). Based on experience with 100+ SaaS builders and extensive framework experimentation.

## Core insight

Most production "AI agents" are not all that agentic. They're mostly deterministic code with LLM steps sprinkled in at the right points. Agents, at least the good ones, don't follow "here's your prompt, here's tools, loop until done." They're comprised of mostly just software.

## The 12 Factors

1. **Natural Language to Tool Calls** — Convert natural language to structured tool calls; deterministic code executes them
2. **Own your prompts** — Control prompt construction; don't outsource to frameworks
3. **Own your context window** — Actively manage what goes into context; the context window is the API
4. **Tools are just structured outputs** — Tools don't need to be complex; they're just structured JSON output triggering deterministic code
5. **Unify execution state and business state** — Keep one source of truth for both
6. **Launch/Pause/Resume with simple APIs** — Agent workflows must support async patterns
7. **Contact humans with tool calls** — Encode human contact points as tools the agent can invoke
8. **Own your control flow** — Don't let frameworks control the loop; you own the while loop
9. **Compact errors into context window** — Error information should be compacted and fed back
10. **Small, focused agents** — Smaller agents with focused scopes are more reliable
11. **Trigger from anywhere, meet users where they are** — Agents triggered by cron, webhooks, messages, not just chat
12. **Make your agent a stateless reducer** — State in, state out; deterministic and testable

## Why frameworks fail

The common journey of SaaS builders:
1. Decide to build an agent
2. Grab $FRAMEWORK to move fast
3. Get to 70-80% quality bar
4. Realize 80% isn't good enough for production
5. Getting past 80% requires reverse-engineering the framework
6. Start over from scratch

The thesis: fastest way to get good AI software in customer hands is to take **small, modular concepts from agent building** and incorporate them into existing products, rather than adopting a framework wholesale.

The agent loop pattern at its core:
```python
context = [initial_event]
while True:
    next_step = await llm.determine_next_step(context)
    context.append(next_step)
    if next_step.intent == "done":
        return next_step.final_answer
    result = await execute_step(next_step)
    context.append(result)
```
