# Author Phase — Writing SKILL.md

## Workflow

### 1. Read the contracts

Before writing a single line, load the test files:

```
tests/behavioral-tests.json
tests/adversarial-tests.json   (if present)
spec.md
```

Understand every `then.agent_behavior` clause. These are your acceptance criteria. If a clause is ambiguous, note it — the skill may need to make an explicit instruction to disambiguate the behavior.

### 2. Design the progressive disclosure structure

Decide what lives at each level:

| Level | Scope | Token budget |
|-------|-------|-------------|
| 1 — Metadata | `name` + `description` frontmatter | ~100 tokens |
| 2 — Body | SKILL.md markdown after frontmatter | <500 lines |
| 3 — References | `references/*.md` loaded on demand | unlimited |

**Level 1 (metadata):** The `name` must match the directory name (lowercase, hyphens). The `description` is the primary trigger — it must describe both *what* the skill does and *when* to use it. Include keywords the agent's discovery system will match against.

**Level 2 (body):** The SKILL.md body teaches *how*. It should:
- Route to references for detailed procedures
- Include concrete examples (input → output pairs)
- Use imperative form for instructions
- Explain *why* rules exist, not just state them

**Level 3 (references):** Encyclopedic detail. Schemas, templates, edge case procedures, platform-specific variants. Each reference file linked directly from SKILL.md (one level deep — no transitive chains).

### 3. Write the frontmatter

```yaml
---
name: my-skill
description: What the skill does and when to use it. Include keywords for discovery. Write in third person.
license: MIT
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
metadata:
  version: 0.1.0
  author: your-name
---
```

Required fields: `name`, `description`.

### 4. Write the body

**Pattern: routing table for meta-skills.**

If your skill routes to sub-skills or has phases, use a routing table:

```markdown
## Routing

| Intent | Target | Trigger words |
|--------|--------|---------------|
| Review code | code-review skill | "review", "PR", "diff" |
| Create skill | skills-engineering author | "create skill", "new skill" |
```

**Pattern: phase-based workflows.**

If your skill has sequential phases, describe the sequence and how to advance:

```markdown
## Phases

1. **Setup** — detect environment, collect inputs
2. **Process** — do the work (spawn subagents if parallelizable)
3. **Verify** — run tests, check outputs
4. **Report** — present results

Advance to next phase by calling scripts/generate.sh --phase <name>.
```

**Pattern: examples.**

Concrete input → output pairs are more effective than abstract descriptions:

```markdown
## Examples

**Input:** "Review PR #42 for security issues"
**Output:** Security review with three sections: auth flow, input validation, dependency risks.
```

**Pattern: conditional workflows.**

When the skill handles variants:

```markdown
## Workflow selection

- Creating a new X? → Creation workflow
- Editing an existing X? → Edit workflow
- Reviewing X? → Review workflow
```

### 5. Description engineering

The `description` field is the primary discovery mechanism. Combat "undertriggering" (skill not activating when it should) by making descriptions specific and action-oriented.

**Good:** "Review pull requests for security vulnerabilities, code quality, logic errors, and documentation gaps. Use when reviewing a PR, diff, or code change."

**Bad:** "Helps with code review." (too vague — what kind? when?)

**Include:**
- What the skill does (the capability)
- When to use it (the trigger context)
- Key distinguishing keywords ("review PR", "diff", "code change")

**Avoid:**
- Generic verbs without context ("helps", "assists")
- Platform-specific terms unless the skill is platform-specific
- Time-sensitive info (will rot)

### 6. Keep it under 500 lines

If the body approaches 500 lines:
1. Move detailed procedures to `references/`
2. Move templates to `assets/`
3. Move scripts to `scripts/`
4. Move platform-specific instructions to separate reference files
5. Add a table of contents at the top of long reference files (>300 lines)

Anthropic's test: "For each line, ask: 'Would removing this cause the agent to make mistakes?' If not, cut it."

### 7. Verify against behavioral contracts

After writing, re-read the behavioral tests. Can you check off each `then.agent_behavior` clause? If the skill doesn't explicitly instruct the agent to do something the test expects, add that instruction.

## Naming conventions

- Use gerund form: `reviewing-code`, `processing-pdfs`, `authoring-skills`
- Match the directory name exactly
- Lowercase, hyphens only, max 64 chars
- Avoid vague names: `helper`, `utils`, `tools`
- Avoid reserved words: `anthropic`, `claude`

## Scripts need TDD tests

Every script in `scripts/` must have an acceptance test file. Scripts are code — they get the same TDD discipline as `.py` or `.sh` files in the project.

### Test file conventions

- Place in `tests/test-<script-name>.sh` (e.g. `test-generate.sh` for `scripts/generate.sh`)
- Follow the swain pattern: `set +e`, `pass()`/`fail()` functions, `PASS`/`FAIL` counters
- Structure tests as **Acceptance Criteria (AC)** numbered clauses mapped to behavior contracts
- Exit 0 on all pass, exit 1 on any failure

### Test template

```bash
#!/usr/bin/env bash
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="$(cd "$SCRIPT_DIR/.." && pwd)/scripts/<script-name>.sh"

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1 — $2"; FAIL=$((FAIL + 1)); }

echo "=== <script-name> Acceptance Tests ==="
echo "Script: $TARGET_SCRIPT"
echo ""

# --- AC1: <description> ---
output=$(bash "$TARGET_SCRIPT" <args> 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC1: exits 0 for valid input"
else
  fail "AC1: exit code" "expected 0, got $status"
fi

if echo "$output" | grep -q "<expected output>"; then
  pass "AC1: output contains expected text"
else
  fail "AC1: output" "missing expected text in output=$output"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
```

### Red/green discipline for scripts

1. **Red:** Write the test file first. Confirm it fails against the current (or empty) script. Each AC clause should fail individually.
2. **Green:** Write the script to satisfy each AC clause. Run the test after each clause is implemented — don't write the entire script before testing.
3. **Refactor:** After all ACs pass, clean up the script (DRY, extract helpers) without breaking tests.

### Test coverage expectations

| Script complexity | Minimum ACs | What to cover |
|-------------------|------------|---------------|
| Thin wrapper (1-2 branches) | 3-5 | Happy path, error path, edge case |
| Router/state machine | 10-15 | Every branch, every phase, tier transitions |
| Data processor | 5-10 | Valid input, invalid input, boundary values, empty input |

### Integration: tests in the behavioral-test.json

When authoring a skill that has scripts, at least one behavioral test should verify the script test suite passes:

```json
{
  "id": "beh-00N",
  "name": "script-tests-pass",
  "given": "The skill is fully authored",
  "when": "Script acceptance tests are run",
  "then": {
    "agent_behavior": [
      "All script test files in tests/ exit 0",
      "Each test file reports zero failures"
    ]
  }
}
```

## Writing style

- **Prefer imperative form.** "Route to references for detail," not "You should route to references."
- **Explain why.** "Keep body under 500 lines because the context window is the primary constraint — every line crowds out the actual task."
- **Avoid heavy-handed MUSTs.** If everything is MUST, nothing is important. Reserve for critical rules.
- **Use theory of mind.** Write for a smart agent that needs to know *what to do differently* from its default behavior. The default assumption is the agent already knows general best practices.
