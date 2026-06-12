# Agent Testing Frameworks — Trove Synthesis

## Overview

This trove surveys the landscape of AI agent testing and evaluation frameworks. The sources span five major tool ecosystems (promptfoo, Anthropic evals methodology, LangSmith, Weights & Biases, Arize Phoenix) plus two foundational research pieces from Anthropic on statistical rigor and automated behavioral evaluation.

## Key Findings

### 1. Agent evals are fundamentally different from traditional LLM evals

Every source converges on this point. Agent evaluation is harder because of:
- **Non-determinism that compounds** across multi-turn trajectories (promptfoo, Anthropic)
- **Intermediate steps mattering** — the path to the answer is as important as the answer itself
- **System-level testing**, not just model-level — the harness/scaffold is part of what's being tested

### 2. Three-layer grading taxonomy is universal

All frameworks support some variant of:
- **Code-based graders** — deterministic checks (unit tests, string matching, JSON validation, static analysis). Fast, cheap, objective. Used by promptfoo, LangSmith, Anthropic, Arize.
- **Model-based/LLM-as-judge graders** — rubric-based scoring, natural language assertions. Flexible but non-deterministic and requires calibration. Used by all five.
- **Human graders** — gold standard for calibration. Expensive, used sparingly.

### 3. Statistical rigor for non-deterministic evals

Anthropic's research (Nov 2024) provides the theoretical foundation:
- **CLT with SEM** for confidence intervals
- **Clustered standard errors** for grouped questions
- **Paired-difference analysis** as a "free" variance reduction technique
- **Power analysis** to determine sample sizes
- **pass@k** (at least one success in k trials) vs **pass^k** (all k succeed)

promptfoo implements practical non-determinism handling via `--repeat N` and flexible assertions.

### 4. Agent-specific evaluation patterns

- **Coding agents:** Unit tests are the natural grader. All sources agree on outcome verification over path checking.
- **Conversational agents:** Require LLM-as-user simulators. Multi-dimensional success criteria (resolution + tone + efficiency). Anthropic's τ2-Bench.
- **Research agents:** Groundedness checks, coverage checks, source quality. Hardest to automate due to subjectivity.
- **Computer use agents:** OSWorld, WebArena. State verification at the OS/app level.

### 5. Eval lifecycle and maintenance

Anthropic and W&B both emphasize evaluation-driven development:
1. Start with 20-50 tasks from real failures
2. Write unambiguous tasks with reference solutions
3. Balance positive and negative test cases
4. Build robust, isolated eval harnesses
5. Monitor for saturation — graduate capability evals to regression suites
6. Read transcripts regularly
7. Dedicated ownership for infrastructure, domain experts for tasks

### 6. Tool ecosystem comparison

| Tool | Primary Strength | Best For |
|------|-----------------|----------|
| **promptfoo** | Declarative YAML configs, red teaming, multi-provider | Quick eval setup, CI/CD integration, security testing |
| **LangSmith** | LangChain integration, trace-to-dataset, trajectory eval | Teams already in LangChain ecosystem, deep agent workflows |
| **W&B Weave** | Experiment tracking, evaluation-driven development | Research/experimentation phase, prompt versioning |
| **Arize Phoenix** | OpenTelemetry-native, trace+session evals, open-source | Self-hosted, framework-agnostic, production observability |
| **Anthropic methodology** | Eval theory + best practices (not a tool) | Guiding eval design regardless of tool choice |

### 7. Gaps and open questions

- **Multi-agent evaluation** is not well-covered by any source
- **Long-horizon agent evals** (hours-long tasks) remain challenging — Bloom from Anthropic is the closest attempt
- **Cost of evaluation at scale** — running large agent eval suites is expensive, and cost management strategies are underdocumented
- **Calibration drift** — LLM-as-judge accuracy degrades as judge models change or are updated; no source details automated recalibration
- **Cross-framework portability** — each tool has its own config format; no standard interchange format for eval tasks