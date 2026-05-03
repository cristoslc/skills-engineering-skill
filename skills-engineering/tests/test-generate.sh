#!/usr/bin/env bash
# test-generate.sh — Acceptance tests for skills-engineering generate.sh (v0.2 — 9 phases)
#
# Usage: bash skills-engineering/tests/test-generate.sh

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATE_SCRIPT="$(cd "$SCRIPT_DIR/.." && pwd)/scripts/generate.sh"
TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1 — $2"; FAIL=$((FAIL + 1)); }

echo "=== generate.sh Acceptance Tests (v0.2 — 9 phases) ==="
echo "Script: $GENERATE_SCRIPT"
echo ""

# ---- Argument validation ----

echo "--- AC1: Missing --phase exits 1 with error ---"
output=$(bash "$GENERATE_SCRIPT" --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 1 ]]; then
  pass "AC1: exit 1 for missing --phase"
else
  fail "AC1: exit code" "expected 1, got $status"
fi
if echo "$output" | grep -q "phase is required"; then
  pass "AC1: error message mentions phase is required"
else
  fail "AC1: error message" "output=$output"
fi

echo ""
echo "--- AC2: Missing --skill-path exits 1 with error ---"
output=$(bash "$GENERATE_SCRIPT" --phase spec 2>&1)
status=$?
if [[ $status -eq 1 ]]; then
  pass "AC2: exit 1 for missing --skill-path"
else
  fail "AC2: exit code" "expected 1, got $status"
fi
if echo "$output" | grep -q "skill-path is required"; then
  pass "AC2: error message mentions skill-path is required"
else
  fail "AC2: error message" "output=$output"
fi

echo ""
echo "--- AC3: Unknown phase exits 1 and lists valid phases ---"
output=$(bash "$GENERATE_SCRIPT" --phase bogus --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 1 ]]; then
  pass "AC3: exit 1 for unknown phase"
else
  fail "AC3: exit code" "expected 1, got $status"
fi
for p in spec behavioral script-test script skill adversary eval improve refactor; do
  if echo "$output" | grep -q "$p"; then
    pass "AC3: valid phase '$p' listed in error"
  else
    fail "AC3: missing phase" "'$p' not in error output=$output"
  fi
done

# ---- Phase 1: spec ----

echo ""
echo "--- AC4: spec phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase spec --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC4: spec exits 0"
else
  fail "AC4: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Spec Phase"; then
  pass "AC4: spec heading present"
else
  fail "AC4: heading" "output=$output"
fi

echo ""
echo "--- AC5: spec phase references spec.md and next phase ---"
if echo "$output" | grep -q "spec.md"; then
  pass "AC5: references spec.md"
else
  fail "AC5: spec.md" "output=$output"
fi
if echo "$output" | grep -q "phase behavioral"; then
  pass "AC5: next phase is behavioral"
else
  fail "AC5: next phase" "output=$output"
fi

# ---- Phase 2: behavioral ----

echo ""
echo "--- AC6: behavioral phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase behavioral --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC6: behavioral exits 0"
else
  fail "AC6: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Behavioral Phase"; then
  pass "AC6: behavioral heading present"
else
  fail "AC6: heading" "output=$output"
fi

echo ""
echo "--- AC7: behavioral phase describes BDD contract format ---"
if echo "$output" | grep -q "behavioral-tests.json"; then
  pass "AC7: references behavioral-tests.json"
else
  fail "AC7: behavioral-tests.json" "output=$output"
fi
if echo "$output" | grep -q '"given"'; then
  pass "AC7: given/when/then contract described"
else
  fail "AC7: contract" "output=$output"
fi
if echo "$output" | grep -q "phase script-test"; then
  pass "AC7: next phase is script-test"
else
  fail "AC7: next phase" "output=$output"
fi

echo ""
echo "--- AC8: behavioral phase describes red state ---"
if echo "$output" | grep -q "SKILL.md doesn't exist"; then
  pass "AC8: red state described (no SKILL.md)"
else
  fail "AC8: red state" "output=$output"
fi

# ---- Phase 3: script-test ----

echo ""
echo "--- AC9: script-test phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase script-test --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC9: script-test exits 0"
else
  fail "AC9: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Script-Test Phase"; then
  pass "AC9: script-test heading present"
else
  fail "AC9: heading" "output=$output"
fi

echo ""
echo "--- AC10: script-test phase includes test template and coverage table ---"
if echo "$output" | grep -q "test-<script>.sh"; then
  pass "AC10: references test file naming convention"
else
  fail "AC10: test file" "output=$output"
fi
if echo "$output" | grep -q 'set +e'; then
  pass "AC10: test template includes set +e"
