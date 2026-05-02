---
date: 2026-05-01
topic: skill-design
---

# Script/LLM Scope Boundary

**Core insight:** All sources agree that deterministic operations should be scripted, not LLM-generated. The disagreement — and the design decision for any skill — is *how much* to script.

## Three positions on the spectrum

### Full scripting (code-review)
- The script IS the orchestrator — all phase logic, model detection, prompt assembly, result synthesis
- The LLM is a thin caller: pipe JSON in, read output, follow instructions
- SKILL.md is effectively documentation for the script's interface
- **When to use:** workflows where correctness matters more than adaptability. Review sequencing, model detection, JSON merging — all in bash+jq

### Leaf-only scripting (swain)
- SKILL.md contains the workflow logic as prose
- Scripts are utility functions: swain-bookmark.sh, swain-session-check.sh, swain-lockfile.sh
- The LLM does intent routing, decision-making, and prose
- Bash does computation, state management, and git operations
- **When to use:** workflows where the LLM's judgment adds value (prioritization, scoping, prose generation)

### Bundled tools (Anthropic Agent Skills)
- Skills can include code for Claude to execute as tools
- Certain operations (sorting, form field extraction) are better suited to deterministic code
- **When to use:** skills that perform operations too precise for token generation

## The design decision

For any given operation: **script it if** the LLM would need to interpret branching logic to produce a correct result. Let the LLM handle it if the operation requires judgment (tone, prioritization, scoping) or prose generation (explanations, documentation, synthesis).

**Rule of thumb:** If you'd write a test for it, script it. If you'd describe it in a design doc, let the LLM handle it.
