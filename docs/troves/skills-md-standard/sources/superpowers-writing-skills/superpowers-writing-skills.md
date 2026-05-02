---
source: https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
title: Writing Skills — obra/superpowers
type: web-page
fetched: 2026-05-01
---

# Writing Skills — obra/superpowers

A skill for creating new skills following TDD principles. Part of the Superpowers framework (176k stars, MIT licensed).

## Overview

**Writing skills IS Test-Driven Development applied to process documentation.** You write test cases (pressure scenarios with subagents), watch them fail (baseline behavior), write the skill (documentation), watch tests pass (agents comply), and refactor (close loopholes).

**Core principle:** If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

**REQUIRED BACKGROUND:** You MUST understand superpowers:test-driven-development before using this skill. Official guidance: Anthropic's best practices available in anthropic-best-practices.md.

## What is a Skill?

A **skill** is a reference guide for proven techniques, patterns, or tools that help future Claude instances find and apply effective approaches. Skills are NOT narratives about how you solved a problem once.

## TDD Mapping for Skills

| TDD Concept | Skill Creation |
|-------------|----------------|
| Test case | Pressure scenario with subagent |
| Production code | Skill document (SKILL.md) |
| RED (test fails) | Agent violates rule without skill (baseline) |
| GREEN (test passes) | Agent complies with skill present |
| Refactor | Close loopholes while maintaining compliance |

The entire skill creation process follows RED-GREEN-REFACTOR.

## When to Create a Skill

**Create when:** technique wasn't intuitively obvious, you'd reference across projects, pattern applies broadly, others would benefit.

**Don't create for:** one-off solutions, standard practices well-documented elsewhere, project-specific conventions (put in CLAUDE.md), things enforceable with regex/validation (automate it).

## Directory Structure

```
skills/
  skill-name/
    SKILL.md              # Main reference (required)
    supporting-file.*     # Only if needed
```

Flat namespace. Separate files for: heavy reference (100+ lines), reusable tools. Keep inline: principles, code patterns (<50 lines).

## SKILL.md Structure

**Frontmatter (YAML):**
- Two required fields: `name` and `description`
- `name`: Letters, numbers, and hyphens only (no parentheses, special chars)
- `description`: Third-person, describes ONLY when to use (NOT what it does)
  - Start with "Use when..." to focus on triggering conditions
  - Include specific symptoms, situations, and contexts
  - **NEVER summarize the skill's process or workflow**
  - Keep under 500 characters if possible

**Body:** Overview, When to Use (with optional small inline flowchart), Core Pattern (before/after code comparison), Quick Reference, Implementation, Common Mistakes, optional Real-World Impact.

## Claude Search Optimization (CSO)

**Critical for discovery.** The description field answers "Should I read this skill right now?"

### Description = When to Use, NOT What the Skill Does

**CRITICAL:** Testing revealed that when a description summarizes the skill's workflow, Claude may follow the description instead of reading the full skill content. A description saying "code review between tasks" caused Claude to do ONE review, even though the skill's flowchart clearly showed TWO reviews.

The description should ONLY describe triggering conditions. Never summarize the process.

**BAD:** "Dispatches subagent per task with code review between tasks"
**GOOD:** "Use when executing implementation plans with independent tasks in the current session"

### Keyword Coverage
Use words Claude would search for: error messages, symptoms ("flaky", "hanging", "zombie"), synonyms ("timeout/hang/freeze"), actual commands and library names.

### Descriptive Naming
Use active voice, verb-first: `creating-skills` not `skill-creation`, `condition-based-waiting` not `async-test-helpers`. Gerunds work well for processes.

### Token Efficiency
- Getting-started workflows: <150 words each
- Frequently-loaded skills: <200 words total
- Other skills: <500 words
- Move details to tool help, use cross-references, compress examples, eliminate redundancy

### Cross-Referencing Other Skills
Use skill name only with explicit requirement markers. No `@` links (force-loads files, burns context).

**GOOD:** `**REQUIRED SUB-SKILL:** Use superpowers:test-driven-development`
**BAD:** `@skills/testing/test-driven-development/SKILL.md` (force-loads, burns context)

## The Iron Law

**NO SKILL WITHOUT A FAILING TEST FIRST.** Applies to NEW skills AND EDITS to existing skills. No exceptions: not for "simple additions", not for "just adding a section", not for "documentation updates". Write before testing: delete it, start over.

## Testing All Skill Types

- **Discipline-enforcing skills** (rules/requirements): pressure scenarios with combined pressures, document rationalizations, add explicit counters
- **Technique skills** (how-to guides): application scenarios, variation scenarios, missing-information tests
- **Pattern skills** (mental models): recognition scenarios, application scenarios, counter-examples
- **Reference skills** (documentation/APIs): retrieval scenarios, application scenarios, gap testing

## Bulletproofing Skills Against Rationalization

Skills enforcing discipline need to resist rationalization. Strategies: close every loophole explicitly with forbiddan workaround lists, address "spirit vs letter" arguments ("Violating the letter = violating the spirit"), build rationalization tables from baseline testing, create red flags lists for self-checking, update CSO for violation symptoms.

## RED-GREEN-REFACTOR for Skills

**RED:** Run pressure scenario with subagent WITHOUT the skill. Document exact behavior, verbatim rationalizations, which pressures triggered violations.

**GREEN:** Write skill addressing those specific rationalizations. Don't add extra content for hypothetical cases. Re-run same scenarios WITH skill — agent should now comply.

**REFACTOR:** Agent found new rationalization? Add explicit counter. Re-test until bulletproof.

## Flowchart Usage

Use flowcharts ONLY for non-obvious decision points, process loops where you might stop too early, "when to use A vs B" decisions. Never use for reference material, code examples, linear instructions, or generic labels.

## Code Examples

One excellent example beats many mediocre ones. Choose most relevant language. Complete and runnable, well-commented explaining WHY, from real scenario, shows pattern clearly.

## Anti-Patterns

- ❌ Narrative example (too specific, not reusable)
- ❌ Multi-language dilution (mediocre quality, maintenance burden)
- ❌ Code in flowcharts (can't copy-paste)
- ❌ Generic labels (step1, helper2 — labels should have semantic meaning)

## Skill Creation Checklist (TDD Adapted)

**RED Phase:** Create pressure scenarios (3+ combined pressures), run WITHOUT skill documenting baseline, identify rationalization patterns.

**GREEN Phase:** Name with letters/numbers/hyphens only, YAML frontmatter with name + description, description starts with "Use when..." in third person with triggers/symptoms, keywords throughout, clear overview, address specific baseline failures, one excellent example, re-run WITH skill to verify.

**REFACTOR Phase:** Identify new rationalizations, add explicit counters (discipline skills), build rationalization table, create red flags list, re-test until bulletproof.

**Quality Checks:** Small flowchart only if decision non-obvious, quick reference table, common mistakes section, no narrative storytelling, supporting files only for tools or heavy reference.

**Deployment:** Commit to git and push.

## The Bottom Line

**Creating skills IS TDD for process documentation.** Same Iron Law, same RED-GREEN-REFACTOR cycle, same benefits. If you follow TDD for code, follow it for skills.
