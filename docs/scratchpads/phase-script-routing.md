---
date: 2026-05-01
topic: skill-design
---

# Phase-Script Routing as Decision Hygiene

**Core insight:** In a highly-engineered skill, the LLM should not be reasoning about workflow state or reading large branching decision trees. It should make one simple call and get back exactly the instructions it needs.

**The pattern:**
- The LLM calls `generate.sh --phase <intent>` with a single parameter
- The script handles all branching logic (which phase, which validation rules, which instructions)
- The LLM receives one targeted prompt — only the instructions for that moment
- The LLM's job is content execution; the script's job is routing

**Why it matters:**
- Removes LLM interpretation of workflow state — unreliable at best
- Never loads irrelevant instructions — clean context per phase
- One decision point at entry, deterministic output from there

**Source:** code-review-skill's `generate.sh` pattern. SKILL.md explicitly says "Do not reference this file for phase instructions — the script output IS the guidance."

**Contrast:** swain-design embeds the full branching logic as prose in SKILL.md. The LLM reads 300+ lines and must figure out which path applies. Works for broad intent routing (swain meta-router), but breaks down for precise workflow sequencing.

**Application:** skills-engineering skill — three phases (author, eval, improve). LLM calls `generate.sh --phase author` and gets a 30-line prompt. Never sees eval criteria, never parses a validation tree, never decides its own path.

---

# Meta-Routing vs. Phase-Routing

**Meta-routing** (swain's `swain` skill): A flat keyword table in SKILL.md. The LLM reads the table, matches user intent to a sub-skill name, and dispatches. Works because the decision surface is a 25-line table — low interpretation burden.

**Phase-routing** (code-review's `generate.sh`): A bash script with internal state machine. The LLM calls it with a phase name, gets back instructions and the next phase name. Works because the decision surface is one function call — zero interpretation burden.

**When to use which:**
- Meta-routing when you're dispatching to entirely different skills (different domains, different instructions)
- Phase-routing when you're sequencing steps within one skill (same domain, sequential instructions, branching complexity)
