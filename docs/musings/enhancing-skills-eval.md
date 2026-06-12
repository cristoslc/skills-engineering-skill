# Enhancing Skills Eval with Agent Testing Best Practices

The current skills-engineering eval phase is a good foundation — specialist-topology subagent grading,
Track A/B comparison — but compared to what promptfoo, Anthropic, LangSmith, and Arize do, we're
leaving signal on the floor. Here's what a v2 eval system could borrow.

## 1. Multi-modal grading (three layers, not one)

{--Today every test is graded by an LLM subagent.--}{++Not entirely accurate. Script acceptance tests (test-*.sh) are already code-based, deterministic bash — no subagent involved. The claim is true for behavioral/adversarial tests only.++} That is Anthropic's "model-based" grader — flexible,
but non-deterministic and expensive. Add two more layers:

| Layer | Mechanism | What it catches |
|-------|-----------|-----------------|
| Code-based | Shell assertions on output structure, file state, tool calls | Format violations, boundary leaks, broken scripts |
| Model-based | LLM subagent with rubric (current system) | Semantic quality, tone, completeness |
| Statistical | pass@k / pass^k across N trials | Flaky tests, stochastic failures, ambiguous tasks |

Code-based graders don't need a subagent — they run as shell assertions after the trial. A test
could assert "file X must exist", "tool Y was called with param Z", or "JSON output matches schema".
Fast, cheap, objective. {--This already exists as the `assert` key in test JSON but is only used by
the grader subagent, not as a first-pass filter.--}{++Partially true. The test JSON format uses `then.agent_behavior` (behavioral) and `must_not`/`must` (adversarial) as structured assertion clauses — not a separate `assert` key. These are currently passed to the grader subagent as rubric input, never evaluated locally. The insight is right (local pre-filter before LLM grading), but the mechanism should extend the existing `then`/`must_not`/`must` structure, not add a new `assert` key.++}

## 2. Statistical evaluation for non-determinism

The current system runs each test once. If it fails, the improve phase tries to fix it.{++ This is accurate — there is no `--repeat` flag in generate.sh.++} But
Anthropic's research shows: agent behavior varies between runs. A single failure could be bad
luck, not a real regression.

