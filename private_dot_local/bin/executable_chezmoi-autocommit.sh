#!/usr/bin/env bash
set -euo pipefail

OPENCODE_BIN="${OPENCODE_BIN:-$HOME/.local/bin/opencode}"
BRANCH="${CHEZMOI_AUTOCOMMIT_BRANCH:-main}"

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

# Ensure SSH agent socket is available for git push
if [ -z "${SSH_AUTH_SOCK:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/keyring/ssh" ]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/keyring/ssh"
fi

if ! SOURCE_DIR="$(chezmoi source-path 2>/dev/null)"; then
    log "ERROR: could not determine the chezmoi source directory."
    exit 1
fi

if [ ! -d "$SOURCE_DIR/.git" ]; then
    log "ERROR: $SOURCE_DIR is not a git repository."
    exit 1
fi

# Skip if another git operation is in progress
for marker in index.lock rebase-merge rebase-apply MERGE_HEAD; do
    if [ -e "$SOURCE_DIR/.git/$marker" ]; then
        log "WARNING: $SOURCE_DIR/.git/$marker exists, another git process may be active. Skipping run."
        exit 0
    fi
done

if [ ! -x "$OPENCODE_BIN" ]; then
    log "ERROR: opencode binary not found at $OPENCODE_BIN"
    exit 1
fi

# Fetch first so we know whether the remote moved. Being offline is not fatal.
REMOTE_AVAILABLE=true
if ! git -C "$SOURCE_DIR" fetch --prune origin "$BRANCH"; then
    REMOTE_AVAILABLE=false
    log "WARNING: could not fetch origin/$BRANCH; continuing with local changes only."
fi

# Capture live dotfile changes into the source state. Only files already
# managed by chezmoi are re-added; untracked files are never picked up.
if [ -n "$(chezmoi status)" ]; then
    log "Live configuration drift detected. Running chezmoi re-add..."
    chezmoi re-add
else
    log "No live configuration drift."
fi

# Commit with opencode so changes are grouped into conventional commits.
if [ -n "$(git -C "$SOURCE_DIR" status --porcelain)" ]; then
    log "Uncommitted dotfile changes detected. Running opencode auto-commit..."

    PROMPT="$(cat <<'EOF'
You are an automated git commit assistant for a chezmoi dotfiles repository. Commit the uncommitted changes into clean, logical chunks using Conventional Commits.

Follow these rules strictly:
1. Inspect the repository state with `git status` and `git diff` (including untracked files).
2. If there are no uncommitted changes (working tree clean), stop immediately without making any commits.
3. Group all modified and untracked changes into cohesive, logical chunks by configuration area/scope. Keep files that belong to the same configuration together, and never mix unrelated areas in one commit (for example: nvim, herdr, hypr, zsh, tmux, terminal emulators, systemd units, git/chezmoi, opencode).
4. For each chunk:
   - Stage only the relevant files using `git add <file1> <file2> ...`. Do NOT use `git add .` or `git add -A`.
   - Commit using Conventional Commits format: `<type>(<scope>): <concise description in imperative mood>`
     - Types: feat, fix, chore, refactor, docs, style, perf.
     - Scopes used in this repository: nvim, herdr, hypr, zsh, tmux, terminals, systemd, git, chezmoi, opencode.
     - The description must be lowercase, imperative, and without a trailing period.
     - Examples from this repository's history: `fix(hypr): remap workspace-to-monitor bindings`, `feat(nvim): track rust plugin overrides`, `chore(terminals): sync font sizes`.
5. Repeat until all changes are committed.
6. Verify with `git status` that the working tree is clean.
7. Do NOT run git push. Pushing to origin is handled automatically by the runner script.
8. Do NOT amend, squash, rebase, or reset any existing commit.
9. Do NOT commit anything that looks like a secret or credential (tokens, passwords, private keys, API keys). If such content appears in the diff, leave those files uncommitted and report them.
EOF
)"

    (
        cd "$SOURCE_DIR"
        "$OPENCODE_BIN" run --auto "$PROMPT"
    )

    if [ -n "$(git -C "$SOURCE_DIR" status --porcelain)" ]; then
        log "ERROR: opencode left uncommitted changes; refusing to sync with the remote."
        git -C "$SOURCE_DIR" status --porcelain >&2
        exit 1
    fi

    log "All dotfile changes committed."
else
    log "No uncommitted dotfile changes."
fi

# Rebase onto the remote when it has new commits. Using rebase (rather than a
# merge) keeps the history linear and replays local commits on top.
BEFORE_HEAD="$(git -C "$SOURCE_DIR" rev-parse HEAD)"

if [ "$REMOTE_AVAILABLE" = true ]; then
    if ! git -C "$SOURCE_DIR" rebase "origin/$BRANCH"; then
        git -C "$SOURCE_DIR" rebase --abort || true
        log "ERROR: rebase onto origin/$BRANCH failed (conflict). Aborted; resolve manually."
        exit 1
    fi
fi

AFTER_HEAD="$(git -C "$SOURCE_DIR" rev-parse HEAD)"

# Propagate remote changes to the live files.
if [ "$BEFORE_HEAD" != "$AFTER_HEAD" ]; then
    log "Remote changes integrated. Applying them to the live configuration..."
    chezmoi apply --force
    systemctl --user daemon-reload || log "WARNING: systemctl --user daemon-reload failed."
else
    log "No remote changes to apply."
fi

# Push local commits.
UNPUSHED="$(git -C "$SOURCE_DIR" rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)"
if [ "$UNPUSHED" -gt 0 ]; then
    if [ "$REMOTE_AVAILABLE" = false ]; then
        log "WARNING: $UNPUSHED commit(s) pending; cannot push while offline."
    else
        log "Pushing $UNPUSHED commit(s) to remote..."
        git -C "$SOURCE_DIR" push origin HEAD
        log "Successfully pushed to remote."
    fi
else
    log "No unpushed commits."
fi

log "chezmoi-autocommit run finished."
