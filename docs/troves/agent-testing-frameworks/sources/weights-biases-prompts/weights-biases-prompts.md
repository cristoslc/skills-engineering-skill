# Weights & Biases — LLM Evaluation: Metrics, Frameworks, and Best Practices

W&B provides LLMOps tooling through Weave (traces and evaluations) and Prompts (prompt engineering IDE).

## Key Capabilities

- **W&B Weave:** Tracing, evaluation, and continuous monitoring for LLM pipelines. Captures traces, action logs, and outcomes for reproducibility.
- **W&B Prompts:** Prompt management with versioning, experiment tracking, and side-by-side comparison of prompt variations.
- **W&B Artifacts:** Version and track every step of your LLM pipeline.
- **W&B Tables:** Organize text prompts by complexity and similarity for visually interactive evaluation loops.

## Evaluation-Driven Development — Wandbot Case Study

W&B's documentation chatbot transformed from v1.0 to v1.1 using evaluation-driven development:

- Initial "refactor-first, evaluate-later" approach failed — discovered the necessity of systematic evaluation.
- Built a sophisticated auto-evaluation framework aligned with human annotations.
- Achieved accuracy improvement from 72% to 81% and 84% latency reduction.
- Switched from FAISS to ChromaDB, transitioned to LangChain Expression Language, optimized RAG pipeline.

Key lesson: changes to one component (like embedding models or LLM versions) can have non-linear, unexpected interactions with other components.

## LLM-as-a-Judge Best Practices

- Use clear, structured rubrics to grade each dimension
- Hiding model identity prevents self-evaluation and authority bias
- Instructions should state how verbosity is treated
- Run multiple judges or prompt variants and analyze disagreement for higher impact evaluations
- Match rubric complexity to the judge model's capability
- Strong benchmark LLMs can follow multi-criterion rubrics more reliably than smaller models

## Safety and Guardrails

Guardrails feature monitors safety, bias, and other metrics. Agent behavior is dynamic and non-deterministic. Evaluation is no longer about single prompt completions but about multi-step workflows.