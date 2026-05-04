# skills-engineering-skill

A skill (and supporting research) for **engineering Agent Skills** using a rigorous TDD lifecycle. Built on the SKILL.md protocol so the resulting skills can be loaded by any compatible agent harness.

## What's in this repo

```
skills/skills-engineering/   The skill itself (SKILL.md, scripts, tests, references)
docs/scratchpads/            Design notes on skill engineering patterns
docs/troves/                 Curated research sources
PURPOSE.md                   One-line repo purpose
skills-lock.json             Lockfile for vendored upstream skills
```

## The `skills-engineering` skill

A nine-phase TDD lifecycle for authoring, evaluating, and improving Agent Skills:

| # | Phase | TDD state | Job |
|---|-------|-----------|-----|
| 1 | spec | — | Declare intent, boundaries, and script contracts |
| 2 | behavioral | Red | BDD contracts: `Given X, When skill activates, Then agent does Y` |
| 3 | script-test | Red | Acceptance tests for every script before scripts exist |
| 4 | script | Green | Implement scripts AC-by-AC until tests pass |
| 5 | skill | Green | Write SKILL.md + references to pass behavioral tests |
| 6 | adversary | Red | Boundary attacks against the now-known surface |
| 7 | eval | Assert | Run script tests → behavioral → adversarial; grade and aggregate |
| 8 | improve | — | Fix eval failures, loop back to eval |
| 9 | refactor | — | Optional: clean internal structure without changing behavior |

A phase router script emits a single targeted prompt per phase so the LLM never sees cross-phase content — context isolation is treated as an API boundary.

### Use it

```bash
bash skills/skills-engineering/scripts/generate.sh \
  --phase <spec|behavioral|script-test|script|skill|adversary|eval|improve|refactor> \
  --skill-path .agents/skills/<skill-name>
```

Invoke via the Skill tool: `/skills-engineering` (or let the harness auto-trigger from the description). Works with Claude Code, opencode, or any compatible harness.

### Key design principles

- **Every script gets TDD** — scripts are code, same discipline as `.py` or `.sh`.
- **Adversarial tests come after the skill exists** — you can't write effective boundary attacks against a skill you haven't read.
- **The context window is the API** — phase isolation prevents authoring leakage into eval and vice versa.
- **Description is the trigger** — the YAML `description` field is the primary discovery mechanism.

## License

MIT (see `skills/skills-engineering/SKILL.md` frontmatter).
