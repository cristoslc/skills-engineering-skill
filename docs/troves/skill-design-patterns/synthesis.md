# Skill Design Patterns — Synthesis

## Meta-routing: skills that invoke other skills

Both projects use a **dispatcher/meta-router** pattern to compose skills. The caller routes intent to the correct sub-skill via keyword matching, keeping the entry surface flat while delegating complexity to specialists.

**Swain meta-router** (`swain` skill, 25 lines): A standalone SKILL.md that matches user intent keywords to sub-skills via a routing table. The `allowed-tools: Skill` field restricts this skill to only invoking other skills — it never performs substantive work itself. Each row maps intent signals (e.g., "research, evidence, gather sources") to a specific swain-* skill. A disambiguation rule at the top handles edge cases (e.g., "what is a spec" routes to swain-help, while "how do I create a spec" routes to swain-design).

**Code-review generate.sh** (`code-review-skill/scripts/generate.sh`): The router is a bash script, not a SKILL.md. It accepts `--phase` values (init, setup, agents, synthesize, report) and returns `next_phase` and `prompt` fields. The orchestrator calls it in sequence, following the script's output rather than reading the SKILL.md directly.

**Key difference:** Swain's router is declarative (keyword table in SKILL.md), designed for the agent to read and dispatch. Code-review's router is imperative (phase state machine in bash), designed for deterministic step-by-step execution without LLM interpretation of the routing logic.

## Phase-based orchestration

Both projects organize complex workflows as **sequential phases**, but with opposite philosophies on where phase logic lives.

**Code-review: script-driven phases.** Seven phases (init, setup, segment-review, agents, synthesize, report, route) defined in `generate.sh` (834 lines of bash). Each phase call produces a self-contained output including `next_phase`, `prompt`, and structured data (JSON). The SKILL.md explicitly says "Do not reference this file for phase instructions — the script output IS the guidance." This pattern shifts execution control from the LLM to deterministic code. The LLM becomes a phase executor rather than a workflow planner.

**Swain: skill-driven phases.** Swain-design defines phases in its SKILL.md (377 lines) with the workflow embedded as prose instructions. Phase transitions are documented in `references/phase-transitions.md`. The LLM reads the skill file and follows the numbered steps, invoking shell scripts as sub-operations. This places more trust in the LLM's ability to follow sequential instructions.

**Anthropic Claude Code: explore → plan → code.** A four-phase pattern (Explore in Plan Mode → Create plan → Implement in Normal Mode → Commit). Separates research from execution to avoid solving the wrong problem. For trivial tasks, skip the plan entirely. This represents a middle ground: the LLM does the exploration and planning, but the human gates the transition to implementation (`simonw-agentic-engineering-patterns`, `anthropic-claude-code-best-practices`).

**Convergence point:** All patterns use the same conceptual structure — phases with explicit next-step guidance — but vary the execution locus (bash vs. LLM vs. human-gated LLM). The tradeoff is reliability vs. flexibility. Bash phases are deterministic but rigid; LLM phases are adaptive but can drift; human-gated phases add a quality gate at the cost of throughput.

## Subagent dispatch

Both projects run **parallel subagents** to decompose work, but with different dispatch topologies.

**Code-review: two dispatch modes.**
- `specialist`: One subagent per review lens (security, style, logic, docs, memory), each reviews all code segments. Produces N copies of every file read (4× overhead).
- `segment`: One subagent per code segment, each applies all lenses sequentially. Reads each file once but loses parallel specialization.
- Both modes guarantee every line is reviewed under every specialization. The choice is a resource tradeoff: CPU vs. I/O.

**Swain: superpowers skill chaining.** Instead of spawning parallel subagents for lenses, swain chains into superpowers skills (brainstorming, writing-plans, TDD, verification) as sequential invocations. Superpowers skills are invoked as whole skills via the Skill tool, not decomposed further. The chain is defined in each skill's integration section: brainstorming before creative work, writing-plans before implementation, TDD during implementation, verification before completion claims.

**Anthropic Claude Code: Writer/Reviewer pattern.** Run two parallel Claude sessions — one writes code, a second reviews it with fresh context (no bias from having written it). Also supports subagents for investigation: "use subagents to investigate X" keeps exploration context out of the main conversation (`anthropic-claude-code-best-practices`).

**HumanLayer 12-Factor: Small, Focused Agents (Factor 10).** Smaller agents with focused scopes are more reliable than large general-purpose ones. Each agent should have a bounded set of responsibilities rather than a bag-of-tools approach (`humanlayer-12-factor-agents`).