Add a `--repeat N` flag (mirroring promptfoo's model). For each test:

1. Run `N` trials (default 3 for full tier, 1 for smoke)
2. Compute pass@k: agent succeeds in *at least one* of N trials
3. Compute pass^k: agent succeeds in *all* N trials
4. Report both — they tell different stories

A capability eval (skill in development) should optimize pass@k. A regression eval (shipped skill)
should enforce pass^k.

## 3. Eval-driven development for skill tasks

Anthropic's roadmap: "20-50 simple tasks drawn from real failures is a great start."

The current spec phase writes behavioral contracts before the skill exists. This is good. But:
- Tasks come from imagination, not production failures {++— fair point, though the adversary phase (phase 6) does generate negative cases from the skill's actual boundaries. The gap is in the spec phase, not the lifecycle.++}
- No reference solutions are collected alongside tasks {++— the `then.agent_behavior` clauses *are* the reference solutions for behavioral tests. They define exactly what "pass" looks like. The gap is for adversarial tests, where reference solutions are implicit (refuse/ignore).++}
- Positive/negative balance isn't tracked {++— partially addressed. The adversary phase generates `must_not` tests after the skill exists. A spec-phase `negative_cases` section would duplicate this. The real gap is that adversarial tests come *after* skill authoring, not *alongside* behavioral tests.++}

Add to spec.md:
- A `negative_cases` section: "what should the agent NOT do" — balanced against positive cases
{++— Risk: duplicating the adversary phase's purpose. Better to strengthen the adversary phase or add a "negative spec" checklist that feeds into it, rather than embedding adversarial concerns in spec.md.++}
- Reference solutions for each task before coding starts
{++— Behavioral `then` clauses already serve this purpose. For adversarial tests, the reference solution is "agent refuses/stays in boundary" — hard to write before the skill exists.++}
- Source tasks from real agent failures in consumer projects, not hypotheticals

## 4. Gradation: from capability to regression

When a skill passes all tests, the suite graduates from "capability eval" to "regression eval".
This should be automatic:

- After a full eval pass with 100%, tag the suite as regression
- Add a saturation monitor: if the same suite passes at 100% for 3 consecutive evals, flag it
- Harder tests (adversarial) become the new capability eval
- A regression failure should block all changes (CI red)

Currently, there's no distinction. A 100% pass rate means "done" — but it should mean "moved to
regression, new harder tests needed."

{++Accurate — the eval reference doc says "stop when all tests pass" with no lifecycle beyond that. This is a real gap.++}

## 5. Transcript review as a structured activity

Anthropic: "You won't know if your graders are working unless you read the transcripts."

{--The current system discards trial transcripts after grading.--}{++Not exactly. The grader subagent receives the full agent output and produces structured evidence per clause. What's missing is persistent storage of the raw transcript for post-hoc pattern analysis, not the grading itself.++} Capture them in `.eval-traces/` with:
- Full agent output per test
- Tool calls and decisions
- Grader reasoning (not just pass/fail)

During the improve phase, load recent traces and surface patterns: "agent consistently failed on
tool selection when the skill description had ambiguous keywords." This turns transcript review
from a chore into a signal source.

## 6. Online eval traces from production

LangSmith and Arize both offer: capture production traces → turn into regression tests.

Consumer projects that build skills should feed production failures back into the eval suite.
This is the eval loop:

```
Prod failure → trace captured → task extracted → added to test suite → eval catches it next time
```

The skills-engineering skill doesn't own the consumer's production infra — but it could emit
a trace format that consumers can import. An `export-eval-trace` script that dumps trial data
in a standard JSONL format would open this path.

{++Scope concern: this conflates offline skill eval with production observability. Better to start by enriching `.eval-results.json` with the data the grader already produces (clause-level evidence, per-test timing), then let consumers decide how to ingest it. The Arize/LangSmith/promptfoo integration framing is premature.++}

## 7. LLM-as-judge calibration and drift

The current system uses one subagent to grade another. This is fine initially, but:

- What if the grading model gets updated? Calibration drifts.
- What if the grading rubric is too lenient for one test and too strict for another?
- Is there a human baseline to compare against?

Add a calibration step: periodically run a small set of tasks with known answers (reference
solutions), check if the grader's scores match the known labels. If deviation exceeds a
threshold, flag the grader for recalibration.

{++Premature. The current grader uses a deterministic rubric — every clause must pass for overall pass. Calibration matters most for subjective grading scales (1-5 scores), not binary pass/fail with evidence. This becomes relevant when grading moves to softer rubrics, but right now the rubric design minimizes subjectivity by design. Defer until the base eval system has code-based pre-filtering and repeat-N.++}

## 8. Concrete build-out: translating trove knowledge into skill eval features

The agent-testing-frameworks trove catalogs what the ecosystem does. Here is a concrete
sequence of features to build into the skills-engineering skill, prioritized by impact:

### Phase A: Code-based pre-grading (least effort, highest leverage)

{++Confirmed — highest leverage change. The eval phase already runs deterministic script tests first (a gate), then dispatches to subagents for behavioral/adversarial. The gap is: no local assertion pass between "script tests pass" and "dispatch to grader." This would extend the existing gate pattern to cover structural checks on behavioral/adversarial assertions before paying for an LLM grader.++}

Before dispatching each trial to a grader subagent, run a shell-level assertion pass.
{--The test JSON already has an `assert` key — but today it's passed to the grader subagent
as part of the grading prompt. Instead, evaluate it locally first:--}{++The test JSON uses `then.agent_behavior`, `must_not`, and `must` as assertion clauses — there is no separate `assert` key. These are currently rubric input for the grader. The change: extract checkable assertions (file existence, pattern presence, tool call verification) and evaluate them as shell assertions before dispatching to the LLM grader.++}

```
trial output → shell assertions (code-based) → if all pass → LLM grader for semantic quality
                                       → if any fail → report failure, skip LLM grader
```

This would:
- Catch format violations, boundary leaks, and missing files in milliseconds
- Reduce grader subagent calls by ~40% on failing tests
- Provide deterministic evidence that doesn't vary by model choice
- Align with promptfoo's assertion-first design and Anthropic's code-based grader tier

### Phase B: Repeat-N with pass@k / pass^k

Add a `--repeat N` flag to `generate.sh --phase eval`. When set:
1. The eval harness runs each test N times (independent trials, clean context each time)
2. Aggregation computes both metrics:
   - pass@k: at least 1 of N passes (lenient — for capability evals)
   - pass^k: all N pass (strict — for regression evals)
3. The improve phase receives both scores and prioritizes fixing failures that
   fail consistently (low pass^k) over flaky failures (high pass@k, low pass^k)

Anthropic's key insight: pass@k and pass^k diverge as N grows. A skill that passes
90% of trials individually might only pass 53% of 5-trial batches consistently.
That 53% number is what users will experience.

### Phase C: Task quality gates in spec phase

Add automated checks when the spec phase writes test cases:
- Positive/negative balance checker: at least 30% of tests should test what the
  skill should NOT do (mirrors Anthropic's "balanced problem sets" rule)
- Reference solution validator: each test must have a known-good solution that
  the grader can reference
- Task ambiguity detector: if two subagent graders disagree on a test's pass/fail
  verdict, flag the task as ambiguous (Anthropic: "a good task is one where two
  domain experts would independently reach the same verdict")

{++Redundancy risk: the adversary phase already generates negative cases (`must_not`) after the skill exists. Adding a 30% negative requirement to the spec phase duplicates this. The ambiguity detector doubles grading cost (two subagents per test). The reference solution validator is reasonable for adversarial tests but behavioral `then` clauses already define pass criteria. Defer — the adversary phase covers the negative-case gap if strengthened.++}

### Phase D: Capability-to-regression automatic pipeline

After eval, if all tests pass at pass^k=1.0 across `--repeat 3`, automatically:
1. Tag the current suite as regression
2. Generate a new capability suite from harder adversarial tests or user-contributed
   failures
3. Add the regression suite to a run-every-commit config

This implements Anthropic's "graduate to regression" pattern and ensures the skill
keeps getting challenged rather than saturating.

{++Good direction. Requires: (1) a suite metadata format with a `type: capability|regression` tag, (2) a graduation heuristic in the eval phase, (3) a `--tier regression` mode in generate.sh. Design after Phase A and B are implemented.++}

### Phase E: Trace export for consumer integration

After each eval run, emit `.eval-traces/trial-<id>.jsonl` containing:
- Full transcript (agent output, tool calls, intermediate reasoning)
- Grading decisions per clause with evidence
- Timing and cost data

Consumer projects can then:
- Import traces into Arize Phoenix for production monitoring
- Feed them into promptfoo for CI/CD integration
- Use them as LangSmith datasets for regression testing

This is the bridge between offline skill evals and the consumer's production observability
stack — and it's the piece that makes the eval loop self-sustaining over time.

{++Over-scoped. Start by enriching `.eval-results.json` with clause-level evidence and per-test timing — data the grader already produces but doesn't persist. The Arize/LangSmith/promptfoo integration framing is consumer-side scope creep. The skill should emit rich results; consumers decide how to ingest.++}

## Summary

| Capability | Current | V2 target |
|---|---|---|
| Grading layers | Model-based only | Code-based + Model-based + Statistical |

{++Correction: the current system has two grading layers already — deterministic script tests (bash, no subagent) and model-based behavioral/adversarial grading. What's missing is code-based pre-filtering *between* these two: local shell assertions on behavioral/adversarial test output before paying for an LLM grader.++}
| Non-determinism | Untracked | pass@k + pass^k across N trials |
| Task sourcing | Speculative | Real failures + balanced positive/negative |
| Suite lifecycle | Flat | Capability → Regression pipeline |
| Transcripts | Discarded | Saved, analyzed for patterns |

{++Correction: not discarded — the grader subagent processes them and produces structured evidence. What's missing is persistent storage of raw transcripts for post-hoc pattern analysis.++}
| Production feedback | None | Trace import format |
| Judge calibration | None | Periodic reference-check |

{++Premature — current rubric is binary pass/fail with evidence, minimizing subjectivity.++}

None of this requires a new tool — promptfoo, LangSmith, and Arize already implement pieces of
this. The question is which pieces to embed in the skills-engineering workflow vs. which to
leave to the consumer project's choice of tool. The phasing above favors embedding code-based
grading and repeat-N (high leverage, low friction) while deferring production trace integration
to Phase E (requires consumer-side infra).