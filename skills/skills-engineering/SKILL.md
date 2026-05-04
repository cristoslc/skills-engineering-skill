---
name: skills-engineering
description: Author, evaluate, and iteratively improve Agent Skills (SKILL.md protocol) using a rigorous TDD lifecycle. Handles spec declaration, BDD behavioral contract authoring, script TDD (red-green per acceptance criterion), SKILL.md authoring, adversarial boundary testing, full eval with subagent-driven grading, improvement loops, and optional refactoring. Use when creating a new skill, evaluating an existing skill, improving a skill from eval feedback, or engineering the SKILL.md structure.
license: MIT
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Skill
metadata:
  short-description: Engineer Agent Skills with full TDD and BDD
  version: 0.2.0
  author: cristos
---

# Skills Engineering

This skill teaches an agent how to **author, evaluate, and iteratively improve** Agent Skills. It follows a rigorous TDD lifecycle with nine phases. Each phase has one job. Each phase's output feeds the next phase's red state.

Do not reference this file for phase instructions. Call `scripts/generate.sh` — the script output is the guidance.

## Phase routing

| # | Phase | TDD state | Job |
|---|-------|-----------|-----|
| 1 | **spec** | — | Declare intent, boundaries, and script contracts in spec.md |
| 2 | **behavioral** | Red | Write BDD contracts: `Given X, When skill activates, Then agent does Y` |
| 3 | **script-test** | Red | Write acceptance tests for every script before the scripts exist |
| 4 | **script** | Green | Write scripts AC-by-AC until tests pass |
| 5 | **skill** | Green | Write SKILL.md + references to pass behavioral tests |
| 6 | **adversary** | Red | Write boundary attacks now that the skill's surface is known |
| 7 | **eval** | Assert | Full run: script tests → behavioral → adversarial. Grade and aggregate. |
| 8 | **improve** | — | Fix failures from eval, loop back to eval |
| 9 | **refactor** | — | Clean up internal structure without changing behavior (optional) |

## How to invoke

```bash
bash skills/skills-engineering/scripts/generate.sh \
  --phase <spec|behavioral|script-test|script|skill|adversary|eval|improve|refactor> \
  --skill-path .agents/skills/<skill-name>
```

The script emits a targeted prompt and the next phase name. Follow its output — it handles tier detection, test set selection, and phase sequencing. The LLM never sees cross-phase content.

## Skill directory layout

```
<skill-name>/
├── SKILL.md                     # Required: YAML frontmatter + instructions
├── spec.md                      # Lightweight intent + script contracts
├── references/                  # Documentation loaded on demand
├── scripts/                     # Executable code (Bash, Python)
├── assets/                      # Templates, images, data files
└── tests/
    ├── behavioral-tests.json    # BDD: Given/When/Then behavioral contracts
    ├── adversarial-tests.json   # Boundary attacks
    ├── smoke-tests.json         # Fast subset for trivial changes
    └── test-<script>.sh         # Acceptance tests for each script
```

## Progressive disclosure in skill design

1. **Metadata** (name + description) — loaded at startup. Teaches the agent *when* to use the skill.
2. **SKILL.md body** — loaded on activation. Route to references for detail, don't embed everything.
3. **References** — loaded on demand. Encyclopedic knowledge, schemas, detailed procedures.

## Complexity tiers

The phase router detects change scope and selects the appropriate test level:

| Tier | Trigger | Tests |
|------|---------|-------|
| **Smoke** | Typo, wording change, single-line non-structural edit | smoke-tests.json |
| **Behavioral** | Adding references, modifying workflows, changing phase instructions | behavioral-tests.json |
| **Full** | Routing table changes, phase additions/removals, spec.md changes, structural rework | behavioral-tests.json + adversarial-tests.json |

## Key design principles

- **Every script gets TDD.** Write acceptance tests first (script-test phase), then implement AC-by-AC (script phase). Scripts are code — same discipline as `.py` or `.sh`.
- **Adversarial tests come after the skill exists.** You can't write effective boundary attacks against a skill you haven't read. The adversary phase studies the concrete skill and crafts targeted attacks.
- **The context window is the API.** Phase isolation protects context. Authoring never sees eval criteria. Eval never sees authoring instructions.
- **Skills are code.** Skill files are markdown syntax. Non-trivial edits require worktree isolation.
- **Description is the trigger.** The `description` field is the primary discovery mechanism. Write it to describe both what the skill does and when to use it.
- **Behavioral expectations live in the skill, not in agent memory.** When a user gives feedback about how a skill should behave (output format, required sections, mandatory steps, prohibitions), that requirement MUST be encoded in `SKILL.md`, a referenced file, or a script/template inside the skill directory. NEVER store it as agent memory — memory is invisible to other consumers of the skill (other users, other sessions, CI runs). If you find yourself reaching for the memory tool to record a skill's required behavior, stop and update the skill instead. Memory is for cross-skill, cross-project preferences about *how the operator wants to collaborate*; skills carry their own behavioral contracts.
