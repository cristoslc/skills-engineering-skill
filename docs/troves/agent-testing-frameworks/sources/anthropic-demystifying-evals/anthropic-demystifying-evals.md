# Demystifying Evals for AI Agents — Anthropic

Published Jan 09, 2026. Written by Mikaela Grace, Jeremy Hadfield, Rodrigo Olivares, and Jiri De Jonghe.

## Key Definitions

- **Task** (problem/test case): A single test with defined inputs and success criteria.
- **Trial**: Each attempt at a task. Run multiple trials because model outputs vary.
- **Grader**: Logic that scores some aspect of the agent's performance. A task can have multiple graders, each containing multiple assertions (checks).
- **Transcript** (trace/trajectory): Complete record of a trial — outputs, tool calls, reasoning, intermediate results.
- **Outcome**: Final state in the environment at the end of the trial. A flight-booking agent might say "Your flight has been booked" but the outcome is whether a reservation exists in the database.
- **Evaluation harness**: Infrastructure that runs evals end-to-end, runs tasks concurrently, records steps, grades outputs, aggregates results.
- **Agent harness** (scaffold): The system that enables a model to act as an agent — processes inputs, orchestrates tool calls, returns results. When evaluating "an agent," you're evaluating the harness AND the model together.
- **Evaluation suite**: Collection of tasks designed to measure specific capabilities or behaviors.

## Why Build Evaluations?

After early prototyping, once an agent is in production and scaling, building without evals breaks down. The breaking point: users report the agent feels worse after changes and the team is "flying blind."

Without evals, debugging is reactive: wait for complaints, reproduce manually, fix the bug, hope nothing else regressed. Teams can't distinguish real regressions from noise, automatically test changes against hundreds of scenarios, or measure improvements.

Writing evals is useful at any stage. Early on, evals force product teams to specify what success means. Later they help uphold a consistent quality bar.

Evals shape how quickly you can adopt new models. Teams without evals face weeks of testing; competitors with evals can upgrade in days.

## Three Types of Graders

### Code-based graders
**Methods:** String match (exact, regex, fuzzy), binary tests (fail-to-pass, pass-to-pass), static analysis (lint, type, security), outcome verification, tool calls verification, transcript analysis (turns taken, token usage)
**Strengths:** Fast, cheap, objective, reproducible, easy to debug, verify specific conditions
**Weaknesses:** Brittle to valid variations, lacking in nuance, limited for subjective tasks

### Model-based graders
**Methods:** Rubric-based scoring, natural language assertions, pairwise comparison, reference-based evaluation, multi-judge consensus
**Strengths:** Flexible, scalable, captures nuance, handles open-ended tasks and freeform output
**Weaknesses:** Non-deterministic, more expensive than code, requires calibration with human graders for accuracy

### Human graders
**Methods:** SME review, crowdsourced judgment, spot-check sampling, A/B testing, inter-annotator agreement
**Strengths:** Gold standard quality, matches expert user judgment, used to calibrate model-based graders
**Weaknesses:** Expensive, slow, often requires access to human experts at scale

## Capability vs. Regression Evals

**Capability evals:** "What can this agent do well?" Start at a low pass rate, targeting tasks the agent struggles with — gives teams a hill to climb.

**Regression evals:** "Does the agent still handle all the tasks it used to?" Should have nearly 100% pass rate. Protect against backsliding.

After launch, capability evals with high pass rates can "graduate" to become a regression suite.

## Evaluating Coding Agents

Effective evals rely on well-specified tasks, stable test environments, and thorough tests for generated code. Deterministic graders are natural because software is straightforward to evaluate: does the code run and do tests pass?

Example task with theoretical YAML:
```yaml
task:
  id: "fix-auth-bypass_1"
  desc: "Fix authentication bypass when password field is empty and ..."
  graders:
    - type: deterministic_tests
      required: [test_empty_pw_rejected.py, test_null_pw_rejected.py]
    - type: llm_rubric
      rubric: prompts/code_quality.md
    - type: static_analysis
      commands: [ruff, mypy, bandit]
    - type: state_check
      expect:
        security_logs: {event_type: "auth_blocked"}
    - type: tool_calls
      required:
        - {tool: read_file, params: {path: "src/auth/*"}}
        - {tool: edit_file}
        - {tool: run_tests}
  tracked_metrics:
    - type: transcript
      metrics: [n_turns, n_toolcalls, n_total_tokens]
    - type: latency
      metrics: [time_to_first_token, output_tokens_per_sec, time_to_last_token]
```

