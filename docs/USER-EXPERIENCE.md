# User Experience

## UX Principles

- **Phase-driven**: The agent follows a strict phase sequence — no skipping ahead
- **Context-isolated**: Each phase only sees its own instructions, preventing eval-authoring contamination
- **Fail-fast**: Script tests and code-based assertions catch deterministic failures before expensive LLM grading
- **Progressive disclosure**: Three levels of information (metadata → SKILL.md → references)

## Quality Attributes

- **Correctness**: 9-phase TDD lifecycle with red-green-refactor discipline
- **Reliability**: assert_sh pre-grading eliminates false positives from LLM grader variability
- **Speed**: Smoke tier runs in seconds; full eval parallelizes via specialist topology
- **Auditability**: `.eval-results.json` captures every test result with evidence

## Key Interactions

- Agent invokes skill by description trigger → phase router detects scope → emits phase prompt
- Eval phase: script tests (deterministic) → assert_sh (code-based) → subagent grading (semantic)
- Improve phase: read `.eval-results.json` → generalize, don't overfit → re-eval loop

→ `docs/user-experience/` — detailed UX documents