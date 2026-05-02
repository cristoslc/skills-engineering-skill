---
title: "Closing the Knowledge Gap with Agent Skills — Google Developers Blog"
source: https://developers.googleblog.com/closing-the-knowledge-gap-with-agent-skills/
author: Philipp Schmid, Mark McDonald (Google DeepMind)
type: web
fetched: 2026-05-01
tags: [google, gemini, agent-skills, evaluation, knowledge-gap, benchmarks]
---

# Closing the Knowledge Gap with Agent Skills

Google's empirical evaluation of agent skills for closing the LLM knowledge gap. Published March 25, 2026.

## The knowledge gap

LLMs have fixed knowledge from their training cutoff. New libraries are launched daily, best practices evolve quickly. This gap can't be solved purely by model scaling. Agent skills provide a practical engineering solution.

## Gemini API Developer Skill

Built a skill that:
- Explains high-level API feature set
- Describes current models and SDKs per language
- Demonstrates basic sample code for each SDK
- Lists documentation entry points as sources of truth

Available on GitHub: `google-gemini/gemini-skills`

## Evaluation methodology

- 117 prompts generating Python or TypeScript code using Gemini SDKs
- Categories: agentic coding, chatbots, document processing, streaming, SDK features
- Both "vanilla" mode (direct prompting) and skill-enabled mode
- Skill-enabled mode uses same system instruction as Gemini CLI, with `activate_skill` and `fetch_url` tools
- Failure defined as: using old/incorrect SDK

## Benchmark results

### By model
- Gemini 3.0 Pro: 6.8% vanilla → 96.6% with skill
- Gemini 3.0 Flash: 6.8% vanilla → 91.5% with skill
- Gemini 3.1 Pro: 28.2% vanilla → 97.4% with skill
- Gemini 2.5 Pro: lower baseline, didn't improve as much

### By domain (3.1 Pro with skill)
- Agentic tasks: 100%
- Chatbots: 100%
- Document processing: 100%
- Streaming: 100%
- SDK usage: 95% (lowest — failures included prompts explicitly requesting deprecated Gemini 2.0 models)

## Key findings

1. **Skills work dramatically, but require reasoning**: Modern models with strong reasoning capabilities benefit far more than older models
2. **Single SKILL.md can boost accuracy from 6.8% to 96%+**: The benchmark proves the approach works at scale
3. **Specific beats generic**: Being explicit about what's correct (latest API patterns) *and* what's forbidden (deprecated patterns) is key

## Known issues

- Vercel's work shows AGENTS.md instructions can be more effective than skills in some cases
- No great skill update mechanism — manual updates required, stale skill information risks doing more harm than good
- Google continues exploring MCP-based alternatives for live SDK knowledge
