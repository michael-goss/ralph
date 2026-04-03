---
name: ralph-prd-to-issues
description: Break a PRD into independently-grabbable local task files using tracer-bullet vertical slices. Use when user wants to convert a PRD to issues, create implementation tickets, or break down a PRD into work items.
---

# PRD to Issues

Break a PRD into independently-grabbable task files using vertical slices (tracer bullets). Each issue is saved as a separate Markdown file in `.issues/` with YAML frontmatter for machine-readable metadata.

## Process

### 1. Locate the PRD

Ask the user for the PRD file path (e.g. `.ralph/.prds/feature-name.md`).

If the PRD is not already in your context window, read it from disk.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Break the PRD into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories from the PRD this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Write the issue files

Create `.ralph/.issues/` if it doesn't exist. Save each issue as a separate Markdown file with a zero-padded numeric prefix and a slugified title (e.g. `.ralph/.issues/001-setup-auth.md`, `.ralph/.issues/002-add-transport-form.md`).

Each file uses YAML frontmatter for machine-readable fields, followed by a Markdown body.

<issue-template>
---
type: AFK
status: todo
priority: 1
blocked_by: []
prd: .ralph/.prds/<prd-filename>.md
---

# <Title>

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Reference specific sections of the parent PRD rather than duplicating content.

## Acceptance criteria

- Criterion 1
- Criterion 2
- Criterion 3

## User stories addressed

Reference by number from the parent PRD:

- User story 3
- User story 7
</issue-template>

Frontmatter field notes:
- `type`: `AFK` or `HITL`
- `status`: always `todo` when created
- `priority`: integer, 1 = highest. Assign based on dependency order and importance.
- `blocked_by`: array of issue IDs (e.g. `["001", "002"]`), or empty array if no blockers
- `prd`: path to the parent PRD file

Do NOT create GitHub issues. Do NOT modify the parent PRD file.
