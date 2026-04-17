# Ralph

An autonomous AFK coding loop powered by Claude Code. Ralph picks up issues from a local queue, implements them, and commits results — all while you're away from keyboard.

Inspired by [Ralph Wiggum AFK coding](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum).

## Setup

Run Ralph from a **dedicated second clone** of your project. Two reasons:

1. The Docker sandbox syncs files bidirectionally with its workspace, so `pnpm install` inside the sandbox pollutes the checkout's `node_modules` with Linux binaries. A second clone isolates that pollution from your main checkout and lets you keep QAing in parallel.
2. The sandbox only mounts its working directory via virtiofs. A **git worktree** won't work because its `.git` is just a pointer file (`gitdir: ...`) referencing a gitdir outside the mount — commits made inside the sandbox land in a stub database and never reach your host. A full clone keeps the entire `.git` database inside the mount, so commits persist on disk.

Ralph works directly on the same feature branch (e.g. `MM-777`) — no separate `-ralph` branch needed. Your main checkout can fetch the latest commits for QA.

In your customer/target project:

```bash
# 1. Commit .ralph/ to .gitignore in your main checkout
echo ".ralph/" >> .gitignore
git add .gitignore && git commit -m "chore: gitignore .ralph/"
git push

# 2. Clone the repo a second time (path is your choice, sibling to your main checkout)
git clone <customer-repo-url> <ralph-clone-path>
cd <ralph-clone-path>

# 3. Check out the feature branch
git fetch origin
git checkout <feature>

# 4. Clone this repo into .ralph (inside the Ralph clone)
git clone <ralph-repo-url> .ralph

# 5. Create the Docker sandbox, trigger OAuth, install deps
.ralph/setup.sh
```

`setup.sh` creates a named Docker sandbox (`ralph`), installs Ralph's permission settings into the sandbox, starts Claude interactively so you can complete the OAuth flow against your Claude subscription, then installs `pnpm` and project dependencies inside the sandbox. It only needs to run once per clone.

### Permissions

Ralph ships a permission deny-list in `.ralph/.claude/settings.json` that blocks destructive git operations (`git init`, `git branch`, `git checkout`, `git reset`, `git worktree`, writes to `.git/`, …). The loop runs in a dedicated clone, so it only ever needs `git add` and `git commit` — anything else indicates the agent got confused and started reshaping the repo.

`setup.sh` copies this file into the sandbox at `/home/agent/.claude/settings.json` (user-level settings, loaded regardless of CWD). The file inside the sandbox is a **snapshot**, not a live reference — if you edit `.ralph/.claude/settings.json` later, re-sync with:

```bash
docker sandbox exec -i ralph bash -c 'cat > /home/agent/.claude/settings.json' < .ralph/.claude/settings.json
```

Deny rules are enforced even in `bypassPermissions` mode, so the loop cannot override them.

### Pulling Ralph's commits into your main checkout

Both clones work on the same branch (e.g. `MM-777`). After a Ralph run, push from the Ralph clone and fetch on your main checkout:

```bash
# In the Ralph clone
git push origin <feature>

# In the main checkout — just fast-forward, no rebase needed
git fetch origin
git pull
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

Once a feature is finished, wipe the working state before starting the next one:

```bash
.ralph/cleanup.sh
```

This removes `.ralph/.prds/` and `.ralph/.issues/`.

## Directory structure

From the customer project root:

```
customer-project/
  .ralph/                    # THIS REPO (gitignored from customer repo)
    setup.sh                 # one-time sandbox creation + OAuth
    cleanup.sh               # remove PRDs and issues after a feature
    interactive.sh           # interactive Claude session in sandbox
    ralph.sh                 # AFK loop launcher
    PROMPT.md                # loop prompt (customize per project)
    .claude/
      settings.json          # permission deny-list, copied into sandbox by setup.sh
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
- **Sandbox pollutes `node_modules`**: The Docker sandbox syncs files bidirectionally, so `pnpm install` inside the sandbox overwrites the host's `node_modules` with Linux binaries. This is why Ralph should run from a dedicated second clone (see Setup).
- **Worktrees don't work**: The sandbox only mounts its working directory via virtiofs. A git worktree's `.git` is a pointer file referencing a gitdir outside the mount, so commits made inside the sandbox go into a sandbox-local stub `.git` and never reach the host. Use a full clone instead.
- **No retry policy yet**: If an issue fails, it stays `failed`. No automatic retry or escalation.
- **No logging yet**: No per-issue activity log beyond git commits and status changes.
