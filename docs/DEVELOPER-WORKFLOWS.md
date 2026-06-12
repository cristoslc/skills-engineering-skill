# Developer Workflows

## Build

No build step required. The skill is pure Bash + Jinja2 templates.

## Test

```bash
# Run all acceptance tests for generate.sh
bash skills/skills-engineering/tests/test-generate.sh

# Run a single phase through generate.sh
bash skills/skills-engineering/scripts/generate.sh --phase <phase> --skill-path <path>

# Run with eval tier override
bash skills/skills-engineering/scripts/generate.sh --phase eval --skill-path <path> --diff-scope full

# Run with repeat-N for statistical evaluation
bash skills/skills-engineering/scripts/generate.sh --phase eval --skill-path <path> --repeat 3
```

## Deploy

Skills are deployed by committing to the repository. No CI/CD pipeline required — the skill is consumed in-place by the agent.

## Local Dev

1. Clone the repository
2. Edit skill files under `skills/skills-engineering/`
3. Run `test-generate.sh` to verify changes
4. Use worktrees (`.worktrees/`) for parallel development

→ `docs/developer-workflows/` — detailed workflow documents