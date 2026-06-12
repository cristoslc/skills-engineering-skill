# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `assert_sh` field to behavioral, adversarial, and smoke test JSON templates for code-based pre-grading
- Step 2.5 (shell assertions) to eval phase — runs before LLM grader dispatch
- Track 0 (code-based assertions) to eval grading workflow
- `code_based` field to `.eval-results.json` format
- `--repeat N` flag to `generate.sh` for statistical evaluation
- `pass@k` and `pass^k` metrics in eval output when `--repeat > 1`
- `--tier` flag as alias for `--diff-scope`
- `suite-meta.json` template with capability/regression graduation state
- Graduation rules and lifecycle documentation in `references/eval/phase.md`
- Suite lifecycle check in eval phase output
- Input validation for `--repeat` flag (rejects non-numeric, negative, and zero values)
- Behavioral tests beh-011 through beh-013 (assert_sh, repeat-N, suite graduation)
- Adversarial tests adv-004 through adv-006 (assert_sh fabrication, assertion skipping, auto-graduation)
- Smoke tests smk-005 through smk-007 (template validation, suite-meta format, repeat validation)
- Script acceptance tests AC41 through AC50 (assert_sh, code_based, --repeat, suite-meta)

### Changed
- Improved `.eval-results.json` format to include `code_based` section
- Updated `references/improve/phase.md` to mention code_based failures and pass@k/pass^k
- Updated `SKILL.md` design principles to mention code-based pre-grading
- Annotated `docs/musings/enhancing-skills-eval.md` with criticmarkup corrections