# Skills Engineering Skill — Agent Guidance

This file supplements `~/.agents/AGENTS.md` with project-specific rules.

## Purpose

→ `PURPOSE.md` — This project engineers Agent Skills using the SKILL.md protocol with a 9-phase TDD lifecycle.

## Project Navigation

- `PURPOSE.md` — One-paragraph outcome statement
- `README.md` — User-facing landing page
- `CHANGELOG.md` — Keep-a-changelog format, updated every PR
- `skills/skills-engineering/` — The skill itself (SKILL.md, scripts, tests, references, assets)
- `docs/` — Hub files and spoke directories

## Hubs and Spokes

Each upper-case hub indexes detail in a `docs/` subdirectory:
- `docs/ARCHITECTURE.md` → `docs/architecture/`
- `docs/UBIQUITOUS-LANGUAGE.md` → `docs/ubiquitous-language/`
- `docs/TECH-STACK.md` → `docs/tech-stack/`
- `docs/DEVELOPER-WORKFLOWS.md` → `docs/developer-workflows/`
- `docs/USER-EXPERIENCE.md` → `docs/user-experience/`
- `AGENTS.md` → `docs/agents-detail/`
- `docs/adr/` — numbered decision records (no hub file)
- `docs/plans/` — implementation plans (no hub file)
- `docs/musings/` — pre-artifact thought capture (no hub file)

## Key Conventions

- **9-phase TDD lifecycle**: spec → behavioral → script-test → script → skill → adversary → eval → improve → refactor
- **Every script gets TDD**: Write acceptance tests first, implement AC-by-AC
- **Code-based pre-grading**: `assert_sh` runs before LLM grader dispatch
- **Phase isolation**: Authoring phases never see eval criteria
- **Skills are code**: Non-trivial edits require worktree isolation
- **Test suite standards**: Every test suite must include at least one failure-path test

## Testing

```bash
bash skills/skills-engineering/tests/test-generate.sh
```

## Linting

ShellCheck for all Bash scripts.

## Related

- `docs/agents-detail/project-navigation.md` — how to orient yourself in this project