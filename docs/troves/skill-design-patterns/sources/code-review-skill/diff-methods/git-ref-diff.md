# Git Ref Diff Method

## Purpose

Review changes between two git refs using `git diff`.

## Argument Resolution

The SKILL.md orchestration layer resolves user arguments to actual refs:

| User Input | Resolved Refs |
|------------|--------------|
| (no args) + staged changes | `--cached` |
| (no args) + no staged changes | `main...HEAD` or `trunk...HEAD` |
| `staged` | `--cached` |
| `unstaged` | (working tree changes) |
| `REF` | `REF...HEAD` |
| `REF1 REF2` | `REF1...REF2` |
| `REF1...REF2` | `REF1...REF2` |

## Diff Acquisition Commands

### Staged changes
```bash
git diff --cached
```

### Unstaged changes
```bash
git diff
```

### Two refs
```bash
git diff REF1...REF2
```

### Check if staged changes exist
```bash
git diff --cached --quiet
# Exit code 0 = no staged changes
# Exit code 1 = staged changes exist
```

### Detect default trunk branch
```bash
# Check for main first, then trunk, then master
git rev-parse --verify main 2>/dev/null || \
git rev-parse --verify trunk 2>/dev/null || \
git rev-parse --verify master 2>/dev/null
```

## Diff Size Check

Before sending to agents, check diff size:

```bash
wc -l /tmp/codereview_diff.txt
```

If > 3000 lines:
1. Split into chunks of ~2500 lines
2. Run each agent on each chunk
3. Merge findings before synthesis

## Chunking Command

```bash
split -l 2500 /tmp/codereview_diff.txt /tmp/codereview_chunk_
```

## Output

The diff content should be read via the Read tool (not Bash) to enter agent context.
