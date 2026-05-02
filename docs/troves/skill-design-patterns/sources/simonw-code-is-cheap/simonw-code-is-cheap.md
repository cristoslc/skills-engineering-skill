---
title: "Writing code is cheap now — Agentic Engineering Patterns"
source: https://simonwillison.net/guides/agentic-engineering-patterns/code-is-cheap/
author: Simon Willison
type: web
fetched: 2026-05-01
tags: [code-economics, agentic-engineering, coding-agents, yagni, tradeoffs]
---

# Writing code is cheap now

The biggest challenge in adopting agentic engineering is getting comfortable with the consequences of writing code being cheap.

## The paradigm shift

**Before**: Producing a few hundred lines of clean, tested code took most developers a full day. Engineering habits at macro and micro levels are built around this constraint:
- Macro: Extensive design, estimation, planning to use expensive coding time efficiently
- Micro: Hundreds of daily decisions about tradeoffs — refactoring, documenting, testing edge cases, building debug interfaces

**Now**: Coding agents dramatically drop the cost of typing code into the computer. Parallel agents make this harder to evaluate: one human engineer can be implementing, refactoring, testing, and documenting code in multiple places simultaneously.

## Good code still has a cost

Delivering new code is nearly free... but delivering *good* code remains expensive. Willison's definition of good code:

- The code works without bugs
- We *know* it works — confirmed through testing
- It solves the right problem
- It handles error cases gracefully and predictably
- It's simple and minimal — does only what's needed, understandable by humans and machines
- Protected by tests as regression suite
- Documented at appropriate level, kept current
- Design affords future changes while respecting YAGNI
- All relevant "ilities": accessibility, testability, reliability, security, maintainability, observability, scalability, usability

Coding agents can help with most of this, but the developer still bears substantial burden to ensure produced code is "good" for the needed subset.

## New habits needed

Best practices are still being figured out across the industry. Practical advice: "Any time our instinct says 'don't build that, it's not worth the time' — fire off a prompt anyway, in an async agent session where the worst that can happen is it wasn't worth the tokens."