**Convergence point:** All share a common design principle — **specialization via separation.** Code-review separates by review lens; swain separates by development phase; Anthropic separates write from review; 12-Factor separates by bounded responsibility. All avoid monolithic "do it all" instructions in favor of composable units.

## Competitor attribution (adversarial framing)

Code-review uses a novel pattern: **attribute the code under review to a competitor's experimental model.** The `generate.sh` init phase detects the reviewing model's maker from `MODEL_MAKER` or heuristics, then computes an opposite competitor. For example, if Claude is reviewing, the code is framed as "Google's experimental Gemini output." This is undisclosed to the user (`--flag undisclosed`). The goal is to heighten skepticism by triggering the model's competitive assessment instincts.

This is an adversarial quality technique — it exploits model behavior to improve review rigor. No equivalent pattern exists in swain or the external sources, which are collaborative rather than adversarial by design.

## Progressive disclosure in practice

All sources converge on progressive disclosure as the fundamental skill design pattern. The canonical model has three levels, formalized by Anthropic (`anthropic-agent-skills`).

**Level 1 — Metadata (loaded at startup):** The agent pre-loads name and description of every installed skill into its system prompt. Just enough to know *when* a skill is relevant.

**Level 2 — SKILL.md body (loaded on demand):** Full skill instructions loaded when the agent determines the skill is relevant to the current task.

**Level 3+ — Bundled references (loaded only as needed):** Additional context files in the skill directory, referenced by name from SKILL.md. The agent navigates to these only when specific workflows demand them.

**Concrete implementations:**

**Anthropic Agent Skills** (`anthropic-agent-skills`): A skill is a directory with a `SKILL.md` file containing YAML frontmatter with `name` and `description`. Level 1 is the metadata block; Level 2 is the SKILL.md body; Level 3+ are bundled files referenced by name. The PDF skill splits form-filling instructions into a separate `forms.md` so the core SKILL.md stays lean. The amount of context that can be bundled is effectively unbounded because agents with filesystem tools don't need to read everything into context at once.

**Code-review:** Level 1 is the SKILL.md name+description (loaded at startup). Level 2 is the phase prompt from `generate.sh` (loaded per-phase). Level 3 is agent files and diff method files (loaded on demand by subagents). The phase prompt is generated fresh each time, so it can incorporate payload-specific context (model maker, diff scope, dispatch mode).

**Swain:** Level 1 is the swain meta-router's routing table. Level 2 is the specific swain-* skill's SKILL.md. Level 3 is `references/` files loaded only when a workflow step references them.

**OpenAI Harness Engineering** (`openai-harness-engineering`): Applies progressive disclosure at the repository level. AGENTS.md is a ~100 line table of contents pointing to a structured `docs/` directory. This is a direct rejection of the "one big AGENTS.md" anti-pattern — agents start with a small, stable entry point and are taught where to look next.

## AGENTS.md / CLAUDE.md as navigational maps

A strong consensus emerges: the agent instruction file should be a **table of contents, not an encyclopedia**.

**OpenAI's lesson** (`openai-harness-engineering`): "One big AGENTS.md" fails because (a) context is scarce — a giant file crowds out the task, (b) too much guidance becomes non-guidance — when everything is "important," nothing is, (c) it rots instantly, (d) it's hard to verify mechanically. Their solution: 100-line AGENTS.md pointing to a structured `docs/` directory with design-docs, exec-plans, product-specs, and references. Enforced by linters and CI jobs.

**Anthropic's CLAUDE.md design** (`anthropic-claude-code-best-practices`): "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it." Include only things Claude can't figure out from reading code. Exclude standard conventions, detailed API docs (link instead), and self-evident practices. Use `@path/to/import` syntax for modular imports. Supports home folder, project root, parent/child directories for progressive scope.

**Swain's AGENTS.md** (`swain-skill-ecosystem`): Provides a session roadmap and ecosystem overview. The entry point is intentionally lean; individual skill SKILL.md files carry the specialized instructions.

**Convergence point:** All sources independently converged on the same conclusion: keep the entry file short, make it a map, make it mechanically verifiable, and push detailed knowledge into structured sub-documents.

## Harness engineering: the agent-first repository

OpenAI's "harness engineering" (`openai-harness-engineering`) is the most radical practice documented: building a product with **0 lines of manually-written code**. Three engineers driving Codex produced ~1M lines and ~1,500 PRs in 5 months at ~1/10th traditional development speed.

Key patterns from this experiment:

