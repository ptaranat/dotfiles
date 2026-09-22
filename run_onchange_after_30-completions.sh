#!/bin/sh
# Completions no package manager installs. Homebrew drops official ones into
# $(brew --prefix)/share/zsh/site-functions, already on fpath, so most tools
# need nothing; check there before hand-rolling anything. pnpm is the exception
# because it comes from mise, which installs none. Generated once here rather
# than on every shell start.

set -eu

DEST="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"
mkdir -p "$DEST"

# mise activates via a shell hook, so its tools are unreachable from the plain
# sh chezmoi uses. The shims are, and each re-execs mise at the right version.
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

# The cache is keyed on fpath, so a new file needs the dump rebuilt. Removing
# it is enough; compinit rebuilds on the next shell.
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump" \
      "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump.zwc" 2>/dev/null || true
