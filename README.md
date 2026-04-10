# Ralph

An autonomous AFK coding loop powered by Claude Code. Ralph picks up issues from a local queue, implements them, and commits results — all while you're away from keyboard.

Inspired by [Ralph Wiggum AFK coding](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum).

## Setup

Because the Docker sandbox syncs files bidirectionally with its workspace, running `pnpm install` inside the sandbox pollutes your main checkout's `node_modules` with Linux binaries. To avoid this, run Ralph from a **dedicated git worktree** on its own branch, so the pollution is isolated from your main working copy and you can continue to QA in parallel.

Git refuses to check out the same branch in two worktrees at once, so Ralph gets a sibling branch. Ralph commits to `<feature>-ralph`; you periodically merge (or rebase) those commits into `<feature>` in your main worktree when you want to adopt them.

In your customer/target project:

```bash
# 1. Add .ralph to .gitignore (in the main checkout)
echo ".ralph/" >> .gitignore

# 2. Create a sibling branch for Ralph, forked from your feature branch
git branch <feature>-ralph <feature>

# 3. Create a dedicated worktree for Ralph on that sibling branch
#    (path is your choice)
git worktree add <worktree-path> <feature>-ralph
cd <worktree-path>

# 4. Clone this repo into .ralph (inside the worktree)
git clone <ralph-repo-url> .ralph

# 5. Create the Docker sandbox, trigger OAuth, install deps
.ralph/setup.sh
```

`setup.sh` creates a named Docker sandbox (`ralph`), starts Claude interactively so you can complete the OAuth flow against your Claude subscription, then installs `pnpm` and project dependencies inside the sandbox. It only needs to run once per worktree.

### Adopting Ralph's commits in your main worktree

While Ralph runs in the worktree, your main checkout stays on `<feature>` for QA. To pull in Ralph's work:

```bash
# In the main worktree
git merge <feature>-ralph      # or: git rebase <feature>-ralph
```

## Workflow

### Interactive planning (you at the keyboard)

Launch an interactive Claude session inside the sandbox with ralph skills loaded:

```bash
.ralph/interactive.sh
```

This gives you access to all ralph skills (`/ralph-grill-me`, `/ralph-write-a-prd`, `/ralph-prd-to-issues`, etc.).

**Step-by-step:**

1. **Discuss** — Use `/ralph-grill-me` to stress-test an idea or plan
2. **Write PRD** — Use `/ralph-write-a-prd` to create a PRD (saved to `.ralph/.prds/`)
3. **Create issues** — Use `/ralph-prd-to-issues` to break the PRD into vertical slices (saved to `.ralph/.issues/`)
4. **Review issues** — Check `.ralph/.issues/` directory, adjust priorities, mark any as `HITL`
5. **Customize PROMPT.md** — Add project-specific commands (test, lint, typecheck) to `.ralph/PROMPT.md`

### AFK loop (Ralph does the work)

```bash
.ralph/ralph.sh        # default 50 iterations
.ralph/ralph.sh 10     # or specify a count
```

Each iteration:
- Picks the highest-priority `todo` issue (skips `HITL` and `blocked`)
- Sets status to `in_progress`
- Implements it, runs feedback loops (test/lint/typecheck)
- Commits code to the **customer repo** on the current branch
- Sets status to `done` (or `failed` if stuck)
- Exits early when all issues are done

### After the loop

```bash
# Review what Ralph did
git log --oneline

# Push if satisfied
git push
```

PRDs, plans, and issues in `.ralph/` are ephemeral working state — no need to commit them. They only live as long as the feature is being worked on.

## Directory structure

From the customer project root:

```
customer-project/
  .ralph/                    # THIS REPO (gitignored from customer repo)
    setup.sh                 # one-time sandbox creation + OAuth
    interactive.sh           # interactive Claude session in sandbox
    ralph.sh                 # AFK loop launcher
    PROMPT.md                # loop prompt (customize per project)
    .claude/
      skills/                # skills loaded via --add-dir
        ralph-grill-me/
        ralph-write-a-prd/
        ralph-prd-to-issues/
        ralph-tdd/
    .prds/                   # PRDs created by /write-a-prd
    .issues/                 # issues created by /prd-to-issues
  .gitignore                 # contains ".ralph/"
  (rest of customer project)
```

## Issue format

```markdown
---
type: AFK
status: todo
priority: 1
blocked_by: []
prd: .ralph/.prds/feature-name.md
---

# Issue title

## What to build
Description of the vertical slice.

## Acceptance criteria
- Criterion 1
- Criterion 2
```

Frontmatter fields:
- **type**: `AFK` (loop works it) | `HITL` (loop skips it, needs human)
- **status**: `todo` | `in_progress` | `done` | `blocked` | `failed`
- **priority**: integer, 1 = highest
- **blocked_by**: array of issue IDs (e.g. `["001", "002"]`), or `[]`

You can add new issues to `.ralph/.issues/` while the loop is running.

## Skills

| Skill | Purpose |
|-------|---------|
| `/ralph-grill-me` | Stress-test a plan or design through relentless questioning |
| `/ralph-write-a-prd` | Create a PRD through user interview and codebase exploration |
| `/ralph-prd-to-issues` | Break a PRD into independently-grabbable issue files |
| `/ralph-tdd` | Test-driven development with red-green-refactor loop |

## Prerequisites

- Docker Desktop with [Docker sandbox support](https://docs.docker.com/ai/sandboxes/agents/claude-code/)
- A Claude subscription (Pro or Max) — OAuth is handled interactively during `setup.sh`, no API key required

## Known limitations

- **PROMPT.md is generic**: You must customize it per project with your test/lint/typecheck commands, conventions, and codebase context.
- **Sandbox pollutes `node_modules`**: The Docker sandbox syncs files bidirectionally, so `pnpm install` inside the sandbox overwrites the host's `node_modules` with Linux binaries. This is why Ralph should run from a dedicated git worktree (see Setup).
- **No retry policy yet**: If an issue fails, it stays `failed`. No automatic retry or escalation.
- **No logging yet**: No per-issue activity log beyond git commits and status changes.
