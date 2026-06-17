# Plan 002: Add README structure, prerequisites, and installation

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: Read `README.md` and confirm plan 001 changes
> are present (no `formt`, heading is `## Arguments`). If plan 001 is not done,
> either complete it first or apply its fixes inline before proceeding.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: plans/001-fix-readme-typos-and-examples.md
- **Category**: docs
- **Planned at**: commit `no-commits`, 2026-06-17

## Why this matters

A new reader landing on this repo cannot answer three basic questions: what problem
does this solve, what do I need before running it, and how do I install it?
The README jumps straight to example output. Without prerequisites and installation,
the project is unusable even after the tool is implemented.

## Current state

`README.md` opens with:

```markdown
# compare

a simple benchmarking tool that compares output of time command wrapper for 2 different commands.

stores output on new lines in a file, loops n times.
```

Missing sections:
- Clear value proposition / when to use this tool
- Prerequisites (git, shell, `time`, writable repo)
- Installation (none documented; tool not in repo yet)
- Project status honesty (spec vs shipped tool)

The repo contains no `package.json`, `Cargo.toml`, `Makefile`, or script — installation
section must be honest about current state while leaving a placeholder pattern.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Verify sections | `rg -n '^## ' README.md` | lists all H2 headings |
| Check prerequisites | `rg 'Prerequisites|Installation|Requirements' README.md` | at least one match each for Prerequisites and Installation |

## Scope

**In scope**:
- `README.md` — add/restructure intro, prerequisites, installation, table of contents (if ≥6 sections)

**Out of scope**:
- Implementing the actual CLI
- Creating `package.json` or install scripts (note as TODO in README if absent)
- LICENSE, CONTRIBUTING files

## Git workflow

- Branch: `advisor/002-readme-structure`
- Commit message: `docs: add prerequisites and installation to README`
- Do NOT push unless instructed.

## Steps

### Step 1: Rewrite the opening description

Replace the two-sentence stub under `# compare` with a structured intro:

1. **One-line summary** — what it is (git-isolated command benchmarker using `/usr/bin/time` output).
2. **Problem statement** — why naive `time cmd1; time cmd2` comparisons are misleading (shared filesystem state, caches, uncommitted changes).
3. **Approach in one sentence** — isolates each command on its own git branch from a saved baseline.

Target length: 4–6 sentences total. Use sentence case for the summary line under the H1 (capitalize first word only, unless proper nouns).

**Verify**: `rg -n '^# compare' -A8 README.md` shows the new intro block.

### Step 2: Add `## Prerequisites` section

Insert after the intro, before example output. Document:

| Prerequisite | Why |
|--------------|-----|
| Git repository with a clean or commit-able working tree | tool creates commits and branches |
| POSIX shell | command execution |
| `time` (bash builtin or `/usr/bin/time`) | captures timing output |
| Write access to parent of `cwd` (for default log path `../tests/...`) | log file location |

Add a note: commands are passed as quoted strings and executed via the shell — only compare trusted commands.

**Verify**: `rg '^## Prerequisites' README.md` matches.

### Step 3: Add `## Installation` section

Because no implementation exists in the repo yet, use an honest two-part structure:

```markdown
## Installation

> **Status**: The CLI is not yet published in this repository. The sections below
> describe the intended installation paths.

### From source (planned)

\`\`\`bash
# TODO: update when install script or package manifest lands
git clone <repo-url>
cd compare
# e.g. cargo install --path .  OR  npm link  OR  ./install.sh
\`\`\`

### Verify installation (planned)

\`\`\`bash
compare --help
\`\`\`
```

Replace `<repo-url>` with a placeholder comment `<!-- set when repo is published -->` or leave as `<repo-url>` if unknown.

**Verify**: `rg '^## Installation' README.md` matches; section mentions current not-yet-implemented status.

### Step 4: Add optional table of contents

If the README has ≥6 `##` sections after edits, add a compact TOC after the intro:

```markdown
## Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- ...
```

**Verify**: `rg '^## Contents' README.md` matches OR section count <6 and TOC intentionally omitted.

## Test plan

Manual review checklist:

- [ ] A reader with zero context understands *why* they'd use `compare` vs raw `time`
- [ ] Prerequisites list every external dependency the workflow implies (git, shell, time, disk)
- [ ] Installation does not claim the tool is installable today without qualification

## Done criteria

- [ ] `README.md` contains `## Prerequisites` and `## Installation`
- [ ] Intro explains git-isolation rationale in plain language
- [ ] Installation section honestly states tool is not yet in repo (or documents real install if code landed)
- [ ] Section order: Title → Intro → Contents (optional) → Prerequisites → Installation → (existing sections)
- [ ] Only `README.md` modified
- [ ] `plans/README.md` status row for 002 updated to DONE

## STOP conditions

Stop and report if:

- An implementation (script, binary, package manifest) has landed in the repo — installation docs must reference the real path instead of "planned" placeholders.
- The README already has conflicting installation instructions from another contributor.

## Maintenance notes

- When the CLI is implemented, replace the "planned" installation block with real commands in a follow-up plan.
- Keep prerequisites in sync if the tool adds dependencies (e.g. Python, Node).