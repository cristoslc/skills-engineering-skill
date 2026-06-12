# LangSmith — LLM & AI Agent Evals Platform

LangSmith is the complete framework-agnostic AI agent and LLM observability, evaluation, and deployment platform from LangChain.

## Key Capabilities

- **Tracing:** Capture every step of your LLM app. Traces — not code — provide the only record of what your agent did and why.
- **Offline evaluation:** Run evaluations on curated datasets during development to compare versions, benchmark performance, catch regressions.
- **Online evaluation:** Score real-world production traffic in real-time to detect quality drift.
- **LLM-as-judge evaluators:** Bootstrap initial labels, then refine with human annotation.
- **Custom run evaluators:** Evaluate tool calls, intermediate steps, and whole trajectories.
- **Annotation queues:** Collect expert feedback, assign to SMEs, calibrate automated evaluation.
- **Dataset management:** Turn any production trace into a reusable regression test with one click.

## Agent Evaluation Features

Evaluates both individual reasoning steps and tool calls (trace-level) and whether the agent achieved the user's actual goal (session-level).

**Trajectory evaluation:** Use LangChain's TrajectoryEvalChain to instruct an LLM to grade the efficacy of the agent's actions — ensuring the agent isn't just providing correct answers but is also being efficient about how it uses external resources.

**Deep agents evaluation patterns:** LangChain built four production "Deep Agents" (coding agent, in-app assistant, email assistant, agent builder). Their evaluation approach uses Pytest and Vitest integrations that automatically log all test cases to experiments. Each test execution produces a trace viewable in LangSmith. Flexible assertion logic within test functions — either through regex pattern matching or LLM-as-judge evaluation.

## Evaluation Types

- Safety checks, format validation, quality heuristics
- Reference-free LLM-as-judge
- Multi-turn evaluators
- Code-based evaluators
- Human review

## Integrations

Framework-agnostic. Works with LangChain, LangGraph, custom code, or any LLM application. Integrated with Pytest and Vitest for CI/CD testing.