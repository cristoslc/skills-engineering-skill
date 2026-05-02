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

**Convergence point:** Both patterns use the same conceptual structure — phases with explicit next-step guidance — but vary the execution locus (bash vs. LLM). The tradeoff is reliability vs. flexibility. Bash phases are deterministic but rigid; LLM phases are adaptive but can drift.

## Subagent dispatch

Both projects run **parallel subagents** to decompose work, but with different dispatch topologies.

**Code-review: two dispatch modes.**
- `specialist`: One subagent per review lens (security, style, logic, docs, memory), each reviews all code segments. Produces N copies of every file read (4× overhead).
- `segment`: One subagent per code segment, each applies all lenses sequentially. Reads each file once but loses parallel specialization.
- Both modes guarantee every line is reviewed under every specialization. The choice is a resource tradeoff: CPU vs. I/O.

**Swain: superpowers skill chaining.** Instead of spawning parallel subagents for lenses, swain chains into superpowers skills (brainstorming, writing-plans, TDD, verification) as sequential invocations. Superpowers skills are invoked as whole skills via the Skill tool, not decomposed further. The chain is defined in each skill's integration section: brainstorming before creative work, writing-plans before implementation, TDD during implementation, verification before completion claims.

**Convergence point:** Both share a common design principle — **specialization via separation.** Code-review separates by review lens; swain separates by development phase. Both avoid monolithic "do it all" instructions in favor of composable units.

## Competitor attribution (adversarial framing)

Code-review uses a novel pattern: **attribute the code under review to a competitor's experimental model.** The `generate.sh` init phase detects the reviewing model's maker from `MODEL_MAKER` or heuristics, then computes an opposite competitor. For example, if Claude is reviewing, the code is framed as "Google's experimental Gemini output." This is undisclosed to the user (`--flag undisclosed`). The goal is to heighten skepticism by triggering the model's competitive assessment instincts.

This is an adversarial quality technique — it exploits model behavior to improve review rigor. No equivalent pattern exists in swain, which is collaborative rather than adversarial by design.

## Progressive disclosure in practice

Both projects implement the three-level progressive disclosure model from the SKILL.md standard, but interpret it differently.

**Code-review:** Level 1 is the SKILL.md name+description (loaded at startup). Level 2 is the phase prompt from `generate.sh` (loaded per-phase). Level 3 is agent files and diff method files (loaded on demand by subagents). The phase prompt is generated fresh each time, so it can incorporate payload-specific context (model maker, diff scope, dispatch mode).

**Swain:** Level 1 is the swain meta-router's routing table. Level 2 is the specific swain-* skill's SKILL.md. Level 3 is `references/` files loaded only when a workflow step references them. Swain skills aggressively use `references/` for detailed procedures (tdd-enforcement, alignment-checking, tk-cheatsheet) to keep the main SKILL.md under the 500-line limit.

## Session and state management

Swain introduces **session lifecycle management** as a skill design concern, which is absent from code-review.

- **Session state**: `.agents/session.json` and `.agents/session-state.json` track active session identity.
- **Session check preamble**: Every swain skill runs `swain-session-check.sh` before state-changing operations. If no session is active, the skill informs the operator and offers to start one.
- **Bookmarks**: Cross-session context pointers stored in `.agents/session.json`. Agents pick up where the previous session left off.
- **Decision budget**: Sessions have a decision cap (default 5). Exceeding it triggers a teardown nudge.
- **Completion pipeline**: A three-step quality gate (BDD tests → smoke tests → retro) with atomic state tracking in `.agents/completion-state.json`.
- **Teardown sequence**: Six-step shutdown (orphan detection, dirty check, pipeline catch-up, ticket sync, merge branches, cleanup, commit handoff).

This is an architectural layer above individual skills — session management as shared infrastructure. Code-review is stateless per invocation.

## Worktree isolation

