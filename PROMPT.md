# Ralph Loop Prompt

TODO: Customize this prompt for your project.

## Task

1. Read all files in `.ralph/.issues/`
2. Pick the highest-priority `todo` issue (lowest priority number)
   - Skip issues with `type: HITL`
   - Skip issues whose `blocked_by` IDs are not yet `done`
3. Set the issue status to `in_progress`
4. Implement the issue
5. Run feedback loops before committing (typecheck, test, lint)
6. If green: commit, set status to `done`, append a log entry
7. If stuck: set status to `failed`, append a log entry with reason

## Rules

- Work on ONE issue per iteration
- Make a git commit per completed issue
- If no `todo` issues remain, output `<promise>COMPLETE</promise>`
