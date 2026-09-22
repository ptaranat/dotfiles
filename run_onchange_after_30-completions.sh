#!/bin/sh
# Homebrew covers most completions; this is for mise's pnpm.

set -eu

DEST="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"
mkdir -p "$DEST"

# mise tools are only on PATH via a shell hook; use the shims.
PNPM=""
if command -v pnpm >/dev/null 2>&1; then
	PNPM="pnpm"
elif [ -x "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims/pnpm" ]; then
	PNPM="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims/pnpm"
fi

if [ -n "$PNPM" ]; then
	if "$PNPM" completion zsh >"$DEST/_pnpm.tmp" 2>/dev/null && [ -s "$DEST/_pnpm.tmp" ]; then
		mv "$DEST/_pnpm.tmp" "$DEST/_pnpm"
		echo "==> wrote pnpm completions"
	else
		rm -f "$DEST/_pnpm.tmp"
	fi
fi

rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump" \
      "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump.zwc" 2>/dev/null || true
