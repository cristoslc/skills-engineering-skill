---
source: https://code.claude.com/docs/en/skills
title: Extend Claude with skills — Claude Code Docs
type: web-page
fetched: 2026-05-01
---

# Extend Claude with skills — Claude Code Docs

Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`.

Create a skill when you keep pasting the same playbook, checklist, or multi-step procedure into chat, or when a section of CLAUDE.md has grown into a procedure rather than a fact. Unlike CLAUDE.md, a skill's body loads only when it's used.

Claude Code skills follow the Agent Skills open standard with added features: invocation control, subagent execution, dynamic context injection.

## Where skills live

| Location | Path | Applies to |
|----------|------|------------|
| Enterprise | managed settings | All users in org |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin enabled |

Priority: enterprise > personal > project. Plugin: `plugin-name:skill-name` namespace.

Live change detection: skill directories watched within session. Automatic discovery from nested `.claude/skills/` for monorepos.

## Claude Code frontmatter reference

All fields optional; only `description` is recommended.

| Field | Description |
|-------|-------------|
| `name` | Display name. Default: directory name. Lowercase, numbers, hyphens, max 64 chars. |
| `description` | What and when to use. Default: first paragraph of markdown. Truncated at 1536 chars. |
| `when_to_use` | Additional trigger context. Appended to description, counts toward 1536-char cap. |
| `argument-hint` | Autocomplete hint: `[issue-number]`, `[filename] [format]` |
| `arguments` | Named positional arguments for `$name` substitution |
| `disable-model-invocation` | `true` to prevent Claude auto-load. Default: `false` |
| `user-invocable` | `false` to hide from `/` menu. Default: `true` |
| `allowed-tools` | Tools without per-use approval when skill active |
| `model` | Model override (applies for current turn) |
| `effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `context` | `fork` to run in forked subagent |
| `agent` | Subagent type when `context: fork` |
| `hooks` | Hooks scoped to skill lifecycle |
| `paths` | Glob patterns limiting when skill activates |
| `shell` | `bash` (default) or `powershell` for shell injection blocks |

## String substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed at invocation |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index |
| `$name` | Named argument from `arguments` field |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Skill's SKILL.md directory |

## Invocation control

| Frontmatter | User invoke | Claude invoke | When loaded |
|-------------|------------|---------------|-------------|
| (default) | Yes | Yes | Description always; full on invoke |
| `disable-model-invocation: true` | Yes | No | Description not in context; full when user invokes |
| `user-invocable: false` | No | Yes | Description always; full when invoked |

## Dynamic context injection

`` !`<command>` `` runs shell commands before skill content is sent to Claude. Output replaces placeholder. Multi-line via ` ```! ` blocks. Preprocessing — Claude only sees final result.

## Run skills in a subagent

`context: fork` runs in isolation. Skill content becomes subagent prompt. No conversation history. `agent` field specifies Explore, Plan, general-purpose, or custom from `.claude/agents/`.

## Permission control

- Deny all: `Skill`
- Allow specific: `Skill(commit)`, `Skill(review-pr *)`
- Deny specific: `Skill(deploy *)`
- `allowed-tools` grants without per-use approval but doesn't restrict

## Skill content lifecycle

Invoked skill content enters conversation as single message, stays for session. On compaction: most recent invocation of each skill re-attached (first 5000 tokens), combined budget 25000 tokens. Re-invoke after compaction if needed.