**Repository knowledge as system of record.** Anything Codex can't access in-context effectively doesn't exist. Slack discussions, Google Docs, and tacit knowledge are invisible to the agent. All context must be pushed into the repo as versioned artifacts. This forces a discipline similar to onboarding: "In the same way you would onboard a new teammate on product principles, engineering norms, and team culture, giving the agent this information leads to better-aligned output."

**Architecture enforcement as multiplier.** Rigid layered architecture with strictly validated dependency directions, enforced by custom linters and structural tests. "This is the kind of architecture you usually postpone until you have hundreds of engineers. With coding agents, it's an early prerequisite: the constraints are what allows speed without decay."

**Garbage collection for AI slop.** Agents replicate existing patterns — even suboptimal ones. OpenAI encodes "golden principles" into the repo and runs recurring background Codex tasks that scan for deviations and open targeted refactoring PRs. "Technical debt is like a high-interest loan: it's almost always better to pay it down continuously in small increments."

**Merge philosophy shift.** Minimal blocking merge gates, short-lived PRs, test flakes handled with follow-up runs. "In a system where agent throughput far exceeds human attention, corrections are cheap, and waiting is expensive."

## Red/green TDD as agent instruction pattern

Simon Willison identifies TDD, specifically the red/green variant, as a pattern that coding agents excel at (`simonw-red-green-tdd`, `simonw-agentic-engineering-patterns`). "Use red/green TDD" works as a compact prompt that every good model understands as shorthand for the full test-first workflow. The pattern is effective because: (a) agents risk writing non-working code, (b) test-first protects against this, (c) it ensures a regression suite, (d) confirming failure first prevents false-positive tests.

Anthropic independently confirms this (`anthropic-claude-code-best-practices`): "Give Claude a way to verify its work — this is the single highest-leverage thing you can do."

Swain's completion pipeline (`swain-skill-ecosystem`) operationalizes this as a three-step quality gate: BDD tests → smoke tests → retro, with atomic state tracking.

## Context window as the fundamental constraint

Both Anthropic sources (`anthropic-claude-code-best-practices`, `anthropic-agent-skills`) and the 12-Factor Agents framework (`humanlayer-12-factor-agents`) identify the context window as the primary constraint driving all other skill design decisions.

**Anthropic's practices:**
- `/clear` between unrelated tasks
- After two failed corrections, `/clear` and start fresh (polluted context is worse than lost context)
- Auto-compaction summarizes conversation history when approaching limits
- `/btw` for side questions that don't enter conversation history
- Subagents for investigation keep exploration out of the main conversation

**HumanLayer Factor 3 — Own your context window** (`humanlayer-12-factor-agents`): "The context window is the API." Actively manage what goes into context rather than letting frameworks decide. Factor 9 — Compact errors into context window — ensures error information is concisely fed back.

**Anthropic Agent Skills** (`anthropic-agent-skills`): Progressive disclosure exists precisely because the context window is finite. The three-level model keeps context low until a skill is needed.

## Session and state management

Swain introduces **session lifecycle management** as a skill design concern, which is absent from code-review.

- **Session state**: `.agents/session.json` and `.agents/session-state.json` track active session identity.
- **Session check preamble**: Every swain skill runs `swain-session-check.sh` before state-changing operations. If no session is active, the skill informs the operator and offers to start one.
- **Bookmarks**: Cross-session context pointers stored in `.agents/session.json`. Agents pick up where the previous session left off.
- **Decision budget**: Sessions have a decision cap (default 5). Exceeding it triggers a teardown nudge.
- **Completion pipeline**: A three-step quality gate (BDD tests → smoke tests → retro) with atomic state tracking in `.agents/completion-state.json`.
- **Teardown sequence**: Six-step shutdown (orphan detection, dirty check, pipeline catch-up, ticket sync, merge branches, cleanup, commit handoff).

Anthropic's Claude Code supports session persistence differently (`anthropic-claude-code-best-practices`): `claude --continue` / `--resume` to pick up conversations, `/rename` for session naming, checkpoints that persist across sessions. HumanLayer's Factor 6 — Launch/Pause/Resume — and Factor 12 — Stateless Reducer — formalize state management for production agents as async, resumable patterns (`humanlayer-12-factor-agents`).

Swain's session infrastructure is the most comprehensive but is tightly coupled to its own CLI launcher (`bin/swain`), limiting portability to other agent runtimes.

## Worktree isolation

