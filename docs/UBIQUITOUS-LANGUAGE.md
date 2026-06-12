# Ubiquitous Language

Domain vocabulary for skill engineering, organized by bounded context.

## Skill Lifecycle Context

| Term | Definition |
|------|-----------|
| **Skill** | A markdown-based instruction set (SKILL.md) that teaches an agent when and how to perform a task |
| **Phase** | A distinct step in the TDD lifecycle (spec, behavioral, script-test, script, skill, adversary, eval, improve, refactor) |
| **Phase router** | The `generate.sh` script that detects change scope and emits phase-specific prompts |
| **Complexity tier** | Classification of change scope: smoke (trivial), behavioral (moderate), full (structural) |
| **Progressive disclosure** | Three-level information architecture: metadata → SKILL.md → references |

## Test Context

| Term | Definition |
|------|-----------|
| **Behavioral test** | A BDD contract (Given/When/Then) that specifies what the agent should do when the skill activates |
| **Adversarial test** | A boundary attack (attack/must_not/must) that specifies what the agent must NOT do |
| **Smoke test** | A fast structural validation for trivial changes |
| **assert_sh** | A shell command assertion that runs before LLM grading, exiting 0 on pass |
| **code_based** | Pre-grading result from assert_sh — deterministic, no LLM cost |
| **Track A** | Behavioral pass/fail grading via LLM subagent |
| **Track B** | Qualitative A/B comparison grading |

## Evaluation Context

| Term | Definition |
|------|-----------|
| **pass@k** | The test passes in at least one of k trials (lenient — capability eval) |
| **pass^k** | The test passes in all k trials (strict — regression eval) |
| **capability suite** | A test suite still in development, optimizing pass@k |
| **regression suite** | A graduated test suite enforcing pass^k, blocking changes on failure |
| **Graduation** | Auto-promotion from capability to regression after 3 consecutive full passes |

→ `docs/ubiquitous-language/` — detailed term definitions