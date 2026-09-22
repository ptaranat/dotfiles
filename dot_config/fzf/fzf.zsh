# fzf shell integration, sourced by unixorn/fzf-zsh-plugin. The plugin knows
# only ~/.fzf.zsh or $FZF_PATH/fzf.zsh, so .zshrc points FZF_PATH here to keep
# it under XDG_CONFIG_HOME.
#
# `fzf --zsh` emits the bindings and completions from the installed binary,
# replacing a pair of files sourced from a hardcoded brew prefix, so nothing
# goes stale when fzf moves. zsh-vi-mode claims ctrl-R and ctrl-T during init,
# which is what the zvm_after_init_commands hook in .zshrc re-sources for.
source <(fzf --zsh)
