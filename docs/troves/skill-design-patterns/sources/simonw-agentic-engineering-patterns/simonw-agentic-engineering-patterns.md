---
title: "Agentic Engineering Patterns — Simon Willison"
source: https://simonwillison.net/2026/Feb/23/agentic-engineering-patterns/
author: Simon Willison
type: web
fetched: 2026-05-01
tags: [agentic-engineering, design-patterns, coding-agents, vibe-coding, ai-assisted-programming]
---

# Agentic Engineering Patterns

Simon Willison's project to collect and document coding practices and patterns for getting the best results from coding agents (Claude Code, OpenAI Codex).

## Core definitions

**Agentic Engineering**: Building software using coding agents where the defining feature is that they can both generate *and execute* code — allowing them to test and iterate independently of turn-by-turn guidance from their human supervisor.

**Vibe coding**: (original definition) Coding where you pay no attention to the code at all, associated with non-programmers using LLMs to write code. Agentic Engineering is the opposite end of the scale: professional software engineers amplifying their expertise.

## Format and structure

The project is loosely inspired by *Design Patterns: Elements of Reusable Object-Oriented Software* (1994). Published as a "guide" — a collection of chapters where each chapter is a blog post designed to be updated over time rather than frozen at first publication. This solves the challenge of publishing "evergreen" content on a blog.

**First published chapters** (Feb 23, 2026):
1. **Writing code is cheap now** — how the cost of churning out initial working code has dropped to almost nothing, disrupting existing intuitions about tradeoffs
2. **Red/green TDD** — how test-first development helps agents write more succinct, reliable code

Willison has a strong policy of not publishing AI-generated writing under his own name. All words are his own; LLMs used for proofreading and example code only.

## Key architectural decisions

- The Guide/Chapter model in Django: models for Guide, Chapter, and ChapterChange with associated views
- Most of the implementation written by Claude Opus 4.6 running in Claude Code for web, accessed via iPhone
- Plan to add chapters at rate of 1-2 per week
