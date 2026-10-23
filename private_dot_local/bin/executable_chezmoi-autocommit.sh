#!/usr/bin/env bash
set -euo pipefail

OPENCODE_BIN="${OPENCODE_BIN:-$HOME/.local/bin/opencode}"
OPENCODE_MODEL="${OPENCODE_MODEL:-google/gemini-3.8-flash}"
BRANCH="${CHEZMOI_AUTOCOMMIT_BRANCH:-main}"

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

NOTIFY_BIN="$HOME/.local/bin/notify-desktop.sh"
APP_NAME="chezmoi"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

notify() {
    local urgency="$1" title="$2" body="$3"
    [ -x "$NOTIFY_BIN" ] || return 0
    "$NOTIFY_BIN" --app "$APP_NAME" -u "$urgency" "$title" "$body" >/dev/null 2>&1 || true
}

notify_failure() {
    notify critical "Dotfiles sync failed" "$1"
}

# Ensure SSH agent socket is available for git push
if [ -z "${SSH_AUTH_SOCK:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/keyring/ssh" ]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/keyring/ssh"
fi

if ! SOURCE_DIR="$(chezmoi source-path 2>/dev/null)"; then
    log "ERROR: could not determine the chezmoi source directory."
    notify_failure "Could not determine the chezmoi source directory"
    exit 1
fi

if [ ! -d "$SOURCE_DIR/.git" ]; then
    log "ERROR: $SOURCE_DIR is not a git repository."
    notify_failure "$SOURCE_DIR is not a git repository"
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
    notify_failure "opencode binary not found at $OPENCODE_BIN"
    exit 1
fi

# Guard state left behind by an interrupted run. `chezmoi re-add` projects the
# live files into the source tree; if a run dies between that capture and the
# commit, the tree holds changes nobody chose to commit, and the next run would
# commit and push them with an auto-written message. The marker makes that state
# detectable, and a capture is always reproducible from the live files, so it is
# safe to discard.
CAPTURE_MARKER="$SOURCE_DIR/.git/autocommit-capture"

rollback_capture() {
    local stat
    stat="$(git -C "$SOURCE_DIR" diff --stat HEAD || true)"
    if [ -n "$stat" ]; then
        log "Reverting captured changes (live files are untouched; the next run re-captures them):"
        printf '%s\n' "$stat" >&2
    fi
    if ! git -C "$SOURCE_DIR" restore --source=HEAD --staged --worktree .; then
        log "ERROR: could not revert captured changes automatically."
    fi
    rm -f "$CAPTURE_MARKER"
}

if [ -e "$CAPTURE_MARKER" ]; then
    log "WARNING: a previous run was interrupted before committing. Restoring the source tree."
    rollback_capture
fi

# Never let re-add overwrite edits made directly in the source tree: live state
# always wins in `chezmoi re-add`, so mixing the two silently loses work. The
# rollback below is only safe because the tree is known to be clean here.
if [ -n "$(git -C "$SOURCE_DIR" status --porcelain --untracked-files=no)" ]; then
    log "ERROR: $SOURCE_DIR has uncommitted edits. Commit or stash them first (re-add would overwrite them)."
    git -C "$SOURCE_DIR" status --porcelain --untracked-files=no >&2
    notify_failure "Uncommitted source edits; re-add would overwrite them"
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
# `chezmoi status` also lists pending run_ scripts as "R"; those always show up
# and are not configuration drift, so they are filtered out here.
DRIFT="$(chezmoi status | grep -vE '^ *R' || true)"
if [ -n "$DRIFT" ]; then
    log "Live configuration drift detected. Running chezmoi re-add..."
    : >"$CAPTURE_MARKER"
    if ! chezmoi re-add; then
        log "ERROR: chezmoi re-add failed."
        rollback_capture
        notify_failure "chezmoi re-add failed; source tree restored"
        exit 1
    fi
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

    if ! (
        cd "$SOURCE_DIR"
        "$OPENCODE_BIN" run --auto --model "$OPENCODE_MODEL" "$PROMPT"
    ); then
        log "ERROR: opencode auto-commit failed."
        rollback_capture
        notify_failure "opencode auto-commit failed; captured changes reverted, will retry next run"
        exit 1
    fi

    if [ -n "$(git -C "$SOURCE_DIR" status --porcelain)" ]; then
        log "ERROR: opencode left uncommitted changes; refusing to sync with the remote."
        git -C "$SOURCE_DIR" status --porcelain >&2
        rollback_capture
        notify_failure "opencode left changes uncommitted; captured changes reverted"
        exit 1
    fi

    log "All dotfile changes committed."
else
    log "No uncommitted dotfile changes."
fi

rm -f "$CAPTURE_MARKER"

# Rebase onto the remote when it has new commits. Using rebase (rather than a
# merge) keeps the history linear and replays local commits on top.
BEFORE_HEAD="$(git -C "$SOURCE_DIR" rev-parse HEAD)"

if [ "$REMOTE_AVAILABLE" = true ]; then
    if ! git -C "$SOURCE_DIR" rebase "origin/$BRANCH"; then
        git -C "$SOURCE_DIR" rebase --abort || true
        log "ERROR: rebase onto origin/$BRANCH failed (conflict). Aborted; resolve manually."
        notify_failure "Rebase onto origin/$BRANCH conflicted; resolve manually"
        exit 1
    fi
fi

AFTER_HEAD="$(git -C "$SOURCE_DIR" rev-parse HEAD)"

# Propagate remote changes to the live files.
if [ "$BEFORE_HEAD" != "$AFTER_HEAD" ]; then
    log "Remote changes integrated. Applying them to the live configuration..."
    if ! chezmoi apply --force; then
        log "ERROR: chezmoi apply failed after integrating remote changes."
        notify_failure "Applying remote changes to live files failed"
        exit 1
    fi
    systemctl --user daemon-reload || log "WARNING: systemctl --user daemon-reload failed."
else
    log "No remote changes to apply."
fi

# Push local commits.
UNPUSHED="$(git -C "$SOURCE_DIR" rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)"
if [ "$UNPUSHED" -gt 0 ]; then
    if [ "$REMOTE_AVAILABLE" = false ]; then
        log "WARNING: $UNPUSHED commit(s) pending; cannot push while offline."
        notify_failure "Offline: $UNPUSHED commit(s) pending; will push on the next run"
    else
        log "Pushing $UNPUSHED commit(s) to remote..."
        if ! git -C "$SOURCE_DIR" push origin HEAD; then
            log "ERROR: push to origin/$BRANCH failed."
            notify_failure "Push to origin/$BRANCH failed"
            exit 1
        fi
        log "Successfully pushed to remote."
        notify normal "Dotfiles synced" "$UNPUSHED commit(s) pushed to origin/$BRANCH"
    fi
else
    log "No unpushed commits."
fi

log "chezmoi-autocommit run finished."
