# fzf shell integration.
#
# Sourced by unixorn/fzf-zsh-plugin. The plugin has no XDG support of its own,
# only ~/.fzf.zsh or $FZF_PATH/fzf.zsh, so .zshrc points FZF_PATH here to land
# it under XDG_CONFIG_HOME. The lone `unset xdg_path` left in the plugin refers
# to a variable it never sets: leftover from XDG handling that was removed.
#
# `fzf --zsh` replaces the old pair of completion.zsh and key-bindings.zsh
# sourced from a hardcoded /opt/homebrew/opt/fzf prefix. It emits both from the
# installed binary, so nothing here goes stale when fzf is upgraded or moves.
# The file this replaces also prepended that prefix to $PATH, which was dead for
# as long as fzf was not actually installed through brew.
#
# Key bindings used to be commented out, and the plugin binds none of its own,
# so ctrl-R and ctrl-T did nothing at all. They work now. zsh-vi-mode claims
# those keys during its init, which is what the zvm_after_init_commands hook in
# .zshrc is for: it re-sources the plugin, and so this file, after zvm has
# finished rebinding.
source <(fzf --zsh)
