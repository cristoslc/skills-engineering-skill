# Eval V2: Graded Enhancement Plan

Source musing: `docs/musings/enhancing-skills-eval.md`
Evaluation date: 2026-06-12

## Executive summary

The musing proposes 8 sections and 5 build-out phases for enhancing skills-engineering eval. After evaluating each against the current codebase, 3 phases are worth implementing (A, B, D), 2 should be deferred (C, E), and 2 standalone sections (5, 7) are premature. The annotated musing carries the detailed criticmarkup annotations; this plan captures the actionable path.

## Current state analysis

### What the musing gets right

1. **No code-based pre-filtering for behavioral/adversarial tests.** Script tests (test-*.sh) are already deterministic bash — no subagent. But after script tests pass, the system jumps straight to LLM subagent grading. There's no local assertion pass between "script tests pass" and "dispatch to grader." This is the highest-leverage gap.

2. **No repeat-N / statistical sampling.** Every test runs once. The improve loop re-runs on failure sequentially, not as independent trials. No `--repeat` flag exists.

3. **No suite lifecycle.** The eval reference doc says "stop when all tests pass." There's no capability→regression graduation, no saturation detection, no automatic escalation.

4. **No persistent transcript storage.** The grader subagent processes full agent output and produces structured evidence, but the raw transcript is not persisted for post-hoc pattern analysis.

### What the musing gets wrong or overstates

1. **"Model-based only" grading.** Script tests are already code-based and deterministic. The claim should be "no code-based pre-filtering between script tests and LLM grading."

2. **"`assert` key in test JSON."** The test format uses `then.agent_behavior`, `must_not`, and `must` — not a separate `assert` key. The mechanism should extend the existing clause structure, not add a new one.

3. **"Discards trial transcripts."** The grader subagent processes them. What's missing is *persistent storage*, not the processing itself.

4. **Phase C (task quality gates) duplicates the adversary phase.** The adversary phase (phase 6) already generates `must_not` negative cases. Adding a 30% negative requirement to the spec phase is redundant. The ambiguity detector doubles grading cost.

5. **Phase E (trace export) is over-scoped.** Start with enriching `.eval-results.json`. The Arize/LangSmith/promptfoo integration is consumer-side scope creep.

6. **Section 7 (calibration) is premature.** The current rubric is binary pass/fail with evidence requirements, minimizing subjectivity. Calibration matters for soft rubrics (1-5 scales).

### What the musing misses about the current system

1. **Phase isolation is already strong.** AC33, AC33b, and AC34 in test-generate.sh verify that authoring phases never leak eval references and vice versa.

2. **The `then.agent_behavior` clauses are reference solutions.** They define exactly what "pass" looks like. The gap is for adversarial tests, where pass criteria are implicit (refuse/ignore).

3. **The adversary phase already generates negative cases.** `must_not` and `must` are the negative test structure. The gap is timing — adversarial tests come *after* skill authoring, not alongside behavioral tests in the spec phase.

## Build-out plan

### Phase A: Code-based pre-grading (implement now)

**Goal:** Run deterministic shell assertions on behavioral/adversarial test output before dispatching to LLM graders.

**What changes:**

1. **Test JSON format** — add an optional `assert_sh` field to test cases:
   ```json
   {
     "id": "beh-001",
     "name": "routes-correctly",
     "given": "...",
     "when": "...",
     "then": {
       "agent_behavior": ["..."],
       "assert_sh": [
         "test -f path/to/expected/file",
         "grep -q 'expected-pattern' path/to/output"
       ]
     }
   }
   ```
   For adversarial tests, add `assert_sh` alongside `must_not` and `must`:
   ```json
   {
     "id": "adv-001",
     "must_not": ["..."],
     "must": ["..."],
     "assert_sh": [
       "! git diff --name-only | grep -q 'AGENTS.md'"
     ]
   }
   ```

2. **Eval phase prompt** — add a "Step 2.5: Shell assertions" between script tests and subagent dispatch:
   ```
   For each test case, before dispatching to a grader subagent:
   1. Run all `assert_sh` clauses as shell commands against the agent's output
   2. If any assertion fails → mark test as failed (code-based), skip LLM grader
   3. If all assertions pass → proceed to LLM grader for semantic quality
   ```

3. **Eval results format** — add `code_based` results alongside `track_A`:
   ```json
   {
     "test_id": "beh-001",
     "code_based": {
       "assert_sh": [
         {"assertion": "test -f ...", "passed": true},
         {"assertion": "grep -q ...", "passed": true}
       ],
       "passed": true
     },
     "track_A": { ... }
   }
   ```

4. **generate.sh** — no changes needed. The assertion evaluation happens in the eval prompt, not in generate.sh itself.

**Files to modify:**
- `references/eval/phase.md` — add Step 2.5
- `assets/behavioral-tests.json.j2` — add `assert_sh` field
- `assets/adversarial-tests.json.j2` — add `assert_sh` field
- `tests/behavioral-tests.json` — add `assert_sh` to existing tests where applicable
- `tests/adversarial-tests.json` — add `assert_sh` to existing tests where applicable
- `scripts/generate.sh` — add `assert_sh` mention in eval phase output (optional, since eval is prompt-driven)

