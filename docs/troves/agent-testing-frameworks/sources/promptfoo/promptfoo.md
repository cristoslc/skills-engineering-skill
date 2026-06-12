# promptfoo

Promptfoo is an open-source CLI and library for evaluating and red-teaming LLM apps. Originally built for LLM apps serving over 10 million users in production. Now part of OpenAI.

## Capabilities

- Build reliable prompts, models, and RAGs with benchmarks specific to your use-case
- Secure apps with automated red teaming and pentesting
- Speed up evaluations with caching, concurrency, and live reloading
- Score outputs automatically by defining metrics
- Use as CLI, library, or in CI/CD
- Supports OpenAI, Anthropic, Azure, Google, HuggingFace, open-source models like Llama, or custom API providers

## Workflow and Philosophy

Test-driven prompt engineering is much more effective than trial-and-error.

1. Define test cases: Identify core use cases and failure modes
2. Configure evaluation: Specify prompts, test cases, and API providers
3. Run evaluation: Execute evaluation and record model outputs
4. Analyze results: Set up automatic requirements or review in structured format/web UI
5. Feedback loop: Expand test cases as you gather more examples and feedback

## Agent Evaluation (from Evaluate Coding Agents guide)

Coding agents present a different evaluation challenge than standard LLMs. A chat model transforms input to output in one step. An agent decides what to do, does it, observes the result, and iterates — often dozens of times.

### Why Agent Evals Are Different

- **Non-determinism compounds.** A chat model's temperature affects one generation. An agent's temperature affects every tool call, every decision to read another file, every choice to retry.
- **Intermediate steps matter.** Two agents might produce identical final outputs, but one read 3 files and the other read 30.
- **Capability is gated by architecture.** You can't prompt a plain LLM into reading files. You're evaluating the system, not just the model.

### Capability Tiers

- **Tier 0: Text** — `openai:gpt-5.1`, `anthropic:claude-sonnet-4-6`. Use for code generation, explanation, JSON output, baseline behavior. No file reads, shell commands, or tool traces.
- **Tier 1: Coding agent SDK** — `openai:codex-sdk`, `anthropic:claude-agent-sdk`, `opencode:sdk`. Codebase reads, refactors, command runs, CI-friendly agent QA. Watch for side effects, tool permissions, session state.
- **Tier 2: Rich client server** — `openai:codex-app-server`, `openai:codex-desktop`. App-server events, approvals, skills, plugins, thread details. Experimental protocol and local child process.

### Evaluation Techniques

**Structured output:** Provider-enforced schemas (Codex `output_schema`, Claude `output_format.json_schema`) make downstream assertions simpler. Use `contains-json` or `is-json`.

**Cost and latency:** Agent tasks can be expensive. A security audit might cost $0.10-0.30 and take 30-120 seconds. Set thresholds to catch regressions.

**Non-determinism:** Run evals multiple times with `--repeat 3` to measure variance. Write flexible assertions that accept equivalent phrasings. If a prompt fails 50% of the time, the prompt is ambiguous.

**LLM-as-judge:** For semantic quality, use model grading:
```yaml
- type: llm-rubric
  value: |
    Is bcrypt used correctly (proper salt rounds, async hashing)?
    Is MD5 completely removed?
    Score 1.0 for secure, 0.5 for partial, 0.0 for insecure.
  threshold: 0.8
```

### Assertion Types

- Contains JSON, is JSON
- JavaScript (custom logic)
- Cost threshold
- Latency threshold
- LLM rubric
- Trajectory step count, tool used, tool sequence
- Deterministic: equals, contains, regex, javascript, etc.

### QA Checklist

- A plain LLM baseline for tasks that require file or tool access
- At least one structured assertion
- Cost and latency thresholds for long-running tasks
- `--no-cache` during development
- A disposable workspace for write-capable tests
- Trace or metadata assertions when the intermediate path matters
- A repeated run (`--repeat 3`) for prompts expected to be stable

### Evaluation Principles

- **Test the system, not the model.** "What is a linked list?" tests knowledge. "Find all linked list implementations in this codebase" tests agent capability.
- **Measure objectively.** "Is the code good?" is subjective. "Did it find the 3 intentional bugs?" is measurable.
- **Include baselines.** A plain LLM fails tasks requiring file access. This makes capability gaps visible.
- **Check token patterns.** Huge prompt + small completion = agent reading files. Small prompt + large completion = you're testing the model, not the agent.
- **Assert the path when the path matters.** Use trace assertions or provider metadata.