Swain enforces **worktree isolation for all mutating work** — skills detect whether they're running in a worktree and refuse to proceed on trunk for non-trivial changes. Code-review has no equivalent. Anthropic's Claude Code supports worktree isolation per session (`anthropic-claude-code-best-practices`). OpenAI's harness engineering (`openai-harness-engineering`) uses worktree isolation so Codex can launch and drive one app instance per change, including ephemeral observability stacks per worktree.

## Script as execution surface

Both projects use **scripts as the authoritative execution layer**, but for different reasons.

**Code-review `generate.sh` (834 lines):** The script IS the orchestrator. All phase logic, model detection, competitor computation, agent prompt assembly, and result synthesis happen in bash+jq. The LLM is a thin caller: it pipes JSON in, reads output, and follows instructions.

**Swain scripts:** Scripts are utility functions called from within LLM-driven skill workflows. The SKILL.md contains the workflow logic; scripts handle specific deterministic operations.

**Anthropic Agent Skills** (`anthropic-agent-skills`): Skills can include code for Claude to execute as tools. Certain operations (sorting, form field extraction) are better suited for deterministic code execution than token generation. Code is deterministic, so workflows are consistent and repeatable.

**Convergence point:** All agree that deterministic operations (file operations, git, computation, encoding conventions) should be scripted, not LLM-generated. The disagreement is scope: code-review scripts the entire workflow; swain scripts only the leaf operations; Anthropic scripts both leaf operations and bundled tools.

## Model hint annotations

Swain uses HTML comment annotations to guide model selection: `<!-- swain-model-hint: opus, effort: high -->` for complex artifact creation and `<!-- swain-model-hint: sonnet, effort: low -->` for procedural transitions. This pattern is absent from the external sources, which tend to rely on human operator discretion to choose the model.

## Artifact-as-state architecture

Swain treats markdown files under `docs/` as the **system of record** — specs, epics, ADRs encode intent, decisions, and completion criteria. Skills read artifacts to understand context, write to them to record decisions, and cross-reference them for alignment checks.

OpenAI's harness engineering (`openai-harness-engineering`) independently arrived at the same architecture: `docs/` as the system of record with design-docs, exec-plans (with active/completed + progress/decision logs), product-specs, and references. Both treat plans as first-class versioned artifacts checked into the repository rather than ephemeral chat context. Code-review has no equivalent — it is a pure service skill with no state beyond a single invocation.

## Agent Skills as open standard

Anthropic published Agent Skills as an open standard in December 2025 (`anthropic-agent-skills`). Google has adopted this format for the Gemini API developer skill (`google-agent-skills-knowledge-gap`). The format is simple: a directory containing a `SKILL.md` file with YAML frontmatter. This simplicity is intentional — "Skills are a simple concept with a correspondingly simple format. This simplicity makes it easier for organizations, developers, and end users to build customized agents."

Google's evaluation (`google-agent-skills-knowledge-gap`) provides empirical validation: a single SKILL.md file boosted Gemini 3.0 Pro's accuracy on SDK code generation from 6.8% to 96.6%. Key finding: "skills work dramatically, but require reasoning" — modern models with strong reasoning benefit far more than older models. The knowledge gap is a structural limitation of LLMs that no amount of model scaling fixes; Agent Skills provide a practical engineering solution.

Known issues: no great skill update mechanism (manual updates required, stale skills risk doing more harm than good). Google continues exploring MCP-based alternatives.

## 12-Factor Agents: production-grade design axioms

HumanLayer's 12-Factor Agents (`humanlayer-12-factor-agents`) provides a set of axioms for production-grade LLM applications. Key factors with direct skill-design implications:

- **Factor 1 (NL → Tool Calls):** Convert natural language to structured tool calls; deterministic code executes them. This is the fundamental agent loop pattern.
- **Factor 2 (Own your prompts):** Control prompt construction; don't outsource to frameworks.
- **Factor 4 (Tools are just structured outputs):** Tools don't need to be complex. They're structured JSON output triggering deterministic code. Creates clean separation between LLM decision-making and application action.
- **Factor 8 (Own your control flow):** Don't let frameworks control the agent loop. You own the while loop.
- **Factor 10 (Small, focused agents):** Smaller agents with focused scopes are more reliable than monolithic bag-of-tools agents.
- **Factor 12 (Stateless reducer):** State in, state out; deterministic and testable.

The thesis is that the fastest way to get good AI software into customers' hands is to take **small, modular concepts from agent building** and incorporate them into existing products, rather than adopting a framework wholesale. This aligns with both Swain's composable skill approach and code-review's script-driven design.

## Framework skepticism

