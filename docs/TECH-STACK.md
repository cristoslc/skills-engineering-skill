# Tech Stack

## Language & Runtime

- **Bash 5.x** — Primary scripting language for `generate.sh` and all acceptance tests
- **Jinja2** — Template engine for test JSON generation (`.j2` files in `assets/`)

## Key Dependencies

- **git** — Worktree management, diff-scope detection
- **No external runtime dependencies** — The skill runs as pure Bash + Jinja2 templates

## Toolchain

- ShellCheck for linting Bash scripts
- `bash` test runner for acceptance tests (no framework, raw `set +e` + pass/fail counters)

## Infrastructure

- Local-first — no server, no database, no API calls
- Git repository as the only persistence layer
- Subagents as the compute model (parallel test execution via specialist topology)

→ `docs/tech-stack/` — detailed technology decisions