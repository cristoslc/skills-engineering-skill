# Local Platform

## Detection

Detect local when:
- No git remote exists (`git remote` returns empty)
- Remote URL does not match any known forge patterns

## Diff Acquisition

For local-only repos, diffs are acquired via `git diff` commands.

## Posting Reviews

No posting available for local-only mode. Reviews are always written to local files only.

Report location: `~/Downloads/code-review-{timestamp}.md`
