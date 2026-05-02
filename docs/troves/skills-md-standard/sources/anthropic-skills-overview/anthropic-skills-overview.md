---
source: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
title: Agent Skills — Claude API Docs
type: web-page
fetched: 2026-05-01
---

# Agent Skills — Claude API Docs Overview

Agent Skills are modular capabilities that extend Claude's functionality. Each Skill packages instructions, metadata, and optional resources (scripts, templates) that Claude uses automatically when relevant.

## Why use Skills

Skills are reusable, filesystem-based resources providing domain-specific expertise: workflows, context, and best practices. Unlike one-off prompts, Skills load on-demand and eliminate repetition across conversations.

Key benefits: specialize Claude, reduce repetition, compose capabilities.

## Three levels of loading

**Level 1: Metadata** (always loaded, ~100 tokens per skill) — YAML frontmatter provides discovery info loaded into system prompt at startup. Lightweight: Claude only knows each skill exists and when to use it.

**Level 2: Instructions** (loaded when triggered, under 5k tokens) — SKILL.md body with procedural knowledge. Claude reads SKILL.md from filesystem via bash only when the description matches the user's request.

**Level 3: Resources and code** (loaded as needed, effectively unlimited) — Bundled files (FORMS.md, REFERENCE.md, scripts). Script execution output goes to context; script code never enters context.

## The Skills architecture

Skills exist as directories on a VM. Claude accesses content via filesystem:
- On-demand file access: reads only needed files
- Efficient script execution: code never enters context, only output
- No practical limit on bundled content: no context penalty until accessed

## Where Skills work

- **Claude API**: Pre-built + custom. Requires beta headers: `code-execution-2025-08-25`, `skills-2025-10-02`, `files-api-2025-04-14`. Custom Skills shared org-wide.
- **Claude Code**: Custom Skills only. Filesystem-based, no API uploads.
- **Claude.ai**: Both pre-built and custom. Custom Skills uploaded as zip via Settings. Individual per user, not org-wide.

## Skill structure

```yaml
---
name: your-skill-name
description: Brief description of what this Skill does and when to use it
---
```

Required fields: `name` and `description`.

`name` constraints: max 64 chars, lowercase/numbers/hyphens only, no XML tags, no reserved words ("anthropic", "claude"). `description`: non-empty, max 1024 chars, no XML tags. Should include both what and when.

## Pre-built Skills

PowerPoint (pptx), Excel (xlsx), Word (docx), PDF (pdf).

## Security

Use Skills only from trusted sources. Audit thoroughly: SKILL.md, scripts, images, all resources. Skills fetching from external URLs pose particular risk. Treat like installing software.

## Limitations

- Custom Skills do not sync across surfaces (Claude.ai, API, Claude Code are separate)
- Claude.ai: individual user only
- Claude API: no network access, no runtime package installation
- Claude Code: full network access, discourage global package installs
