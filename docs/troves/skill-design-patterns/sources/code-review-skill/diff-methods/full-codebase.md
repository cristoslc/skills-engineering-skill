# Full Codebase Review Method

## Purpose

Review the entire codebase (or a subset) without requiring a git diff. Agents receive complete file contents instead of change hunks. Use this when the user asks for a general review, health check, or audit of the codebase rather than reviewing specific changes.

## When to Use This Method

The orchestrator should select `full-codebase` as the `diff_method` when:

- The user says "review the codebase" or "review this project" (no refs mentioned).
- The user provides a directory path or glob pattern instead of git refs.
- The `--full` flag is passed.
- There are no git refs to diff (e.g., fresh repo with no commits).

## Argument Resolution

| User Input | Resolution |
|------------|------------|
| `--full` | Review all tracked source files. |
| `--full src/` | Review files under `src/` only. |
| `--full "**/*.py"` | Review files matching the glob. |
| `--full --agents security` | Full review with only security agent. |
| `--full --dispatch segment` | Full review using segment-dispatch mode. |
| (no refs, no staged changes) | Fall back to full-codebase automatically. |

## Dispatch Modes

Two dispatch strategies trade off between file IO, parallelism, and specialization isolation. Both guarantee that every line of code is reviewed under every active specialization.

### `specialist` (default)

One subagent per specialization (security, style, logic, docs). Each subagent receives all segments and reviews them under its single lens.

- Parallelism: 4 concurrent subagents (assuming 4 specializations).
- File IO: each file is read 4 times (once per subagent).
- Specialization isolation: strong — each lens has its own dedicated context.

### `segment`

One subagent per code segment. Each subagent calls `generate.sh --phase segment-review` to get a merged prompt containing all specialization rubrics, then walks through each lens sequentially on its assigned segment.

- Parallelism: N concurrent subagents (one per segment).
- File IO: each file is read once (by the single subagent that owns its segment).
- Specialization isolation: weaker — lenses share context within one agent, which may cause cross-pollination or anchoring bias.
- Subagent prompt: obtained by calling `generate.sh --phase segment-review` with `segment_id` in the payload.

## File Discovery

### All tracked source files

```bash
git ls-files
```

### Files under a specific path

```bash
git ls-files -- <path>
```

### Files matching a glob

```bash
git ls-files -- <glob-pattern>
```

### Exclude non-source files

Filter out binary, generated, and dependency files. Apply these exclusion rules:

1. Skip directories: `node_modules/`, `vendor/`, `.venv/`, `__pycache__/`, `dist/`, `build/`, `target/`, `.git/`.
2. Skip generated files: `*.lock`, `*.min.js`, `*.min.css`, `*.bundle.js`, `package-lock.json`, `yarn.lock`, `go.sum`, `Cargo.lock`.
3. Skip binary files: `*.png`, `*.jpg`, `*.gif`, `*.ico`, `*.woff`, `*.ttf`, `*.eot`, `*.pdf`, `*.zip`, `*.tar.gz`.
4. Skip large data files: `*.csv`, `*.json` (unless clearly source), `*.sql`, `*.db`.

### Build the file list

```bash
git ls-files | grep -v -E '(node_modules/|vendor/|\.venv/|__pycache__/|dist/|build/|target/|\.lock$|\.min\.|package-lock|yarn\.lock|go\.sum|Cargo\.lock|\.png$|\.jpg$|\.gif$|\.ico$|\.woff|\.ttf|\.eot|\.pdf$|\.zip$|\.tar\.gz$|\.csv$|\.db$)' > /tmp/codereview_file_list.txt
wc -l /tmp/codereview_file_list.txt
```

## Segmentation

Full codebase reviews split files into segments to fit within context thresholds.

### Size Check

```bash
FILE_COUNT=$(wc -l < /tmp/codereview_file_list.txt)
TOTAL_LINES=$(xargs wc -l < /tmp/codereview_file_list.txt | tail -1 | awk '{print $1}')
```

### Decision rules

- **< 3000 total lines**: One segment. No splitting needed.
- **3000–10000 total lines**: Split into segments of ~2500 lines each.
- **> 10000 total lines**: Sample-based review. Select the most important files:
  1. Entry points (`main.*`, `index.*`, `app.*`, `mod.*`).
  2. Files with the most recent changes (`git log --format="" --name-only -20 | sort | uniq -c | sort -rn | head -20`).
  3. Configuration and security-adjacent files.
  Warn the user that the codebase exceeds review capacity and only a sample will be reviewed.

### How dispatch modes use segments

| | specialist | segment |
|---|---|---|
| Subagent count | 4 (one per lens) | N (one per segment) |
| Each subagent sees | all segments | one segment |
| Each subagent applies | one lens | all lenses sequentially |
| Total review passes | 4 × N segments | 1 × N segments |
| Files read per subagent | all files | one segment's files |

**Both modes guarantee every line is reviewed under every specialization.** The difference is how that work is partitioned across subagents.

### Build segments

```bash
# Split file list into segments of ~2500 total lines
awk 'BEGIN{lines=0; seg=0} {print > sprintf("/tmp/codereview_segment_%03d.txt", seg); lines+=$1; if(lines>=2500){lines=0; seg+=1}}' /tmp/codereview_file_list.txt
```

Each segment file contains a list of file paths.

## File Content Acquisition

For each file in the list, read via the Read tool (not Bash) so content enters context directly:

```
Read each file from /tmp/codereview_file_list.txt
```

## Adapted Agent Instructions

When using `full-codebase`, prefix each agent dispatch with this note:

> You are reviewing complete source files, not a diff. Report issues found anywhere in the provided files. Focus on the most impactful problems — do not exhaustively list minor style issues across the entire codebase. Prioritize correctness and security over style in a full-review context.

## Output

File contents are read via the Read tool (not Bash) to enter agent context. The file list is stored at `/tmp/codereview_file_list.txt`. Segment file lists are stored at `/tmp/codereview_segment_###.txt`.