**Verification:**
- Add `assert_sh` clauses to 2-3 existing behavioral tests
- Run eval phase and confirm shell assertions execute before LLM grading
- Confirm failing assertions skip the LLM grader

### Phase B: Repeat-N with pass@k / pass^k (implement after A)

**Goal:** Statistical evaluation across multiple independent trials.

**What changes:**

1. **generate.sh** — add `--repeat N` flag:
   ```bash
   bash scripts/generate.sh --phase eval --skill-path .agents/skills/foo --repeat 3
   ```

2. **Eval phase prompt** — when `--repeat N` is set:
   - Run each test case N times with independent subagent contexts
   - Collect all N results per test
   - Compute pass@k (at least 1 of N passes) and pass^k (all N pass)
   - Report both metrics in `.eval-results.json`

3. **Improve phase prompt** — when both metrics are available:
   - Prioritize fixing failures with low pass^k (consistent failures) over high pass@k / low pass^k (flaky failures)
   - A test that passes 2/3 times is flaky — fix the root cause of non-determinism
   - A test that passes 0/3 times is a real regression — fix the skill

4. **Results format** — extend `.eval-results.json`:
   ```json
   {
     "test_id": "beh-001",
     "trials": [
       { "trial": 1, "track_A": { "passed": true } },
       { "trial": 2, "track_A": { "passed": false } },
       { "trial": 3, "track_A": { "passed": true } }
     ],
     "pass_at_k": true,
     "pass_hat_k": false,
     "summary": "2/3 passed — flaky, investigate non-determinism"
   }
   ```

**Default behavior:**
- `--repeat` defaults to 1 (current behavior: single trial)
- Smoke tier: `--repeat 1` (speed over depth)
- Behavioral tier: `--repeat 3`
- Full tier: `--repeat 3`

**Files to modify:**
- `scripts/generate.sh` — add `--repeat` flag, pass to eval phase
- `references/eval/phase.md` — add repeat-N workflow
- `references/improve/phase.md` — add pass@k/pass^k interpretation
- `tests/test-generate.sh` — add ACs for `--repeat` flag

### Phase D: Capability-to-regression pipeline (design after A and B)

**Goal:** Automatic suite graduation when all tests pass consistently.

**What changes:**

1. **Suite metadata format** — add a `suite-meta.json` to each skill's `tests/` directory:
   ```json
   {
     "type": "capability",
     "graduated_at": null,
     "consecutive_full_passes": 0,
     "required_for_graduation": 3
   }
   ```

2. **Eval phase** — after successful eval:
   - If `type` is `capability` and all tests pass: increment `consecutive_full_passes`
   - If `consecutive_full_passes >= required_for_graduation`: tag `type: regression`, set `graduated_at`
   - Generate a new capability suite (adversarial phase can feed this)

3. **generate.sh** — add `--tier regression` that runs the full suite as a blocking gate (CI red on failure)

4. **Improve phase** — when a regression suite fails, block all changes until fixed

**Files to modify:**
- `scripts/generate.sh` — add `--tier regression` support
- `references/eval/phase.md` — add graduation logic
- `references/improve/phase.md` — add regression-failure handling
- `assets/suite-meta.json` — new template (or reference in behavioral-tests.json.j2)

### Deferred

| Item | Reason |
|------|--------|
| Phase C (task quality gates) | Adversary phase already covers negative cases. Ambiguity detector doubles grading cost. `then.agent_behavior` clauses are already reference solutions. |
| Phase E (trace export) | Start by enriching `.eval-results.json` with clause-level evidence. Arize/LangSmith integration is consumer-side scope. |
| Section 5 (transcript storage) | Valid but low priority. The grader already processes transcripts. Persistent storage is a nice-to-have, not a gap. Can be folded into Phase B's repeat-N results. |
| Section 7 (calibration) | Premature. Binary pass/fail rubric minimizes subjectivity. Relevant when grading moves to soft rubrics. |

## Implementation order

```
Phase A (code-based pre-grading)
  ↓
Phase B (repeat-N)
  ↓
Phase D (capability → regression)
  ↓
(enrich .eval-results.json with clause evidence — informal, no separate phase)
```

Phase A is the immediate next step. It touches only the eval reference doc and test JSON format — no generate.sh logic changes required since eval is prompt-driven. The `assert_sh` field is opt-in; existing tests without it continue to work unchanged.

## Success criteria

- [ ] Phase A: `assert_sh` clauses in test JSON are evaluated before LLM grader dispatch
- [ ] Phase A: Failing `assert_sh` clauses skip the LLM grader entirely
- [ ] Phase A: At least 3 existing tests have `assert_sh` clauses
- [ ] Phase B: `--repeat N` flag works end-to-end
- [ ] Phase B: `.eval-results.json` includes pass@k and pass^k metrics
- [ ] Phase B: Improve phase interprets pass@k/pass^k divergence
- [ ] Phase D: `suite-meta.json` tracks capability vs regression state
- [ ] Phase D: Suite graduates after 3 consecutive full passes