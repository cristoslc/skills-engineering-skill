---
source: https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
title: Skill Creator SKILL.md — anthropics/skills
type: web-page
fetched: 2026-05-01
---

# Skill Creator — Anthropic's Official Skill for Creating Skills

A skill for creating new skills and iteratively improving them through an eval-driven loop.

## High-level process

1. Decide what you want the skill to do and roughly how it should do it
2. Write a draft of the skill
3. Create a few test prompts and run Claude on them
4. Help the user evaluate results qualitatively and quantitatively
5. Rewrite the skill based on feedback
6. Repeat until satisfied
7. Expand the test set and try again at larger scale

## Creating a skill

### Capture Intent
Understand the user's intent. Extract answers from conversation history first — tools used, sequence of steps, corrections the user made, input/output formats observed.

Key questions: What should the skill enable? When should it trigger? Expected output format? Should test cases be set up? (Skills with objectively verifiable outputs benefit from tests; subjective skills like writing style often don't need them.)

### Interview and Research
Proactively ask about edge cases, input/output formats, example files, success criteria, dependencies. Check available MCPs for research (searching docs, finding similar skills, looking up best practices).

### Write the SKILL.md
Key components from the interview:
- **name**: Skill identifier
- **description**: Primary triggering mechanism — include both what the skill does AND specific contexts for when to use it. Combat "undertriggering" by making descriptions slightly "pushy."
- **compatibility**: Required tools, dependencies (optional, rarely needed)
- **the rest of the skill** — instructions, workflows, examples

### Skill Writing Guide

**Anatomy of a Skill:**
```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```

**Progressive Disclosure:**
1. Metadata (name + description) — Always in context (~100 words)
2. SKILL.md body — In context whenever skill triggers (under 500 lines ideal)
3. Bundled resources — As needed (unlimited, scripts can execute without loading)

**Key patterns:**
- Keep SKILL.md under 500 lines; add hierarchy if approaching limit
- Reference files clearly from SKILL.md with guidance on when to read them
- For large reference files (>300 lines), include a table of contents
- Domain organization: organize by variant (aws.md, gcp.md, azure.md)

**Writing Style:**
- Prefer imperative form in instructions
- Explain why things are important instead of heavy-handed MUSTs
- Use theory of mind; make skills general, not super-narrow
- Write a draft, then improve it with fresh eyes

**Writing Patterns:**
- Template pattern: "ALWAYS use this exact template" for strict requirements
- Examples pattern: input/output pairs showing desired style
- Conditional workflow: "Creating? → Creation. Editing? → Editing."

### Test Cases
After writing the draft, create 2-3 realistic test prompts. Save to `evals/evals.json`:
```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

## Running and evaluating test cases

**Step 1: Spawn all runs.** For each test case, spawn two subagents: one with the skill, one baseline (no skill for new skills, old version for improvements). Both launched in the same turn.

**Step 2: Draft assertions while runs in progress.** Good assertions are objectively verifiable with descriptive names. Subjective skills evaluated qualitatively.

**Step 3: Capture timing data as runs complete.** Save `total_tokens` and `duration_ms` to timing.json immediately — this data only comes through task notifications.

**Step 4: Grade, aggregate, and launch viewer.**
- Grade each run via grader subagent (fields: `text`, `passed`, `evidence`)
- Aggregate into benchmark: `python -m scripts.aggregate_benchmark`
- Analyst pass: surface patterns stats hide
- Launch viewer: `python eval-viewer/generate_review.py`
- Cowork/headless: use `--static <output_path>` for standalone HTML

**Step 5: Read feedback.** Process `feedback.json`, focus on specific complaints.

## Improving the skill

The heart of the loop. Key principles:

1. **Generalize from feedback.** Don't overfit to the few test examples. For stubborn issues, try different metaphors or patterns.
2. **Keep the prompt lean.** Remove things not pulling their weight.
3. **Explain the why.** Today's LLMs are smart — explain reasoning so the model understands importance. All-caps ALWAYS/NEVER is a yellow flag.
4. **Look for repeated work.** If all test cases independently wrote similar helper scripts, bundle that script into `scripts/`.

**Iteration loop**: improve → rerun all tests (with baselines) → launch reviewer with `--previous-workspace` → wait for feedback → repeat.

## Description optimization

The description field is the primary mechanism determining whether Claude invokes a skill. After creating/improving a skill, offer to optimize.

Process: generate 20 eval queries (mix of should-trigger and should-not-trigger, realistic, edge-case-focused, near-misses for negatives), review with user via HTML template, run `python -m scripts.run_loop` (splits 60/40 train/test, 3 runs per query, up to 5 iterations, selects best by test score).

Important: Claude only consults skills for tasks it can't easily handle itself. Simple queries like "read this PDF" won't trigger skills regardless of description quality. Eval queries must be substantive.

## Specialized agents

- **Executor**: Runs skills against eval prompts
- **Grader**: Evaluates outputs against assertions
- **Comparator**: Blind A/B comparison between skill versions
- **Analyzer**: Suggests targeted improvements from results

## Environment-specific instructions

**Claude.ai**: No subagents → sequential execution, skip baselines, skip benchmarking, skip description optimization (needs `claude` CLI), present results inline.

**Cowork**: Subagents work, no browser → use `--static` for viewer, feedback via downloaded JSON, packaging works.

## Packaging

Run `python -m scripts.package_skill <path>` to produce a `.skill` file. For updates, preserve the original name and copy to writable location first.
