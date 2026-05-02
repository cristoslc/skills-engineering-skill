---
title: "Best Practices for Claude Code — Anthropic Engineering"
source: https://www.anthropic.com/engineering/claude-code-best-practices
author: Anthropic
type: web
fetched: 2026-05-01
tags: [anthropic, claude-code, best-practices, context-management, prompt-engineering, scaling]
---

# Best Practices for Claude Code

Anthropic's official guide of patterns proven effective across internal teams and external engineers.

## Core constraint

**Claude's context window fills up fast, and performance degrades as it fills.** Every message, file read, and command output consumes context. This is the fundamental constraint that drives nearly all best practices.

## Key patterns

### Verify work
Single highest-leverage thing: give Claude a way to verify its own work (tests, screenshots, expected outputs). Without clear success criteria, Claude produces something that looks right but doesn't work.

### Explore → Plan → Code
Separate research and planning from implementation. Use Plan Mode for exploration, create detailed implementation plans, then switch to Normal Mode for execution. For trivial tasks (typos, simple fixes), skip the plan — go direct.

### Provide specific context
- Scope the task with specific file, scenario, testing preferences
- Point to sources (git history, specific patterns, example files)
- Reference existing patterns: "follow the pattern in HotDogWidget.php"
- Describe symptoms + likely location + what "fixed" looks like
- Use `@` to reference files, paste screenshots/images, provide URLs, pipe data

### CLAUDE.md design
Effective CLAUDE.md: include only things Claude can't figure out from reading code. Run `/init` for a starter. Keep concise — for each line, ask "Would removing this cause Claude to make mistakes?" If not, cut it.

Include: Bash commands Claude can't guess, code style rules that differ from defaults, repo etiquette, architectural decisions, dev environment quirks, common gotchas.

Exclude: anything Claude can figure out by reading code, standard conventions, detailed API docs (link instead), info that changes frequently, long explanations.

CLAUDE.md can import additional files via `@path/to/import` syntax. Supports home folder, project root, parent/child directories.

### Subagents for investigation
Delegate research with "use subagents to investigate X." Subagents run in separate context windows and report back summaries, keeping main conversation clean.

### Session management
- Course-correct early: `Esc` to stop, `/rewind` to restore previous state, `/clear` to reset context between unrelated tasks
- Two failed corrections = signal to `/clear` and start fresh with better prompt
- Auto-compaction summarizes conversation history when approaching context limits
- `/compact <instructions>` for manual control
- `/btw` for side questions that don't enter conversation history
- `claude --continue` / `--resume` to pick up where left off

### Scaling horizontally
- Non-interactive mode: `claude -p "prompt"` for CI, hooks, scripts
- Fan out across files: generate task list, loop with `claude -p` per file
- Auto mode: classifier reviews commands, blocks risks while letting routine work proceed
- Multiple sessions: desktop app, web, agent teams (Writer/Reviewer pattern)
- Worktree isolation per session

## Anti-patterns

- Kitchen sink session (unrelated tasks in same session)
- Correcting over and over (polluted context with failed approaches)
- Over-specified CLAUDE.md (too long, rules get lost)
- Trust-then-verify gap (plausible-looking but edge-case-broken output)
- Infinite exploration (unscoped investigation filling context)
