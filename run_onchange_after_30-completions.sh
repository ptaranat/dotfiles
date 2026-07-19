#!/bin/sh
# Shell completions that no package manager installs for us.
#
# Most tools here need nothing: Homebrew drops official completions into
# $(brew --prefix)/share/zsh/site-functions, which is already on fpath, so bun,
# mise, chezmoi, atuin, uv and gh all work with no configuration. Do not
# hand-roll completions for anything installed by brew -- check that directory
# first.
#
# pnpm is the exception, because it comes from mise rather than brew and mise
# does not install shell completions. It can generate its own, so this writes
# that output once into the user site-functions directory rather than
# regenerating it on every shell start.

set -eu

DEST="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"
mkdir -p "$DEST"

# mise activates by manipulating PATH from a shell hook, so its tools are not
# reachable from the plain sh chezmoi runs scripts in. The shim directory is,
# and each shim re-execs mise with the right version.
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
