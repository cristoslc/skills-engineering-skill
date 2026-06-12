# Hardening Skills Eval with Agent Testing Best Practices

The current skills-engineering eval phase is a good foundation — specialist-topology subagent grading,
Track A/B comparison — but compared to what promptfoo, Anthropic, LangSmith, and Arize do, we're
leaving signal on the floor. Here's what a v2 eval system could borrow.

## 1. Multi-modal grading (three layers, not one)

Today every test is graded by an LLM subagent. That is Anthropic's "model-based" grader — flexible,
but non-deterministic and expensive. Add two more layers:

| Layer | Mechanism | What it catches |
|-------|-----------|-----------------|
| Code-based | Shell assertions on output structure, file state, tool calls | Format violations, boundary leaks, broken scripts |
| Model-based | LLM subagent with rubric (current system) | Semantic quality, tone, completeness |
| Statistical | pass@k / pass^k across N trials | Flaky tests, stochastic failures, ambiguous tasks |

Code-based graders don't need a subagent — they run as shell assertions after the trial. A test
could assert "file X must exist", "tool Y was called with param Z", or "JSON output matches schema".
Fast, cheap, objective. This already exists as the `assert` key in test JSON but is only used by
the grader subagent, not as a first-pass filter.

## 2. Statistical evaluation for non-determinism

The current system runs each test once. If it fails, the improve phase tries to fix it. But
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
- Tasks come from imagination, not production failures
- No reference solutions are collected alongside tasks
- Positive/negative balance isn't tracked

Add to spec.md:
- A `negative_cases` section: "what should the agent NOT do" — balanced against positive cases
- Reference solutions for each task before coding starts
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

## 5. Transcript review as a structured activity

Anthropic: "You won't know if your graders are working unless you read the transcripts."

The current system discards trial transcripts after grading. Capture them in `.eval-traces/` with:
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

## 7. LLM-as-judge calibration and drift

The current system uses one subagent to grade another. This is fine initially, but:

- What if the grading model gets updated? Calibration drifts.
- What if the grading rubric is too lenient for one test and too strict for another?
- Is there a human baseline to compare against?

Add a calibration step: periodically run a small set of tasks with known answers (reference
solutions), check if the grader's scores match the known labels. If deviation exceeds a
threshold, flag the grader for recalibration.

## Summary

| Capability | Current | V2 target |
|---|---|---|
| Grading layers | Model-based only | Code-based + Model-based + Statistical |
| Non-determinism | Untracked | pass@k + pass^k across N trials |
| Task sourcing | Speculative | Real failures + balanced positive/negative |
| Suite lifecycle | Flat | Capability → Regression pipeline |
| Transcripts | Discarded | Saved, analyzed for patterns |
| Production feedback | None | Trace import format |
| Judge calibration | None | Periodic reference-check |

None of this requires a new tool — promptfoo, LangSmith, and Arize already implement pieces of
this. The question is which pieces to embed in the skills-engineering workflow vs. which to
leave to the consumer project's choice of tool.