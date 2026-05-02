---
title: "Red/green TDD — Agentic Engineering Patterns"
source: https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/
author: Simon Willison
type: web
fetched: 2026-05-01
tags: [tdd, testing, coding-agents, agentic-engineering, red-green]
---

# Red/green TDD

"Use red/green TDD" is a succinct way to get better results out of a coding agent.

## Why TDD for agents

TDD (Test Driven Development) ensures every piece of code is accompanied by automated tests. The most disciplined form is **test-first development**: write tests first, confirm they fail, then implement until they pass.

This is a fantastic fit for coding agents because:
- Agents risk writing code that doesn't work, or building unnecessary code
- Test-first development protects against both mistakes
- Ensures a robust test suite that protects against future regressions
- As projects grow, the chance of new changes breaking existing features grows — tests prevent this

## The red/green cycle

**Red phase**: Watch the tests fail — confirms tests are actually testing the intended behavior
**Green phase**: Confirm they now pass — verifies the implementation works

Critical to confirm tests fail *before* implementing. Skipping this risks building tests that pass already, failing to exercise the new implementation.

Every good model understands "red/green TDD" as shorthand for: "use test driven development, write the tests first, confirm that the tests fail before you implement the change that gets them to pass."

## Example prompt

```
Build a Python function to extract headers from a markdown string. Use red/green TDD.
```
