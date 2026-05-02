---
title: "Harness Engineering: Leveraging Codex in an Agent-First World — OpenAI Engineering"
source: https://openai.com/index/harness-engineering/
author: Ryan Lopopolo (OpenAI)
type: web
fetched: 2026-05-01
tags: [openai, codex, agentic-engineering, harness, repository-design, architecture-enforcement]
---

# Harness Engineering: Leveraging Codex in an Agent-First World

OpenAI's internal experiment: building a product with **0 lines of manually-written code**. Three engineers driving Codex produced ~1M lines of code and ~1,500 PRs over 5 months, at ~1/10th traditional development time.

## The constraint

No human-written code allowed. Every line — application logic, tests, CI config, docs, observability, internal tooling — by Codex. **Humans steer. Agents execute.**

When something failed, the fix was never "try harder" but "what capability is missing, and how do we make it legible and enforceable for the agent?"

## Repository knowledge as system of record

Tried "one big AGENTS.md" — it failed because:
- Context is a scarce resource — a giant instruction file crowds out task, code, and docs
- Too much guidance becomes non-guidance — when everything is "important," nothing is
- It rots instantly — stale rules accumulate, agents can't tell what's true
- Hard to verify mechanically — no coverage, freshness, ownership checks

Instead: **AGENTS.md as table of contents (~100 lines)**, pointing to a structured `docs/` directory as the system of record. This enables **progressive disclosure**: agents start with a small entry point and are taught where to look next.

## Knowledge store layout

```
AGENTS.md (100 lines — table of contents)
ARCHITECTURE.md
docs/
  design-docs/     (index.md, core-beliefs.md, ...)
  exec-plans/      (active/, completed/, tech-debt-tracker.md)
  generated/       (db-schema.md)
  product-specs/   (index.md, ...)
  references/      (design-system-reference-llms.txt, ...)
  DESIGN.md
  FRONTEND.md
  PLANS.md
  PRODUCT_SENSE.md
  QUALITY_SCORE.md
  RELIABILITY.md
  SECURITY.md
```

Enforced mechanically: linters and CI jobs validate knowledge base is up-to-date, cross-linked, structured correctly. A recurring "doc-gardening" agent scans for stale docs.

## Agent legibility

Anything Codex can't access in-context effectively doesn't exist. Knowledge in Google Docs, Slack, or people's heads is invisible. Only repo-local, versioned artifacts (code, markdown, schemas, executable plans) are seeable. This pushes more context into the repo over time.

Technologies described as "boring" tend to be easier for agents to model. In some cases, cheaper to reimplement subsets of functionality than work around opaque upstream behavior.

## Architecture enforcement

Built around rigid layered architecture per business domain with strictly validated dependency directions. Enforced via Codex-generated custom linters and structural tests. The constraints are what allows speed without architectural drift.

In human-first workflows these rules feel pedantic. With agents, they become multipliers: encoded once, applied everywhere at once.

## Throughput changes merge philosophy

Minimal blocking merge gates. Short-lived PRs. Test flakes addressed with follow-up runs rather than blocking. Corrections are cheap, waiting is expensive. This would be irresponsible in a low-throughput environment.

## End-to-end autonomy capabilities

Given a single prompt, Codex can now: validate codebase state, reproduce bugs, record failure demonstration video, implement fix, validate fix by driving the app, record resolution video, open PR, respond to agent/human feedback, detect/remediate build failures, escalate to human only when judgment required, and merge.

## Garbage collection

Codex replicates existing patterns — even suboptimal ones. Team initially spent Fridays (20% of week) cleaning up "AI slop." Instead, encoded "golden principles" into repo with recurring background Codex tasks that scan for deviations and open targeted refactoring PRs. Most reviewable in under a minute. Functions like garbage collection for technical debt.
