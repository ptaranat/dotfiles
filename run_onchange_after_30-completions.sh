#!/bin/sh
# Shell completions no package manager installs for us. Brew-installed tools
# need nothing: their completions land in $(brew --prefix)/share/zsh/site-functions,
# already on fpath. Check there before hand-rolling anything. pnpm is the
# exception, coming from mise, which installs no completions.

set -eu

DEST="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"
mkdir -p "$DEST"

# mise activates via a shell hook, so its tools are not on PATH in the plain sh
# chezmoi uses. The shim directory is, and each shim re-execs mise.
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

# The completion cache is keyed on fpath contents, so a newly added file is not
# picked up until the dump is rebuilt. Removing it is enough; compinit rebuilds
# on the next shell.
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump" \
      "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump.zwc" 2>/dev/null || true
