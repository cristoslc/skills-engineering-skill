---
title: "Equipping Agents for the Real World with Agent Skills — Anthropic Engineering"
source: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
author: Barry Zhang, Keith Lazuka, Mahesh Murag (Anthropic)
type: web
fetched: 2026-05-01
tags: [anthropic, agent-skills, progressive-disclosure, skillmd, claude-code]
---

# Equipping Agents for the Real World with Agent Skills

Anthropic's engineering blog on Agent Skills — organized folders of instructions, scripts, and resources that agents discover and load dynamically to perform better at specific tasks. Published Oct 16, 2025. Later published as [open standard](https://agentskills.io/) (Dec 18, 2025).

## Core concept

Building a skill is like creating an onboarding guide for a new hire. Instead of building fragmented, custom-designed agents, anyone can specialize agents with composable capabilities by capturing procedural knowledge.

## Anatomy of a skill

A skill is a directory containing a `SKILL.md` file with YAML frontmatter (required: `name` and `description`).

### Three levels of progressive disclosure

1. **Level 1 — Metadata**: At startup, agent pre-loads name and description of every installed skill into system prompt. Just enough to know *when* a skill should be used.
2. **Level 2 — SKILL.md body**: Full skill instructions loaded when agent determines skill is relevant to the current task.
3. **Level 3+ — Bundled files**: Additional context files bundled in the skill directory, referenced by name from SKILL.md. Agent navigates to these only as needed.

Example: PDF skill has `SKILL.md` referencing `reference.md` and `forms.md`. Form-filling instructions are split out so the core stays lean.

The amount of context that can be bundled into a skill is effectively unbounded because agents with filesystem tools don't need to read everything into context window at once.

### Code execution in skills

Skills can include code for Claude to execute as tools. Certain operations are better suited for deterministic code execution than token generation (sorting, form field extraction). Code is deterministic, so workflows are consistent and repeatable.

## Skill authoring guidelines

- **Start with evaluation**: Identify gaps by running agents on representative tasks, observe where they struggle
- **Structure for scale**: Split SKILL.md when it becomes unwieldy; move mutually-exclusive context to separate files
- **Think from Claude's perspective**: Monitor how Claude uses your skill; pay special attention to name/description
- **Iterate with Claude**: Ask Claude to capture successful approaches and common mistakes into skill content; ask it to self-reflect when it goes off track

## Security

Install only from trusted sources. Audit thoroughly before use. Pay attention to code dependencies, bundled resources, and instructions that direct Claude to untrusted external network sources.

## Future directions

- Skills complement MCP servers by teaching agents complex workflows involving external tools
- Goal: enable agents to create, edit, and evaluate Skills on their own, codifying their own behavior patterns into reusable capabilities
