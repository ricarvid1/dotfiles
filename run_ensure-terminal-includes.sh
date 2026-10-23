#!/usr/bin/env bash
# Keep the Omarchy-owned terminal configs loading the chezmoi-managed personal.*
# files.
#
# Those four configs cannot be managed by chezmoi: `omarchy font set` and
# `omarchy display text size` rewrite the font family/size in them, so tracking
# them turned every monitor/text-size change into a commit. Personal settings
# therefore live in personal.toml / personal.ini / personal.conf, and this
# script guarantees the include line that loads them exists. It is idempotent,
# so it is safe on every apply, on a second machine, and after an Omarchy
# upgrade rewrites a config.

set -u

add_ghostty_include() {
    local f="$HOME/.config/ghostty/config"
    [[ -f $f ]] || return 0
    grep -qF 'ghostty/personal.conf' "$f" && return 0
    printf '\n# Personal settings, tracked by chezmoi\nconfig-file = ?"~/.config/ghostty/personal.conf"\n' >>"$f"
}

add_foot_include() {
    local f="$HOME/.config/foot/foot.ini"
    [[ -f $f ]] || return 0
    grep -qF 'foot/personal.ini' "$f" && return 0
    if grep -qE '^\[main\][[:space:]]*$' "$f"; then
        awk '!done && /^\[main\][[:space:]]*$/ {
                 print
                 print "include=~/.config/foot/personal.ini"
                 done = 1
                 next
             }
             { print }' "$f" >"$f.tmp" && mv "$f.tmp" "$f"
    else
        printf '[main]\ninclude=~/.config/foot/personal.ini\n' | cat - "$f" >"$f.tmp" && mv "$f.tmp" "$f"
    fi
}

add_alacritty_include() {
    local f="$HOME/.config/alacritty/alacritty.toml"
    [[ -f $f ]] || return 0
    grep -qF 'alacritty/personal.toml' "$f" && return 0
    python3 - "$f" <<'PY' || return 0
import re
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    text = fh.read()

entry = '    "~/.config/alacritty/personal.toml",\n'
match = re.search(r"(?m)^import\s*=\s*\[", text)
if match:
    close = text.find("]", match.end())
    if close == -1:
        sys.exit(0)
    text = text[:close] + entry + text[close:]
else:
    text = "import = [\n" + entry + "]\n\n" + text

with open(path, "w", encoding="utf-8") as fh:
    fh.write(text)
PY
}

add_ghostty_include
add_foot_include
add_alacritty_include
