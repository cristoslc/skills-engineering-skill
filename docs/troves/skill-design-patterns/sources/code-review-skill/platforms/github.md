# GitHub Platform

## Detection

Detect GitHub when `git remote get-url origin` contains:
- `github.com`
- `github:`

## Diff Acquisition

For GitHub, diffs are always acquired locally via `git diff`. No `gh pr diff` needed for fetching.

## Posting Reviews (Optional)

If the user explicitly asks to post the review to GitHub:

### Prerequisites
- `gh` CLI installed and authenticated (`gh auth status`)

### Posting Steps

1. **Post summary comment**:
   ```bash
   gh pr comment <PR_NUMBER> --body "Review summary here"
   ```

2. **Post inline review comments** (if specific lines):
   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/reviews \
     -X POST \
     -f body="Review summary" \
     -f event="COMMENT" \
     -f comments[0][path]=file/path \
     -f comments[0][line]=42 \
     -f comments[0][body]="Finding description"
   ```

### Important
- Only post if user explicitly asks. Default is local report only.
- The `gh` CLI must be authenticated.
