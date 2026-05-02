# Forgejo Platform

## Detection

Detect Forgejo when `git remote get-url origin` contains:
- `forgejo`
- `gitea`
- `codeberg` (runs Forgejo)
- Port `:3000` (common Forgejo default)

## Diff Acquisition

For Forgejo, diffs are always acquired locally via `git diff`. No Forgejo API calls needed for fetching.

## Posting Reviews (Optional)

If the user explicitly asks to post the review to Forgejo:

### Prerequisites
- `FORGEJO_TOKEN` environment variable set with API token
- Token must have `repo` scope

### Posting Steps

1. **Get the PR number** from context or ask user.

2. **Post review summary**:
   ```bash
   curl -X POST \
     -H "Authorization: token $FORGEJO_TOKEN" \
     -H "Content-Type: application/json" \
     "https://forgejo.example.com/api/v1/repos/{owner}/{repo}/pulls/{index}/reviews" \
     -d '{
       "body": "Review summary here",
       "event": "COMMENT" | "APPROVE" | "REQUEST_CHANGES"
     }'
   ```

3. **Post individual comments** (if findings have specific lines):
   ```bash
   curl -X POST \
     -H "Authorization: token $FORGEJO_TOKEN" \
     -H "Content-Type: application/json" \
     "https://forgejo.example.com/api/v1/repos/{owner}/{repo}/pulls/{index}/reviews/{id}/comments" \
     -d '{
       "body": "Finding description",
       "path": "file/path",
       "line": 42
     }'
   ```

### Important
- Only post if user explicitly asks. Default is local report only.
- Never log the token.
- Respect rate limits (Forgejo may be self-hosted with lower limits).
