# Arize AI — Agent Observability, Evaluation & Improvement Platform

Arize offers Phoenix (open-source) and Arize AX (enterprise SaaS).

## Phoenix — Open-Source Platform

Phoenix is an open-source AI observability platform designed for experimentation, evaluation, and troubleshooting.

### Key Capabilities

- **Tracing:** Trace LLM application runtime using OpenTelemetry-based instrumentation. Vendor and language agnostic. Supports OpenAI Agents SDK, Claude Agent SDK, LangGraph, Vercel AI SDK, Mastra, CrewAI, LlamaIndex, DSPy.
- **Playground:** Optimize prompts, compare models, adjust parameters, replay traced LLM calls.
- **Prompt Management:** Version, store, deploy, track prompt changes.
- **Datasets & Experiments:** Create datasets from production traces, run controlled experiments across prompt strategies, agent configurations, or toolchains.
- **Evaluations:** Run span, trace, and session evals at scale. LLM-as-a-judge evaluations for accuracy, tool-calling, planning, and goal achievement.
- **PXI (Built-in Agent):** Debug traces, iterate on prompts, navigate Phoenix with an opt-in, permission-gated agent.

### Evaluation Features

- Dual-level evaluation covers both individual reasoning steps and tool calls (trace-level) and whether the agent achieved the user's goal (session-level)
- Online and offline LLM-as-a-judge evaluations
- Custom evaluators
- OpenInference standard for interoperability

## Arize AX — Enterprise Platform

Extends Phoenix with:
- Managed infrastructure with advanced agent observability datastore (adb)
- Online evals
- Continual improvement workflows
- Self-improving agent workflows combining trace analysis, evaluation feedback, and golden data sets
- Built-in analytics for measuring performance impact over time

## Integration

Built on OpenInference and OpenTelemetry standards. Integrates with Azure, AWS Bedrock, and major LLM providers and frameworks. Skills available for AI coding agents to add observability.