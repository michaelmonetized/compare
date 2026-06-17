# Plan 001: Fix README typos and broken examples

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat HEAD -- README.md` (or read
> `README.md` directly if no commits exist). Compare "Current state" excerpts
> against the live file before proceeding; on a mismatch, treat it as a STOP
> condition.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: docs
- **Planned at**: commit `no-commits`, 2026-06-17

## Why this matters

The README is the only artifact in this repository. Typos and a broken example
command (`formt` instead of `format`) signal carelessness and will cause users
to copy-paste failing commands. Fixing these is zero-risk, high-leverage, and
unblocks every other README improvement plan.

## Current state

- `README.md` — sole project file; describes a CLI benchmarking tool.

Known defects (verify line numbers may shift slightly):

```markdown
# Line 18 — typo in example command
compare "vp exec biome formt --fix" "vp exec oxlint --fix" -n 100

# Line 22 — misspelled heading
## Arguements

# Line 32 — typo in prose
beteween the 2 cases
```

Additional style inconsistency: some headings end with colons (`## Usage:`,
`## Example output file contents:`) while others do not (`## How it works`).

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Read file | `cat README.md` | file contents displayed |
| Verify typo gone | `rg -n 'formt|Arguements|beteween' README.md` | exit 1, no matches |
| Verify fix present | `rg -n 'format|Arguments|between' README.md` | matches in expected locations |

## Scope

**In scope**:
- `README.md` — typo fixes, example command correction, heading spelling

**Out of scope**:
- Adding new sections (plan 002)
- Expanding CLI docs (plan 003)
- Rewriting workflow prose (plan 004)
- Any source code or config files

## Git workflow

- Branch: `advisor/001-fix-readme-typos`
- Commit message: `docs: fix README typos and example command`
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Fix the example usage command

In `README.md`, in the Usage code block, change `biome formt` to `biome format`.

**Verify**: `rg 'formt' README.md` → no output (exit 1)

### Step 2: Fix heading and prose typos

- Change `## Arguements` to `## Arguments`
- Change `beteween` to `between` in the "How it works" section

**Verify**: `rg 'Arguements|beteween' README.md` → no output (exit 1)

### Step 3: Normalize heading punctuation (optional, in-scope)

Remove trailing colons from section headings for consistency:
- `## Example output file contents:` → `## Example output`
- `## Usage:` → `## Usage`
- Keep `## How it works` and `## Arguments` without colons

**Verify**: `rg '^## .+:$' README.md` → no output (exit 1)

## Test plan

No automated tests exist. Manual verification only:

- Read the Usage example aloud — both commands should be plausible lint/format invocations.
- Confirm no regressions: `rg -c 'compare' README.md` still returns ≥3 matches.

## Done criteria

- [ ] `rg 'formt|Arguements|beteween' README.md` returns no matches
- [ ] Usage example contains `biome format`
- [ ] Section heading reads `## Arguments`
- [ ] No section headings end with a trailing colon
- [ ] Only `README.md` modified (`git status` or file list check)
- [ ] `plans/README.md` status row for 001 updated to DONE

## STOP conditions

Stop and report back if:

- `README.md` content does not match the excerpts in "Current state" (file has drifted).
- Fixing typos reveals the example commands reference tools that should stay as-is for a reason (e.g. intentional `formt` alias).

## Maintenance notes

- Re-run the `rg` verification after any future README edit to prevent typo regression.
- Plan 002/003 will add content; do not duplicate their scope here.