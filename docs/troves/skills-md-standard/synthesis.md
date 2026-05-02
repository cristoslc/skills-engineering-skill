# The SKILL.md Standard — Synthesis

## What is a SKILL.md?

A **SKILL.md** defines a reusable Agent Skill — a modular capability that extends AI agents (Claude, Codex, Gemini CLI, Copilot, Cursor, etc.) with specialized knowledge and workflows. It is the entry point file within a skill directory, combining structured YAML metadata with freeform Markdown instructions.

All sources converge on this definition. The Agent Skills open standard at `agentskills.io/specification` provides the canonical format; Anthropic's engineering blog (`anthropic-skills-blog`) explains the design rationale; the Claude API docs (`anthropic-skills-overview`) describe how the runtime interprets them; and the Claude Code docs (`claude-code-skills`) describe Claude Code-specific extensions.

## Required structure

Every skill is a **directory** containing at minimum a `SKILL.md` file. The file must start with **YAML frontmatter** (between `---` markers) followed by **Markdown instructions**.

### Required frontmatter fields

| Field | Constraints |
|-------|-------------|
| `name` | Max 64 chars. Lowercase letters, numbers, hyphens only (`a-z`, `0-9`, `-`). Must match parent directory name. No leading/trailing/consecutive hyphens. No XML tags. No reserved words ("anthropic", "claude" in Claude API). |
| `description` | Max 1024 chars (spec) / 200 chars (claude.ai). Must be non-empty. Should describe BOTH what the skill does and when to use it. Include keywords for agent discovery. Always write in third person. |

### Optional frontmatter fields (spec)

`license`, `compatibility` (max 500 chars, environment requirements), `metadata` (arbitrary string→string map), `allowed-tools` (space-separated, experimental).

### Claude Code extended frontmatter

Claude Code adds: `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `model`, `effort`, `context` (fork for subagents), `agent`, `hooks`, `paths` (glob patterns), `shell`.

Claude Code is **less strict about required fields** — all fields are optional there; only `description` is recommended. In Claude Code, if `name` is omitted the directory name is used; if `description` is omitted the first paragraph of markdown is used.

## Directory structure

```
skill-name/
├── SKILL.md          # Required: YAML frontmatter + Markdown instructions
├── scripts/          # Optional: executable code (Python, Bash, JS)
├── references/       # Optional: documentation loaded on demand
├── assets/           # Optional: templates, images, data files
└── ...               # Any additional files or directories
```

Sources agree on this layout (`agentskills-spec`, `anthropic-skills-blog`, `claude-code-skills`).

## Progressive disclosure (core design principle)

All sources emphasize this three-level loading system:

1. **Metadata** (~100 tokens) — `name` and `description` loaded at startup for ALL installed skills. In system prompt. Zero context penalty per skill until selected.
2. **Instructions** (<5000 tokens recommended; <500 lines) — Full `SKILL.md` body loaded ONLY when the skill is activated.
3. **Resources** (unlimited) — Bundled files in `scripts/`, `references/`, `assets/` loaded only when needed. Scripts execute without loading code into context; only output consumes tokens.

The Anthropic blog describes this as "like a well-organized manual that starts with a table of contents, then specific chapters, and finally a detailed appendix." Claude only loads information progressively as tasks require.

## Key points of agreement

- **Description is the trigger.** Every source emphasizes the `description` field as the primary mechanism for skill discovery and activation. Claude uses it to choose from potentially 100+ installed skills (per `claude-skills-best-practices`).
- **Keep it concise.** Default assumption: Claude is already smart. Only add context it doesn't have. SKILL.md body under 500 lines.
- **One level deep references.** All reference files should link directly from SKILL.md, not transitively. Deeply nested references cause partial reads.
- **Cross-platform portability.** The format works across Claude Code, Codex CLI, Gemini CLI, GitHub Copilot, Cursor, OpenCode, and 20+ community tools. Skills sticking to core format (standard frontmatter + markdown) work everywhere without modification.
- **Scripts preferred for deterministic ops.** Utility scripts save tokens, ensure consistency, are more reliable than generated code. Distinguish: execute vs. read as reference.
- **Security model.** Only install from trusted sources. Audit SKILL.md, scripts, images, all bundled content. Skills fetching external URLs pose particular risk.

## Platform divergences

- **Claude API**: `name` is required, no reserved words. No network access, no runtime package installs.
- **Claude Code**: `name` is optional (falls back to directory name). Full network access. Adds `context: fork` for subagents, dynamic shell injection (`!`), string substitution (`$ARGUMENTS`, `$N`, `${CLAUDE_SESSION_ID}`, etc.), permission control (`Skill(commit)` syntax).
- **Claude.ai**: Custom description limit is 200 chars (vs. 1024). Skills uploaded as zip. Individual per user, not org-wide.

## Writing best practices (from `claude-skills-best-practices`)

- **Naming**: Use gerund form (`processing-pdfs`, `analyzing-spreadsheets`). Avoid vague (`helper`, `utils`).
- **Degrees of freedom**: Match to task fragility. High freedom (text instructions) for multi-approach tasks; low freedom (exact scripts) for fragile/destructive ops.
- **Workflows**: Break complex ops into sequential steps with checklists. Implement feedback loops (validate → fix → repeat).
- **Examples pattern**: Provide input/output pairs. More effective than descriptions alone.
- **Avoid time-sensitive info**: Use "Old patterns" section in collapsible `<details>` block.

## Tooling: Skill Creator plugin

Anthropic provides an official Claude Code plugin (`skill-creator`) for authoring skills. Installed via `/plugin install skill-creator@anthropic-agent-skills`. Provides four modes: Create, Eval, Improve, Benchmark. Under the hood uses four composable agents (Executor, Grader, Comparator, Analyzer).

The plugin implements an eval-driven workflow: capture intent → interview/research → write draft → create test cases → spawn parallel subagent runs (with-skill + baseline) → grade → aggregate benchmark → launch viewer → read feedback → iterate → optimize description → package as `.skill` file.

Key detail from the SKILL.md: **Claude only consults skills for tasks it can't easily handle itself.** Simple queries like "read this PDF" won't trigger skills regardless of description quality. Eval queries must be substantive enough that Claude would actually benefit from consulting a skill.

The skill-creator source lives in both `github.com/anthropics/skills` and `github.com/anthropics/claude-plugins-official`. A community fork at `daymade/claude-code-skills` adds additional guardrails.

## Gaps

- No formal validation tooling is part of the spec; `skills-ref` is a community reference library for validation.
- The `allowed-tools` field is marked "Experimental" in the spec — support varies across implementations.
- No spec-level guidance on how agent implementations should handle conflicting or overlapping skill descriptions.
- The `metadata` field has no reserved keys or naming conventions beyond "use reasonably unique names."
