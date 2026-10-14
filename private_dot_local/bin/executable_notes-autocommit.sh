#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${VAULT_DIR:-$HOME/vaults/luceda}"
OPENCODE_BIN="${OPENCODE_BIN:-$HOME/.opencode/bin/opencode}"

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Ensure SSH agent socket is available for git push
if [ -z "${SSH_AUTH_SOCK:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/keyring/ssh" ]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/keyring/ssh"
fi

if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $REPO_DIR is not a git repository." >&2
    exit 1
fi

if [ ! -x "$OPENCODE_BIN" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: opencode binary not found at $OPENCODE_BIN" >&2
    exit 1
fi

# Check for index lock
if [ -f "$REPO_DIR/.git/index.lock" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $REPO_DIR/.git/index.lock exists, another git process may be active. Skipping run." >&2
    exit 0
fi

HAS_UNCOMMITTED=""
if [ -n "$(git -C "$REPO_DIR" status --porcelain)" ]; then
    HAS_UNCOMMITTED="true"
fi

# Function to check if local commits are ahead of upstream
count_unpushed() {
    git -C "$REPO_DIR" rev-list --count @{u}..HEAD 2>/dev/null || echo "0"
}

# Short-circuit if there are neither uncommitted changes nor unpushed commits
if [ -z "$HAS_UNCOMMITTED" ] && [ "$(count_unpushed)" -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Working tree clean and up to date with remote. Nothing to commit or push."
    exit 0
fi

# Commit uncommitted changes with opencode if any exist
if [ -n "$HAS_UNCOMMITTED" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Uncommitted changes detected in $REPO_DIR. Running opencode auto-commit..."

    PROMPT='You are an automated git commit assistant. Your job is to inspect the current repository and commit uncommitted changes into clean, logical chunks using Conventional Commits.

Follow these rules strictly:
1. Check the repository state using `git status` and `git diff` (including untracked files).
2. If there are no uncommitted changes (working tree clean), stop immediately without making any commits.
3. Group all modified and untracked changes into cohesive, logical chunks:
   - Associate attachment files (e.g., images in attachments/) with the notes that reference them.
   - Separate unrelated notes and topics into distinct commits (e.g., monthly notes, todo lists, project-specific notes).
   - Do NOT commit everything in a single batch unless all changes genuinely belong to the same topic.
4. For each chunk:
   - Stage only the relevant files using `git add <file1> <file2> ...`. Do NOT use `git add .` or `git add -A`.
   - Commit using Conventional Commits format matching this repository'\''s established style:
     `<type>(<scope>): <concise description in imperative mood>`
     - Examples based on repo history:
       - docs(banda): add CLI design specification note
       - docs(monthly): update October 2026 log
       - docs(todo): update task list
     - Use `docs` as the primary type for vault notes. Use scopes reflecting the topic/feature (e.g., `banda`, `monthly`, `smatrix`, `todo`).
     - Message should be lowercase, imperative, and without a trailing period.
5. Repeat until all changes are committed.
6. Verify with `git status` that the working tree is clean.
7. Do NOT run git push (pushing to origin will be handled automatically by the runner script).
8. Do NOT amend, squash, or rebase any existing commits.'

    (
        cd "$REPO_DIR"
        "$OPENCODE_BIN" run \
            --auto \
            "$PROMPT"
    )
fi

# Push commits to remote if branch is ahead
UNPUSHED="$(count_unpushed)"
if [ "$UNPUSHED" -gt 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Pushing $UNPUSHED commit(s) to remote..."
    git -C "$REPO_DIR" push origin HEAD
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully pushed to remote."
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] No unpushed commits."
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] notes-autocommit run finished."
