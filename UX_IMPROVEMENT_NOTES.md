# Hypomnema UX Improvement Notes

This document records product-facing UX reasoning and implementation guidance.
It is a concise decision record, not private chain-of-thought.

## Product promise

Hypomnema should answer one question quickly:

> “What was I working on, and how do I continue it safely?”

The product is strongest when it behaves like a work-resumption layer across
coding harnesses. It should hide CLI differences and expose task intent.

## Current experience

1. The home screen offers resume/find context and prepare a brief.
2. The memory view lists recent task exchanges.
3. Search supports lexical and local vector lookup through the CLI path.
4. Result cards show status, harness readiness, workspace, and branch when available.
5. Enter resumes the native session.
6. `n` edits a generated handoff and starts a fresh harness session.
7. `c` copies the handoff.
8. `o` previews task context.
9. Launch confirmation shows action, harness, workspace, branch, and command.
10. Missing CLIs and missing workspaces produce actionable warnings.

## UX principles

### 1. Task language over harness language

Users think in terms of tasks, not session IDs or command flags. Use “Resume
task”, “Start fresh with context”, and “Copy handoff”. Keep source-specific
commands in confirmation or diagnostic views only.

### 2. Show confidence before action

Before launching, show the harness, readiness, workspace, branch, and action.
The user should know where the next process will start.

### 3. Preserve user control

Search, filters, editable handoffs, cancellation, and clipboard export should
all be available without destructive side effects.

### 4. Keep the default path short

The common path should be: open Hypomnema, select the latest task, press Enter,
confirm, and continue. Advanced controls should not dominate the screen.

### 5. Fail into recovery

An unavailable CLI, stale session, or missing folder should lead to a useful
alternative: copy the handoff, start fresh, choose another harness, or remain
in the current folder.

## Highest-value improvements

### A. Last active task card

Keep the latest active task visually prominent. Include project, status, title,
last activity, workspace, and next known outcome. Enter should select it by
default.

Acceptance criteria:

- A user can resume the latest task without searching.
- The card does not hide whether the task is blocked or completed.
- The card remains useful when the remembered workspace is missing.

### B. Editable handoff

The generated handoff should be a starting point, not an immutable summary.
Opening it in `$VISUAL` or `$EDITOR` keeps the implementation dependency-free.

Acceptance criteria:

- The generated text includes task, status, last request, context, outcome,
  and a safety instruction.
- Empty edits cancel safely.
- The edited text is exactly what the fresh harness receives.
- The final launch confirmation occurs after editing.

### C. Launch confirmation

The confirmation screen is a safety boundary. It should make the final action
legible before a process replaces Hypomnema.

Acceptance criteria:

- Resume shows the native command and session identifier.
- Fresh launch shows the harness and a redacted “handoff prompt” marker.
- Workspace and branch are visible.
- Enter launches and Escape cancels without changing state.

### D. Harness fallback

The product should not strand the user when the original harness is absent.
Offer another installed harness or a copy-only path.

Suggested flow:

1. Detect the unavailable native CLI.
2. Show installed alternatives.
3. Let the user choose one.
4. Adapt the handoff to a generic initial prompt.
5. Preserve the original source as provenance.

### E. Session health

A remembered session can be valid, stale, completed, blocked, or unavailable.
Expose this as a small status label rather than making users infer it from a
failed launch.

Suggested labels:

- Active: recent activity and a usable workspace.
- Stale: no recent activity but still resumable.
- Blocked: the recorded outcome contains a dependency or blocker.
- Completed: the recorded outcome indicates completion.
- Unavailable: missing CLI, missing workspace, or unsupported source.

### F. Worktree awareness

A project folder is not enough for coding work. Branch and worktree identity
reduce accidental edits in the wrong checkout.

Suggested metadata:

- Repository root.
- Branch.
- Worktree path.
- Dirty-file count.
- Last observed commit.

Keep this information in the confirmation view and selected-card details, not
in every result row.

### G. Task lifecycle actions

Users need a way to correct memory state. Add lightweight actions:

- Mark open.
- Mark blocked.
- Mark completed.
- Archive.

These should update local metadata without rewriting source conversation logs.

### H. Better handoff editing

The editor should eventually offer a small template or generated sections:

- Goal.
- Current state.
- What changed.
- Open questions.
- Next action.
- Relevant files.

Do not force all sections. Empty sections should be omitted from the final
prompt.

### I. Search affordances

Search should be discoverable and forgiving:

- `/` focuses search.
- Recent searches appear after an empty result.
- Search examples appear before the first query.
- A visible filter shows All/Open/Blocked/Completed.
- Vector search remains explicitly local and optional.

### J. Privacy and redaction

Copied handoffs can leave the local machine. Add conservative redaction for
API keys, bearer tokens, passwords, private key blocks, and obvious secrets.
Show “some content redacted” when redaction occurs.

## Harness-specific guidance

### Cursor

- Confirm the `agent --resume SESSION` command.
- Preserve the repository folder.
- Fresh mode should receive a plain initial prompt.

### Claude Code

- Confirm `claude --resume SESSION`.
- Fresh mode can use the edited handoff as the initial prompt.
- Make the distinction between Claude Code and Claude Desktop explicit.

### Codex

- Confirm `codex resume SESSION`.
- Fresh mode should remain a normal task prompt.
- Keep local workspace context visible.

### Copilot

- Confirm `copilot --resume SESSION` when available.
- Fall back to copy-only when the CLI is unavailable.
- Preserve the original Copilot source label in the handoff.

## Information hierarchy

The result card should prioritize:

1. Task title.
2. Status.
3. Project and time.
4. Harness readiness.
5. Match reason or excerpt.

The details area should prioritize:

1. Last request.
2. Outcome.
3. Workspace and branch.
4. Available actions.

## Keyboard model

Keep the current compact model:

- Enter: resume task.
- `n`: edit handoff and start fresh.
- `c`: copy handoff.
- `o`: preview context.
- `/`: search.
- `f`: cycle status filter.
- `?`: show help.
- Escape: go back or cancel.

Do not add more shortcuts until the help view can explain them clearly.

## Empty and error states

### No indexed memories

Explain that a scan or sync is needed and show the exact next command.

### No search results

Suggest a shorter phrase, another project scope, a status filter reset, or
recent searches.

### Missing CLI

Show the unavailable harness, installed alternatives, and copy handoff.

### Missing workspace

Show the remembered path, the current path, and a warning before launch.

### Resume failure

Keep the task selected and offer retry, fresh session, or copy handoff.

## Metrics worth tracking locally

Avoid external analytics by default. Local counters can answer whether UX is
working:

- Time from opening Hypomnema to launch.
- Resume versus fresh-session choice rate.
- Copy-only rate.
- Cancelled confirmation rate.
- Missing-CLI recovery rate.
- Search-to-resume conversion.
- Empty-result frequency.

The goal is not surveillance; it is identifying friction in a local tool.

## Recommended implementation order

1. Validate the current editable-handoff and confirmation flow.
2. Add installed-harness fallback.
3. Add worktree and dirty-state information.
4. Add session health and lifecycle metadata.
5. Add conservative secret redaction.
6. Add local friction counters only if the first five changes still leave
   uncertainty.

## Deliberate non-goals

- Cloud synchronization.
- Team collaboration.
- A web dashboard.
- A second database solely for UX metadata.
- Automatic launching without confirmation.
- Replacing each harness’s native session model.

These add operational and safety complexity before the local resume loop is
fully validated.