A notable convergence across sources: all express skepticism about agent frameworks as the primary vehicle for production work.

**HumanLayer** (`humanlayer-12-factor-agents`): Most builders who adopt a framework hit 70-80% quality, realize it's not good enough, then reverse-engineer the framework and start over. "The fastest way I've seen for builders to get good AI software in the hands of customers is to take small, modular concepts from agent building, and incorporate them into their existing product."

**Anthropic Claude Code** (`anthropic-claude-code-best-practices`): The extension system (skills, hooks, subagents, MCP, plugins) is designed as modular composable units rather than a monolithic framework. "For guidance on choosing between skills, subagents, hooks, and MCP, see Extend Claude Code."

**Swain** (`swain-skill-ecosystem`): Skills are composable, stateless units invoked via the Skill tool. The infrastructure (session, worktree, locks) is shared, but individual skills are independent.

**Code-review** (`code-review-skill`): The bash script, not a framework, is the orchestrator. All logic is transparent and auditable.

## Key points of agreement

- **Skills should be modular and composable.** All sources decompose complex workflows into multiple invocations rather than monolithic instructions.
- **Progressive disclosure is fundamental.** The three-level loading model (metadata → body → references) is universal. Context is scarce; load only what's needed, when it's needed.
- **Description is the trigger.** All rely on the SKILL.md `description` field for agent discovery and activation. Google's study confirms name+description quality directly impacts skill invocation accuracy.
- **Scripts are preferred for deterministic operations.** All use scripts for git, computation, state management, and operations better suited to code than token generation.
- **Skills are code.** Swain states this as a governance principle. Anthropic bundles executable scripts in skills. OpenAI treats harness tooling as code. Code-review has the script be the authoritative layer.
- **Keep the entry file short.** Every source independently converged on AGENTS.md/CLAUDE.md as a navigational map, not an encyclopedia.
- **Frameworks are scaffolding, not architecture.** Every source prefers composable units over monolithic frameworks for production work.
- **Verification is the highest-leverage investment.** Willison's TDD pattern, Anthropic's "always provide verification," and Swain's completion pipeline all converge on testability as the primary quality driver.
- **Writing code is cheap now.** Willison's central thesis (`simonw-code-is-cheap`) — the cost to produce working code has dropped to near-zero, disrupting existing tradeoff intuitions — is validated by OpenAI's 1M lines of agent-generated code in 5 months.

## Platform divergences

- **Statefulness**: Swain skills are stateful (sessions, bookmarks, decisions). Code-review is stateless per invocation. Anthropic Claude Code supports session persistence but no formal lifecycle. HumanLayer advocates stateless reducers (Factor 12).
- **Safety infrastructure**: Swain has locks, worktree isolation, decision budgets, completion pipelines. Anthropic has sandboxing, permission allowlists, auto-mode classifier. OpenAI has linter enforcement and garbage collection agents. Code-review has none.
- **Routing mechanism**: Swain routes via keyword matching in SKILL.md. Code-review routes via phase state machine in bash. Anthropic routes via skill discovery from metadata description. HumanLayer routes via owned control flow (Factor 8).
- **LLM trust model**: Swain trusts the LLM to follow prose instructions. Code-review replaces LLM workflow control with script output. Anthropic Claude Code uses Plan Mode as a human-gated safety boundary. OpenAI uses mechanical enforcement (linters, CI) rather than trust.
- **Ecosystem size**: Swain is a 25+ skill ecosystem with cross-skill chains. Code-review is a single skill with internal subagent dispatch. Anthropic is a platform with an extension marketplace. HumanLayer is a set of design axioms rather than an implementation.

## Gaps

- Code-review has no session or state management — cannot resume interrupted reviews.
- Swain's meta-router requires all sub-skills to be installed; if one is missing, routing degrades silently.
- Neither project has a formal skill dependency declaration system (beyond skills-lock.json for provenance).
- Code-review's competitor attribution is undisclosed to users — transparency vs. effectiveness tension.
- Swain's session infrastructure is tightly coupled to its own CLI launcher (`bin/swain`), limiting portability to other agent runtimes.
- No source addresses skill semantic versioning or compatibility contracts between skill versions.
- Google's evaluation revealed stale skills are a worse-than-nothing problem — no source has addressed skill update/distribution mechanics.
- HumanLayer's 12 factors are axioms, not implemented patterns — the gap between principle and practice remains wide.
- Willison's Agentic Engineering Patterns is a work in progress — several planned chapters (anti-patterns, hoarding, interactive explanations) are still unpublished.
