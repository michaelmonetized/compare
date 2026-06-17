# Plan 003: Document complete CLI reference and output format

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: Confirm plan 001 is applied. Read current
> `README.md` Arguments section before editing.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: LOW
- **Depends on**: plans/001-fix-readme-typos-and-examples.md
- **Category**: docs
- **Planned at**: commit `no-commits`, 2026-06-17

## Why this matters

The current CLI documentation is a single usage line and three bullet flags.
Critical gaps: positional argument order vs flags, meaning of template variables
in the default output path, what `vp exec` refers to, and how to read the `time`
output lines. Users cannot run the tool correctly from the README alone.

## Current state

Arguments section (`README.md`):

```markdown
## Arguments

compare first second [cwd] [flags...]

-n, --number The number of iterations
-c, --cwd The command working directory
-o, --output path to output dir/filename default is ../tests/compare-$cwd-$c1-$c2-$endtime.log
```

Problems:
1. `cwd` appears both as positional `[cwd]` and as `-c, --cwd` — relationship unclear.
2. Template variables `$cwd`, `$c1`, `$c2`, `$endtime` are undefined.
3. `vp exec` in examples is unexplained project-specific wrapper jargon.
4. Example output is labeled `bash` but is sample log content, not a shell script.
5. No `--help` mention; no exit codes; no description of what gets recorded per iteration.

Example output:

```bash
vp exec biome lint --fix  1.36s user 0.36s system 151% cpu 1.134 total
vp exec oxlint --fix  0.21s user 0.18s system 73% cpu 0.528 total

```

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Section check | `rg '^## (Usage|Arguments|Output)' README.md` | all three headings exist |
| Template vars documented | `rg '\$cwd|\$c1|\$c2|\$endtime' README.md` | vars appear in a definition table, not only in default path |

## Scope

**In scope**:
- `README.md` — rewrite Usage, Arguments → CLI Reference, add Output format section

**Out of scope**:
- Implementing CLI parsing
- Changing actual default path behavior in code
- Expanding git workflow (plan 004)

## Git workflow

- Branch: `advisor/003-readme-cli-reference`
- Commit message: `docs: expand CLI reference and output format`
- Do NOT push unless instructed.

## Steps

### Step 1: Replace `## Arguments` with `## CLI reference`

Use a structured reference. Suggested content (adapt if implementation differs when code lands):

```markdown
## CLI reference

\`\`\`
compare <command-a> <command-b> [options]
\`\`\`

### Positional arguments

| Argument | Description |
|----------|-------------|
| `command-a` | Shell command for case A (quote if it contains spaces or flags). |
| `command-b` | Shell command for case B. |

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `-n`, `--number <N>` | Run each command N times per branch. | `1` (confirm or document actual default when code exists) |
| `-c`, `--cwd <path>` | Working directory for both commands. | current directory |
| `-o`, `--output <path>` | Log file path. See [Output file naming](#output-file-naming). | see below |

### Output file naming

When `-o` is omitted, the log is written to:

\`\`\`
../tests/compare-<cwd>-<c1>-<c2>-<endtime>.log
\`\`\`

| Token | Meaning |
|-------|---------|
| `<cwd>` | Sanitized basename or slug of the working directory |
| `<c1>` | Short slug derived from command A (e.g. `biome-lint`) |
| `<c2>` | Short slug derived from command B (e.g. `oxlint`) |
| `<endtime>` | Timestamp when the run completed (e.g. `20260617T143022Z`) |

> **Note**: If positional `[cwd]` syntax from an earlier draft conflicts with `-c`,
> document only the flag-based form and remove ambiguous positional `cwd` unless
> the implementation supports it.
```

Resolve the positional `[cwd]` vs `-c` conflict: **prefer documenting `-c` only** unless source code proves positional cwd exists (no code in repo — remove positional cwd from synopsis).

**Verify**: `rg '^## CLI reference' README.md` matches; `rg '## Arguments' README.md` returns no match.

### Step 2: Expand `## Usage` with multiple examples

Provide at least three examples:

1. **Basic** — two commands, default iterations
2. **Repeated sampling** — `-n 100` (keep biome/oxlint theme)
3. **Custom cwd and output** — `-c ./my-project -o ./results/bench.log`

Add a callout explaining `vp exec` if it remains in examples:

```markdown
> Examples use `vp exec` — a project-local wrapper that runs tools in a
> consistent environment. Substitute your own commands (e.g. `npx biome lint`).
```

**Verify**: Usage section contains ≥3 distinct `compare` invocations in fenced blocks.

### Step 3: Add `## Output format` section

Move/rename example output here. Changes:

- Use a `text` or `log` fenced block label instead of `bash`
- Annotate one sample line:

```markdown
Each iteration appends one line per command. Lines follow the POSIX `time` format:

\`\`\`text
<command>  <user>s user <system>s system <cpu>% cpu <elapsed> total
\`\`\`

Example excerpt from a log file:

\`\`\`text
vp exec biome lint --fix  1.36s user 0.36s system 151% cpu 1.134 total
vp exec oxlint --fix  0.21s user 0.18s system 73% cpu 0.528 total
\`\`\`

Blank lines may separate iteration pairs depending on implementation.
```

Add one sentence on which field users typically compare (`total` wall time vs `%cpu`).

**Verify**: `rg '^## Output format' README.md` matches; example block language is not `bash`.

## Test plan

Manual review:

- [ ] A user can construct a valid command using only the CLI reference table
- [ ] Default log path tokens are all defined
- [ ] No undefined jargon (`vp exec` explained or removed)

## Done criteria

- [ ] `## CLI reference` replaces `## Arguments`
- [ ] Positional `cwd` ambiguity resolved (documented or removed)
- [ ] `## Output format` exists with annotated `time` line format
- [ ] ≥3 usage examples present
- [ ] Only `README.md` modified
- [ ] `plans/README.md` status row for 003 updated to DONE

## STOP conditions

Stop and report if:

- Implementation code exists and defines different flags or defaults than documented — align docs to code instead of this plan's assumptions.
- Default iteration count or output path template differs from plan — document actual behavior.

## Maintenance notes

- When CLI is implemented, add a `compare --help` output snapshot or test that docs match clap/argparse definitions.
- If slug algorithm for `<c1>`/`<c2>` is non-obvious, add one concrete example of generated filename.