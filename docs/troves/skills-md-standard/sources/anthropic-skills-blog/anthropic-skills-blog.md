---
source: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
title: Equipping agents for the real world with Agent Skills
type: web-page
fetched: 2026-05-01
---

# Equipping agents for the real world with Agent Skills

Published Oct 16, 2025. Updated Dec 18, 2025: Agent Skills published as an open standard at agentskills.io.

## Core concept

A skill is a directory containing a `SKILL.md` file with organized folders of instructions, scripts, and resources. Building a skill is like putting together an onboarding guide for a new hire — anyone can specialize agents with composable capabilities by capturing procedural knowledge.

## The anatomy of a skill

A skill is a directory containing a `SKILL.md` file. This file must start with YAML frontmatter containing required metadata: `name` and `description`. At startup, the agent pre-loads `name` and `description` of every installed skill into its system prompt.

This metadata is the **first level** of progressive disclosure: just enough information for Claude to know when each skill should be used. The actual body is the **second level** — Claude loads the full `SKILL.md` into context when the skill is relevant.

As skills grow complex, they can bundle additional files referenced by name from `SKILL.md`. These linked files are the **third level** (and beyond) of detail, which Claude navigates and discovers only as needed.

## Progressive disclosure

The core design principle. Like a well-organized manual: table of contents → specific chapters → detailed appendix.

1. Context starts with core system prompt + metadata for all skills + user's message
2. Claude triggers skill by reading `skill/SKILL.md` via bash
3. Claude optionally reads bundled files (e.g., `forms.md`)
4. Claude proceeds now that relevant instructions are loaded

## Code execution in skills

Skills can include code for Claude to execute. Benefits: efficiency (sorting via code vs token generation), deterministic reliability, script runs without loading code or data into context, consistent and repeatable workflows.

## Development and evaluation guidelines

- **Start with evaluation**: Identify gaps on representative tasks without skills, build incrementally
- **Structure for scale**: Split SKILL.md into separate files when unwieldy. Keep mutually exclusive contexts separate. Code can be both executable tools and documentation.
- **Think from Claude's perspective**: Monitor how Claude uses your skill. Pay attention to `name` and `description` — Claude uses these for triggering decisions.
- **Iterate with Claude**: Ask Claude to capture successful approaches into reusable context. If it goes off track, ask it to self-reflect.

## Security

Install skills only from trusted sources. Audit thoroughly: SKILL.md, scripts, images, code dependencies. Be cautious of skills instructing Claude to connect to untrusted external network sources.

## Future directions

Simple concept with simple format. Future: skills creating, editing, and evaluating skills themselves; complementing MCP servers by teaching agents complex workflows.