## Evaluating Conversational Agents

Challenge: quality of the interaction itself is part of what you're evaluating. Often require a second LLM to simulate the user.

Success is multidimensional: is the ticket resolved (state check), did it finish in <10 turns (transcript constraint), was the tone appropriate (LLM rubric)?

## Evaluating Research Agents

Unlike coding agents where unit tests provide binary signals, research quality can only be judged relative to the task. Unique challenges: experts may disagree, ground truth shifts as reference content changes, longer outputs create more room for mistakes.

Strategies: groundedness checks (claims supported by retrieved sources), coverage checks (key facts a good answer must include), source quality checks.

## Non-Determinism in Agent Evals

**pass@k:** Likelihood that an agent gets at least one correct solution in k attempts. A score of 50% pass@1 means the model succeeds at half the tasks on its first try.

**pass^k:** Probability that ALL k trials succeed. As k increases, pass^k falls. If your agent has 75% per-trial success rate and you run 3 trials, probability of passing all three is (0.75)³ ≈ 42%.

Both metrics are useful. pass@k for tools where one success matters, pass^k for agents where consistency is essential.

## Roadmap from Zero to One

**Step 0: Start early.** 20-50 simple tasks drawn from real failures is a great start.

**Step 1: Start with what you already test manually.** Convert user-reported failures into test cases.

**Step 2: Write unambiguous tasks with reference solutions.** A good task: two domain experts would independently reach the same pass/fail verdict. With frontier models, 0% pass@100 is most often a signal of a broken task, not an incapable agent.

**Step 3: Build balanced problem sets.** Test both cases where behavior SHOULD occur and where it SHOULDN'T. One-sided evals create one-sided optimization.

**Step 4: Build a robust eval harness with a stable environment.** Each trial should be isolated from a clean environment. Shared state can cause correlated failures or artificially inflate performance.

**Step 5: Design graders thoughtfully.** Choose deterministic graders where possible, LLM graders where necessary. Don't check for very specific tool call sequences — agents find valid approaches eval designers didn't anticipate. Grade what the agent produced, not the path it took. Build in partial credit. LLM-as-judge graders should be closely calibrated with human experts.

**Step 6: Check the transcripts.** You won't know if graders are working unless you read transcripts and grades from many trials.

**Step 7: Monitor for capability eval saturation.** An eval at 100% tracks regressions but provides no signal for improvement.

**Step 8: Keep eval suites healthy long-term.** Establish dedicated evals teams for core infrastructure while domain experts contribute tasks. Practice eval-driven development: build evals to define planned capabilities before agents can fulfill them.

## Eval Frameworks Mentioned

- **Harbor:** Containerized agent eval framework. Standardized format for tasks and graders. Terminal-Bench 2.0 ships through Harbor registry.
- **Braintrust:** Offline evaluation + production observability + experiment tracking. Pre-built scorers for factuality, relevance.
- **LangSmith:** Tracing, offline/online evals, dataset management. Tight LangChain integration.
- **Langfuse:** Self-hosted open-source alternative for data residency requirements.
- **Arize Phoenix:** Open-source for LLM tracing, debugging, offline/online evals. AX is SaaS for scale.

## How Evals Fit with Other Methods

| Method | Pros | Cons |
|--------|------|------|
| **Automated evals** | Fast iteration, reproducible, no user impact, runs on every commit | Up-front investment, ongoing maintenance, false confidence |
| **Production monitoring** | Real user behavior, catches missed issues, ground truth | Reactive, noisy signals, instrumentation investment |
| **A/B testing** | Actual user outcomes, controls for confounds, scalable | Slow, only tests deployed changes |
| **User feedback** | Surfaces unanticipated problems, real examples | Sparse, self-selected, users rarely explain why |
| **Manual transcript review** | Builds intuition, catches subtle issues, calibrates what "good" looks like | Time-intensive, doesn't scale, coverage inconsistent |
| **Systematic human studies** | Gold-standard quality, handles subjective tasks | Expensive, slow turnaround, inter-rater disagreement |