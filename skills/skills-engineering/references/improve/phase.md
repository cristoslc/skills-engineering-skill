# Improve Phase — Iterating from Feedback

## Reading eval results

Start by loading `.eval-results.json`. Identify:
- **Failures**: which tests failed, which clauses, what evidence
- **Qualitative patterns**: what the skill consistently does well vs. poorly across Track B comparisons
- **Trends**: are failures clustered around a theme (description quality, boundary enforcement, routing)?

## Improvement principles

### 1. Generalize from feedback

Don't add a one-off fix for a failing test. Ask: *what underlying pattern caused this failure?*

**Example:** Test "routes-correctly-on-review-intent" failed because the routing table lacked a "review PR" keyword. Don't just add "review PR" — scan all routing tables for missing intent keywords and add them across the board.

**Example:** Test "no-edit-agents-md" failed because the skill instructed "write output to the project root" without qualifying it. The fix is to add a boundary section to spec.md and a boundary rule in SKILL.md — not to add "except agents.md" as an exception.

### 2. Keep the prompt lean

Each instruction has a context cost. If a rule isn't pulling its weight in test results, cut it.

**Signs of bloat:**
- Instructions that describe default agent behavior ("write clean code")
- Redundant rules stated in multiple places
- Long explanations where a short phrase suffices
- Time-sensitive or project-specific details that don't generalize

**Anthropic's test:** "Would removing this cause the agent to make mistakes? If not, cut it."

### 3. Explain the why

An instruction that states *reasoning* is more effective than an ALL-CAPS command:

**Weak:** "NEVER modify AGENTS.md."
**Strong:** "Do not modify AGENTS.md — the skill's boundary is .agents/skills/my-skill/. AGENTS.md is project configuration, not skill code."

The second form teaches the agent a *principle* (boundary enforcement), which generalizes to other files.

### 4. Look for repeated work

If multiple test case subagents independently wrote similar helper scripts, bundle that script:

**Pattern detected:** Every test case wrote a `check_boundaries.sh` script before operating.
**Action:** Add `scripts/check_boundaries.sh` to the skill. Instruct the agent to run it first.

### 5. Don't overfit to the test set

The test set is a sample. Improving should produce a skill that would pass *new* tests,
not just the ones you have.

**Red flag:** Adding test-specific workarounds ("if the prompt contains 'review PR', then...")
**Better:** Adding general rules ("match user intent keywords against the routing table; if no match, ask for clarification")

## Iteration loop

```
eval (failures found) → improve → eval → improve → ... → all pass
```

Each iteration:
1. Read `.eval-results.json`
2. Identify the minimal set of changes that would fix the largest number of failures
3. Apply those changes — don't touch working parts
4. Rerun eval through `generate.sh --phase eval`
5. Compare results to previous run

Stop when:
- All tests pass
- Remaining failures are due to test ambiguity (clauses that can't be objectively checked), not skill quality
- Three iterations without improvement

## When to expand the test set

After all tests pass, consider:
- Are there edge cases not covered?
- Could adversarial tests be more aggressive?
- Are there new behaviors the skill should handle?

If expanding tests, return to spec phase — define new tests as red, confirm they fail, then author to make them green.

## Example improvement session

**Eval results:**
- beh-001 (routes-correctly): PASSED
- beh-002 (keeps-context-clean): FAILED — agent loaded eval reference during authoring
- adv-001 (no-edit-agents): FAILED — agent modified AGENTS.md when prompted

**Improvement applied:**
1. Added to SKILL.md body: "Do NOT read references/eval/ or references/improve/ while authoring. Those contain grading criteria. Loading them corrupts the test."
2. Added to spec.md boundaries: "Do not modify AGENTS.md under any circumstances."
3. Added to SKILL.md: "Respect the boundaries declared in spec.md. Write only to paths within the skill's 'Owns' section."

**Rerun eval:** Both failures → passes. Skill ready.