Swain enforces **worktree isolation for all mutating work** — skills detect whether they're running in a worktree and refuse to proceed on trunk for non-trivial changes. The `swain-do` worktree preamble (Step 0: commit dirty files, Step 1: detect context, Step 2: check for existing worktrees, Step 3: inform operator to use `bin/swain` for creation) is an example of a skill enforcing operational safety constraints.

Code-review has no equivalent — it operates on whatever directory it's pointed at.

## Script as primary execution surface

Both projects use **scripts as the authoritative execution layer**, but for different reasons.

**Code-review `generate.sh` (834 lines):** The script IS the orchestrator. All phase logic, model detection, competitor computation, agent prompt assembly, and result synthesis happen in bash+jq. The LLM is a thin caller: it pipes JSON in, reads output, and follows instructions. The SKILL.md is effectively documentation for the script's interface.

**Swain scripts (`swain-bookmark.sh`, `swain-session-check.sh`, `swain-lockfile.sh`, `chart.sh`, etc.):** Scripts are utility functions called from within LLM-driven skill workflows. The SKILL.md contains the workflow logic; scripts handle specific deterministic operations. The split is: LLM for intent, decision-making, and prose; bash for computation, state management, and git operations.

**Convergence point:** Both agree that deterministic operations (file operations, git, computation, encoding conventions) should be scripted, not LLM-generated. The disagreement is scope: code-review scripts the entire workflow; swain scripts only the leaf operations.

## Model hint annotations

Swain uses HTML comment annotations to guide model selection: `<!-- swain-model-hint: opus, effort: high -->` for complex artifact creation and `<!-- swain-model-hint: sonnet, effort: low -->` for procedural transitions. These are per-section overrides that let the skill author specify which model capability tier is appropriate for each workflow segment.

This pattern is absent from code-review.

## Artifact-as-state architecture

Swain treats markdown files under `docs/` as the **system of record** — specs, epics, ADRs encode intent, decisions, and completion criteria. Skills read artifacts to understand context, write to them to record decisions, and cross-reference them for alignment checks. The artifact hierarchy (Vision → Initiative → Epic → Spec) provides a navigable structure for skills to traverse.

Code-review has no equivalent — it is a pure service skill with no state beyond a single invocation.

## Key points of agreement

- **Skills should be modular and composable.** Both projects decompose complex workflows into multiple skill invocations rather than monolithic instructions.
- **Scripts are preferred for deterministic operations.** Both use bash scripts for git, computation, and state management. Neither generates scripts on the fly.
- **Progressive disclosure is fundamental.** Both use the three-level loading model (metadata → body → references) to keep context low until a skill is needed.
- **Description is the trigger.** Both rely on the SKILL.md `description` field for agent discovery and activation.
- **Skills are code.** Swain explicitly states this principle in its governance; code-review embodies it by having the script, not the SKILL.md, be the authoritative layer.

## Platform divergences

- **Statefulness**: Swain skills are stateful (sessions, bookmarks, decisions). Code-review is stateless per invocation.
- **Safety infrastructure**: Swain has locks, worktree isolation, decision budgets, completion pipelines. Code-review has none.
- **Routing mechanism**: Swain routes via keyword matching in SKILL.md. Code-review routes via phase state machine in bash.
- **LLM trust model**: Swain trusts the LLM to follow prose instructions. Code-review replaces LLM workflow control with script output.
- **Ecosystem size**: Swain is a 25+ skill ecosystem with cross-skill chains. Code-review is a single skill with internal subagent dispatch.

## Gaps

- Code-review has no session or state management — cannot resume interrupted reviews.
- Swain's meta-router requires all sub-skills to be installed; if one is missing, routing degrades silently.
- Neither project has a formal skill dependency declaration system (beyond skills-lock.json for provenance).
- Code-review's competitor attribution is undisclosed to users — transparency vs. effectiveness tension.
- Swain's session infrastructure is tightly coupled to its own CLI launcher (`bin/swain`), limiting portability to other agent runtimes.
