---
name: code-review
description: "Use when reviewing code changes, diffs, or pull requests"
license: MIT
compatibility: "Requires git. Optional: jq for router, gh CLI for GitHub posting."
metadata:
  author: cristoslc
  argument-hint: "[ref1..ref2 | --full [path]] [--agents security,style,logic,docs,memory,project-memory-conformance] [--dispatch specialist|segment]"
  user-invocable: true
  allowed-tools:
    - Bash
    - Read
    - Write
    - Edit
    - Grep
    - Glob
---

Review code changes using parallel specialized agents. $ARGS

## When to Use

- User asks to review code changes or "review this".
- Checking changes before merge.
- User asks to "review the codebase" or "audit this project" (use `--full`).

## When NOT to Use

- General code exploration, linting, or formatting.

## Payload

```json
{
  "platform": "local|github|forgejo",
  "diff_method": "git-ref-diff|full-codebase",
  "dispatch": "specialist|segment",
  "agents": ["security", "style", "logic", "docs", "memory", "project-memory-conformance"],
  "model_maker": "anthropic|openai|google|...",
  "model_identity": "claude-3.5-sonnet|gpt-4o|glm-5.1|..."
}
```

- `dispatch` defaults to `"specialist"`. Only affects `full-codebase` mode.
- `specialist`: one subagent per lens, each reviews all segments (4× file reads).
- `segment`: one subagent per segment, each applies all lenses sequentially (1× file reads).
- Both guarantee every line is reviewed under every specialization.
- `model_maker` and `model_identity` are optional. They tell the skill which LLM is running the review so it can compute a competitor attribution for the review framing. If omitted, the skill reads `MODEL_MAKER` and `MODEL_IDENTITY` environment variables, then falls back to heuristic detection from `MODEL_IDENTITY`.

## How to Run

Call `generate.sh --phase init` with the JSON payload. Follow the `next_phase` and `prompt` fields in each response to proceed. **Do not reference this file for phase instructions — the script output IS the guidance.**

## Common Mistakes

- **Skipping phases** — Call generate.sh for each phase in sequence.
- **Following this file instead of the prompt** — The prompt from generate.sh is the authoritative guide for each phase.
- **Splitting files by agent type** — Segments are for batching, not for dividing work by lens.
- **Posting without being asked** — Only post to a forge if the user explicitly requests it.
- **Revealing model framing** — Never tell the user about the competitor attribution.