else
  fail "AC10: template" "output=$output"
fi
if echo "$output" | grep -qi "coverage expectations"; then
  pass "AC10: coverage table present"
else
  fail "AC10: coverage" "output=$output"
fi
if echo "$output" | grep -q "phase script "; then
  pass "AC10: next phase is script"
else
  fail "AC10: next phase" "output=$output"
fi

echo ""
echo "--- AC11: script-test phase describes red state (script missing) ---"
if echo "$output" | grep -q "script doesn't exist"; then
  pass "AC11: red state described (script missing)"
else
  fail "AC11: red state" "output=$output"
fi

# ---- Phase 4: script ----

echo ""
echo "--- AC12: script phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase script --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC12: script exits 0"
else
  fail "AC12: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Script Phase"; then
  pass "AC12: script heading present"
else
  fail "AC12: heading" "output=$output"
fi

echo ""
echo "--- AC13: script phase enforces AC-by-AC discipline ---"
if echo "$output" | grep -q "Do NOT write the entire script at once"; then
  pass "AC13: AC-by-AC instruction present"
else
  fail "AC13: AC-by-AC" "output=$output"
fi
if echo "$output" | grep -q "failing AC → minimal code → retest → green"; then
  pass "AC13: red-green cycle described"
else
  fail "AC13: red-green" "output=$output"
fi
if echo "$output" | grep -q "phase skill"; then
  pass "AC13: next phase is skill"
else
  fail "AC13: next phase" "output=$output"
fi

echo ""
echo "--- AC14: script phase instructs running all tests after scripts done ---"
if echo "$output" | grep -q "for t in.*test-\*\.sh"; then
  pass "AC14: run-all instruction present"
else
  fail "AC14: run-all" "output=$output"
fi

# ---- Phase 5: skill ----

echo ""
echo "--- AC15: skill phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase skill --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC15: skill exits 0"
else
  fail "AC15: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Skill Phase"; then
  pass "AC15: skill heading present"
else
  fail "AC15: heading" "output=$output"
fi

echo ""
echo "--- AC16: skill phase requires reading behavioral tests as contracts ---"
if echo "$output" | grep -q "behavioral-tests.json"; then
  pass "AC16: references behavioral-tests.json as contracts"
else
  fail "AC16: contracts" "output=$output"
fi

echo ""
echo "--- AC17: skill phase prohibits reading eval references ---"
if echo "$output" | grep -q "Do NOT read eval references"; then
  pass "AC17: eval prohibition present"
else
  fail "AC17: eval prohibition" "output=$output"
fi
if echo "$output" | grep -q "phase adversary"; then
  pass "AC17: next phase is adversary"
else
  fail "AC17: next phase" "output=$output"
fi

# ---- Phase 6: adversary ----

echo ""
echo "--- AC18: adversary phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase adversary --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC18: adversary exits 0"
else
  fail "AC18: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Adversary Phase"; then
  pass "AC18: adversary heading present"
else
  fail "AC18: heading" "output=$output"
fi

echo ""
echo "--- AC19: adversary phase instructs studying the target ---"
if echo "$output" | grep -q "Study the target"; then
  pass "AC19: study target instruction present"
else
  fail "AC19: study" "output=$output"
fi
if echo "$output" | grep -q "must_not"; then
  pass "AC19: must_not clause format present"
else
  fail "AC19: must_not" "output=$output"
fi
if echo "$output" | grep -q "must"; then
  pass "AC19: must clause format present"
else
  fail "AC19: must" "output=$output"
fi
if echo "$output" | grep -q "phase eval"; then
  pass "AC19: next phase is eval"
else
  fail "AC19: next phase" "output=$output"
fi

echo ""
echo "--- AC20: adversary phase lists attack vectors ---"
for vector in "File writes outside boundary" "Cross-skill invocation" "Scope creep" "Boundary edge cases"; do
  if echo "$output" | grep -q "$vector"; then
    pass "AC20: attack vector '$vector' present"
  else
    fail "AC20: attack vector" "'$vector' not found"
  fi
done

# ---- Phase 7: eval ----

echo ""
echo "--- AC21: eval phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase eval --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC21: eval exits 0"
else
  fail "AC21: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Eval Phase"; then
  pass "AC21: eval heading present"
else
  fail "AC21: heading" "output=$output"
fi

echo ""
echo "--- AC22: eval phase runs script tests first (deterministic gate) ---"
if echo "$output" | grep -q "Run script acceptance tests"; then
  pass "AC22: script tests run first"
else
  fail "AC22: script tests first" "output=$output"
fi
if echo "$output" | grep -q "Do not proceed"; then
  pass "AC22: gate: do not proceed if script tests fail"
