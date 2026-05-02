---
source: https://agentskills.io/specification
title: Agent Skills Specification
type: web-page
fetched: 2026-05-01
---

# Agent Skills Specification

The authoritative specification, hosted at agentskills.io.

## Directory structure

A skill is a directory containing, at minimum, a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

## SKILL.md format

Must contain YAML frontmatter followed by Markdown content.

### Frontmatter

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | Max 64 chars. Lowercase letters, numbers, and hyphens only. Must not start or end with a hyphen. Must match parent directory name. No consecutive hyphens (`--`). |
| `description` | Yes | Max 1024 chars. Non-empty. Describes what the skill does and when to use it. Include specific keywords for agent discovery. |
| `license` | No | License name or reference to bundled license file. Short recommended. |
| `compatibility` | No | Max 500 chars. Environment requirements (intended product, system packages, network access, etc.). Most skills do not need this. |
| `metadata` | No | Arbitrary key-value map (string→string). Use reasonably unique key names. |
| `allowed-tools` | No | Space-separated string of pre-approved tools. Experimental; support varies between implementations. |

### `name` field

- 1-64 characters
- Unicode lowercase alphanumeric (`a-z`) and hyphens (`-`) only
- Must not start or end with hyphen
- Must not contain consecutive hyphens (`--`)
- Must match parent directory name

Valid: `pdf-processing`, `data-analysis`, `code-review`
Invalid: `PDF-Processing` (uppercase), `-pdf` (starts with hyphen), `pdf--processing` (consecutive hyphens)

### `description` field

- 1-1024 characters
- Should describe both what and when
- Include specific keywords for agent discovery

Good: "Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction."
Poor: "Helps with PDFs."

### Minimal example

```markdown
---
name: skill-name
description: A description of what this skill does and when to use it.
---
```

### Body content

Markdown body after frontmatter contains skill instructions. No format restrictions. Recommended sections: step-by-step instructions, examples of inputs/outputs, common edge cases.

Agent loads entire file once it activates a skill. Consider splitting longer content into referenced files.

## Optional directories

### scripts/
Executable code agents can run. Self-contained or clearly document dependencies. Include helpful error messages. Handle edge cases gracefully. Common: Python, Bash, JavaScript.

### references/
Additional documentation loaded on demand: `REFERENCE.md`, `FORMS.md`, domain-specific files. Keep focused — smaller files = less context.

### assets/
Static resources: templates, images, data files (lookup tables, schemas).

## Progressive disclosure

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (<5000 tokens recommended): Full `SKILL.md` body when skill activated
3. **Resources** (as needed): Files in `scripts/`, `references/`, or `assets/` loaded only when required

Keep main `SKILL.md` under 500 lines. Move detailed reference material to separate files.

## File references

Use relative paths from skill root. Keep references one level deep from `SKILL.md`. Avoid deeply nested reference chains.

## Validation

```bash
skills-ref validate ./my-skill
```
