---
source: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
title: Skill authoring best practices — Claude API Docs
type: web-page
fetched: 2026-05-01
---

# Skill authoring best practices

## Core principles

### Concise is key
Context window is a public good. Only metadata is pre-loaded; SKILL.md loaded when triggered. Still, every token competes with conversation history. Default assumption: Claude is already very smart. Challenge each piece of information.

### Set appropriate degrees of freedom
- **High freedom** (text instructions): Multiple valid approaches, decisions depend on context
- **Medium freedom** (pseudocode/scripts with parameters): Preferred pattern exists, some variation acceptable
- **Low freedom** (specific scripts, few parameters): Fragile operations, consistency critical

Analogy: narrow bridge needs exact guardrails; open field needs general direction.

### Test with all models
Test with Haiku (fast — enough guidance?), Sonnet (balanced — clear?), Opus (powerful — over-explaining?).

## Skill structure

### Naming conventions
Use gerund form: `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`. Avoid vague (`helper`, `utils`), generic (`documents`), reserved words.

### Writing effective descriptions
Always write in third person (injected into system prompt). Be specific with key terms for both what and when. Claude uses description to choose from potentially 100+ skills.

Good: "Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."
Bad: "Helps with documents"

### Progressive disclosure patterns
Keep SKILL.md body under 500 lines. Three patterns:
1. **High-level guide with references**: Quick start in SKILL.md, links to separate files
2. **Domain-specific organization**: Organize by domain (finance.md, sales.md, product.md)
3. **Conditional details**: Basic content inline, advanced linked

### Avoid deeply nested references
Keep references one level deep from SKILL.md. Nested references cause partial reads. All reference files should link directly from SKILL.md.

### Table of contents for long reference files
For reference files over 100 lines, include a TOC so Claude sees full scope even with partial reads.

## Workflows and feedback loops

### Use workflows for complex tasks
Break complex operations into sequential steps. Provide a checklist Claude can copy and check off. Works for any complex, multi-step process — with or without code.

### Implement feedback loops
Pattern: run validator → fix errors → repeat. Can use reference documents as validators (Claude compares against STYLE_GUIDE.md) or script-based validators.

## Content guidelines

### Avoid time-sensitive information
Don't include "before/after date" instructions. Use "Old patterns" section in collapsible `<details>` block for historical context.

### Use consistent terminology
Choose one term throughout: always "API endpoint" (not mixing "URL", "route", "path").

## Common patterns

### Template pattern
For strict requirements: "ALWAYS use this exact template." For flexible: "Here is a sensible default, use your best judgment."

### Examples pattern
Provide input/output pairs. Examples help Claude understand style and detail level better than descriptions alone.

### Conditional workflow pattern
Guide Claude through decision points: "Creating new? → Creation workflow. Editing? → Editing workflow."

## Anti-patterns
- Avoid Windows-style paths (use forward slashes)
- Avoid offering too many options — provide a default with escape hatch
- Don't include unnecessary explanations Claude already knows

## Skills with executable code

### Solve, don't punt
Handle error conditions in scripts. Document configuration parameters — no "voodoo constants."

### Provide utility scripts
Pre-made scripts are more reliable than generated code, save tokens, save time, ensure consistency. Make clear: execute or read as reference?

### Plan-validate-execute pattern
For complex tasks: create plan in structured format → validate with script → execute. Catches errors early. Validation scripts should be verbose with specific error messages.

### Package dependencies
List required packages in SKILL.md. Claude API: no network access, no runtime package install. Claude.ai: can install from npm/PyPI/GitHub. Claude Code: discourage global installs.

## Evaluation and iteration
- Build evaluations first: identify gaps → create 3 scenarios → baseline → write minimal instructions → iterate
- Develop iteratively with Claude: Claude A designs, Claude B tests in real tasks, observe, refine
- Observe how Claude navigates: unexpected paths, missed connections, overreliance, ignored content

## Checklist for effective Skills
- Description specific with key terms, includes what and when
- SKILL.md body under 500 lines
- Additional details in separate files
- No time-sensitive information
- Consistent terminology
- Concrete examples
- File references one level deep
- Progressive disclosure used appropriately
- Workflows have clear steps
- Tested with Haiku, Sonnet, and Opus
- At least three evaluations created