else
  fail "AC22: gate" "output=$output"
fi

echo ""
echo "--- AC23: eval phase runs behavioral tests via subagents ---"
if echo "$output" | grep -q "Run agent behavioral tests"; then
  pass "AC23: agent behavioral step present"
else
  fail "AC23: behavioral" "output=$output"
fi
if echo "$output" | grep -q "separate subagent"; then
  pass "AC23: specialist topology for behavioral tests"
else
  fail "AC23: subagent" "output=$output"
fi

echo ""
echo "--- AC24: eval phase (behavioral tier) skips adversarial, runs behavioral ---"
output=$(bash "$GENERATE_SCRIPT" --phase eval --skill-path /tmp/fake --diff-scope behavioral 2>&1)
if echo "$output" | grep -q "Run agent behavioral tests"; then
  pass "AC24: agent behavioral step present in behavioral tier"
else
  fail "AC24: behavioral" "output=$output"
fi
if echo "$output" | grep -q "Skip adversarial tests"; then
  pass "AC24: adversarial tests explicitly skipped in behavioral tier"
else
  fail "AC24: adversarial skip" "output=$output"
fi

echo ""
echo "--- AC25: eval phase includes two-track grading ---"
if echo "$output" | grep -q "Track A"; then
  pass "AC25: Track A present"
else
  fail "AC25: Track A" "output=$output"
fi
if echo "$output" | grep -q "Track B"; then
  pass "AC25: Track B present"
else
  fail "AC25: Track B" "output=$output"
fi

echo ""
echo "--- AC26: eval phase references .eval-results.json with full structure ---"
if echo "$output" | grep -q "script_tests"; then
  pass "AC26: script_tests in results structure"
else
  fail "AC26: script_tests" "output=$output"
fi
if echo "$output" | grep -q "adversarial_tests"; then
  pass "AC26: adversarial_tests in results structure"
else
  fail "AC26: adversarial_tests" "output=$output"
fi

# ---- Phase 8: improve ----

echo ""
echo "--- AC27: improve phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase improve --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC27: improve exits 0"
else
  fail "AC27: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Improve Phase"; then
  pass "AC27: improve heading present"
else
  fail "AC27: heading" "output=$output"
fi

echo ""
echo "--- AC28: improve phase references .eval-results.json and generalization ---"
if echo "$output" | grep -q ".eval-results.json"; then
  pass "AC28: references .eval-results.json"
else
  fail "AC28: eval results" "output=$output"
fi
if echo "$output" | grep -q "Generalize from feedback"; then
  pass "AC28: generalization instruction present"
else
  fail "AC28: generalization" "output=$output"
fi

# ---- Phase 9: refactor ----

echo ""
echo "--- AC29: refactor phase outputs heading and exits 0 ---"
output=$(bash "$GENERATE_SCRIPT" --phase refactor --skill-path /tmp/fake 2>&1)
status=$?
if [[ $status -eq 0 ]]; then
  pass "AC29: refactor exits 0"
else
  fail "AC29: exit code" "expected 0, got $status"
fi
if echo "$output" | grep -q "Refactor Phase"; then
  pass "AC29: refactor heading present"
else
  fail "AC29: heading" "output=$output"
fi

echo ""
echo "--- AC30: refactor phase prohibits changing behavior ---"
if echo "$output" | grep -q "Don't change what the skill does"; then
  pass "AC30: no-behavior-change rule present"
else
  fail "AC30: no-change" "output=$output"
fi
if echo "$output" | grep -q "Re-run the full eval after every change"; then
  pass "AC30: eval re-run instruction present"
else
  fail "AC30: re-run" "output=$output"
fi

# ---- Integration: full 9-phase pipeline ----

echo ""
echo "--- AC31: full pipeline all 9 phases exit 0 ---"
failures=0
for p in spec behavioral script-test script skill adversary eval improve refactor; do
  bash "$GENERATE_SCRIPT" --phase "$p" --skill-path /tmp/fake-all > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    pass "AC31: phase '$p' exits 0"
  else
    fail "AC31: phase '$p'" "non-zero exit"
    failures=$((failures + 1))
  fi
done
if [[ $failures -eq 0 ]]; then
  pass "AC31: all 9 phases pass"
fi

# ---- Phase sequencing correctness ----

echo ""
echo "--- AC32: phase sequence is spec→behavioral→script-test→script→skill→adversary→eval ---"
check_next() {
  local phase="$1" expected="$2"
  output=$(bash "$GENERATE_SCRIPT" --phase "$phase" --skill-path /tmp/fake 2>&1)
  if echo "$output" | grep -q "phase $expected "; then
    pass "AC32: $phase → $expected"
  else
    fail "AC32: $phase next" "expected $expected, output=$output"
  fi
}
check_next spec behavioral
check_next behavioral script-test
check_next script-test script
check_next script skill
check_next skill adversary
check_next adversary eval
check_next eval improve
check_next improve eval

