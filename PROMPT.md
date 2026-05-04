## Task

1. Read all files in `.ralph/.issues/`
2. Pick highest-priorty `todo` issue, prioritize in this order:
    1. Architectural decisions and core abstractions
    2. Integration points between modules
    3. Unknown unknowns and spike work
    4. Standard features and implementation
    5. Polish, cleanup, and quick wins
    - Fail fast on risky work. Save easy wins for later.
    - Skip issues with `type: HITL`
    - Skip issues whose `blocked_by` IDs are not yet `done`
3. Set the issue status to `in_progress`
4. Implement the issue
5. Run feedback loops before committing (typecheck, test, lint):
    1. TypeScript: pnpm --filter={package} typecheck (must pass with no errors)
    2. Tests: pnpm --filter={package} test:unit (must pass)
    3. Lint: pnpm --filter={package} lint (must pass)
    - Do NOT finish if any feedback loop fails. Fix issues first.
6. If green: commit, set status to `done`, append a log entry
7. If stuck: set status to `failed`, append a log entry with reason

## Rules

- Work on ONE issue per iteration
- Make a git commit per completed issue (without co-authored-by)
- Git state is prepared. Only `git add` / `git commit` are permitted for writes. Do not attempt branch, remote, reset, rebase, or `.git/` changes — the harness will block them.
- If no `todo` issues remain, output `<promise>COMPLETE</promise>`
- use /ralph-tdd skill

## AFK Mode

This loop runs unattended. No human will answer questions.

- **Never ask for confirmation or approval.** Do not ask "Shall I proceed?", "Does this look right?", or similar. When the /ralph-tdd skill presents a plan, immediately proceed with implementation.
- **The issue file + PRD are your spec.** All design decisions, acceptance criteria, and scope are already defined there. If the skill asks you to make choices, derive the answer from the issue and PRD.
- **If something is genuinely ambiguous** (not covered by the issue or PRD), make the simplest choice that satisfies the acceptance criteria, document your decision in the log entry, and move on.
- **Every iteration must produce either a commit or a `failed` status.** An iteration that only outputs a plan or asks a question is a wasted iteration.

## Mindset

This codebase will outlive you. Every shortcut you take becomes
someone else's burden. Every hack compounds into technical debt
that slows the whole team down.

You are not just writing code. You are shaping the future of this
project. The patterns you establish will be copied. The corners
you cut will be cut again.

Fight entropy. Leave the codebase better than you found it.
