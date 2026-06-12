# Architecture

This project implements a 9-phase TDD lifecycle for Agent Skills using the SKILL.md protocol.

## Phase Architecture

The skill operates as a phase router. Each phase is a distinct concern:

1. **spec** — Declare intent and boundaries
2. **behavioral** — Write BDD behavioral contracts (red)
3. **script-test** — Write acceptance tests for scripts (red)
4. **script** — Implement scripts AC-by-AC (green)
5. **skill** — Write SKILL.md + references (green)
6. **adversary** — Write boundary attacks (red)
7. **eval** — Run all tests and grade (assert)
8. **improve** — Fix failures, loop back to eval
9. **refactor** — Clean up without changing behavior (optional)

## Key Design Decisions

- **Phase isolation**: Authoring phases never see eval criteria. Eval never sees authoring instructions.
- **Specialist topology**: Each test case runs in an isolated subagent context.
- **Code-based pre-grading**: `assert_sh` shell assertions run before LLM grader dispatch.
- **Progressive disclosure**: Metadata → SKILL.md → references. The context window is the API.

→ `docs/architecture/` — detailed architecture documents