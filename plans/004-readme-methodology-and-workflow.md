# Plan 004: Expand methodology and git-isolation workflow

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: Confirm plans 001 and 003 are reflected in
> `README.md` (CLI reference and output format sections exist).

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: LOW
- **Depends on**: plans/003-readme-cli-reference-and-output.md
- **Category**: docs
- **Planned at**: commit `no-commits`, 2026-06-17

## Why this matters

The single most valuable idea in the README is buried in one vague sentence:
benchmarks are only meaningful when exactly one variable differs between cases.
The git branch workflow is the tool's differentiator but is described in one
paragraph with no sequence diagram, cleanup behavior, or limitations. Expanding
this section turns the README from a stub into credible methodology documentation.

## Current state

```markdown
## How it works

Tests only really matter if the variables are limited to a single difference between the 2 cases.

This creates a commit on the current branch to save the state, checks out a new branch for each case off the original working branch, then in each case branch (named after the command) runs each command $n times recording results in an aptly named comparison log file outside the cwd.
```

Missing:
- Step-by-step workflow (before / during / after)
- Branch naming convention
- What happens to the snapshot commit and case branches afterward
- Warnings (dirty tree, commands that modify tracked files, long-running commands)
- Limitations (does not control CPU governor, thermal throttling, etc.)
- How to analyze results (even a one-liner: compare `total` column)

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Section exists | `rg '^## (How it works|Methodology|Workflow)' README.md` | at least one match |
| Limitations | `rg -i 'limitation|cleanup|caveat' README.md` | ≥1 match |

## Scope

**In scope**:
- `README.md` — expand/rename "How it works", add limitations, optional mermaid diagram

**Out of scope**:
- Implementing git operations in code
- Adding analysis scripts or spreadsheet templates
- CI integration docs

## Git workflow

- Branch: `advisor/004-readme-methodology`
- Commit message: `docs: expand benchmark methodology and git workflow`
- Do NOT push unless instructed.

## Steps

### Step 1: Rename and restructure as `## How it works`

Split into subsections:

```markdown
## How it works

### Methodology: change one variable

Meaningful A/B benchmarks require isolating a single difference between case A
and case B. If case A runs on a warm cache and case B on a cold disk, you are
measuring cache state — not the tools. This tool reduces git working-tree drift
by giving each command its own branch from a shared baseline commit.

### Workflow

1. **Snapshot** — commit (or stash — document actual behavior when code exists)
   current branch state so both cases start identical.
2. **Branch per case** — create `compare/<slug-a>` and `compare/<slug-b>` from
   that snapshot (adjust naming to match implementation).
3. **Execute** — on each branch, `cd` into `--cwd` and run the command `-n` times,
   appending `time` output to the log file (see [Output format](#output-format)).
4. **Restore** — return to the original branch; document whether case branches
   and snapshot commit are kept, deleted, or left for inspection.

### Workflow diagram

\`\`\`mermaid
sequenceDiagram
    participant User
    participant compare
    participant Git
    participant Log

    User->>compare: compare "cmd A" "cmd B" -n N
    compare->>Git: snapshot working tree
    compare->>Git: create branch for A
    compare->>Git: checkout branch A
    loop N times
        compare->>Log: append time output for A
    end
    compare->>Git: create branch for B
    compare->>Git: checkout branch B
    loop N times
        compare->>Log: append time output for B
    end
    compare->>Git: restore original branch
    compare->>User: log path
\`\`\`
```

**Verify**: `rg '^### Methodology' README.md` and `rg '^### Workflow' README.md` match.

### Step 2: Add `### Limitations and caveats`

Include at minimum:

- Does not pin CPU frequency or isolate cores — OS scheduling noise remains.
- Commands that mutate the repo may diverge branches before timing starts; prefer read-only or idempotent commands for fair comparison.
- Requires user judgment to ensure only one intentional variable differs (tool enforces git isolation, not semantic equivalence).
- Default log path is outside `cwd` — confirm parent `tests/` directory exists or document auto-create behavior as TODO until code exists.

**Verify**: `rg '^### Limitations' README.md` matches.

### Step 3: Add brief `### Analyzing results`

One short paragraph:

- Sort or filter log lines by command prefix.
- Compare the `total` (elapsed) column for wall-clock time; use `%cpu` for CPU utilization differences.
- For `-n > 1`, recommend reporting median or p95 rather than a single run (manual for now).

**Verify**: `rg '^### Analyzing' README.md` matches.

## Test plan

Manual review:

- [ ] Reader understands *why* git branches are used
- [ ] Reader knows what state git is left in after a run (or where to find TODO)
- [ ] Mermaid diagram renders on GitHub (basic syntax only)

## Done criteria

- [ ] `## How it works` has Methodology, Workflow, Limitations, and Analyzing subsections
- [ ] Mermaid sequence diagram present
- [ ] Original one-paragraph content replaced, not duplicated
- [ ] Only `README.md` modified
- [ ] `plans/README.md` status row for 004 updated to DONE

## STOP conditions

Stop and report if:

- Implementation uses a different workflow (e.g. worktrees instead of branches, no snapshot commit) — document actual behavior.
- Mermaid is undesirable for this repo — replace with ASCII diagram in same step and note in report.

## Maintenance notes

- Reconcile branch naming and cleanup with implementation when code lands; add a "Git state after run" table.
- Future plan could add a small `scripts/summarize-log.sh` — out of scope here.