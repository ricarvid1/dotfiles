#!/usr/bin/env bash
set -euo pipefail

app="sync"
urgency="normal"
timeout=""

usage() {
    echo "usage: notify-desktop.sh [--app NAME] [-u low|normal|critical] [-t MS] TITLE [BODY]" >&2
}

while (($# > 0)); do
    case "$1" in
    --app)
        (($# >= 2)) || { echo "notify-desktop: missing value for --app" >&2; exit 2; }
        app="$2"
        shift 2
        ;;
    -u | --urgency)
        (($# >= 2)) || { echo "notify-desktop: missing value for $1" >&2; exit 2; }
        urgency="$2"
        shift 2
        ;;
    -t | --expire-time)
        (($# >= 2)) || { echo "notify-desktop: missing value for $1" >&2; exit 2; }
        timeout="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    -*)
        echo "notify-desktop: unknown option: $1" >&2
        exit 2
        ;;
    *)
        break
        ;;
    esac
done

title="${1-}"
body="${2-}"

if [ -z "$title" ]; then
    usage
    exit 2
fi

# Prefer Omarchy's notification sender so toasts match the shell's styling.
# Fall back to libnotify on machines without it. Never fail the caller: a
# missing notification daemon must not break a sync job.
if [ -x /usr/share/omarchy/bin/omarchy-notification-send ]; then
    args=(--app-name "$app" -u "$urgency")
    [ -n "$timeout" ] && args+=(-t "$timeout")
    /usr/share/omarchy/bin/omarchy-notification-send "${args[@]}" "$title" "$body" >/dev/null 2>&1 || true
elif command -v notify-send >/dev/null 2>&1; then
    args=(-a "$app" -u "$urgency")
    [ -n "$timeout" ] && args+=(-t "$timeout")
    notify-send "${args[@]}" "$title" "$body" >/dev/null 2>&1 || true
else
    echo "notify-desktop: no notification tool found" >&2
fi

exit 0