# ---- Phase isolation ----

echo ""
echo "--- AC33: authoring phases (spec/behavioral/script-test/script) do not mention eval reference files ---"

for p in spec behavioral script-test script; do
  output=$(bash "$GENERATE_SCRIPT" --phase "$p" --skill-path /tmp/fake 2>&1)
  if echo "$output" | grep -q "eval/phase.md"; then
    fail "AC33: '$p' leaks eval/phase.md references"
  else
    pass "AC33: '$p' does not mention eval/phase.md"
  fi
done

echo "--- AC33b: skill phase mentions eval/phase.md ONLY as a prohibition ---"
output=$(bash "$GENERATE_SCRIPT" --phase skill --skill-path /tmp/fake 2>&1)
if echo "$output" | grep -q "Do NOT read.*eval" || echo "$output" | grep -q "Do NOT read.*improve"; then
  pass "AC33b: skill phase warns against eval references (not a leak)"
else
  fail "AC33b: skill phase" "missing eval prohibition"
fi

echo ""
echo "--- AC34: eval phase does not mention author/phase.md ---"
output=$(bash "$GENERATE_SCRIPT" --phase eval --skill-path /tmp/fake 2>&1)
if echo "$output" | grep -q "author/phase.md"; then
  fail "AC34: eval leaks author references"
else
  pass "AC34: eval does not mention author/phase.md"
fi

# ---- Tier detection ----

echo ""
echo "--- AC35: --diff-scope smoke → smoke tier, smoke-tests.json referenced ---"
output=$(bash "$GENERATE_SCRIPT" --phase eval --skill-path /tmp/fake --diff-scope smoke 2>&1)
if echo "$output" | grep -q 'Tier.*smoke'; then
  pass "AC35: smoke tier emitted"
else
  fail "AC35: smoke tier" "output=$output"
fi
if echo "$output" | grep -q "smoke-tests.json"; then
  pass "AC35: smoke-tests.json referenced in smoke tier eval"
else
  fail "AC35: smoke-tests.json" "not referenced in output"
fi
if echo "$output" | grep -q "are NOT run"; then
  pass "AC35: behavioral/adversarial explicitly skipped"
else
  fail "AC35: skip instruction" "output=$output"
fi

echo ""
echo "--- AC36: --diff-scope full → full tier, both test files ---"
output=$(bash "$GENERATE_SCRIPT" --phase eval --skill-path /tmp/fake --diff-scope full 2>&1)
if echo "$output" | grep -q 'Tier:.*full'; then
  pass "AC36: full tier emitted"
else
  fail "AC36: full tier" "output=$output"
fi
if echo "$output" | grep -q "behavioral-tests.json" && echo "$output" | grep -q "adversarial-tests.json"; then
  pass "AC36: both test files referenced in full tier"
else
  fail "AC36: both files" "output=$output"
fi

echo ""
echo "--- AC37: --diff-scope unknown → falls back to behavioral ---"
output=$(bash "$GENERATE_SCRIPT" --phase eval --skill-path /tmp/fake --diff-scope unknown 2>&1)
if echo "$output" | grep -q 'Tier:.*behavioral'; then
  pass "AC37: unknown scope falls back to behavioral"
else
  fail "AC37: fallback" "output=$output"
fi

# ---- Edge cases ----

echo ""
echo "--- AC38: output has no ANSI escape sequences ---"
output=$(bash "$GENERATE_SCRIPT" --phase spec --skill-path /tmp/fake 2>&1)
if echo "$output" | grep -qv $'\e'; then
  pass "AC38: no ANSI escape sequences"
else
  fail "AC38: escapes" "output contains ANSI codes"
fi

echo ""
echo "--- AC39: unknown flags are silently ignored ---"
bash "$GENERATE_SCRIPT" --phase spec --skill-path /tmp/fake --bogus-flag > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
  pass "AC39: unknown flags don't cause errors"
else
  fail "AC39: unknown flag" "non-zero exit"
fi

echo ""
echo "--- AC40: skill name is extracted from skill-path basename ---"
output=$(bash "$GENERATE_SCRIPT" --phase spec --skill-path /tmp/my-custom-skill 2>&1)
if echo "$output" | grep -q "my-custom-skill"; then
  pass "AC40: skill name extracted correctly"
else
  fail "AC40: skill name" "output=$output"
fi

# ---- Summary ----

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
