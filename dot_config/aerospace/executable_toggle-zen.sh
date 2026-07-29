#!/usr/bin/env sh
# Toggle AeroSpace outer gaps between normal and "zen" (wallpaper-visible) sizes.
# AeroSpace has no runtime gaps command, so this rewrites the config;
# auto-reload-config picks it up, hence no reload-config call.
#
# Edits a git-tracked file, so the tree shows dirty while zen is active.

set -eu

CONFIG="${HOME}/.config/aerospace/aerospace.toml"

NORMAL_OUTER=6
ZEN_OUTER=120

[ -f "$CONFIG" ] || { echo "config not found: $CONFIG" >&2; exit 1; }

current=$(sed -n 's/^gaps\.outer\.top *= *\([0-9][0-9]*\).*/\1/p' "$CONFIG")
[ -n "$current" ] || { echo "could not read gaps.outer.top from $CONFIG" >&2; exit 1; }

if [ "$current" = "$ZEN_OUTER" ]; then
    target=$NORMAL_OUTER
else
    target=$ZEN_OUTER
fi

sed -i '' -E "s/^(gaps\.outer\.(left|bottom|top|right)[[:space:]]*=[[:space:]]*)[0-9]+/\1${target}/" "$CONFIG"

echo "outer gaps: ${current} -> ${target}"
